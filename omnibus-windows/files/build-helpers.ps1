# Helpers dot-sourced into every RUN by the Dockerfile's SHELL directive, so
# each is defined once. RUN lines themselves cannot contain double quotes
# (powershell -Command loses them); this file can.

# Kill every process still loading the MSYS2 runtime. A keyring hook can leave
# gpg-agent/dirmngr holding the step's stdout pipe, which is how docker build
# hangs on MSYS2. taskkill exits 128 when nothing matched; that is not an error.
function reap {
  & taskkill /F /FI 'MODULES eq msys-2.0.dll' | Out-Host
  $global:LASTEXITCODE = 0
}

# Run a command in an MSYS2 login shell, reap, and throw on a non-zero exit.
function msys([string]$cmd) {
  & C:\msys64\usr\bin\bash.exe -lc $cmd
  $rc = $LASTEXITCODE
  reap
  if ($rc) { throw "msys2: [$cmd] exited $rc" }
}

# Same, but the exit code is logged and ignored: an upgrade of msys2-runtime
# tears down the shell running pacman, so the code carries no information.
function msys_try([string]$cmd) {
  & C:\msys64\usr\bin\bash.exe -lc $cmd
  Write-Host "msys2 (exit code tolerated): [$cmd] exited $LASTEXITCODE"
  reap
}

# choco install at a pinned version. 3010 (reboot requested) is a complete
# install; a container cannot reboot anyway.
function cinst([string]$pkg, [string]$ver, [string[]]$extra = @()) {
  & choco install $pkg --version $ver -y --no-progress --limit-output @extra
  if ($LASTEXITCODE -notin 0, 3010) { throw "choco install $pkg $ver failed: $LASTEXITCODE" }
}

# Best-effort delete for temp files only. It ends on a succeeding statement
# because powershell -Command exits 1 when the last statement's $? is false,
# and a SilentlyContinue delete that fails still sets it false. Deletes that
# must succeed use a plain Remove-Item so they fail the build.
function clean([string[]]$paths) {
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $paths
  Write-Host "cleaned: $($paths -join ' ')"
}

# git config --system that fails the build on error. MSYS=noglob stops the
# MSYS2 runtime from glob-expanding arguments such as * when its git is
# started from PowerShell.
function gitcfg([string]$git, [string[]]$cfg) {
  $env:MSYS = 'noglob'
  & $git config --system @cfg
  $rc = $LASTEXITCODE
  Remove-Item Env:MSYS -ErrorAction SilentlyContinue
  if ($rc) { throw "$git config --system $cfg failed: $rc" }
}
