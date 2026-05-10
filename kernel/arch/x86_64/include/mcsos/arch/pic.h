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
#define PIC_MASTER_OFFSET 0x20u
#define PIC_SLAVE_OFFSET  0x28u

void pic_remap(uint8_t master_offset, uint8_t slave_offset);
void pic_send_eoi(uint8_t irq);

void pic_mask_all(void);
void pic_unmask_irq(uint8_t irq);

uint8_t pic_read_master_mask(void);
uint8_t pic_read_slave_mask(void);

#endif
