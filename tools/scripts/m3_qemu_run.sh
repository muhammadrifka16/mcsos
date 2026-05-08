#!/usr/bin/env bash

set -Eeuo pipefail

ISO="${1:-build/mcsos.iso}"

TIMEOUT_SEC="${MCSOS_QEMU_TIMEOUT:-15}"

OVMF_CODE="${OVMF_CODE:-/usr/share/OVMF/OVMF_CODE_4M.fd}"
OVMF_VARS="${OVMF_VARS:-build/OVMF_VARS_4M.fd}"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

test -f "$ISO" \
    || fail "ISO tidak ditemukan: $ISO"

command -v qemu-system-x86_64 >/dev/null 2>&1 \
    || fail "qemu-system-x86_64 tidak ditemukan"

test -f "$OVMF_CODE" \
    || fail "OVMF_CODE tidak ditemukan: $OVMF_CODE"

test -f "$OVMF_VARS" \
    || fail "OVMF_VARS tidak ditemukan: $OVMF_VARS"

timeout "$TIMEOUT_SEC" \
qemu-system-x86_64 \
    -machine q35 \
    -m 256M \
    -smp 1 \
    -cpu qemu64 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$OVMF_VARS" \
    -cdrom "$ISO" \
    -boot d \
    -serial stdio \
    -nographic \
    -no-reboot \
    -no-shutdown \
    || true

echo "PASS: QEMU smoke test M3 selesai"
