#include <log.h>

void serial_write(const char *s);

void log_info(const char *message)
{
    serial_write("[INFO] ");
    serial_write(message);
    serial_write("\n");
}

void log_panic(const char *message)
{
    serial_write("[PANIC] ");
    serial_write(message);
    serial_write("\n");
}
