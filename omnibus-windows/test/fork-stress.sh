#!/usr/bin/env bash
#
# MSYS2 fork() emulation under process isolation: the single risk that could
# have sunk the container approach. Escalating: subshells, pipelines,
# concurrent background forks, then a real parallel compile (zlib). Any
# failure exits non-zero; build.ps1 gates publishing on it.
#
# Not shipped in the image. build.ps1 bind-mounts test/ at C:\tests and runs:
#   C:\msys64\usr\bin\bash.exe -l C:/tests/fork-stress.sh
#
# MAKE_JOBS overrides the compile parallelism. nproc reports the host's CPU
# count even under docker --cpus, so pass the real budget when it is capped.
#
# Failure signatures and first responses (see README):
#   fork: retry: Resource temporarily unavailable   -> peflags -d0 /usr/bin/msys-2.0.dll
#   child_copy: ... failed                          -> same (documented Docker case)
#   dofork: forked process died unexpectedly        -> same
#   ld returned 116                                 -> autorebase.bat, rebuild image
set -e
work=$(mktemp -d)
fail() { echo "FORK_STRESS=fail: $1"; for f in "$work"/*.log; do [ -f "$f" ] && { echo "--- $f"; tail -20 "$f"; }; done; exit 1; }
trap 'fail "command failed at line $LINENO"' ERR

uname -a
gcc --version | head -1
jobs="${MAKE_JOBS:-$(nproc)}"
echo "make jobs: $jobs"

echo "=== 1. subshell forks (500) ==="
for i in $(seq 1 500); do ( : ) ; done; echo ok

echo "=== 2. pipeline forks (200) ==="
for i in $(seq 1 200); do echo x | cat | wc -l > /dev/null ; done; echo ok

echo "=== 3. concurrent background forks (64) ==="
# Background commands are exempt from set -e and a bare `wait` is always 0,
# so wait on each pid and count the dots the children wrote.
pids=()
for i in $(seq 1 64); do ( sleep 0.2; echo -n . ) & pids+=($!); done > "$work/dots"
failed=0
for pid in "${pids[@]}"; do wait "$pid" || failed=$((failed + 1)); done
dots=$(wc -c < "$work/dots")
[ "$failed" -eq 0 ] || fail "$failed background forks exited non-zero"
[ "$dots" -eq 64 ] || fail "expected 64 forks to report, got $dots"
echo ok

echo "=== 4. real compile, parallel (zlib) ==="
cd "$work"
wget -q https://zlib.net/fossils/zlib-1.3.1.tar.gz
tar xf zlib-1.3.1.tar.gz
cd zlib-1.3.1
./configure --prefix="$work/zi" > "$work/configure.log" 2>&1
make -j"$jobs" > "$work/make.log" 2>&1
make install > "$work/install.log" 2>&1
echo zlib ok
cd / && rm -rf "$work"

echo "=== 5. rebase state ==="
peflags /usr/bin/msys-2.0.dll || true
echo "FORK_STRESS=ok"
