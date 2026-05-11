.RECIPEPREFIX := >

CC := clang
LD := ld.lld
OBJDUMP := llvm-objdump
READELF := readelf
NM := nm

CFLAGS := \
--target=x86_64-unknown-none-elf \
-std=c17 \
-ffreestanding \
-fno-builtin \
-fno-stack-protector \
-fno-stack-check \
-fno-pic \
-fno-pie \
-fno-lto \
-m64 \
-march=x86-64 \
-mabi=sysv \
-mno-red-zone \
-mno-mmx \
-mno-sse \
-mno-sse2 \
-mcmodel=kernel \
-Wall \
-Wextra \
-Werror \
-Ikernel/arch/x86_64/include \
-Ikernel/include \
-Iinclude

ASFLAGS := \
--target=x86_64-unknown-none-elf \
-ffreestanding \
-fno-pic \
-fno-pie \
-m64 \
-mno-red-zone \
-Wall \
-Wextra \
-Werror \
-Ikernel/arch/x86_64/include \
-Ikernel/include \
-Iinclude

LDFLAGS := \
-nostdlib \
-static \
-z max-page-size=0x1000 \
-T linker.ld

BUILD_DIR := build

SRCS_C := \
kernel/arch/x86_64/idt.c \
kernel/arch/x86_64/pic.c \
kernel/core/kmain.c \
kernel/core/log.c \
kernel/core/panic.c \
kernel/core/serial.c \
kernel/core/trap.c \
kernel/lib/memory.c \
src/pit.c \
src/pmm.c \
src/vmm.c

SRCS_S := \
kernel/arch/x86_64/isr.S \
kernel/boot/boot.S \
kernel/boot/multiboot2_header.S

OBJS := \
$(BUILD_DIR)/normal/kernel/arch/x86_64/idt.o \
$(BUILD_DIR)/normal/kernel/arch/x86_64/pic.o \
$(BUILD_DIR)/normal/kernel/core/kmain.o \
$(BUILD_DIR)/normal/kernel/core/log.o \
$(BUILD_DIR)/normal/kernel/core/panic.o \
$(BUILD_DIR)/normal/kernel/core/serial.o \
$(BUILD_DIR)/normal/kernel/core/trap.o \
$(BUILD_DIR)/normal/kernel/lib/memory.o \
$(BUILD_DIR)/normal/src/pit.o \
$(BUILD_DIR)/normal/src/pmm.o \
$(BUILD_DIR)/normal/src/vmm.o \
$(BUILD_DIR)/normal/kernel/arch/x86_64/isr.o \
$(BUILD_DIR)/normal/kernel/boot/boot.o \
$(BUILD_DIR)/normal/kernel/boot/multiboot2_header.o

all: $(BUILD_DIR)/kernel.elf

$(BUILD_DIR)/normal/kernel/arch/x86_64/idt.o: kernel/arch/x86_64/idt.c
>mkdir -p $(BUILD_DIR)/normal/kernel/arch/x86_64/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/arch/x86_64/pic.o: kernel/arch/x86_64/pic.c
>mkdir -p $(BUILD_DIR)/normal/kernel/arch/x86_64/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/core/kmain.o: kernel/core/kmain.c
>mkdir -p $(BUILD_DIR)/normal/kernel/core/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/core/log.o: kernel/core/log.c
>mkdir -p $(BUILD_DIR)/normal/kernel/core/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/core/panic.o: kernel/core/panic.c
>mkdir -p $(BUILD_DIR)/normal/kernel/core/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/core/serial.o: kernel/core/serial.c
>mkdir -p $(BUILD_DIR)/normal/kernel/core/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/core/trap.o: kernel/core/trap.c
>mkdir -p $(BUILD_DIR)/normal/kernel/core/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/lib/memory.o: kernel/lib/memory.c
>mkdir -p $(BUILD_DIR)/normal/kernel/lib/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/src/pit.o: src/pit.c
>mkdir -p $(BUILD_DIR)/normal/src/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/src/pmm.o: src/pmm.c
>mkdir -p $(BUILD_DIR)/normal/src/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/src/vmm.o: src/vmm.c
>mkdir -p $(BUILD_DIR)/normal/src/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/arch/x86_64/isr.o: kernel/arch/x86_64/isr.S
>mkdir -p $(BUILD_DIR)/normal/kernel/arch/x86_64/
>$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/boot/boot.o: kernel/boot/boot.S
>mkdir -p $(BUILD_DIR)/normal/kernel/boot/
>$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/boot/multiboot2_header.o: kernel/boot/multiboot2_header.S
>mkdir -p $(BUILD_DIR)/normal/kernel/boot/
>$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.elf: $(OBJS)
>mkdir -p $(BUILD_DIR)
>$(LD) $(LDFLAGS) -Map=$(BUILD_DIR)/kernel.map -o $@ $(OBJS)
>$(READELF) -h $@ > $(BUILD_DIR)/kernel.readelf.header.txt
>$(READELF) -l $@ > $(BUILD_DIR)/kernel.readelf.programs.txt
>$(NM) -n $@ > $(BUILD_DIR)/kernel.syms.txt
>$(OBJDUMP) -d -Mintel $@ > $(BUILD_DIR)/kernel.disasm.txt
>grep -q 'ELF64' $(BUILD_DIR)/kernel.readelf.header.txt
>grep -q 'Machine:[[:space:]]*Advanced Micro Devices X86-64' $(BUILD_DIR)/kernel.readelf.header.txt
>grep -q 'kmain' $(BUILD_DIR)/kernel.syms.txt
>grep -q 'x86_64_idt_init' $(BUILD_DIR)/kernel.syms.txt
>grep -q 'iretq' $(BUILD_DIR)/kernel.disasm.txt
>grep -q 'lidt' $(BUILD_DIR)/kernel.disasm.txt
>grep -q 'outb' $(BUILD_DIR)/kernel.disasm.txt
>grep -q 'hlt' $(BUILD_DIR)/kernel.disasm.txt

iso: $(BUILD_DIR)/kernel.elf
>mkdir -p $(BUILD_DIR)/iso/boot/grub
>cp $(BUILD_DIR)/kernel.elf $(BUILD_DIR)/iso/boot/kernel.elf
>cp iso/boot/grub/grub.cfg $(BUILD_DIR)/iso/boot/grub/grub.cfg
>grub-mkrescue -o $(BUILD_DIR)/mcsos.iso $(BUILD_DIR)/iso

run: iso
>qemu-system-x86_64 \
>-M q35 \
>-cdrom $(BUILD_DIR)/mcsos.iso \
>-serial stdio \
>-no-reboot \
>-no-shutdown

check: $(BUILD_DIR)/kernel.elf
>@echo "[CHECK] kernel build audit"
>file $(BUILD_DIR)/kernel.elf
>readelf -h $(BUILD_DIR)/kernel.elf
>nm -n $(BUILD_DIR)/kernel.elf | grep kmain

clean:
>rm -rf $(BUILD_DIR)

distclean: clean
>rm -rf iso_root limine evidence
