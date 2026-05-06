#!/usr/bin/env bash
set -e

# Direktori untuk menyimpan bukti
EVIDENCE_DIR="build/evidence/M0"
mkdir -p "$EVIDENCE_DIR"

# Metadata alat yang digunakan
echo "[M0] Collecting toolchain metadata"
cat build/meta/toolchain-versions.txt > "$EVIDENCE_DIR/toolchain-versions.txt"

# Output smoke test
echo "[M0] Collecting smoke test output"
cat build/smoke/readelf-header.txt > "$EVIDENCE_DIR/smoke-test.txt"
cat build/smoke/objdump.txt >> "$EVIDENCE_DIR/smoke-test.txt"

# Ringkasan status Git
echo "[M0] Collecting Git summary"
git status --short > "$EVIDENCE_DIR/git-status.txt"
git log --oneline -n 3 > "$EVIDENCE_DIR/git-log.txt"

echo "[M0] Evidence collection complete. Output saved to $EVIDENCE_DIR"
