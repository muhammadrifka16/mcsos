.section .text.boot

.global _start
.type _start, @function

.extern kmain
.extern __stack_top

_start:
    cli

    mov $__stack_top, %rsp
    mov %rsp, %rbp

    call kmain

1:
    hlt
    jmp 1b
