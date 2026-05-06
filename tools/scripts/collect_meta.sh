#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/build/meta"

mkdir -p "$OUT"

{
echo "== DATE =="
date -u

echo
echo "== UNAME =="
uname -a

echo
echo "== CPU =="
nproc

echo
echo "== MEMORY =="
free -h

echo
echo "== REPOSITORY PATH =="
pwd

} > "$OUT/host-readiness.txt"

{
echo "== clang version =="
clang --version

echo
echo "== ld.lld version =="
ld.lld --version

echo
echo "== gcc version =="
gcc --version

echo
echo "== make version =="
make --version

echo
echo "== cmake version =="
cmake --version

echo
echo "== ninja version =="
ninja --version

echo
echo "== qemu version =="
qemu-system-x86_64 --version

} > "$OUT/toolchain-versions.txt"

echo "OK: metadata collected"
