# escape=`
#
# Cinc omnibus builder for Windows: MSYS2 UCRT64, omnibus-toolchain, WiX 3.14,
# 7-Zip and Git for Windows on Server Core ltsc2022, process isolation.
# ltsc2022 runs on both 2022 and 2025 hosts; the Server 2016 artifact floor
# comes from MSYS2's UCRT64 runtime, not this base.
#
# Build on the Docker host with .\build.ps1 (no Docker-in-Docker on Windows).
# To change anything: bump a pin, rebuild, publish a new dated tag, move
# BUILDER_IMAGE_TAG in the product pipelines (it is part of their cache key).
#
# escape=` makes the backtick the continuation character so trailing
# backslashes in Windows paths are safe; RUN code must not use backtick escapes.
# RUN code must not use double quotes either: powershell -Command receives the
# text through the Windows command line, which eats unescaped quotes. Use
# single quotes, -f and +, and '' for a single quote inside a bash command.
# Anything needing more lives in files/build-helpers.ps1, which the SHELL
# directive dot-sources into every RUN.

# servercore plus NetFx3. WiX's binaries run on CLR 4, but the wix314.exe
# installer choco runs needs 3.5, which cannot be enabled in a container.
ARG BASE=ltsc2022
FROM mcr.microsoft.com/dotnet/framework/runtime:3.5-windowsservercore-${BASE}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

COPY files/build-helpers.ps1 C:/build-helpers.ps1
SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; . C:\\build-helpers.ps1;"]

# Pins: one version field each, no hashes, so a bot can bump them (README has
# the Renovate mapping). Integrity: the MSYS2 archive's GPG signature and
# omnitruck's own sha256 check in install.ps1.
ARG CHOCO_VERSION=2.7.4
ARG GIT_VERSION=2.55.0.5
ARG SEVENZIP_VERSION=26.3.0
ARG WIX_VERSION=3.14.1.20250415
# msys2/msys2-installer release tag; archive names drop the dashes.
ARG MSYS2_DATE=2026-06-11
# MSYS2 signing key (files/msys2-signing-key.asc, from the cinc-omnibus cookbook).
ARG MSYS2_KEY_FINGERPRINT=0EBF782C5D53F7E5FB02A66746BD761F7A49B0EC
ARG TOOLCHAIN_VERSION=26.0.3

