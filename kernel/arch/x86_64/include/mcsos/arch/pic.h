#ifndef MCSOS_ARCH_PIC_H
#define MCSOS_ARCH_PIC_H

#include <stdint.h>

/* PIC I/O ports */
#define PIC1_COMMAND 0x20
#define PIC1_DATA    0x21

#define PIC2_COMMAND 0xA0
#define PIC2_DATA    0xA1

/* PIC commands */
#define PIC_EOI      0x20

/* IRQ vector offsets */
#define PIC1_OFFSET  0x20
#define PIC2_OFFSET  0x28

void pic_remap(int offset1, int offset2);
void pic_send_eoi(unsigned char irq);
void pic_mask_all(void);
void pic_unmask_irq(uint8_t irq);

#endif
