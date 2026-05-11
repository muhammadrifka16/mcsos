.section .text
.global _start
.type _start, @function

.extern kmain
.extern __stack_top

_start:
    cli

    movq $__stack_top, %rsp
    andq $-16, %rsp

    movb $'X', %al
    movw $0xE9, %dx
    outb %al, %dx

    call kmain

1:
    hlt
    jmp 1b

.size _start, . - _start
