#include <mcsos/arch/idt.h>

void kmain(void)
{
	volatile unsigned short *vga =
		(volatile unsigned short *)0xB8000;

	vga[0] = 0x0F42;

	x86_64_idt_init();

	vga[1] = 0x0F44;

	for (;;) {
		__asm__ volatile ("hlt");
	}
}
