#include <stdint.h>

#include <mcsos/arch/cpu.h>

#include <mcsos/kernel/log.h>
#include <mcsos/kernel/panic.h>
#include <mcsos/kernel/version.h>

extern uint8_t __kernel_start;
extern uint8_t __kernel_end;

static void m3_selftest(void)
{
    KERNEL_ASSERT(&__kernel_start != (uint8_t *)0);
    KERNEL_ASSERT(&__kernel_end != (uint8_t *)0);
    KERNEL_ASSERT(&__kernel_end >= &__kernel_start);

    log_writeln("[M3] selftest: basic invariants passed");
}

void kmain(void)
{
    uint64_t rflags;

    log_init();

    log_write(MCSOS_NAME);
    log_write(" ");
    log_write(MCSOS_VERSION);
    log_write(" ");
    log_write(MCSOS_MILESTONE);
    log_writeln(" kernel entered");

    log_key_value_hex64(
        "kernel_start",
        (uint64_t)(uintptr_t)&__kernel_start
    );

    log_key_value_hex64(
        "kernel_end",
        (uint64_t)(uintptr_t)&__kernel_end
    );

    rflags = cpu_read_rflags();

    log_key_value_hex64("rflags", rflags);

    m3_selftest();

    KERNEL_PANIC("intentional M3 panic path", 0xDEADBEEFu);
}
