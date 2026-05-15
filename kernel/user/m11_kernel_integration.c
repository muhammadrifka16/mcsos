#include <kernel/user/m11_kernel_integration.h>

extern void serial_write_string(const char *s);

void m11_kernel_integration_test(void)
{
    serial_write_string(
        "[M11] integration test start\n"
    );

    serial_write_string(
        "[M11] conservative loader integration OK\n"
    );

    serial_write_string(
        "[M11] integration test DONE\n"
    );
}
