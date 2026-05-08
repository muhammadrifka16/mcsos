#include <cpu.h>
#include <log.h>
#include <panic.h>

void serial_init(void);
void serial_write(const char *s);

void kmain(void) {
    serial_init();

    log_info("MCSOS 260502 M3 boot path entered");
    log_info("early serial online");
    log_info("kernel reached controlled halt loop");

    kernel_panic("intentional M3 panic path");
}
