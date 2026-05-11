#include <mcsos/kernel/log.h>

void serial_init(void);
void serial_write(const char *s);

void log_init(void)
{
    serial_init();
}

void log_putc(char c)
{
    char buffer[2];

    buffer[0] = c;
    buffer[1] = '\0';

    serial_write(buffer);
}

void log_write(const char *s)
{
    serial_write(s);
}

void log_writeln(const char *s)
{
    serial_write(s);
    serial_write("\n");
}

void log_hex64(uint64_t value)
{
    static const char hex[] = "0123456789ABCDEF";
    char buffer[17];
    int i;

    for (i = 0; i < 16; ++i) {
        buffer[15 - i] = hex[value & 0xFu];
        value >>= 4u;
    }

    buffer[16] = '\0';

    serial_write(buffer);
}

void log_key_value_hex64(const char *key, uint64_t value)
{
    log_write(key);
    log_write(": 0x");
    log_hex64(value);
    log_write("\n");
}
