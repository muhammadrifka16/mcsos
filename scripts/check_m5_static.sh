#!/usr/bin/env bash
set -e

echo "[M5] checking symbols..."

nm -n build/kernel.elf | grep isr_stub_32
nm -n build/kernel.elf | grep pic_remap
nm -n build/kernel.elf | grep pit_configure_hz
nm -n build/kernel.elf | grep timer_on_irq0
nm -n build/kernel.elf | grep x86_64_trap_dispatch

echo "[M5] checking undefined symbols..."

! nm -u build/kernel.elf | grep .

echo "[M5] checking instructions..."

objdump -d build/kernel.elf | grep lidt
objdump -d build/kernel.elf | grep iretq
objdump -d build/kernel.elf | grep outb
objdump -d build/kernel.elf | grep sti
objdump -d build/kernel.elf | grep hlt

echo "[M5] PASS"

