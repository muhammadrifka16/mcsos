#include "pmm.h"
#include "io.h"
#include "serial.h"
#include "pic.h"
#include "pit.h"
#include "vmm.h"

#include <stdint.h>

#include <mcsos/arch/idt.h>
#include <mcsos/kernel/panic.h>

static struct pmm_state kernel_pmm;

static struct vmm_space kernel_space;

static uint64_t hhdm_offset =
    0xFFFF800000000000ULL;

static uint8_t kernel_pmm_bitmap[PMM_BITMAP_BYTES]
__attribute__((aligned(4096)));

static struct boot_mem_region test_regions[] = {
    { .base = 0x00000000ULL, .length = 0x0009f000ULL, .type = BOOT_MEM_USABLE },
    { .base = 0x0009f000ULL, .length = 0x00001000ULL, .type = BOOT_MEM_RESERVED },
    { .base = 0x00100000ULL, .length = 0x00300000ULL, .type = BOOT_MEM_USABLE },
    { .base = 0x00400000ULL, .length = 0x00100000ULL, .type = BOOT_MEM_KERNEL_AND_MODULES },
    { .base = 0x00500000ULL, .length = 0x00400000ULL, .type = BOOT_MEM_USABLE },
};

static void memzero(
    void *ptr,
    uint64_t size
)
{
    uint8_t *p =
        (uint8_t *)ptr;

    for (uint64_t i = 0; i < size; i++) {
        p[i] = 0;
    }
}

static uint64_t kernel_vmm_alloc(
    void *ctx
)
{
    (void)ctx;

    return pmm_alloc_frame(
        &kernel_pmm
    );
}

static void kernel_vmm_free(
    void *ctx,
    uint64_t frame_paddr
)
{
    (void)ctx;

    (void)pmm_free_frame(
        &kernel_pmm,
        frame_paddr
    );
}

static void *kernel_phys_to_virt(
    void *ctx,
    uint64_t paddr
)
{
    (void)ctx;

    return (void *)(uintptr_t)paddr;
}

static void kernel_memory_init(
    const struct boot_mem_region *regions,
    size_t region_count
)
{
    bool ok = pmm_init_from_map(
        &kernel_pmm,
        regions,
        region_count,
        kernel_pmm_bitmap,
        sizeof(kernel_pmm_bitmap),
        PMM_MAX_PHYS_BYTES
    );

    if (!ok) {
        kernel_panic_at(
            __FILE__,
            __LINE__,
            "pmm_init_from_map failed",
            0
        );
    }

    serial_write_string(
        "[m6] pmm initialized\n"
    );

    uint64_t frame_count =
        pmm_frame_count(
            &kernel_pmm
        );

    uint64_t free_count =
        pmm_free_count(
            &kernel_pmm
        );

    (void)frame_count;
    (void)free_count;

    uint64_t frame =
        pmm_alloc_frame(
            &kernel_pmm
        );

    if (frame == PMM_INVALID_FRAME) {
        kernel_panic_at(
            __FILE__,
            __LINE__,
            "pmm_alloc_frame failed",
            0
        );
    }

    serial_write_string(
        "[m6] frame allocated\n"
    );

    if (!pmm_free_frame(
            &kernel_pmm,
            frame
        )) {

        kernel_panic_at(
            __FILE__,
            __LINE__,
            "pmm_free_frame failed",
            0
        );
    }

    serial_write_string(
        "[m6] frame freed\n"
    );
}

void kmain(void)
{
    cpu_cli();

    serial_init();

    serial_write_string(
        "[MCSOS:M5] boot: external interrupt bring-up start\n"
    );

    x86_64_idt_init();

    serial_write_string(
        "[MCSOS:M5] idt: loaded\n"
    );

    pic_remap(
        0x20u,
        0x28u
    );

    pic_mask_all();

    pic_unmask_irq(
        0
    );

    serial_write_string(
        "[MCSOS:M5] pic: remapped, IRQ0 unmasked\n"
    );

    pit_configure_hz(
        100
    );

    serial_write_string(
        "[MCSOS:M5] pit: configured 100Hz\n"
    );

    kernel_memory_init(
        test_regions,
        sizeof(test_regions) /
        sizeof(test_regions[0])
    );

    uint64_t root =
        pmm_alloc_frame(
            &kernel_pmm
        );

    if (root == PMM_INVALID_FRAME) {

        kernel_panic_at(
            __FILE__,
            __LINE__,
            "M7: cannot allocate root page table",
            0
        );
    }

    void *root_virt =
        kernel_phys_to_virt(
            &hhdm_offset,
            root
        );

    if (root_virt == 0) {

        kernel_panic_at(
            __FILE__,
            __LINE__,
            "M7: invalid root virtual address",
            0
        );
    }

    memzero(
        root_virt,
        VMM_PAGE_SIZE
    );

    int rc =
        vmm_space_init(
            &kernel_space,
            root,
            &hhdm_offset,
            kernel_vmm_alloc,
            kernel_vmm_free,
            kernel_phys_to_virt
        );

    if (rc != VMM_MAP_OK) {

        kernel_panic_at(
            __FILE__,
            __LINE__,
            "M7: vmm_space_init failed",
            0
        );
    }

    serial_write_string(
        "M7: VMM core initialized\n"
    );

    serial_write_string(
        "[MCSOS:M5] sti: enabling interrupts\n"
    );

    cpu_sti();

    for (;;) {
        cpu_hlt();
    }
}
