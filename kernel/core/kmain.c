#include "io.h"
#include "serial.h"
#include "pic.h"
#include "pit.h"
#include <mcsos/arch/idt.h>

void kmain(void)
{
    cpu_cli();

    serial_init();
    serial_write_string("[MCSOS:M5] boot: external interrupt bring-up start\n");

    x86_64_idt_init();
    serial_write_string("[MCSOS:M5] idt: loaded\n");

    pic_remap(0x20u, 0x28u);
    pic_mask_all();
    pic_unmask_irq(0);
    serial_write_string("[MCSOS:M5] pic: remapped, IRQ0 unmasked\n");

    pit_configure_hz(100);
    serial_write_string("[MCSOS:M5] pit: configured 100Hz\n");

    serial_write_string("[MCSOS:M5] sti: enabling interrupts\n");
    cpu_sti();

    for (;;) {
        cpu_hlt();
    }
}
