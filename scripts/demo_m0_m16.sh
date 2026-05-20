#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo " MCSOS DEMO M0-M16"
echo "===================================="

echo
echo "[M0] Environment"
uname -a
clang --version | head -n 1
qemu-system-x86_64 --version | head -n 1
git rev-parse --short HEAD

echo
echo "===================================="
echo "[M1-M16] CLEAN BUILD"
echo "===================================="

make clean || true
make build || make

echo
echo "===================================="
echo "[M3/M4] ELF AUDIT"
echo "===================================="

readelf -h build/kernel.elf | head -n 20 || true
nm build/kernel.elf | head -n 20 || true

echo
echo "===================================="
echo "[M5-M12] HOST TESTS"
echo "===================================="

make -C tests/m16 clean all

echo
echo "===================================="
echo "[M13-M16] QEMU RUNTIME"
echo "===================================="

timeout 15s qemu-system-x86_64 \
  -machine q35 \
  -cpu qemu64 \
  -m 512M \
  -serial stdio \
  -display none \
  -no-reboot \
  -no-shutdown \
  -cdrom build/mcsos.iso || true

echo
echo "===================================="
echo " FINAL STATUS "
echo "===================================="

git status
echo
echo "MCSOS M0-M16 DEMO COMPLETE"
