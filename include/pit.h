#ifndef MCSOS_PIT_H
#define MCSOS_PIT_H

#include <stdint.h>

void pit_configure_hz(uint32_t hz);
void timer_on_irq0(void);

#endif
