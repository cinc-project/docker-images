# omnibus-windows

Windows omnibus builder image for Cinc: MSYS2 UCRT64, omnibus-toolchain, WiX
3.14, 7-Zip and Git for Windows on Windows Server Core `ltsc2022`, run under
process isolation on a Server 2022 (now) or Server 2025 (later) Docker host.

It replaces the Server 2016 pet builder. Its failures were all
machine-persistent state: MSYS2 background processes hanging jobs, per-build
temp dirs accumulating on PATH, an omnibus git cache silently serving objects
built by an older gcc, and 80 seconds of `git clean` per build. A container
removes the last three by construction; the first needs the reaper below.

**Status: builds in CI on the Server 2022 host** (first green build
2026-09-12: gcc 16.2.0, binutils 2.47, Ruby 3.4.9, WiX 3.14.1). The loader
and fork stress smoke tests pass under process isolation, and four concurrent
OpenSSL builds completed with no fork or rebase failures. Not yet done: a
single-container OpenSSL timing against the pet builder's 13.4 min, and a
real product build.

## Decisions baked in

| Decision | Why |
|---|---|
| Process isolation, `ltsc2022` base | No hypervisor needed inside a KVM guest; Server Standard allows unlimited process-isolated containers (Hyper-V isolation caps at two). `ltsc2022` runs on both 2022 and 2025 hosts. Artifacts still support Server 2016: the floor comes from MSYS2's UCRT64 runtime, not the base image. |
| Base is the .NET Framework 3.5 runtime image | It is `servercore:ltsc2022` plus the NetFx3 feature. WiX 3.14's binaries target CLR 4 (present everywhere), but the `wix314.exe` installer that the Chocolatey package runs needs 3.5, and the feature cannot be enabled inside a container without the OS payload. |
| Chocolatey for Git, 7-Zip, WiX | Same packages, versions and layouts as the pet builder provisioned by the cinc-omnibus cookbook. |
| MSYS2 from the dated, GPG-signed base archive | What the cookbook does; the `latest` alias has no signature. The build verifies the detached signature against the cookbook's vendored key (`files/msys2-signing-key.asc`). |
| omnibus-toolchain via omnitruck's `install.ps1` | The documented install route for every Cinc product on Windows (cinc.sh). install.ps1 checks the MSI against the sha256 in omnitruck's metadata. |
| UCRT64 only | Never MINGW64/msvcrt. Mixing C runtimes in one process corrupts the linker heap (`ld returned 116`); see the `gems.rb` PATH commentary in cinc-workstation. |
| Windows SDK 8.1 absent | On the pet builder's PATH, probably vestigial (signtool/mt.exe; Cinc does not sign). Being investigated separately; add it only if that comes back positive. |
| No volumes, no cache redesign | The omnibus git cache lives in `$CI_PROJECT_DIR/cache/git_cache` and ships through GitLab `cache:` to S3. That works identically in a container. |

## Contents and pins

| Component | Pin | Source |
|---|---|---|
| Base | `mcr.microsoft.com/dotnet/framework/runtime:3.5-windowsservercore-<BASE>`, BASE defaults to ltsc2022 | MCR |
| Chocolatey | 2.7.4 | community.chocolatey.org |
| Git for Windows | 2.55.0.5 (`/GitOnlyOnPath /NoAutoCrlf ...`) | choco `git` |
| 7-Zip | 26.3.0 | choco `7zip` |
| WiX Toolset | 3.14.1.20250415 | choco `wixtoolset` |
| MSYS2 base | 2026-06-11 (msys2-installer release tag), GPG-verified at build | repo.msys2.org/distrib |
| MSYS2 packages | cookbook default set: `base-devel`, `mingw-w64-ucrt-x86_64-toolchain`, libffi/ncurses/openssl/zlib, git, gnupg, openssh, rsync, wget, bzip2, ca-certificates | pacman, whatever the mirror ships on build day |
| omnibus-toolchain | 26.0.3, sha256 checked by install.ps1 against omnitruck metadata | omnitruck.cinc.sh |

