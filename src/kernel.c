#include <stdint.h>

void kmain(void)
{
    volatile uint16_t *vga = (volatile uint16_t *)0xB8000;

    vga[0] = 0x0F4D; // M
    vga[1] = 0x0F35; // 5

    for (;;) {
        __asm__ volatile ("hlt");
    }
}
