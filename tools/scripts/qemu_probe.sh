#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$ROOT/build/meta"

mkdir -p "$OUT"

REPORT="$OUT/qemu-capabilities.txt"

{
echo "== QEMU VERSION =="
qemu-system-x86_64 --version

echo
echo "== QEMU MACHINES =="
qemu-system-x86_64 -machine help | head -20

echo
echo "== CHECK q35 MACHINE =="

if qemu-system-x86_64 -machine help | grep -q q35; then
echo "OK: q35 machine available"
else
echo "ERROR: q35 machine missing"
exit 1
fi

echo
echo "== CHECK OVMF =="

for path in \
/usr/share/OVMF/OVMF_CODE.fd \
/usr/share/OVMF/OVMF_CODE_4M.fd \
/usr/share/ovmf/OVMF.fd \
/usr/share/qemu/OVMF.fd; do

if [ -r "$path" ]; then
echo "OK: OVMF found at $path"
FOUND=1
fi

done

if [ "${FOUND:-0}" -eq 0 ]; then
echo "ERROR: OVMF firmware not found"
exit 1
fi

} | tee "$REPORT"

echo
echo "OK: qemu probe completed"
