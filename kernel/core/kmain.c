#include "pmm.h"
#include "io.h"
#include "serial.h"
#include "pic.h"
#include "pit.h"
#include "vmm.h"
#include "mcs_sync.h"
#include "mcsfs1.h"

#include <stdint.h>

#include <mcsos/arch/idt.h>
#include <mcsos/kernel/panic.h>
#include "mcsos/syscall.h"
#include <mcsos/kmem.h>
#include <kernel/user/m11_kernel_integration.h>
#include <mcsos/block.h>
#include <stdint.h>

#include "mcsos_thread.h"
#include "mcs_vfs.h"

static struct pmm_state kernel_pmm;

static struct vmm_space kernel_space;

static uint64_t hhdm_offset =
    0xFFFF800000000000ULL;

static uint8_t kernel_pmm_bitmap[PMM_BITMAP_BYTES]
__attribute__((aligned(4096)));

#define M8_BOOT_HEAP_SIZE (64u * 1024u)

static unsigned char
m8_boot_heap[M8_BOOT_HEAP_SIZE]
__attribute__((aligned(4096)));

/* =========================
 * M9 Scheduler Globals
 * ========================= */

 mcsos_scheduler_t g_sched;
static void mcsos_boot_sched_bind(void) { mcsos_sched_set_active(&g_sched); }

static mcsos_thread_t g_boot_thread;
static mcsos_thread_t g_thread_a;
static mcsos_thread_t g_thread_b;

static mcs_ramfs_t g_kernel_ramfs;

static unsigned char g_stack_a[8192]
__attribute__((aligned(16)));

static unsigned char g_stack_b[8192]
__attribute__((aligned(16)));

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

/* =========================
 * M9 Demo Threads
 * ========================= */

static void demo_thread_a(
    void *arg
)
{
    (void)arg;

    for (;;) {

        serial_write_string(
            "[M9] thread A tick\n"
        );

        mcsos_sched_yield(
            &g_sched
        );
    }
}

static void demo_thread_b(
    void *arg
)
{
    (void)arg;

    for (;;) {

        serial_write_string(
            "[M9] thread B tick\n"
        );

        mcsos_sched_yield(
            &g_sched
        );
    }
}

