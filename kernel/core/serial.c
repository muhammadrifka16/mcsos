#include <stdint.h>

#define COM1 0x3F8

static inline void outb(uint16_t port, uint8_t value)
{
    __asm__ volatile (
        "outb %0, %1"
        :
        : "a"(value), "Nd"(port)
    );
}

static inline uint8_t inb(uint16_t port)
{
    uint8_t ret;

    __asm__ volatile (
        "inb %1, %0"
        : "=a"(ret)
        : "Nd"(port)
    );

    return ret;
}

void serial_init(void)
{
    outb(COM1 + 1, 0x00);

    outb(COM1 + 3, 0x80);

    outb(COM1 + 0, 0x03);
    outb(COM1 + 1, 0x00);

    outb(COM1 + 3, 0x03);

    outb(COM1 + 2, 0xC7);

    outb(COM1 + 4, 0x0B);
}

static int serial_transmit_ready(void)
{
    return inb(COM1 + 5) & 0x20;
}

void serial_write_char(char c)
{
    while (!serial_transmit_ready()) {
    }

    outb(COM1, (uint8_t)c);
}

void serial_write_string(const char *s)
{
    while (*s) {
        serial_write_char(*s++);
    }
}

void serial_write(const char *s)
{
    serial_write_string(s);
}