# Build environment as the cinc-omnibus cookbook's loader sets it, plus
# MSYS2_PATH_TYPE=inherit and CHERE_INVOKING so login shells (the test
# scripts, interactive debugging) keep the Windows PATH and the cwd. Set
# early so the MSYS2 login shells below already run as UCRT64.
ENV MSYSTEM=UCRT64 `
    MSYS2_PATH_TYPE=inherit `
    CHERE_INVOKING=yes `
    MSYS2_INSTALL_DIR=C:\msys64 `
    OMNIBUS_TOOLCHAIN_INSTALL_DIR=C:\cinc-project\omnibus-toolchain `
    OMNIBUS_WINDOWS_ARCH=x64 `
    SSL_CERT_FILE=C:\cinc-project\omnibus-toolchain\embedded\ssl\certs\cacert.pem `
    HOMEDRIVE=C: `
    HOMEPATH=\omnibus `
    BASH_ENV=C:\msys64\etc\bash.bashrc

# Chocolatey, same source of tools as the pet builder.
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    $env:chocolateyVersion = $env:CHOCO_VERSION; `
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); `
    $choco = 'C:\ProgramData\chocolatey\bin\choco.exe'; `
    & $choco feature enable -n allowGlobalConfirmation --limit-output; `
    & $choco feature disable -n showDownloadProgress --limit-output; `
    & $choco --version; `
    clean ($env:TEMP + '\*')

# Git for Windows (/NoAutoCrlf: byte-exact git cache), 7-Zip (fast_msi zips
# the install tree), WiX (heat/candle/light).
RUN cinst git $env:GIT_VERSION @('--params', '/GitOnlyOnPath /NoAutoCrlf /NoShellIntegration /NoGuiHereIntegration /NoCredentialManager'); `
    cinst 7zip $env:SEVENZIP_VERSION; `
    cinst wixtoolset $env:WIX_VERSION; `
    foreach ($p in 'git.install', '7zip.install', 'wixtoolset') { `
      Get-ChildItem ('C:\ProgramData\chocolatey\lib\' + $p + '\tools') -Recurse -Include *.exe, *.msi, *.zip -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue }; `
    clean ($env:TEMP + '\*'), 'C:\ProgramData\chocolatey\logs\*'

# MSYS2 base, GPG-verified with Git for Windows' gpg (MSYS-built: /c/ paths),
# then the -Syuu passes as MSYS2's CI does. Separate layer so a pacman hang is
# attributable. The first two passes are msys_try: an upgrade of msys2-runtime
# tears down the shell running pacman, so their exit code means nothing. The
# third pass is strict and must be a no-op; that is the consistency check.
COPY files/msys2-signing-key.asc C:/msys2-signing-key.asc
RUN $date = $env:MSYS2_DATE -replace '-', ''; `
    $url = 'https://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-{0}.sfx.exe' -f $date; `
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile C:\msys2.exe; `
    Invoke-WebRequest -UseBasicParsing -Uri ($url + '.sig') -OutFile C:\msys2.exe.sig; `
    $gpg = 'C:\Program Files\Git\usr\bin\gpg.exe'; `
    New-Item -ItemType Directory -Force -Path C:\msys2-gpg | Out-Null; `
    & $gpg --homedir /c/msys2-gpg --batch --import /c/msys2-signing-key.asc; `
    if ($LASTEXITCODE) { throw ('gpg import of the MSYS2 signing key failed: {0}' -f $LASTEXITCODE) }; `
    $status = & $gpg --homedir /c/msys2-gpg --batch --status-fd 1 --verify /c/msys2.exe.sig /c/msys2.exe; `
    if ($LASTEXITCODE) { throw ('MSYS2 base signature verification failed: {0}' -f $LASTEXITCODE) }; `
    if (-not ($status | Select-String -SimpleMatch 'VALIDSIG' | Select-String -SimpleMatch $env:MSYS2_KEY_FINGERPRINT)) { throw 'MSYS2 base signed by an unexpected key' }; `
    reap; `
    Remove-Item -Recurse -Force C:\msys2-gpg, C:\msys2-signing-key.asc, C:\msys2.exe.sig; `
    $p = Start-Process -Wait -PassThru -FilePath C:\msys2.exe -ArgumentList '-y', '-oC:\'; `
    if ($p.ExitCode) { throw ('msys2 extract failed: {0}' -f $p.ExitCode) }; `
    Remove-Item C:\msys2.exe; `
    msys 'true'; `
    msys_try 'pacman --noconfirm -Syuu --overwrite ''*'' > /var/log/pacman-update-1.log 2>&1'; `
    msys 'cat /var/log/pacman-update-1.log'; `
    msys_try 'rm -f /var/lib/pacman/db.lck; pacman --noconfirm -Syuu --overwrite ''*'' > /var/log/pacman-update-2.log 2>&1'; `
    msys 'cat /var/log/pacman-update-2.log'; `
    msys 'rm -f /var/lib/pacman/db.lck; pacman --noconfirm -Syuu > /var/log/pacman-update-3.log 2>&1; rc=$?; cat /var/log/pacman-update-3.log; exit $rc'; `
    msys 'pacman --noconfirm -Scc'

# UCRT64 build deps (the cookbook's default set), compiler freeze (parity;
# nothing runs pacman -Syu at job time), then autorebase from cmd with no
# MSYS2 process alive. rebaseall picks the 64-bit base address only when
# uname -s says MSYS, so it runs with MSYSTEM=MSYS rather than the image's
# UCRT64. Rebased addresses are file contents and survive the layer commit.
RUN msys 'pacman --noconfirm -S --needed base-devel bzip2 ca-certificates git gnupg mingw-w64-ucrt-x86_64-libffi mingw-w64-ucrt-x86_64-ncurses mingw-w64-ucrt-x86_64-openssl mingw-w64-ucrt-x86_64-toolchain mingw-w64-ucrt-x86_64-zlib openssh rsync wget > /var/log/pacman-install.log 2>&1; rc=$?; cat /var/log/pacman-install.log; exit $rc'; `
    msys 'pacman --noconfirm -Scc'; `
    msys 'sed -i ''s/^#\?IgnorePkg .*/IgnorePkg = mingw-w64-ucrt-x86_64-binutils mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gcc-libs/'' /etc/pacman.conf && grep -n ''^IgnorePkg'' /etc/pacman.conf'; `
    $env:MSYSTEM = 'MSYS'; & cmd /c C:\msys64\autorebase.bat; if ($LASTEXITCODE) { throw ('autorebase.bat exited {0}' -f $LASTEXITCODE) }; $env:MSYSTEM = 'UCRT64'; `
    reap; `
    msys 'gcc --version | head -1; ld --version | head -1; peflags /usr/bin/msys-2.0.dll || true'

# omnibus-toolchain via omnitruck's install.ps1, as cinc.sh documents.
# install.ps1 checks the MSI against omnitruck's sha256 for that version.
# Loading it sets [Console]::OutputEncoding, which throws without an attached
# console (docker build has none), so errors are non-fatal for that one step.
RUN $ErrorActionPreference = 'Continue'; `
    . { Invoke-WebRequest -UseBasicParsing -Uri 'https://omnitruck.cinc.sh/install.ps1' } | Invoke-Expression; `
    $ErrorActionPreference = 'Stop'; `
    install -project omnibus-toolchain -channel stable -version $env:TOOLCHAIN_VERSION -download_directory C:\omnitruck-tmp; `
    Remove-Item -Recurse -Force C:\omnitruck-tmp; `
    if (-not (Test-Path C:\cinc-project\omnibus-toolchain\embedded\bin\ruby.exe)) { throw 'omnibus-toolchain did not install to C:\cinc-project\omnibus-toolchain' }; `
    Get-Content C:\cinc-project\omnibus-toolchain\version-manifest.txt | Select-Object -First 1; `
    & C:\cinc-project\omnibus-toolchain\embedded\bin\ruby.exe --version; `
    if ($LASTEXITCODE) { throw ('embedded ruby exited {0}' -f $LASTEXITCODE) }

# git identity for the omnibus git cache, in both gits' system config.
# safe.directory=*: the runner's helper populates the build volume as another
# container-local SID. PATH goes in the machine registry so every process sees
# it. Windows SDK 8.1 is left out until something proves to need it. The
# test scripts are not in the image; build.ps1 and test/concurrency.ps1
# bind-mount test/ into the containers they run.
COPY files/load-omnibus-toolchain.ps1 C:/omnibus/load-omnibus-toolchain.ps1
RUN foreach ($git in 'C:\Program Files\Git\cmd\git.exe', 'C:\msys64\usr\bin\git.exe') { `
      gitcfg $git @('user.name', 'Omnibus'); `
      gitcfg $git @('user.email', 'omnibus@cinc.sh'); `
      gitcfg $git @('color.ui', 'false'); `
      gitcfg $git @('core.autocrlf', 'false'); `
      gitcfg $git @('core.longpaths', 'true'); `
      gitcfg $git @('--add', 'safe.directory', '*'); `
      & $git config --system --get-all safe.directory; `
      & $git --version }; `
    $prefix = 'C:\Program Files (x86)\WiX Toolset v3.14\bin;C:\Program Files\7-Zip;C:\cinc-project\omnibus-toolchain\embedded\bin;C:\Program Files\Git\cmd;C:\msys64\ucrt64\bin;C:\msys64\usr\bin'; `
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine'); `
    [Environment]::SetEnvironmentVariable('Path', ($prefix + ';' + $machine), 'Machine'); `
    New-Item -ItemType Directory -Force -Path C:\omnibus\cache | Out-Null

# The build helpers are build-time only. Remove the file and restore the
# stock Windows shell so derived images and the runtime carry nothing of it.
RUN Remove-Item C:\build-helpers.ps1
SHELL ["cmd", "/S", "/C"]

WORKDIR C:/omnibus
CMD ["powershell.exe", "-NoLogo"]
