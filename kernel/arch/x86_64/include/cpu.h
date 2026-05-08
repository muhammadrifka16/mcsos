#ifndef MCSOS_CPU_H
#define MCSOS_CPU_H

static inline void cpu_cli(void)
{
    __asm__ volatile ("cli");
}

static inline void cpu_hlt(void)
{
    __asm__ volatile ("hlt");
}

#endif
