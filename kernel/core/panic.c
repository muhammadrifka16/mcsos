#include <cpu.h>
#include <panic.h>
#include <log.h>

__attribute__((noreturn))
void kernel_panic(const char *message)
{
    log_panic(message);

    cpu_cli();

    for (;;) {
        cpu_hlt();
    }
}
