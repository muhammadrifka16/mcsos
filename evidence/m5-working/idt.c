#include <stdint.h>

#include <mcsos/arch/idt.h>

extern void x86_64_breakpoint_stub(void);

__attribute__((aligned(16)))
static x86_64_idt_entry_t idt[256];

static x86_64_idtr_t idtr;

void x86_64_idt_set_gate(
	uint8_t vector,
	uint64_t handler,
	uint8_t type_attributes
)
{
	idt[vector].offset_low =
		(uint16_t)(handler & 0xFFFFu);

	idt[vector].selector =
		X86_64_KERNEL_CODE_SELECTOR;

	idt[vector].ist = 0u;

	idt[vector].type_attributes =
		type_attributes;

	idt[vector].offset_mid =
		(uint16_t)((handler >> 16u) & 0xFFFFu);

	idt[vector].offset_high =
		(uint32_t)((handler >> 32u) & 0xFFFFFFFFu);

	idt[vector].reserved = 0u;
}

void x86_64_idt_init(void)
{
	for (uint16_t i = 0u;
		 i < 256u;
		 ++i) {

		x86_64_idt_set_gate(
			(uint8_t)i,
			0u,
			0u
		);
	}

	x86_64_idt_set_gate(
		3u,
		(uint64_t)x86_64_breakpoint_stub,
		X86_64_IDT_GATE_TRAP
	);

	idtr.limit =
		(uint16_t)(sizeof(idt) - 1u);

	idtr.base =
		(uint64_t)&idt[0];

	__asm__ volatile (
		"lidt %0"
		:
		: "m"(idtr)
		: "memory"
	);
}

uint64_t x86_64_idt_base_for_test(void)
{
	return idtr.base;
}

uint16_t x86_64_idt_limit_for_test(void)
{
	return idtr.limit;
}

void x86_64_trigger_breakpoint_for_test(void)
{
	__asm__ volatile ("int3");
}
