<#
.SYNOPSIS
  Run N concurrent OpenSSL builds in separate containers and report.

.DESCRIPTION
  Single-job success is already demonstrated; this is the materially different
  test. Memory pressure and address-space contention across containers are
  what trigger MSYS2 rebase/fork failures, so run it before raising
  `concurrent` on the runner. Run on the Docker host:

    .\concurrency.ps1                      # 4 x openssl-build.sh
    .\concurrency.ps1 -Jobs 1              # single-container baseline
    .\concurrency.ps1 -Jobs 2 -Script fork-stress.sh

  The scripts are not in the image; this directory is bind-mounted into each
  container at C:\tests, and -Script names a file in it.

  Prints per-container exit code, wall clock, the OPENSSL_BUILD_SECONDS line,
  and greps every log for the known MSYS2 failure signatures. Logs go to
  %TEMP%\cinc-omnibus-windows-stress, outside the image build context.
#>
[CmdletBinding()]
param(
  [string]$Image = 'cincproject/omnibus-windows:ltsc2022',
  [int]$Jobs = 4,
  [string]$Script = 'openssl-build.sh',
  # Per-container limits; leave empty for none. 4 x (4 cpu, 7g) fits the
  # 16 vCPU / 32 GB sizing from the design. --cpus is a rate cap: nproc in
  # the container still reports the host count, so the same number is passed
  # as MAKE_JOBS to keep make from oversubscribing.
  [string]$Cpus = '4',
  [string]$Memory = '7g'
)

# Native commands write progress to stderr; keep that from being turned into
# terminating errors by Stop. Every docker call checks $LASTEXITCODE instead.
$ErrorActionPreference = 'Continue'
$logDir = Join-Path $env:TEMP 'cinc-omnibus-windows-stress'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$signatures = @(
  'fork: retry: Resource temporarily unavailable',
  'child_copy:',
  'dofork: forked process died unexpectedly',
  'ld returned 116',
  'Too many DLLs for available address space'
)

$names = 1..$Jobs | ForEach-Object { "cinc-stress-$_" }
foreach ($n in $names) {
  if (docker ps -aq --filter "name=^$n$") { docker rm -f $n | Out-Null }
}

$runArgs = @('run', '-d', '--isolation', 'process', '-v', ($PSScriptRoot + ':C:\tests:ro'))
if ($Cpus) { $runArgs += @('--cpus', $Cpus, '-e', "MAKE_JOBS=$Cpus") }
if ($Memory) { $runArgs += @('--memory', $Memory) }

$wallStart = Get-Date
foreach ($n in $names) {
  & docker @runArgs --name $n $Image C:\msys64\usr\bin\bash.exe -l "C:/tests/$Script" | Out-Null
  if ($LASTEXITCODE) { throw "docker run $n failed with exit code $LASTEXITCODE" }
  Write-Host "started $n"
}

$results = foreach ($n in $names) {
  $waited = docker wait $n
  if ($LASTEXITCODE -or -not $waited) { throw "docker wait $n failed (exit $LASTEXITCODE, output '$waited')" }
  $code = [int]$waited
  $log = Join-Path $logDir "$n.log"
  docker logs $n 2>&1 | Out-File -Encoding utf8 $log
  $insp = docker inspect $n | ConvertFrom-Json
  if ($LASTEXITCODE -or -not $insp) { throw "docker inspect $n failed" }
  $started = [datetime]$insp.State.StartedAt
  $finished = [datetime]$insp.State.FinishedAt
  $secs = (Select-String -Path $log -Pattern 'OPENSSL_BUILD_SECONDS=(\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Select-Object -First 1)
  $hits = ($signatures | ForEach-Object { Select-String -Path $log -SimpleMatch -Pattern $_ } | ForEach-Object { $_.Line.Trim() } | Select-Object -Unique)
  docker rm $n | Out-Null
  [pscustomobject]@{
    Container    = $n
    ExitCode     = $code
    WallSeconds  = [int]($finished - $started).TotalSeconds
    BuildSeconds = $secs
    Signatures   = ($hits -join ' | ')
  }
}
$wallTotal = [int]((Get-Date) - $wallStart).TotalSeconds

$results | Format-Table -AutoSize
Write-Host "total wall clock: ${wallTotal}s for $Jobs concurrent runs of $Script"
Write-Host "pet builder baseline for one OpenSSL build: 804s (13.4 min)"
Write-Host "logs: $logDir"
if ($results | Where-Object { $_.ExitCode -ne 0 -or $_.Signatures }) {
  Write-Host 'RESULT: FAIL (see logs)' -ForegroundColor Red
  exit 1
}
Write-Host 'RESULT: PASS' -ForegroundColor Green