Every pin is a `--build-arg` (see the `ARG`s at the top of the Dockerfile),
and each is a single version field with no hash beside it, so a bot can bump
it. Not wired up yet; when it is, Renovate is the fit (self-hosted on GitLab):
the built-in Dockerfile manager with `pinDigests` for the base image (Microsoft
republishes the same tag monthly), `nuget` against the Chocolatey v2 feed for
the choco pins, `github-releases` on `msys2/msys2-installer` for the MSYS2
date, and a custom datasource on omnitruck's `versions/all` endpoint for the
toolchain. Group them into one MR on a weekly schedule: every MR touching this
directory costs an hour-long image build. The same mechanism can bump
`BUILDER_IMAGE_TAG` in product pipelines from Docker Hub tags.

The compiler is whatever pacman shipped when the image was built and is then
frozen by the image tag itself; the `IgnorePkg` line is written for parity
with the cookbook only. To move the compiler, rebuild and publish a new dated
tag.

The image also ships:

- `C:\omnibus\load-omnibus-toolchain.ps1`, at the same path the pet builder
  used, so product jobs run unchanged. The environment itself comes from the
  image (Dockerfile `ENV` and the machine PATH); the loader only reports the
  tool versions and fails if any tool is missing or does not run.
- git identity and `safe.directory=*` in both gits' system config, because
  omnibus's git cache commits, and the runner's helper container populates the
  build volume under a different container-local SID.

## Building and publishing

On the Windows Docker host (never inside a container: no Docker-in-Docker on
Windows):

```powershell
cd docker-images\omnibus-windows
.\build.ps1                 # build + loader smoke test + fork stress test
.\build.ps1 -Scratch        # throwaway tag, removed afterwards (what MR pipelines run)
.\build.ps1 -Push -NoCache  # what the publish job runs
```

A normal build produces `cincproject/omnibus-windows:ltsc2022` and `:latest`
(floating) and `cincproject/omnibus-windows:ltsc2022-<yyyymmdd-hhmm>`
(immutable) and prints `BUILDER_IMAGE_TAG=ltsc2022-<yyyymmdd-hhmm>`. Pass
`-NoLatest` when building a base that should not become the default. Expect
an 8 to 12 GB image: Microsoft no longer marks Windows base layers as
foreign, so the whole base is pushed (once; the three tags share layers).
Anonymous Docker Hub pulls are rate-limited, so a `docker login` on the host
helps the product runner; note that the publish job logs out afterwards, so
that login must be under a different account or be redone.

Two things the flags guard against on a shared host:

- `-Scratch` exists because the product runner on the same host pulls with
  `if-not-present`; an MR build that reused the real tags would shadow the
  published image for every product job there. MR pipelines never touch the
  real tags.
- `-NoCache` on publish exists because `--pull` only refreshes the base; the
  pacman layers are otherwise reused from the last build, and a new dated tag
  would carry old packages.

In CI (`.gitlab-ci.yml` in this repo) `build:omnibus-windows` runs on merge
requests touching this directory and `publish:omnibus-windows` on master,
both on the host's shell runner. The publish job requires `DOCKER_USERNAME`
and `DOCKER_TOKEN`, fails before building if they are unset, and logs out
afterwards so the credential never stays on the host. Trigger by hand with
`CINC_BUILD=omnibus-windows`.

Each RUN layer is separable on purpose: Chocolatey, choco packages, MSYS2
base + self-update, MSYS2 packages + rebase, toolchain, config. If `docker
build` hangs, the layer tells you which component. The PowerShell helpers
every layer uses (`msys`, `msys_try`, `reap`, `cinst`, `clean`, `gitcfg`) are
defined once in `files/build-helpers.ps1`, dot-sourced by the `SHELL`
directive during the build and removed from the image at the end, with the
shell reset to the Windows default. `.dockerignore` keeps this README, the
runner config, `build.ps1` and the whole `test/` directory out of the build
context, and `.gitattributes` pins the shell scripts to LF whatever the build
host's git settings are.

