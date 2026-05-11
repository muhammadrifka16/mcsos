/* Multiboot2 entry: 32-bit protected mode -> 64-bit long mode */

.section .bss
.align 4096
pml4_table:  .space 4096
pdpt_table:  .space 4096
pd_table:    .space 4096

.section .data
.align 16
gdt64:
    .quad 0x0000000000000000   /* null */
    .quad 0x00AF9A000000FFFF   /* code 64-bit */
    .quad 0x00CF92000000FFFF   /* data */
gdt64_ptr:
    .word gdt64_ptr - gdt64 - 1
    .long gdt64

.section .text
.code32
.global _start
.type _start, @function
_start:
    cli

    /* Zero page tables */
    movl $pml4_table, %edi
    movl $3*4096/4, %ecx
    xorl %eax, %eax
    rep stosl

    /* PML4[0] -> PDPT */
    movl $pdpt_table, %eax
    orl  $0x3, %eax
    movl %eax, pml4_table

    /* PDPT[0] -> PD */
    movl $pd_table, %eax
    orl  $0x3, %eax
    movl %eax, pdpt_table

    /* PD[0] -> 0MB–2MB (2MB huge page) */
    movl $0x000083, %eax
    movl %eax, pd_table

    /* PD[1] -> 2MB–4MB (covers kernel linked at 2MB) */
    movl $0x200083, %eax
    movl %eax, pd_table+8

    /* Load CR3 */
    movl $pml4_table, %eax
    movl %eax, %cr3

    /* Enable PAE */
    movl %cr4, %eax
    orl  $0x20, %eax
    movl %eax, %cr4

    /* Set EFER.LME */
    movl $0xC0000080, %ecx
    rdmsr
    orl  $0x100, %eax
    wrmsr

    /* Enable paging */
    movl %cr0, %eax
    orl  $0x80000001, %eax
    movl %eax, %cr0

    /* Load GDT 64-bit kita */
    lgdtl gdt64_ptr

    /* Far jump -> flush pipeline, masuk 64-bit */
    ljmp $0x08, $_start64

.code64
_start64:
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    xorw %ax, %ax
    movw %ax, %fs
    movw %ax, %gs

    leaq __stack_top(%rip), %rsp
    andq $-16, %rsp
    xorq %rbp, %rbp

    call kmain

.Lhalt:
    hlt
    jmp .Lhalt

.size _start, . - _start
