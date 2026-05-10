#!/usr/bin/env bash
set -euo pipefail

fail() { echo "[M4][FAIL] $*" >&2; exit 1; }
pass() { echo "[M4][PASS] $*"; }
warn() { echo "[M4][WARN] $*" >&2; }

[[ -d .git ]] || fail "Jalankan dari root repository Git MCSOS."
[[ -f linker.ld ]] || fail "linker.ld belum ada. Selesaikan M2/M3 terlebih dahulu."
