#include <stdint.h>
#include <mcsos/arch/idt.h>

/* Deklarasi semua stub dari isr.S */
#define DECLARE_ISR(n) extern void isr_stub_##n(void);
DECLARE_ISR(0)  DECLARE_ISR(1)  DECLARE_ISR(2)  DECLARE_ISR(3)
DECLARE_ISR(4)  DECLARE_ISR(5)  DECLARE_ISR(6)  DECLARE_ISR(7)
DECLARE_ISR(8)  DECLARE_ISR(9)  DECLARE_ISR(10) DECLARE_ISR(11)
DECLARE_ISR(12) DECLARE_ISR(13) DECLARE_ISR(14) DECLARE_ISR(15)
DECLARE_ISR(16) DECLARE_ISR(17) DECLARE_ISR(18) DECLARE_ISR(19)
DECLARE_ISR(20) DECLARE_ISR(21) DECLARE_ISR(22) DECLARE_ISR(23)
DECLARE_ISR(24) DECLARE_ISR(25) DECLARE_ISR(26) DECLARE_ISR(27)
DECLARE_ISR(28) DECLARE_ISR(29) DECLARE_ISR(30) DECLARE_ISR(31)
DECLARE_ISR(32) DECLARE_ISR(33) DECLARE_ISR(34) DECLARE_ISR(35)
DECLARE_ISR(36) DECLARE_ISR(37) DECLARE_ISR(38) DECLARE_ISR(39)
DECLARE_ISR(40) DECLARE_ISR(41) DECLARE_ISR(42) DECLARE_ISR(43)
DECLARE_ISR(44) DECLARE_ISR(45) DECLARE_ISR(46) DECLARE_ISR(47)

__attribute__((aligned(16)))
static x86_64_idt_entry_t idt[256];
static x86_64_idtr_t idtr;

void x86_64_idt_set_gate(uint8_t vector, uint64_t handler,
                          uint8_t type_attributes)
{
    idt[vector].offset_low      = (uint16_t)(handler & 0xFFFFu);
    idt[vector].selector        = X86_64_KERNEL_CODE_SELECTOR;
    idt[vector].ist             = 0u;
    idt[vector].type_attributes = type_attributes;
    idt[vector].offset_mid      = (uint16_t)((handler >> 16u) & 0xFFFFu);
    idt[vector].offset_high     = (uint32_t)((handler >> 32u) & 0xFFFFFFFFu);
    idt[vector].reserved        = 0u;
}

void x86_64_idt_init(void)
{
    static void (*stubs[48])(void) = {
        isr_stub_0,  isr_stub_1,  isr_stub_2,  isr_stub_3,
        isr_stub_4,  isr_stub_5,  isr_stub_6,  isr_stub_7,
        isr_stub_8,  isr_stub_9,  isr_stub_10, isr_stub_11,
        isr_stub_12, isr_stub_13, isr_stub_14, isr_stub_15,
        isr_stub_16, isr_stub_17, isr_stub_18, isr_stub_19,
        isr_stub_20, isr_stub_21, isr_stub_22, isr_stub_23,
        isr_stub_24, isr_stub_25, isr_stub_26, isr_stub_27,
        isr_stub_28, isr_stub_29, isr_stub_30, isr_stub_31,
        isr_stub_32, isr_stub_33, isr_stub_34, isr_stub_35,
        isr_stub_36, isr_stub_37, isr_stub_38, isr_stub_39,
        isr_stub_40, isr_stub_41, isr_stub_42, isr_stub_43,
        isr_stub_44, isr_stub_45, isr_stub_46, isr_stub_47,
    };

    for (uint16_t i = 0u; i < 256u; ++i) {
        x86_64_idt_set_gate((uint8_t)i, 0u, 0u);
    }

    for (uint8_t i = 0u; i < 48u; ++i) {
        uint8_t attr = (i < 32u)
            ? X86_64_IDT_GATE_TRAP
            : X86_64_IDT_GATE_INTERRUPT;
        x86_64_idt_set_gate(i, (uint64_t)stubs[i], attr);
    }

    idtr.limit = (uint16_t)(sizeof(idt) - 1u);
    idtr.base  = (uint64_t)&idt[0];
    __asm__ volatile ("lidt %0" :: "m"(idtr) : "memory");
}

uint64_t x86_64_idt_base_for_test(void)  { return idtr.base; }
uint16_t x86_64_idt_limit_for_test(void) { return idtr.limit; }
void x86_64_trigger_breakpoint_for_test(void) { __asm__ volatile ("int3"); }
