#!/usr/bin/env bash
# MCSOS Demo M0-M16 — corrected milestone mapping + identity portrait, colorized, animated
set +e

RESET=$'\033[0m'; BOLD=$'\033[1m'; DIM=$'\033[2m'
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'; MAGENTA=$'\033[0;35m'; CYAN=$'\033[0;36m'
GOLD_BRIGHT=$'\033[38;5;220m'; WHITE=$'\033[1;37m'; GRAY=$'\033[38;5;240m'

TOTAL_STEPS=17
STEP_COUNT=0
declare -a RESULT_NUM RESULT_TITLE RESULT_STATUS
CURRENT_NUM=""
CURRENT_TITLE=""

# ---- Lebar terminal & centering global ----
# Satu sumber kebenaran buat lebar terminal, dipakai di semua elemen biar
# nggak ada yang "loncat-loncat" pusatnya. Default 133 sesuai lebar kerja normal.
TERM_COLS=$(tput cols 2>/dev/null || echo 133)
(( TERM_COLS <= 0 )) && TERM_COLS=133

# center_pad LEN -> cetak spasi kiri biar blok selebar LEN center di TERM_COLS
center_pad() {
  local len="$1" pad
  pad=$(( (TERM_COLS - len) / 2 ))
  (( pad < 0 )) && pad=0
  printf '%*s' "$pad" ''
}

BOX_WIDTH=62            # lebar box ╔══...══╗ milestone (termasuk border)
PAD_BLOCK=$(center_pad "$BOX_WIDTH")   # padding tetap dipakai box+progress+step+tabel

typewriter() {
  local text="$1" delay="${2:-0.008}"
  for (( i=0; i<${#text}; i++ )); do
    printf '%s' "${text:$i:1}"
    sleep "$delay"
  done
  printf '\n'
}

progress_bar() {
  local current=$1 total=$2 width=40
  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))
  printf '%s' "$PAD_BLOCK"
  printf "${GOLD_BRIGHT}["
  for ((j=0;j<filled;j++)); do printf '█'; done
  for ((j=0;j<empty;j++)); do printf '░'; done
  printf "] %d/%d${RESET}\n\n" "$current" "$total"
}

section() {
  local num="$1" title="$2" check_desc="$3"
  STEP_COUNT=$((STEP_COUNT+1))
  CURRENT_NUM="$num"
  CURRENT_TITLE="$title"
  local colors=("$GOLD_BRIGHT" "$CYAN" "$MAGENTA" "$GREEN" "$BLUE" "$RED")
  local ncolors=${#colors[@]}
  local cidx=$(( (STEP_COUNT - 1) % ncolors ))
  local C="${colors[$cidx]}"
  local BAR="============================================================"
  local DIV="------------------------------------------------------------"
  echo
  printf '%s' "$PAD_BLOCK"; echo -e "${BOLD}${C}+${BAR}+${RESET}"
  printf '%s' "$PAD_BLOCK"; echo -e "${BOLD}${C}+${BAR}+${RESET}"
  printf '%s' "$PAD_BLOCK"; printf "${BOLD}${C}|${RESET}  ${BOLD}${WHITE}%-58s${RESET}${BOLD}${C}|${RESET}\n" "[$num] $title"
  if [ -n "$check_desc" ]; then
    printf '%s' "$PAD_BLOCK"; echo -e "${BOLD}${C}+${DIV}+${RESET}"
    printf '%s' "$PAD_BLOCK"; printf "${BOLD}${C}|${RESET}  ${BOLD}${WHITE}-> Cek: %-50s${RESET}${BOLD}${C}|${RESET}\n" "$check_desc"
  fi
  printf '%s' "$PAD_BLOCK"; echo -e "${BOLD}${C}+${BAR}+${RESET}"
  printf '%s' "$PAD_BLOCK"; echo -e "${BOLD}${C}+${BAR}+${RESET}"
  progress_bar "$STEP_COUNT" "$TOTAL_STEPS"
  sleep 0.3
}

clear_line() {
  # ANSI clear-to-end-of-line: universal, tidak bergantung pada lebar terminal
  printf '\r\033[K'
}

print_padded_log() {
  # Cetak N baris terakhir dari sebuah log, tiap baris dipotong biar muat
  # di lebar terminal (kalau kepanjangan bakal wrap sendiri & bikin box
  # /alignment di atasnya keliatan berantakan).
  local file="$1" nlines="$2" maxw logline
  maxw=$(( TERM_COLS - ${#PAD_BLOCK} - 4 ))
  (( maxw < 20 )) && maxw=20
  tail -n "$nlines" "$file" | while IFS= read -r logline; do
    if (( ${#logline} > maxw )); then
      logline="${logline:0:$((maxw-3))}..."
    fi
    printf '%s%b  %s%b\n' "$PAD_BLOCK" "$DIM" "$logline" "$RESET"
  done
}

run_step() {
  local desc="$1"; shift
  printf '%s' "$PAD_BLOCK"; echo -e "${YELLOW}▶ ${desc}${RESET}"
  ( "$@" ) > /tmp/mcsos_demo_step.log 2>&1 &
  local pid=$!
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % ${#spin} ))
    clear_line
    printf '%s%s%s%s %s' "$PAD_BLOCK" "$CYAN" "${spin:$i:1}" "$RESET" "$desc"
    sleep 0.08
  done
  wait "$pid"; local status=$?
  clear_line
  if [ $status -eq 0 ]; then
    printf '%s%b✔ %s — PASS%b\n' "$PAD_BLOCK" "$GREEN" "$desc" "$RESET"
    RESULT_NUM+=("$CURRENT_NUM"); RESULT_TITLE+=("$CURRENT_TITLE"); RESULT_STATUS+=("PASS")
  else
    printf '%s%b✘ %s — FAIL (exit %d)%b\n' "$PAD_BLOCK" "$RED" "$desc" "$status" "$RESET"
    printf '%s' "$PAD_BLOCK"; echo -e "${DIM}--- log tail ---${RESET}"
    print_padded_log /tmp/mcsos_demo_step.log 15
    RESULT_NUM+=("$CURRENT_NUM"); RESULT_TITLE+=("$CURRENT_TITLE"); RESULT_STATUS+=("FAIL")
  fi
  sleep 0.2
  return $status
}

step_m0() { find docs -maxdepth 2 -type f | sort; cat docs/reports/M0-laporan.md 2>/dev/null | head -n 20; }
step_m1() { bash tools/scripts/check_toolchain.sh; }
step_m2() { bash tools/scripts/m2_preflight.sh; }
step_m3() { bash tools/scripts/m3_preflight.sh; }
step_m4() { bash tools/scripts/m4_preflight.sh; }
step_m5() { bash scripts/check_m5_static.sh; }
step_m6() { bash scripts/check_m6_static.sh; }
step_m7() { bash scripts/m7_preflight.sh; }
step_m8() { make m8-all; }
step_m9() { make m9-all; }
step_m10() { grep -n "syscall_dispatch\|SYS_" kernel/syscall/syscall.c | head -n 20; cat logs/m10_serial.log 2>/dev/null; }
step_m11() { make m11-all; }
step_m12() { ls -la evidence/M12; cat evidence/M12/qemu-selftest.log 2>/dev/null | tail -n 20; }
step_m13() {
  mkdir -p build/m13
  clang -std=c17 -Wall -Wextra -Werror -Iinclude -Ikernel/include -Ikernel/arch/x86_64/include -Ifs/mcsfs1 \
    tests/m13_vfs_host_test.c kernel/vfs/ramfs.c kernel/vfs/fd.c kernel/vfs/sys_vfs.c \
    -o build/m13/m13_vfs_host_test
  ./build/m13/m13_vfs_host_test
}
step_m14() { make m14-all; }
step_m15() { make m15-all; }
step_m16() { bash scripts/m16_preflight.sh && make -C tests/m16 clean all; }

PORTRAIT_LINES=(
'\033[38;5;17m██████████████████████████████████████████████████████████████████████████████████████████████████████\033[0m'
'\033[38;5;17m███████████████████████████████\033[38;5;95m█\033[38;5;252m█\033[38;5;95m█\033[38;5;17m███\033[38;5;137m█\033[38;5;101m█\033[38;5;186m█\033[38;5;95m█\033[38;5;180m█\033[38;5;101m█\033[38;5;180m█\033[38;5;137m█\033[38;5;95m█\033[38;5;186m█\033[38;5;101m█\033[38;5;180m█\033[38;5;17m█\033[38;5;179m█\033[38;5;137m█\033[38;5;101m█\033[38;5;143m█\033[38;5;95m█\033[38;5;186m█\033[38;5;95m█\033[38;5;101m█\033[38;5;143m██\033[38;5;17m███████\033[38;5;249m█\033[38;5;102m█\033[38;5;17m████████████████████\033[38;5;136m██\033[38;5;95m█\033[38;5;17m████████\033[0m'
'\033[38;5;17m██\033[38;5;102m█\033[38;5;17m██████████\033[38;5;102m█\033[38;5;17m██████████\033[38;5;102m█\033[38;5;17m█████████\033[38;5;95m██\033[38;5;17m█\033[38;5;137m█\033[38;5;95m█\033[38;5;179m█\033[38;5;101m█\033[38;5;137m█\033[38;5;95m█\033[38;5;143m█\033[38;5;101m█\033[38;5;95m█\033[38;5;137m█\033[38;5;101m█\033[38;5;179m█\033[38;5;17m█\033[38;5;137m█\033[38;5;95m█\033[38;5;17m█\033[38;5;137m█\033[38;5;17m█\033[38;5;143m█\033[38;5;17m██\033[38;5;143m█\033[38;5;17m████████\033[38;5;102m█\033[38;5;17m█████████████████████████████\033[38;5;58m█\033[38;5;94m█\033[38;5;17m█\033[0m'
'\033[38;5;94m█\033[38;5;178m████\033[38;5;136m█\033[38;5;17m██\033[38;5;136m█\033[38;5;178m████\033[38;5;95m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m██\033[38;5;136m█\033[38;5;178m████\033[38;5;136m█\033[38;5;17m██\033[38;5;178m███\033[38;5;142m█\033[38;5;100m█\033[38;5;52m████\033[38;5;58m██\033[38;5;100m█\033[38;5;17m█\033[38;5;100m█\033[38;5;178m████\033[38;5;94m█\033[38;5;17m██\033[38;5;178m████\033[38;5;142m█\033[38;5;17m██\033[38;5;136m█\033[38;5;178m████\033[38;5;136m█\033[38;5;17m██\033[38;5;178m█████\033[38;5;136m██\033[38;5;17m██████████\033[38;5;136m█\033[38;5;17m█████\033[0m'
'\033[38;5;94m█\033[38;5;178m█████\033[38;5;17m██\033[38;5;178m█████\033[38;5;17m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;94m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m██\033[38;5;178m█████\033[38;5;136m█\033[38;5;17m██\033[38;5;178m██\033[38;5;100m█\033[38;5;58m█\033[38;5;52m█████████\033[38;5;94m█\033[38;5;178m████\033[38;5;136m█\033[38;5;17m█\033[38;5;94m█\033[38;5;178m█████\033[38;5;17m██\033[38;5;178m██████\033[38;5;17m██\033[38;5;178m███\033[38;5;136m██\033[38;5;178m██\033[38;5;136m█\033[38;5;17m██████\033[38;5;58m█\033[38;5;100m█\033[38;5;178m███\033[38;5;100m█\033[38;5;58m█\033[38;5;17m██\033[0m'
'\033[38;5;94m█\033[38;5;178m█████\033[38;5;94m█\033[38;5;100m█\033[38;5;178m█████\033[38;5;17m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;94m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m█\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;178m███\033[38;5;17m██\033[38;5;178m██\033[38;5;52m█████\033[38;5;95m██\033[38;5;137m█\033[38;5;180m██\033[38;5;95m█\033[38;5;52m█\033[38;5;100m█\033[38;5;178m████\033[38;5;17m█\033[38;5;136m█\033[38;5;178m█████\033[38;5;17m██\033[38;5;178m██\033[38;5;136m█\033[38;5;142m█\033[38;5;178m██\033[38;5;17m██\033[38;5;178m███\033[38;5;17m█\033[38;5;100m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m████████\033[38;5;94m█\033[38;5;178m█\033[38;5;17m█████\033[0m'
'\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;178m██\033[38;5;100m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;178m██\033[38;5;17m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;178m███████\033[38;5;142m█\033[38;5;17m█\033[38;5;100m█\033[38;5;178m██\033[38;5;100m█\033[38;5;136m█\033[38;5;178m██\033[38;5;17m██\033[38;5;178m██\033[38;5;58m█\033[38;5;16m█\033[38;5;58m█\033[38;5;94m█\033[38;5;95m█\033[38;5;137m█\033[38;5;138m█\033[38;5;137m██\033[38;5;180m█\033[38;5;181m█\033[38;5;95m█\033[38;5;58m█\033[38;5;178m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;178m███\033[38;5;17m█\033[38;5;100m█\033[38;5;178m██\033[38;5;136m██\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;100m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█████████\033[38;5;94m█\033[38;5;17m█████\033[0m'
'\033[38;5;94m█\033[38;5;178m██\033[38;5;136m██\033[38;5;178m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m██\033[38;5;178m██\033[38;5;95m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;178m███\033[38;5;100m█\033[38;5;136m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m██\033[38;5;136m█\033[38;5;52m█\033[38;5;95m████\033[38;5;174m█\033[38;5;180m█\033[38;5;137m█\033[38;5;180m█\033[38;5;223m█\033[38;5;138m█\033[38;5;137m█\033[38;5;179m█\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;178m███\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;100m██\033[38;5;178m██\033[38;5;100m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;100m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m███████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;94m█\033[38;5;178m████\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;101m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;94m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m█\033[38;5;178m███\033[38;5;136m██\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;178m██\033[38;5;136m█\033[38;5;95m██\033[38;5;137m██\033[38;5;131m█\033[38;5;137m█\033[38;5;180m██\033[38;5;174m█\033[38;5;223m█\033[38;5;180m██\033[38;5;179m█\033[38;5;94m█\033[38;5;136m█\033[38;5;178m████\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m██\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;100m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m███████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;178m████\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;100m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;94m█\033[38;5;178m██\033[38;5;142m█\033[38;5;17m█\033[38;5;178m███\033[38;5;136m█\033[38;5;142m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;137m██\033[38;5;95m██\033[38;5;137m█\033[38;5;180m████\033[38;5;137m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m███\033[38;5;136m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;178m███\033[38;5;136m██\033[38;5;178m███\033[38;5;17m█\033[38;5;178m███\033[38;5;100m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m███████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;17m██\033[38;5;136m█\033[38;5;178m████\033[38;5;136m█\033[38;5;58m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;94m█\033[38;5;178m██\033[38;5;142m█\033[38;5;94m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m██\033[38;5;178m███\033[38;5;17m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;100m█\033[38;5;178m█\033[38;5;95m█\033[38;5;137m█\033[38;5;180m█\033[38;5;181m██\033[38;5;180m█\033[38;5;217m█\033[38;5;137m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m█\033[38;5;178m███\033[38;5;17m██\033[38;5;178m███\033[38;5;17m█\033[38;5;178m██████\033[38;5;136m█\033[38;5;17m████████████████\033[0m'
'\033[38;5;17m█\033[38;5;100m█\033[38;5;136m█\033[38;5;100m████\033[38;5;17m██\033[38;5;94m█\033[38;5;100m██\033[38;5;17m█\033[38;5;94m█\033[38;5;100m███\033[38;5;136m██\033[38;5;94m█\033[38;5;17m█\033[38;5;100m██\033[38;5;94m█\033[38;5;17m█\033[38;5;100m███\033[38;5;17m██\033[38;5;94m█\033[38;5;100m████\033[38;5;94m█\033[38;5;17m██████████\033[38;5;52m█\033[38;5;131m█\033[38;5;95m█\033[38;5;137m█\033[38;5;180m█\033[38;5;137m█\033[38;5;180m█\033[38;5;223m█\033[38;5;138m█\033[38;5;17m█████████████████\033[38;5;95m████\033[38;5;17m████████████████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m███████\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m█████\033[38;5;136m█\033[38;5;100m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;178m███\033[38;5;17m██\033[38;5;178m█████\033[38;5;142m█\033[38;5;17m████████\033[38;5;52m██\033[38;5;95m█\033[38;5;137m████\033[38;5;131m█\033[38;5;137m█\033[38;5;180m█\033[38;5;223m█\033[38;5;180m█\033[38;5;95m█\033[38;5;17m███████████████████\033[38;5;95m█\033[38;5;137m█\033[38;5;17m██████████████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m███\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;100m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m███\033[38;5;100m█\033[38;5;178m██\033[38;5;136m██\033[38;5;178m██\033[38;5;100m█\033[38;5;17m██\033[38;5;178m██\033[38;5;136m█\033[38;5;178m███\033[38;5;17m██\033[38;5;52m████████\033[38;5;95m█\033[38;5;137m██\033[38;5;138m█\033[38;5;137m██\033[38;5;138m█\033[38;5;137m█\033[38;5;174m█\033[38;5;180m███\033[38;5;95m█\033[38;5;52m█\033[38;5;137m█\033[38;5;58m█\033[38;5;52m██\033[38;5;17m██████████████\033[38;5;137m█\033[38;5;17m█████████████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m███\033[38;5;100m█\033[38;5;178m███\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;142m█\033[38;5;136m██\033[38;5;94m█\033[38;5;100m█\033[38;5;178m██████\033[38;5;17m██\033[38;5;94m█\033[38;5;178m██\033[38;5;136m██\033[38;5;178m██\033[38;5;58m█\033[38;5;52m████\033[38;5;16m███\033[38;5;52m███\033[38;5;58m█\033[38;5;59m█\033[38;5;95m██\033[38;5;58m█\033[38;5;52m███\033[38;5;95m█\033[38;5;138m█\033[38;5;180m██\033[38;5;137m█\033[38;5;52m██\033[38;5;59m█\033[38;5;52m█\033[38;5;59m█\033[38;5;17m████████████\033[38;5;137m█\033[38;5;17m██████████████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m██████\033[38;5;136m█\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m█████\033[38;5;100m██\033[38;5;178m█████\033[38;5;136m█\033[38;5;17m██\033[38;5;100m█\033[38;5;178m██\033[38;5;100m█\033[38;5;136m█\033[38;5;178m█\033[38;5;136m█\033[38;5;52m██████████████\033[38;5;58m█\033[38;5;52m████\033[38;5;59m█\033[38;5;138m█\033[38;5;137m█\033[38;5;180m███\033[38;5;137m█\033[38;5;58m█\033[38;5;59m█\033[38;5;52m█\033[38;5;95m██\033[38;5;17m████████\033[38;5;101m█\033[38;5;137m█\033[38;5;17m███████████████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m███\033[38;5;17m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m███\033[38;5;100m█\033[38;5;178m██\033[38;5;136m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;17m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;100m█\033[38;5;178m█\033[38;5;58m█\033[38;5;52m██████████████\033[38;5;95m█\033[38;5;52m████\033[38;5;59m█\033[38;5;180m█\033[38;5;144m█\033[38;5;137m█\033[38;5;138m█\033[38;5;180m█\033[38;5;181m██\033[38;5;101m█\033[38;5;58m█\033[38;5;59m█\033[38;5;101m█\033[38;5;95m█\033[38;5;17m██████\033[38;5;137m█\033[38;5;95m█\033[38;5;17m████████████████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m███\033[38;5;17m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m███\033[38;5;100m█\033[38;5;178m██\033[38;5;136m█\033[38;5;100m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;178m██████\033[38;5;52m█████\033[38;5;95m█\033[38;5;59m█\033[38;5;95m███\033[38;5;52m█████\033[38;5;137m█\033[38;5;52m███████\033[38;5;58m█\033[38;5;137m██\033[38;5;180m██\033[38;5;181m██\033[38;5;101m█\033[38;5;58m█\033[38;5;59m██\033[38;5;17m███\033[38;5;101m█\033[38;5;95m█\033[38;5;17m█████\033[38;5;95m█\033[38;5;17m████████████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m███\033[38;5;17m█\033[38;5;142m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;94m█\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m███\033[38;5;100m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m█\033[38;5;178m███\033[38;5;100m█\033[38;5;178m███\033[38;5;17m██\033[38;5;178m█\033[38;5;52m███████████████\033[38;5;137m█\033[38;5;58m█\033[38;5;52m███████\033[38;5;58m█\033[38;5;137m██\033[38;5;180m███\033[38;5;223m█\033[38;5;181m█\033[38;5;138m█\033[38;5;59m█\033[38;5;95m█\033[38;5;101m█\033[38;5;95m█\033[38;5;17m████████████████████████████\033[0m'
'\033[38;5;17m█\033[38;5;100m███\033[38;5;17m█\033[38;5;100m███\033[38;5;17m█\033[38;5;94m█\033[38;5;100m██\033[38;5;17m█\033[38;5;94m█\033[38;5;100m██\033[38;5;94m█\033[38;5;17m████\033[38;5;100m██\033[38;5;94m█\033[38;5;17m█\033[38;5;94m█\033[38;5;100m█████\033[38;5;94m█\033[38;5;17m██\033[38;5;100m█\033[38;5;52m█\033[38;5;16m█\033[38;5;52m█████████████\033[38;5;180m█\033[38;5;101m█\033[38;5;52m████████\033[38;5;58m█\033[38;5;137m██\033[38;5;174m█\033[38;5;180m██\033[38;5;217m█\033[38;5;223m██\033[38;5;101m█\033[38;5;59m█\033[38;5;17m█████████████████████████████\033[0m'
'\033[38;5;94m█\033[38;5;178m██████\033[38;5;94m█\033[38;5;17m█████████\033[38;5;95m█\033[38;5;102m█\033[38;5;17m███████████████\033[38;5;59m█\033[38;5;52m█\033[38;5;16m██\033[38;5;52m███████████\033[38;5;101m█\033[38;5;222m█\033[38;5;180m█\033[38;5;58m█\033[38;5;52m██████\033[38;5;16m██\033[38;5;58m█\033[38;5;137m██\033[38;5;180m███\033[38;5;181m█\033[38;5;223m██\033[38;5;101m█\033[38;5;52m█\033[38;5;17m███████\033[38;5;95m█\033[38;5;17m████████████████████\033[0m'
'\033[38;5;17m█\033[38;5;100m██\033[38;5;136m█\033[38;5;178m███\033[38;5;17m███████████████████████████\033[38;5;52m███\033[38;5;16m█\033[38;5;52m█████\033[38;5;58m██\033[38;5;95m██\033[38;5;137m█\033[38;5;180m█\033[38;5;222m███\033[38;5;186m█\033[38;5;137m█\033[38;5;101m█\033[38;5;95m█\033[38;5;58m██\033[38;5;52m███\033[38;5;101m█\033[38;5;95m█\033[38;5;137m███\033[38;5;174m█\033[38;5;180m██\033[38;5;223m██\033[38;5;59m█\033[38;5;17m████████████████████████████\033[0m'
'\033[38;5;17m███\033[38;5;136m█\033[38;5;178m██\033[38;5;100m█\033[38;5;17m███████████████████████████\033[38;5;52m████\033[38;5;16m█\033[38;5;52m█████\033[38;5;58m██\033[38;5;95m█\033[38;5;101m█\033[38;5;144m█\033[38;5;222m███\033[38;5;180m█\033[38;5;137m█\033[38;5;95m██\033[38;5;58m█\033[38;5;59m█\033[38;5;95m███\033[38;5;101m█\033[38;5;17m███\033[38;5;95m█\033[38;5;137m██\033[38;5;180m█\033[38;5;181m██\033[38;5;101m█\033[38;5;17m████\033[38;5;95m█\033[38;5;17m███████████████████████\033[0m'
'\033[38;5;17m██\033[38;5;136m█\033[38;5;178m██\033[38;5;136m█\033[38;5;17m████████\033[38;5;101m█\033[38;5;17m███████████████████\033[38;5;52m████\033[38;5;16m█\033[38;5;52m██████████\033[38;5;101m█\033[38;5;222m█\033[38;5;180m█\033[38;5;58m█\033[38;5;52m█\033[38;5;95m████\033[38;5;52m███\033[38;5;180m█\033[38;5;95m█\033[38;5;17m████\033[38;5;95m█\033[38;5;101m█\033[38;5;137m█\033[38;5;95m█\033[38;5;17m████████\033[38;5;102m█\033[38;5;17m██████\033[38;5;102m█\033[38;5;17m██\033[38;5;102m█\033[38;5;17m██\033[38;5;102m█\033[38;5;17m███████\033[0m'
'\033[38;5;17m█\033[38;5;94m█\033[38;5;178m███\033[38;5;17m█████████████████████████████\033[38;5;95m███\033[38;5;52m█\033[38;5;16m█\033[38;5;52m██████████\033[38;5;59m█\033[38;5;180m█\033[38;5;137m█\033[38;5;95m██\033[38;5;58m█\033[38;5;59m███\033[38;5;95m█\033[38;5;101m█\033[38;5;180m█\033[38;5;222m█\033[38;5;186m█\033[38;5;137m█\033[38;5;95m█\033[38;5;17m███████████████████████████████████\033[0m'
'\033[38;5;17m█\033[38;5;178m███\033[38;5;94m█\033[38;5;17m████████████████████████████\033[38;5;95m█\033[38;5;138m██\033[38;5;137m█\033[38;5;95m█\033[38;5;52m███████\033[38;5;58m█\033[38;5;59m█\033[38;5;95m███\033[38;5;144m█\033[38;5;59m█\033[38;5;58m█\033[38;5;52m██\033[38;5;59m████\033[38;5;95m█\033[38;5;137m█\033[38;5;222m█\033[38;5;180m█\033[38;5;95m█\033[38;5;17m████████████████████████████████████\033[0m'
'\033[38;5;136m█\033[38;5;178m███\033[38;5;100m███\033[38;5;17m██████████████████████████\033[38;5;137m█\033[38;5;138m█\033[38;5;137m██\033[38;5;95m█\033[38;5;52m████\033[38;5;58m█\033[38;5;59m█\033[38;5;95m██\033[38;5;58m█\033[38;5;52m█\033[38;5;59m██\033[38;5;137m█\033[38;5;59m█\033[38;5;52m███\033[38;5;59m██████\033[38;5;144m█\033[38;5;17m██████████████████████████████████████\033[0m'
'\033[38;5;136m█\033[38;5;178m██████\033[38;5;17m█████████████████████████\033[38;5;95m█\033[38;5;174m█\033[38;5;180m█\033[38;5;138m█\033[38;5;101m█\033[38;5;59m█\033[38;5;58m█████\033[38;5;59m███\033[38;5;58m█\033[38;5;52m█\033[38;5;59m█\033[38;5;95m█\033[38;5;101m█\033[38;5;59m█\033[38;5;58m██\033[38;5;52m█\033[38;5;58m█\033[38;5;59m█████\033[38;5;101m█\033[38;5;17m██████████████████████████████████████\033[0m'
)
PORTRAIT_COLS=100
SPARK_CHARS=('✦' '✧' '★' '·' '⋆' '✷')
rand_sparkle() { echo "${SPARK_CHARS[$((RANDOM % ${#SPARK_CHARS[@]}))]}"; }

show_identity_portrait() {
  local rows=${#PORTRAIT_LINES[@]}
  local term_cols
  term_cols=$(tput cols 2>/dev/null || echo 0)

  echo
  sleep 0.2

  if (( term_cols > 0 && term_cols < PORTRAIT_COLS )); then
    echo -e "${YELLOW}⚠ Terminal lebar cuma ${term_cols} kolom, portrait butuh ${PORTRAIT_COLS} kolom.${RESET}"
    echo -e "${YELLOW}  Lebarin/maximize terminal dulu, atau kecilin font, biar gambar gak pecah.${RESET}"
    echo
    return
  fi

  local portrait_pad; portrait_pad=$(center_pad "$PORTRAIT_COLS")
  for ((y=0; y<rows; y++)); do
    printf '%s' "$portrait_pad"
    echo -e "${PORTRAIT_LINES[$y]}"
    if (( y < 8 )); then sleep 0.02; else sleep 0.01; fi
  done

  echo
  sleep 0.2

  # Blok identitas dirata-kirikan terhadap lebar teks TERPANJANG di blok ini,
  # lalu blok itu sendiri di-center. Hasilnya: kolom "Dosen/Prodi/Institusi"
  # tetap sejajar rapi, bukan tiap baris punya pusat sendiri (yang bikin acak).
  local id_name="MUHAMMAD RIFKA Z"
  local id_tagline="Builder. Designer. Learner."
  local id_sep="--------------------------------------------------"
  local id_l1="Dosen Pembimbing  : Muhaemin Sidiq, S.Pd., M.Pd."
  local id_l2="Program Studi     : Pendidikan Teknologi Informasi"
  local id_l3="Institusi         : Institut Pendidikan Indonesia"
  local id_max=0 id_line
  for id_line in "$id_name" "$id_tagline" "$id_sep" "$id_l1" "$id_l2" "$id_l3"; do
    (( ${#id_line} > id_max )) && id_max=${#id_line}
  done
  local id_pad; id_pad=$(center_pad "$id_max")

  printf '%s' "$id_pad"; echo -e "${BOLD}${GOLD_BRIGHT}${id_name}${RESET}"
  printf '%s' "$id_pad"; echo -e "${DIM}${WHITE}${id_tagline}${RESET}"
  printf '%s' "$id_pad"; echo -e "${GRAY}${id_sep}${RESET}"
  printf '%s' "$id_pad"; echo -e "${DIM}${WHITE}${id_l1}${RESET}"
  printf '%s' "$id_pad"; echo -e "${DIM}${WHITE}${id_l2}${RESET}"
  printf '%s' "$id_pad"; echo -e "${DIM}${WHITE}${id_l3}${RESET}"
  echo
  sleep 0.4
}

center_line() {
  # cetak 1 baris dengan padding kiri biar center sesuai lebar terminal.
  # display_len dikasih manual (bukan ${#text}) karena kalau locale terminal
  # bukan UTF-8, bash ngitung box-drawing chars per-byte (bukan per-karakter)
  # jadi hasilnya salah/kepanjangan dan padding jadi 0.
  local text="$1" display_len="$2" term_cols pad
  term_cols=$(tput cols 2>/dev/null || echo 133)
  (( term_cols <= 0 )) && term_cols=133
  pad=$(( (term_cols - display_len) / 2 ))
  (( pad < 0 )) && pad=0
  printf '%*s' "$pad" ''
  printf '%s\n' "$text"
}

clear
BANNER_LINES=(
  "███╗   ███╗ ██████╗███████╗ ██████╗ ███████╗"
  "████╗ ████║██╔════╝██╔════╝██╔═══██╗██╔════╝"
  "██╔████╔██║██║     ███████╗██║   ██║███████╗"
  "██║╚██╔╝██║██║     ╚════██║██║   ██║╚════██║"
  "██║ ╚═╝ ██║╚██████╗███████║╚██████╔╝███████║"
  "╚═╝     ╚═╝ ╚═════╝╚══════╝ ╚═════╝ ╚══════╝"
)
BANNER_DISPLAY_WIDTH=44
echo -e "${BOLD}${GOLD_BRIGHT}"
for line in "${BANNER_LINES[@]}"; do
  center_line "$line" "$BANNER_DISPLAY_WIDTH"
  sleep 0.03
done
echo -e "${RESET}"
center_line "MCSOS COMPLETE DEMO — M0 through M16" 36
sleep 0.3

# ---- Foto + identitas + dosen tampil di sini, SEBELUM cek M0-M16 ----
show_identity_portrait

section "M0"  "BASELINE & GOVERNANCE"           "check_env.sh jalan + smoke ELF64 + baseline docs";                  run_step "M0 baseline docs review" step_m0
section "M1"  "TOOLCHAIN REPRODUCIBLE"          "toolchain terdeteksi, proof ELF64, hash repro sama";                run_step "M1 toolchain check" step_m1
section "M2"  "BOOT IMAGE & KERNEL ELF64"       "kernel.elf higher-half, ISO boot, serial log M2";                   run_step "M2 preflight" step_m2   # TODO: masih FAIL, butuh grep tools/scripts/m2_preflight.sh utk fix presisi
section "M3"  "PANIC PATH & DEBUG WORKFLOW"     "build+panic+audit lulus, GDB breakpoint di kmain";                  run_step "M3 preflight" step_m3
section "M4"  "IDT & EXCEPTION HANDLING"        "IDT loaded, isr_stub_14 ada, nm -u kosong";                         run_step "M4 preflight" step_m4
section "M5"  "EXTERNAL INTERRUPT & TIMER"      "IDT 0-47, PIC remap 20/28, PIT 100Hz, tick jalan";                  run_step "M5 static check" step_m5
section "M6"  "PHYSICAL MEMORY MANAGER"         "PMM init/alloc/free lulus host test & static audit";                run_step "M6 static check" step_m6
section "M7"  "VIRTUAL MEMORY MANAGER"          "VMM build, invlpg & CR3 di disasm, page-fault log";                 run_step "M7 preflight" step_m7
section "M8"  "KERNEL HEAP"                     "heap allocator freestanding, nm -u kosong, log init";               run_step "M8 make all" step_m8
section "M9"  "KERNEL THREAD & SCHEDULER"       "scheduler+context switch, thread switch di log";                    run_step "M9 make all" step_m9   # TODO: masih FAIL (undefined reference mcs_fd_table_init), butuh cek Makefile linker
section "M10" "SYSCALL ABI AWAL"                "syscall dispatch, int80 stub+iretq, smoke test";                    run_step "M10 syscall review" step_m10
section "M11" "ELF64 USER LOADER"               "ELF64 loader lulus host test, symbol plan_load ada";                run_step "M11 make all" step_m11
section "M12" "SINKRONISASI KERNEL"             "sinkronisasi lock/atomik, nm bersih, QEMU smoke";                   run_step "M12 evidence review" step_m12
section "M13" "VFS MINIMAL & RAMFS"             "VFS/RAMFS/FD host test lulus, nm -u kosong";                        run_step "M13 host test" step_m13
section "M14" "BLOCK DEVICE LAYER"              "block device driver host test, ELF64 valid";                        run_step "M14 make all" step_m14
section "M15" "FILESYSTEM PERSISTENT (MCSFS1)"  "MCSFS1 host test, ELF64 valid, disasm+checksum";                    run_step "M15 make all" step_m15
section "M16" "CRASH CONSISTENCY (MCSFS1J)"     "journaling MCSFS1J tahan crash, recovery teruji";                   run_step "M16 preflight + host test" step_m16

echo
DONE_RULE="=========================================================="
DONE_TITLE="MCSOS M0-M16 DEMO COMPLETE"
echo -e "${BOLD}${GREEN}"
center_line "$DONE_RULE" "${#DONE_RULE}"
center_line "$DONE_TITLE" "${#DONE_TITLE}"
center_line "$DONE_RULE" "${#DONE_RULE}"
echo -e "${RESET}"

# ---- Rekap akhir: tabel ringkas semua milestone, biar gak perlu scroll ke atas ----
TABLE_WIDTH=57   # +------+----------------------------------+------------+
TABLE_PAD=$(center_pad "$TABLE_WIDTH")
echo
printf '%s' "$TABLE_PAD"; echo -e "${BOLD}${GOLD_BRIGHT}+------+----------------------------------+------------+${RESET}"
printf '%s' "$TABLE_PAD"; printf "${BOLD}${GOLD_BRIGHT}|${RESET} %-4s ${BOLD}${GOLD_BRIGHT}|${RESET} %-32s ${BOLD}${GOLD_BRIGHT}|${RESET} %-10s ${BOLD}${GOLD_BRIGHT}|${RESET}\n" "M#" "MILESTONE" "STATUS"
printf '%s' "$TABLE_PAD"; echo -e "${BOLD}${GOLD_BRIGHT}+------+----------------------------------+------------+${RESET}"
PASS_COUNT=0
FAIL_COUNT=0
for idx in "${!RESULT_NUM[@]}"; do
  num="${RESULT_NUM[$idx]}"
  title="${RESULT_TITLE[$idx]}"
  status="${RESULT_STATUS[$idx]}"
  printf '%s' "$TABLE_PAD"
  if [ "$status" = "PASS" ]; then
    PASS_COUNT=$((PASS_COUNT+1))
    printf "${BOLD}${GOLD_BRIGHT}|${RESET} %-4s ${BOLD}${GOLD_BRIGHT}|${RESET} %-32s ${BOLD}${GOLD_BRIGHT}|${RESET} ${GREEN}%-10s${RESET} ${BOLD}${GOLD_BRIGHT}|${RESET}\n" "$num" "${title:0:32}" "PASS"
  else
    FAIL_COUNT=$((FAIL_COUNT+1))
    printf "${BOLD}${GOLD_BRIGHT}|${RESET} %-4s ${BOLD}${GOLD_BRIGHT}|${RESET} %-32s ${BOLD}${GOLD_BRIGHT}|${RESET} ${RED}%-10s${RESET} ${BOLD}${GOLD_BRIGHT}|${RESET}\n" "$num" "${title:0:32}" "FAIL"
  fi
done
printf '%s' "$TABLE_PAD"; echo -e "${BOLD}${GOLD_BRIGHT}+------+----------------------------------+------------+${RESET}"
echo
if [ "$FAIL_COUNT" -eq 0 ]; then
  printf '%s' "$TABLE_PAD"; echo -e "${BOLD}${GREEN}Total: ${PASS_COUNT}/${TOTAL_STEPS} milestone PASS. Semua kriteria minimum lulus.${RESET}"
else
  printf '%s' "$TABLE_PAD"; echo -e "${BOLD}${YELLOW}Total: ${PASS_COUNT} PASS, ${FAIL_COUNT} FAIL dari ${TOTAL_STEPS} milestone.${RESET}"
  printf '%s' "$TABLE_PAD"; echo -e "${DIM}${WHITE}Milestone yang FAIL perlu di-debug ulang sebelum lanjut ke milestone berikutnya${RESET}"
  printf '%s' "$TABLE_PAD"; echo -e "${DIM}${WHITE}(cek prosedur rollback & failure analysis di OS_panduan_M<n>.md masing-masing).${RESET}"
fi
echo
