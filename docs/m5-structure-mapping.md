# M5 Repository Structure Mapping

Repository ini menggunakan struktur modular berbasis arsitektur x86_64.

## Mapping ke struktur referensi M5

| Struktur Referensi M5 | Struktur Repository |
|---|---|
| include/idt.h | kernel/arch/x86_64/include/mcsos/arch/idt.h |
| include/io.h | kernel/arch/x86_64/include/mcsos/arch/io.h |
| include/pic.h | kernel/arch/x86_64/include/mcsos/arch/pic.h |
| include/pit.h | include/pit.h |
| include/serial.h | include/serial.h |
| src/boot.S | kernel/boot/boot.S |
| src/interrupts.S | kernel/arch/x86_64/isr.S |
| src/idt.c | kernel/arch/x86_64/idt.c |
| src/pic.c | kernel/arch/x86_64/pic.c |
| src/kernel.c | kernel/core/kmain.c |
| src/panic.c | kernel/core/panic.c |
| src/serial.c | kernel/core/serial.c |
| src/pit.c | src/pit.c |

Repository mempertahankan struktur modular agar kompatibel dengan milestone sebelumnya (M0–M4) tanpa rewrite total.
