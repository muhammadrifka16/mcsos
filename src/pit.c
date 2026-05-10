#include "pit.h"

static volatile uint64_t g_ticks = 0;

void pit_configure_hz(uint32_t hz)
{
    (void)hz;
}

void timer_on_irq0(void)
{
    ++g_ticks;
}