## Runner setup

Two runners on the host, see `runner-config.example.toml`:

| Tag | Executor | Purpose |
|---|---|---|
| `windows-docker-builder` | `shell` (PowerShell) | builds and pushes this image |
| `windows-docker` | `docker-windows` | runs product builds in containers |

Notes that bite:

- `pull_policy = ["if-not-present", "always"]`. The default `always` re-pulls
  a 10 GB image per job. Product pipelines pin dated tags, so a local copy is
  always right, provided nothing else on the host tags those names, which is
  why MR builds use `-Scratch`.
- `builds_dir`, `cache_dir` and any `volumes` must be on `c:` (or a bare drive
  letter). Volume directories must already exist on the host.
- The runner service account must reach the Docker named pipe. For the first
  runs, start the runner interactively as Administrator and solve the service
  account separately.
- Defender: `Add-MpPreference -ExclusionPath 'C:\ProgramData\docker'` (image
  layers) and the chocolatey docker-engine dir. Real-time scanning sat at 90%
  CPU during the four-way OpenSSL run: a container's writable layer is a
  mounted VHDX volume, so path exclusions do not reach the files compilers
  touch. Process exclusions by image name (`-ExclusionProcess 'gcc.exe',
  'ld.exe', 'bash.exe', ...`) are the lever to try; the pet builder simply
  runs with real-time monitoring disabled. Not yet measured either way.
- Docker came from `choco install docker-engine`: binaries under
  `C:\ProgramData\chocolatey\lib\docker-engine\tools\docker\`, service is
  `start= auto` but not started on install.
- Disk: ~10 GB image, ~10 GB writable layer per running build, and Windows
  layer cleanup is not prompt. `docker system prune -a` periodically.

## Using it from a product pipeline

Pilot: **cinc-workstation**. Its Windows job already does exactly what the
image expects (`C:\omnibus\load-omnibus-toolchain.ps1` then
`bash build/build-windows.sh`), its `gems.rb` builds the gem PATH from
`MSYS2_INSTALL_DIR` (set in the image), the Go zip and PortableGit extraction
use the 7-Zip and self-extracting paths the image provides, and
`ruby-windows-system-libraries` copies DLLs from `C:\msys64\ucrt64\bin`. Its
`before_script` / `post-package-windows-cleanup.ps1` machine cleanup becomes a
no-op in a container. The job changes, when that step comes, are:

```yaml
package:windows-2016:                   # PLATFORM_VER 2016 is the artifact floor,
  extends: .package:windows             # not the builder (deploy.sh symlinks the rest)
  image: cincproject/omnibus-windows:${BUILDER_IMAGE_TAG}
  tags:
    - windows-docker
  cache:
    key: windows-${BUILDER_IMAGE_TAG}   # image tag in the key retires manual clearing
  variables:
    PLATFORM_VER: "2016"
    BUILDER_IMAGE_TAG: "ltsc2022-YYYYMMDD-HHMM"   # dated tag printed by build.ps1, never :ltsc2022
```

and, last in `after_script` of every Windows job (also on the pet builder
today, it is free):

```yaml
    - taskkill /F /FI "MODULES eq msys-2.0.dll"; Write-Host "msys2 reaper exit code $LASTEXITCODE (128 = nothing to kill)"; $global:LASTEXITCODE = 0
