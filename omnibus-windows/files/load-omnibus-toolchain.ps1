###############################################################
# Load the base Omnibus environment
#
# Container edition of the cinc-omnibus cookbook's
# load-omnibus-toolchain.ps1 template, at the same path so
# product jobs run unchanged. The image already sets the
# environment (Dockerfile ENV) and the machine PATH, so this
# only reports the tool versions and fails if any tool is
# missing or does not run. Windows SDK 8.1 is intentionally
# absent from the image.
###############################################################
$ErrorActionPreference = 'Stop'

###############################################################
# Query tool versions
###############################################################

$env:OMNIBUS_GIT_VERSION=git --version
$env:OMNIBUS_RUBY_VERSION=ruby --version
$env:OMNIBUS_GEM_VERSION=gem --version
$env:OMNIBUS_BUNDLER_VERSION=bundle --version
$env:OMNIBUS_GCC_VERSION=(gcc --version)[0]
$env:OMNIBUS_MAKE_VERSION=(make --version)[0]
$env:OMNIBUS_SEVENZIP_VERSION=(7z -h)[1]
$env:OMNIBUS_WIX_HEAT_VERSION=(heat -help)[0]
$env:OMNIBUS_WIX_CANDLE_VERSION=(candle -help)[0]
$env:OMNIBUS_WIX_LIGHT_VERSION=(light -help)[0]

# A tool that is on PATH but cannot run (missing DLL) prints nothing.
foreach ($name in 'OMNIBUS_GIT_VERSION', 'OMNIBUS_RUBY_VERSION', 'OMNIBUS_GEM_VERSION',
                  'OMNIBUS_BUNDLER_VERSION', 'OMNIBUS_GCC_VERSION', 'OMNIBUS_MAKE_VERSION',
                  'OMNIBUS_SEVENZIP_VERSION', 'OMNIBUS_WIX_HEAT_VERSION',
                  'OMNIBUS_WIX_CANDLE_VERSION', 'OMNIBUS_WIX_LIGHT_VERSION') {
  if (-not [Environment]::GetEnvironmentVariable($name)) {
    throw "$name is empty: the tool is missing or failed to run"
  }
}

Write-Host " ========================================"
Write-Host " = Tool Versions"
Write-Host " ========================================"

Write-Host " 7-Zip..........$env:OMNIBUS_SEVENZIP_VERSION"
Write-Host " Bundler........$env:OMNIBUS_BUNDLER_VERSION"
Write-Host " GCC............$env:OMNIBUS_GCC_VERSION"
Write-Host " Git............$env:OMNIBUS_GIT_VERSION"
Write-Host " Make...........$env:OMNIBUS_MAKE_VERSION"
Write-Host " Ruby...........$env:OMNIBUS_RUBY_VERSION"
Write-Host " RubyGems.......$env:OMNIBUS_GEM_VERSION"
Write-Host " WiX:Heat.......$env:OMNIBUS_WIX_HEAT_VERSION"
Write-Host " WiX:Candle.....$env:OMNIBUS_WIX_CANDLE_VERSION"
Write-Host " WiX:Light......$env:OMNIBUS_WIX_LIGHT_VERSION"

Write-Host " ========================================"
