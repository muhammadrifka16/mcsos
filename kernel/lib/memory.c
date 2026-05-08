#include <stddef.h>

void *memset(void *dest, int value, size_t count)
{
    unsigned char *ptr = dest;

    while (count--) {
        *ptr++ = (unsigned char)value;
    }

    return dest;
}

void *memcpy(void *dest, const void *src, size_t count)
{
    unsigned char *d = dest;
    const unsigned char *s = src;

    while (count--) {
        *d++ = *s++;
    }

    return dest;
}

size_t strlen(const char *str)
{
    size_t len = 0;

    while (str[len]) {
        len++;
    }

    return len;
}
