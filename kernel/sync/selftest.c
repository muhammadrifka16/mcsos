#include "mcs_sync.h"

#include <mcsos/kernel/panic.h>
#include "serial.h"

static mcs_spinlock_t boot_stats_lock;
static mcs_lockdep_state_t boot_lockdep;
static uint64_t boot_counter;

void m12_sync_selftest(void) {
    mcs_lockdep_init(&boot_lockdep);

    mcs_spin_init(
        &boot_stats_lock,
        10u,
        "boot_stats"
    );

    if (mcs_lockdep_before_acquire(
            &boot_lockdep,
            10u,
            "boot_stats") != MCS_SYNC_OK) {
        KERNEL_PANIC("M12 lockdep acquire failed", 0);
    }

    mcs_spin_lock(&boot_stats_lock);

    boot_counter++;

    mcs_spin_unlock(&boot_stats_lock);

    if (mcs_lockdep_after_release(
            &boot_lockdep,
            10u,
            "boot_stats") != MCS_SYNC_OK) {
        KERNEL_PANIC("M12 lockdep release failed", 0);
    }

    serial_write_string("[M12] sync selftest passed\n");
}
