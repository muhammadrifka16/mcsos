#include <mcsos/arch/cpu.h>

void serial_init(void);
void serial_write(const char *s);

void kmain(void)
{
    __asm__ volatile (
        "movb $'K', %%al\n\t"
        "movw $0xE9, %%dx\n\t"
        "outb %%al, %%dx\n\t"
        :
        :
        : "al", "dx"
    );

    serial_init();

    serial_write("[M5] serial ok\n");

    for (;;) {
        cpu_hlt();
    }
}
