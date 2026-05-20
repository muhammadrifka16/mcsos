#!/usr/bin/env bash
set -uo pipefail
mkdir -p artifacts/m15

check() {
  local stage=$1; local label=$2; local cmd=$3
  if eval "$cmd" &>/dev/null; then
    echo "[$stage] OK  : $label"
  else
    echo "[$stage] FAIL: $label"
  fi
}

echo "=========================================="
echo " MCSOS M0-M14 Readiness Detail Check"
echo "=========================================="

# M0
check M0  "direktori docs/"          "[ -d docs ]"
check M0  "artifacts/m0/"            "[ -d artifacts/m0 ]"
check M0  "git history ada"          "git log --oneline | head -1"

# M1
check M1  "artifacts/m1/tool_versions.txt" "[ -f artifacts/m1/tool_versions.txt ]"
check M1  "clang tersedia"           "which clang"

# M2
check M2  "boot ISO/ELF ada"         "ls build/*.iso build/*.elf 2>/dev/null | head -1 | grep -q ."

# M3
check M3  "serial log panic ada"     "find artifacts/m3 -name '*.log' -o -name '*.txt' 2>/dev/null | grep -q ."

# M4
check M4  "artifacts/m4/ ada"        "[ -d artifacts/m4 ]"

# M5
check M5  "artifacts/m5/ ada"        "[ -d artifacts/m5 ]"

# M6
check M6  "PMM host test lulus"      "[ -f artifacts/m6/host_test.txt ] && grep -qi 'pass' artifacts/m6/host_test.txt"

# M7
check M7  "VMM test lulus"           "[ -f artifacts/m7/host_test.txt ] && grep -qi 'pass' artifacts/m7/host_test.txt"

# M8
check M8  "Heap test lulus"          "[ -f artifacts/m8/host_test.txt ] && grep -qi 'pass' artifacts/m8/host_test.txt"

# M9
check M9  "Scheduler object audit"   "[ -f artifacts/m9/nm_undefined.txt ]"

# M10
check M10 "Syscall test lulus"       "[ -f artifacts/m10/host_test.txt ] && grep -qi 'pass' artifacts/m10/host_test.txt"

# M11
check M11 "ELF loader test lulus"    "[ -f artifacts/m11/host_test.txt ] && grep -qi 'pass' artifacts/m11/host_test.txt"

# M12
check M12 "Lock test lulus"          "[ -f artifacts/m12/host_test.txt ] && grep -qi 'pass' artifacts/m12/host_test.txt"

# M13
check M13 "VFS/RAMFS test lulus"     "[ -f artifacts/m13/host_test.txt ] && grep -qi 'pass' artifacts/m13/host_test.txt"

# M14 - paling krusial untuk M15
check M14 "artifacts/m14/ ada"                  "[ -d artifacts/m14 ]"
check M14 "host_test.txt ada"                   "[ -f artifacts/m14/host_test.txt ]"
check M14 "host test lulus"                     "grep -qi 'pass' artifacts/m14/host_test.txt"
check M14 "nm_undefined.txt kosong"             "[ -f artifacts/m14/nm_undefined.txt ] && [ ! -s artifacts/m14/nm_undefined.txt ]"
check M14 "readelf ELF64 REL x86-64"            "grep -q 'ELF64' artifacts/m14/readelf_header.txt 2>/dev/null"
check M14 "mcsfs1/block object ada di repo"     "find . -name '*.c' | xargs grep -l 'block_count\|blkdev\|lba' 2>/dev/null | grep -q ."

echo "=========================================="
echo " Selesai. Paste output ini ke chat."
echo "=========================================="