static void m8_heap_bootstrap(void)
{
    int rc =
        kmem_init(
            m8_boot_heap,
            sizeof(m8_boot_heap)
        );

    if (rc != 0) {

        kernel_panic_at(
            __FILE__,
            __LINE__,
            "M8: kmem_init failed",
            (uint64_t)rc
        );
    }

    void *probe =
        kmem_alloc(
            128
        );

    if (probe == 0) {

        kernel_panic_at(
            __FILE__,
            __LINE__,
            "M8: kmem_alloc probe failed",
            0
        );
    }

    rc =
        kmem_free_checked(
            probe
        );

    if (rc != 0) {

        kernel_panic_at(
            __FILE__,
            __LINE__,
            "M8: kmem_free_checked failed",
            (uint64_t)rc
        );
    }

    kmem_stats_t st;

    kmem_get_stats(
        &st
    );

    (void)st;

    serial_write_string(
        "[M8] kernel heap bootstrap initialized\n"
    );
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

static int64_t k_write_serial_bounded(const char *buf, size_t len) {
    for (size_t i = 0; i < len; ++i) serial_write_char(buf[i]);
    return (int64_t)len;
}
static uint64_t k_get_ticks(void) { return timer_ticks(); }
static void k_yield_current(void) { mcsos_sched_yield(&g_sched); }
static void k_exit_current(int code) {
    (void)code;
    serial_write_string("[M10] exit_thread called (stub)\n");
}
static void m10_syscall_smoke_direct(void) {
    int64_t r = mcsos_syscall_dispatch(MCSOS_SYS_PING, 0, 0, 0, 0, 0, 0);
    if (r != 0x2605020AL) {
        KERNEL_PANIC("M10 syscall ping failed", 0);
    }
    serial_write_string("[M10] syscall ping ok\n");
    int64_t t = mcsos_syscall_dispatch(MCSOS_SYS_GET_TICKS, 0, 0, 0, 0, 0, 0);
    if (t < 0) {
        serial_write_string("[M10] get_ticks returned EBUSY (timer not ready)\n");
    } else {
        serial_write_string("[M10] syscall get_ticks ok\n");
    }
    serial_write_string("[M10] syscall smoke done\n");
}
static uint8_t m15_smoke_disk[128][512];
static int m15_smoke_read(void *ctx, uint32_t lba, void *buf) {
    (void)ctx;
    if (lba >= 128u) return -1;
    __builtin_memcpy(buf, m15_smoke_disk[lba], 512);
    return 0;
}
static int m15_smoke_write(void *ctx, uint32_t lba, const void *buf) {
    (void)ctx;
    if (lba >= 128u) return -1;
    __builtin_memcpy(m15_smoke_disk[lba], buf, 512);
    return 0;
}
static int m15_smoke_flush(void *ctx) { (void)ctx; return 0; }
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

    m8_heap_bootstrap();

    m12_sync_selftest();

    /* =========================
     * M9 Scheduler Init
     * ========================= */

    mcsos_scheduler_init(
        &g_sched,
        &g_boot_thread
    );

    mcsos_boot_sched_bind();

    mcsos_thread_prepare(
        &g_thread_a,
        "demo-a",
        demo_thread_a,
        0,
        g_stack_a,
        sizeof(g_stack_a),
        g_sched.next_id++
    );

    mcsos_thread_prepare(
        &g_thread_b,
        "demo-b",
        demo_thread_b,
        0,
        g_stack_b,
        sizeof(g_stack_b),
        g_sched.next_id++
    );

    mcsos_sched_enqueue(
        &g_sched,
        &g_thread_a
    );

    mcsos_sched_enqueue(
        &g_sched,
        &g_thread_b
    );

    serial_write_string(
        "[M9] scheduler initialized\n"
    );

    {
        mcsos_syscall_ops_t m10_ops;

        m10_ops.get_ticks     = k_get_ticks;
        m10_ops.yield_current = k_yield_current;
        m10_ops.exit_current  = k_exit_current;
        m10_ops.write_serial  = k_write_serial_bounded;

        mcsos_syscall_init(
            &m10_ops
        );

        mcsos_syscall_set_user_region(
            (mcsos_user_region_t){
                0x0000000000400000ULL,
                0x0000800000000000ULL
            }
        );

        serial_write_string(
            "[M10] syscall dispatcher initialized\n"
        );
    }

    {
        extern void x86_64_syscall_int80_stub(void);

        x86_64_idt_set_gate(
            0x80,
            (uint64_t)x86_64_syscall_int80_stub,
            X86_64_IDT_GATE_INTERRUPT
        );

        serial_write_string(
            "[M10] IDT vector 0x80 installed\n"
        );
    }

    m10_syscall_smoke_direct();

    m11_kernel_integration_test();

    mcs_ramfs_init(
        &g_kernel_ramfs
    );

    mcs_ramfs_seed_file(
        &g_kernel_ramfs,
        "/hello.txt",
        (const uint8_t *)"hello-from-m13",
        15u
    );

    serial_write_string(
        "[M13] RAMFS initialized\n"
    );

    {
        mcs_fd_table_t table;
        char buf[16];
        int fd;

        mcs_fd_table_init(
            &table
        );

        fd = mcs_vfs_open(
            &table,
            &g_kernel_ramfs,
            "/hello.txt",
            MCS_O_RDONLY
        );

        if (fd >= 0) {

            mcs_vfs_read(
                &table,
                fd,
                buf,
                5u
            );

            mcs_vfs_close(
                &table,
                fd
            );

            serial_write_string(
                "[M13] VFS runtime selftest OK\n"
            );
        }
    }

    serial_write_string(
        "M7 ready for QEMU smoke test\n"
    );

    static uint8_t ramdisk_mem[512 * 16];

    static struct mcsos_blk_device ram0 = {
        .name = "ram0",
        .block_size = 512,
        .block_count = 16,
        .driver_data = ramdisk_mem,
    };

    mcsos_blk_register(
        &ram0
    );

    uint8_t tmp[512];

    mcsos_blk_read(
        &ram0,
        0,
        1,
        tmp
    );

    mcsos_blk_write(
        &ram0,
        0,
        1,
        tmp
    );
/* M15 MCSFS1 smoke test */
    {
        static struct mcsfs1_blkdev fs_dev;
        static struct mcsfs1_mount  fs_mnt;
        fs_dev.ctx = 0;
        fs_dev.block_count = 128u;
        fs_dev.read  = m15_smoke_read;
        fs_dev.write = m15_smoke_write;
        fs_dev.flush = m15_smoke_flush;
        int rc;
        rc = mcsfs1_format(&fs_dev);
        serial_write_string(rc == 0 ? "[M15] format: OK\n"  : "[M15] format: FAIL\n");
        rc = mcsfs1_mount(&fs_mnt, &fs_dev);
        serial_write_string(rc == 0 ? "[M15] mount: OK\n"   : "[M15] mount: FAIL\n");
        rc = mcsfs1_fsck(&fs_dev);
        serial_write_string(rc == 0 ? "[M15] fsck: OK\n"    : "[M15] fsck: FAIL\n");
        rc = mcsfs1_create(&fs_mnt, "smoke.txt");
        serial_write_string(rc == 0 ? "[M15] create: OK\n"  : "[M15] create: FAIL\n");
        const uint8_t pay[] = "MCSOS M15 smoke";
        rc = mcsfs1_write(&fs_mnt, "smoke.txt", pay, (uint32_t)sizeof(pay)-1u);
        serial_write_string(rc == 0 ? "[M15] write: OK\n"   : "[M15] write: FAIL\n");
        uint8_t rbuf[64]; uint32_t rlen = 0u;
        rc = mcsfs1_read(&fs_mnt, "smoke.txt", rbuf, sizeof(rbuf), &rlen);
        serial_write_string(rc == 0 ? "[M15] read: OK\n"    : "[M15] read: FAIL\n");
        rc = mcsfs1_unlink(&fs_mnt, "smoke.txt");
        serial_write_string(rc == 0 ? "[M15] unlink: OK\n"  : "[M15] unlink: FAIL\n");
        serial_write_string("[M15] smoke test selesai\n");
    }
    serial_write_string(
        "[MCSOS:M5] sti: enabling interrupts\n"
    );

    cpu_sti();

    mcsos_sched_yield(
        &g_sched
    );

    for (;;) {
        cpu_hlt();
    }
}
