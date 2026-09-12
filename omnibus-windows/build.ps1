<#
.SYNOPSIS
  Build, smoke-test and optionally push the cincproject/omnibus-windows image.

.DESCRIPTION
  Runs on the Windows Docker host itself. There is no Docker-in-Docker on
  Windows, so the GitLab jobs for this image use the host's PowerShell shell
  runner rather than the docker:dind image the Linux images build with.

  A normal build produces three tags: floating <base> and latest, and an
  immutable <base>-<yyyyMMdd-HHmm>. Product pipelines pin the dated one
  (BUILDER_IMAGE_TAG): it is part of their omnibus git-cache key, which is
  what keeps a new toolchain from being served objects built by the old one.

  -Scratch builds under a single throwaway tag and removes it after the smoke
  tests. MR pipelines use it: the product runner on this host pulls with
  if-not-present, so a build that reused the real tags would shadow the
  published image for every product job on the host.

.EXAMPLE
  .\build.ps1                 # build + smoke tests
  .\build.ps1 -Scratch        # MR pipeline: throwaway tag, removed afterwards
  .\build.ps1 -Push -NoCache  # publish: full rebuild, push all tags
  .\build.ps1 -Base ltsc2025 -NoLatest   # publish a second base without moving latest
#>
[CmdletBinding()]
param(
  [string]$Repository = 'cincproject/omnibus-windows',
  # Windows Server base generation. ltsc2022 runs on both 2022 and 2025 hosts.
  [string]$Base = 'ltsc2022',
  [string]$DateTag = (Get-Date -Format 'yyyyMMdd-HHmm'),
  [switch]$Push,
  # Full rebuild. Publishing uses it so a new dated tag never carries pacman
  # layers cached from an earlier build.
  [switch]$NoCache,
  # Skip the latest tag, for building a base that should not become the default.
  [switch]$NoLatest,
  # Throwaway tag, removed after the smoke tests (MR pipelines).
  [switch]$Scratch
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if ($Push -and $Scratch) { throw '-Push and -Scratch are mutually exclusive' }

if ($Scratch) {
  $suffix = if ($env:CI_MERGE_REQUEST_IID) { 'mr' + $env:CI_MERGE_REQUEST_IID } else { 'local' }
  $tags = @("${Repository}:scratch-${suffix}")
} else {
  $tags = @("${Repository}:${Base}", "${Repository}:${Base}-${DateTag}")
  if (-not $NoLatest) { $tags += "${Repository}:latest" }
}

# Fail before the hour-long build, not after it, when the publish credentials
# are not there. Outside CI a manual `docker login` on the host is accepted.
$login = $false
if ($Push) {
  if ($env:DOCKER_USERNAME -and $env:DOCKER_TOKEN) {
    $login = $true
  } elseif ($env:CI) {
    throw 'DOCKER_USERNAME and DOCKER_TOKEN must be set to push from CI'
  } else {
    Write-Warning 'DOCKER_USERNAME/DOCKER_TOKEN not set; relying on an existing docker login'
  }
}

$dockerArgs = @('build', '--pull', '--isolation', 'process', '--build-arg', "BASE=${Base}")
if ($NoCache) { $dockerArgs += '--no-cache' }
foreach ($t in $tags) { $dockerArgs += @('--tag', $t) }
$dockerArgs += '.'

Write-Host "==> docker $($dockerArgs -join ' ')"
& docker @dockerArgs
if ($LASTEXITCODE) { throw "docker build failed with exit code $LASTEXITCODE" }

try {
  # Smoke tests in fresh containers from the finished image. The loader sets
  # $ErrorActionPreference = 'Stop' itself and throws on a missing or broken
  # tool; the fork test is the go/no-go check for MSYS2 under process
  # isolation and exits non-zero on any failed fork or compile.
  Write-Host '==> smoke test: load-omnibus-toolchain.ps1'
  & docker run --rm --isolation process $tags[0] powershell -NoProfile -File C:\omnibus\load-omnibus-toolchain.ps1
  if ($LASTEXITCODE) { throw "smoke test (loader) failed with exit code $LASTEXITCODE" }

  Write-Host '==> smoke test: fork-stress.sh'
  $testMount = (Join-Path $PSScriptRoot 'test') + ':C:\tests:ro'
  & docker run --rm --isolation process -v $testMount $tags[0] C:\msys64\usr\bin\bash.exe -l C:/tests/fork-stress.sh
  if ($LASTEXITCODE) { throw "smoke test (fork stress) failed with exit code $LASTEXITCODE" }

  if ($Push) {
    if ($login) {
      Write-Host "==> docker login as $env:DOCKER_USERNAME"
      $env:DOCKER_TOKEN | & docker login --username $env:DOCKER_USERNAME --password-stdin
      if ($LASTEXITCODE) { throw "docker login failed with exit code $LASTEXITCODE" }
    }
    foreach ($t in $tags) {
      Write-Host "==> docker push $t"
      & docker push $t
      if ($LASTEXITCODE) { throw "docker push $t failed with exit code $LASTEXITCODE" }
    }
  }
} finally {
  if ($login) {
    # Never leave the publish credential in the runner account's config.json.
    & docker logout | Out-Host
  }
  if ($Scratch) {
    Write-Host "==> docker rmi $($tags -join ' ')"
    & docker rmi $tags | Out-Host
  }
}

Write-Host ''
if ($Scratch) {
  Write-Host "Scratch build passed (tag removed): $($tags -join ', ')"
} else {
  Write-Host "Built: $($tags -join ', ')"
  Write-Host "BUILDER_IMAGE_TAG=${Base}-${DateTag}"
}
