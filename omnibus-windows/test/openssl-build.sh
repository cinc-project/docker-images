#!/usr/bin/env bash
#
# The go/no-go build: OpenSSL is the largest omnibus software definition
# (13.4 min on the Server 2016 pet builder), perl-heavy, configure-heavy, and
# forks constantly. If MSYS2 in a container breaks, it breaks here.
#
# Not shipped in the image. concurrency.ps1 bind-mounts test/ at C:\tests and runs:
#   C:\msys64\usr\bin\bash.exe -l C:/tests/openssl-build.sh
#
# Prints OPENSSL_BUILD_SECONDS=<n> on success; compare against 804 (13.4 min).
# MAKE_JOBS overrides the parallelism: nproc reports the host's CPU count even
# under docker --cpus, so pass the real budget when it is capped.
# concurrency.ps1 runs several of these at once, which is what actually
# exercises the rebase/address-space failure modes.
set -e
: "${OPENSSL_VERSION:=3.6.3}"
work=$(mktemp -d)
fail() { echo "OPENSSL_BUILD=fail: $1"; for f in "$work"/*.log; do [ -f "$f" ] && { echo "--- $f"; tail -20 "$f"; }; done; exit 1; }
trap 'fail "command failed at line $LINENO"' ERR

uname -a
gcc --version | head -1
jobs="${MAKE_JOBS:-$(nproc)}"
echo "make jobs: $jobs (nproc $(nproc))"

cd "$work"
tarball="openssl-${OPENSSL_VERSION}.tar.gz"
wget -q "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/${tarball}"
tar xf "$tarball"
cd "openssl-${OPENSSL_VERSION}"

start=$(date +%s)
./Configure mingw64 --prefix="$work/ossl" no-docs > "$work/configure.log" 2>&1
make -j"$jobs" > "$work/make.log" 2>&1
make install_sw > "$work/install.log" 2>&1
end=$(date +%s)

"$work/ossl/bin/openssl.exe" version
cd / && rm -rf "$work"
echo "OPENSSL_BUILD_SECONDS=$((end - start))"
