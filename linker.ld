OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

SECTIONS
{
    . = 1M;

    __kernel_start = .;

    .text : ALIGN(4K)
    {
        KEEP(*(.multiboot2))
    *(.text .text.*)
    *(.text .text.*)
    }

    .rodata : ALIGN(4K)
    {
        *(.rodata .rodata.*)
    }

    .data : ALIGN(4K)
    {
        *(.data .data.*)
    }

    .bss : ALIGN(4K)
    {
        *(COMMON)
        *(.bss .bss.*)

        . = ALIGN(16);

        __stack_bottom = .;
        . += 64K;
        __stack_top = .;
    }

    __kernel_end = .;
}
