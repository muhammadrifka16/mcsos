#include "pmm.h"
#include "io.h"
#include "serial.h"
#include "pic.h"
#include "pit.h"

#include <mcsos/arch/idt.h>
#include <mcsos/kernel/panic.h>

static struct pmm_state kernel_pmm;
static uint8_t kernel_pmm_bitmap[PMM_BITMAP_BYTES];

static struct boot_mem_region test_regions[] = {
    { .base = 0x00000000ULL, .length = 0x0009f000ULL, .type = BOOT_MEM_USABLE },
    { .base = 0x0009f000ULL, .length = 0x00001000ULL, .type = BOOT_MEM_RESERVED },
    { .base = 0x00100000ULL, .length = 0x00300000ULL, .type = BOOT_MEM_USABLE },
    { .base = 0x00400000ULL, .length = 0x00100000ULL, .type = BOOT_MEM_KERNEL_AND_MODULES },
    { .base = 0x00500000ULL, .length = 0x00400000ULL, .type = BOOT_MEM_USABLE },
};

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

    serial_write_string("[m6] pmm init start\n");

    bool ok = pmm_init_from_map(
        &kernel_pmm,
        test_regions,
        sizeof(test_regions) / sizeof(test_regions[0]),
        kernel_pmm_bitmap,
        sizeof(kernel_pmm_bitmap),
        PMM_MAX_PHYS_BYTES
    );

    if (!ok) {
        kernel_panic_at(__FILE__, __LINE__, "PMM INIT FAILED", 0);
    }

    serial_write_string("[m6] pmm initialized\n");

    uint64_t frame = pmm_alloc_frame(&kernel_pmm);

    if (frame == PMM_INVALID_FRAME) {
        kernel_panic_at(__FILE__, __LINE__, "PMM ALLOC FAILED", 0);
    }

    serial_write_string("[m6] frame allocated\n");

    if (!pmm_free_frame(&kernel_pmm, frame)) {
        kernel_panic_at(__FILE__, __LINE__, "PMM FREE FAILED", 0);
    }

    serial_write_string("[m6] frame freed\n");

    serial_write_string("[MCSOS:M5] sti: enabling interrupts\n");

    cpu_sti();

    for (;;) {
        cpu_hlt();
    }
}