```

That is MSYS2's documented fix for CI hangs. It goes last with its exit code
neutralised because the runner's PowerShell shell aborts `after_script` at the
first line whose `$?` is false. The `ci-templates` branch `windows-container`
carries the reaper in `templates/package.yml` and the container job shape in
`platforms/windows.yml`.

## Validation

The test scripts are not in the image. From a checkout on the host, mount
`test/` into a container and run them there:

```powershell
docker run --rm -it -v "${PWD}\test:C:\tests:ro" cincproject/omnibus-windows:ltsc2022
C:\omnibus\load-omnibus-toolchain.ps1                    # every tool present
C:\msys64\usr\bin\bash.exe -l C:/tests/fork-stress.sh   # fork emulation go/no-go
C:\msys64\usr\bin\bash.exe -l C:/tests/openssl-build.sh # prints OPENSSL_BUILD_SECONDS
```

Both scripts exit non-zero on any failed fork or compile and take `MAKE_JOBS`
to cap the parallelism. That matters under `docker --cpus`: it is a CPU-rate
cap, so `nproc` inside the container still reports the host's count and
`make -j$(nproc)` oversubscribes. `concurrency.ps1` passes its `-Cpus` value
through as `MAKE_JOBS`.

`build.ps1` runs the first two automatically. On the host,
`test\concurrency.ps1` runs four OpenSSL builds in four containers at once,
reports exit code, wall clock and build seconds per container, and greps the
logs for the failure signatures. First result on the Server 2022 test host
(2026-09-12, `--cpus 4 --memory 7g` per container, Defender real-time
scanning active and pegged at 90% CPU during the run, and, before the
`MAKE_JOBS` fix, each container running `make -j16` inside its 4-CPU cap):

| Container | Exit | Wall clock |
|---|---|---|
| 1 to 4 | 0, no signatures | 1256 to 1296 s each, 1303 s total |

Four builds in 21.7 min against the pet builder's 13.4 min for one, so
roughly 2.5 times the throughput even under that oversubscription. A
single-container run (`-Jobs 1`) with Defender exclusions in place is the
like-for-like number still to collect.

| Symptom | First response |
|---|---|
| `fork: retry: Resource temporarily unavailable` | `peflags -d0 /usr/bin/msys-2.0.dll`; if it helps, add it to the Dockerfile's MSYS2 package layer after the rebase |
| `child_copy: ... failed` | same (the documented Docker-specific case) |
| `dofork: forked process died unexpectedly` | same |
| `ld returned 116` | rebase state or mixed C runtimes on PATH: rerun `autorebase.bat`, rebuild; check nothing MSVCRT-linked precedes `ucrt64\bin` |
| `docker build` hangs on pacman | already split into layers; last resort is moving the package layer to a runtime step |

## Known issues and open items

- **Toolchain releases need the Windows version symlinks.** omnitruck resolves
  every Windows version to `windows/2012r2/`, which on the mirror is a
  symlink to `2016/` (as are 2019, 2022, 10, 11). The products' deploy.sh
  creates those; the toolchain repo's deploy job does not, and its 26.0.x
  Windows MSIs were added by hand. The 26.0.1 to 26.0.3 releases were fixed on
  the mirror on 2026-09-11. Any new toolchain release needs the same, or the
  `install` step here fails with a 404.
- **Windows SDK 8.1** is not installed pending the separate investigation.
- **`core.autocrlf=false`** is set explicitly. The pet builder relied on
  whatever its Git for Windows install chose; byte-exact git-cache round trips
  are the intended behaviour, but it is a deliberate divergence to keep in
  mind if a restored tree looks different.
- **Splitting compile from packaging** (two images, MSI retries cheap, no
  .NET 3.5 in the compile image) is still worth doing but needs omnibus to
  separate `build` from packaging, which it does not do today. It also shapes
  where a future signing stage slots in.
- **Build order (handoff item 10)** does not hold as written: the saved client
  build log shows `libarchive` already building before `chef` (it is a declared
  dependency of the chef software definition), and `ruby-msys2-devkit` must
  stay last because RubyInstaller's rubygems plugin would otherwise compile
  chef's native gems with the embedded devkit instead of the host toolchain.
  No change made.
