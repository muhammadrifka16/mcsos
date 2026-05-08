#ifndef MCSOS_PANIC_H
#define MCSOS_PANIC_H

__attribute__((noreturn))
void kernel_panic(const char *message);

#endif
