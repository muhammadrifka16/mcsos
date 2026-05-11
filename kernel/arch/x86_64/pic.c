#include <mcsos/arch/pic.h>
#include <mcsos/arch/io.h>

static uint8_t pic1_mask;
static uint8_t pic2_mask;

void pic_send_eoi(uint8_t irq)
{
    if (irq >= 8u) {
        outb(PIC2_COMMAND, PIC_EOI);
    }

    outb(PIC1_COMMAND, PIC_EOI);
}

void pic_remap(uint8_t master_offset, uint8_t slave_offset)
{
    pic1_mask = inb(PIC1_DATA);
    pic2_mask = inb(PIC2_DATA);

    /* starts the initialization sequence */
    outb(PIC1_COMMAND, 0x11u);
    io_wait();

    outb(PIC2_COMMAND, 0x11u);
    io_wait();

    /* set vector offset */
    outb(PIC1_DATA, master_offset);
    io_wait();

    outb(PIC2_DATA, slave_offset);
    io_wait();

    /* setup cascading */
    outb(PIC1_DATA, 4u);
    io_wait();

    outb(PIC2_DATA, 2u);
    io_wait();

    /* environment info */
    outb(PIC1_DATA, 0x01u);
    io_wait();

    outb(PIC2_DATA, 0x01u);
    io_wait();

    /* restore masks */
    outb(PIC1_DATA, pic1_mask);
    outb(PIC2_DATA, pic2_mask);
}

void pic_mask_all(void)
{
    outb(PIC1_DATA, 0xFFu);
    outb(PIC2_DATA, 0xFFu);
}

void pic_unmask_irq(uint8_t irq)
{
    uint16_t port;
    uint8_t value;

    if (irq < 8u) {
        port = PIC1_DATA;
    } else {
        port = PIC2_DATA;
        irq -= 8u;
    }

    value = (uint8_t)(inb(port) & (uint8_t)~(1u << irq));

    outb(port, value);
}

uint8_t pic_read_master_mask(void)
{
    return inb(PIC1_DATA);
}

uint8_t pic_read_slave_mask(void)
{
    return inb(PIC2_DATA);
}
