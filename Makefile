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
-Iinclude \
-Iinclude/mcsos/user

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
kernel/mm/kmem.c \
kernel/mcsos_thread.c \
kernel/vfs/ramfs.c \
kernel/vfs/fd.c \
kernel/vfs/sys_vfs.c \
kernel/block/block.c \
kernel/block/ramblk.c \
kernel/block/bcache.c \
src/pit.c \
src/pmm.c \
src/vmm.c \
kernel/syscall/syscall.c \
kernel/user/m11_elf_loader.c \
kernel/user/m11_kernel_integration.c \
kernel/sync/lockdep.c \
kernel/sync/spinlock.c \
kernel/sync/mutex.c \
kernel/sync/selftest.c \

SRCS_S := \
kernel/arch/x86_64/isr.S \
kernel/boot/boot.S \
kernel/boot/multiboot2_header.S \
arch/x86_64/context_switch.S \
kernel/syscall/syscall_entry.S

OBJS := \
$(BUILD_DIR)/normal/kernel/arch/x86_64/idt.o \
$(BUILD_DIR)/normal/kernel/arch/x86_64/pic.o \
$(BUILD_DIR)/normal/kernel/core/kmain.o \
$(BUILD_DIR)/normal/kernel/core/log.o \
$(BUILD_DIR)/normal/kernel/core/panic.o \
$(BUILD_DIR)/normal/kernel/core/serial.o \
$(BUILD_DIR)/normal/kernel/core/trap.o \
$(BUILD_DIR)/normal/kernel/lib/memory.o \
$(BUILD_DIR)/normal/kernel/mm/kmem.o \
$(BUILD_DIR)/normal/kernel/mcsos_thread.o \
$(BUILD_DIR)/normal/kernel/vfs/ramfs.o \
$(BUILD_DIR)/normal/kernel/vfs/fd.o \
$(BUILD_DIR)/normal/kernel/vfs/sys_vfs.o \
$(BUILD_DIR)/normal/kernel/block/block.o \
$(BUILD_DIR)/normal/kernel/block/ramblk.o \
$(BUILD_DIR)/normal/kernel/block/bcache.o \
$(BUILD_DIR)/normal/src/pit.o \
$(BUILD_DIR)/normal/src/pmm.o \
$(BUILD_DIR)/normal/src/vmm.o \
$(BUILD_DIR)/normal/kernel/syscall/syscall.o \
$(BUILD_DIR)/normal/kernel/arch/x86_64/isr.o \
$(BUILD_DIR)/normal/kernel/boot/boot.o \
$(BUILD_DIR)/normal/kernel/boot/multiboot2_header.o \
$(BUILD_DIR)/normal/arch/x86_64/context_switch.o \
$(BUILD_DIR)/normal/kernel/syscall/syscall_entry.o \
$(BUILD_DIR)/normal/kernel/user/m11_elf_loader.o \
$(BUILD_DIR)/normal/kernel/user/m11_kernel_integration.o \
$(BUILD_DIR)/normal/kernel/sync/lockdep.o \
$(BUILD_DIR)/normal/kernel/sync/spinlock.o \
$(BUILD_DIR)/normal/kernel/sync/mutex.o \
$(BUILD_DIR)/normal/kernel/sync/selftest.o \

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

$(BUILD_DIR)/normal/kernel/mm/kmem.o: kernel/mm/kmem.c
>mkdir -p $(BUILD_DIR)/normal/kernel/mm/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/mcsos_thread.o: kernel/mcsos_thread.c
>mkdir -p $(BUILD_DIR)/normal/kernel/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/vfs/ramfs.o: kernel/vfs/ramfs.c
>mkdir -p $(BUILD_DIR)/normal/kernel/vfs/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/vfs/fd.o: kernel/vfs/fd.c
>mkdir -p $(BUILD_DIR)/normal/kernel/vfs/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/vfs/sys_vfs.o: kernel/vfs/sys_vfs.c
>mkdir -p $(BUILD_DIR)/normal/kernel/vfs/
>$(CC) $(CFLAGS) -c $< -o $@


$(BUILD_DIR)/normal/kernel/block/block.o: kernel/block/block.c
>mkdir -p $(BUILD_DIR)/normal/kernel/block/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/block/ramblk.o: kernel/block/ramblk.c
>mkdir -p $(BUILD_DIR)/normal/kernel/block/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/block/bcache.o: kernel/block/bcache.c
>mkdir -p $(BUILD_DIR)/normal/kernel/block/
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

$(BUILD_DIR)/normal/kernel/syscall/syscall.o: kernel/syscall/syscall.c
>mkdir -p $(BUILD_DIR)/normal/kernel/syscall/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/user/m11_elf_loader.o: kernel/user/m11_elf_loader.c
>mkdir -p $(BUILD_DIR)/normal/kernel/user/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/user/m11_kernel_integration.o: kernel/user/m11_kernel_integration.c
>mkdir -p $(BUILD_DIR)/normal/kernel/user/
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

$(BUILD_DIR)/normal/arch/x86_64/context_switch.o: arch/x86_64/context_switch.S
>mkdir -p $(BUILD_DIR)/normal/arch/x86_64/
>$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/syscall/syscall_entry.o: kernel/syscall/syscall_entry.S
>mkdir -p $(BUILD_DIR)/normal/kernel/syscall/
>$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/sync/lockdep.o: kernel/sync/lockdep.c
>mkdir -p $(BUILD_DIR)/normal/kernel/sync/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/sync/spinlock.o: kernel/sync/spinlock.c
>mkdir -p $(BUILD_DIR)/normal/kernel/sync/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/sync/mutex.o: kernel/sync/mutex.c
>mkdir -p $(BUILD_DIR)/normal/kernel/sync/
>$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/normal/kernel/sync/selftest.o: kernel/sync/selftest.c
>mkdir -p $(BUILD_DIR)/normal/kernel/sync/
>$(CC) $(CFLAGS) -c $< -o $@

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
>grub-mkrescue -o $(BUILD_DIR)/mcsos.iso $(BUILD_DIR)/iso --modules="multiboot2 normal iso9660 biosdisk"

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

# =========================
# M8 TARGETS
# =========================

CFLAGS_COMMON := -std=c17 -Wall -Wextra -Werror -Iinclude
CFLAGS_KERNEL_M8 := $(CFLAGS_COMMON) -ffreestanding -fno-builtin -fno-stack-protector -mno-red-zone
M8_BUILD_DIR := build/m8

.PHONY: m8-clean m8-kmem-host-test m8-kmem-freestanding m8-audit m8-all

m8-clean:
>$(RM) -r $(M8_BUILD_DIR)

$(M8_BUILD_DIR):
>mkdir -p $(M8_BUILD_DIR)

m8-kmem-freestanding: | $(M8_BUILD_DIR)
>$(CC) $(CFLAGS_KERNEL_M8) -c kernel/mm/kmem.c -o $(M8_BUILD_DIR)/kmem.freestanding.o

m8-kmem-host-test: | $(M8_BUILD_DIR)
>$(CC) $(CFLAGS_COMMON) tests/test_kmem.c kernel/mm/kmem.c -o $(M8_BUILD_DIR)/test_kmem
>./$(M8_BUILD_DIR)/test_kmem | tee $(M8_BUILD_DIR)/test_kmem.log

m8-audit: m8-kmem-freestanding
>nm -u $(M8_BUILD_DIR)/kmem.freestanding.o | tee $(M8_BUILD_DIR)/nm_u.txt
>test ! -s $(M8_BUILD_DIR)/nm_u.txt
>readelf -h $(M8_BUILD_DIR)/kmem.freestanding.o > $(M8_BUILD_DIR)/readelf_h.txt
>objdump -dr $(M8_BUILD_DIR)/kmem.freestanding.o > $(M8_BUILD_DIR)/kmem.objdump.txt

m8-all: m8-kmem-host-test m8-audit

# =========================
# M9 TARGETS
# =========================

M9_BUILD_DIR := build/m9

CFLAGS_HOST_M9 := \
-std=c17 \
-Wall \
-Wextra \
-Werror \
-DMCSOS_HOST_TEST \
-Iinclude

CFLAGS_KERNEL_M9 := \
-target x86_64-unknown-none-elf \
-std=c17 \
-ffreestanding \
-fno-stack-protector \
-fno-pic \
-mno-red-zone \
-Wall \
-Wextra \
-Werror \
-Iinclude

ASFLAGS_KERNEL_M9 := \
-target x86_64-unknown-none-elf \
-ffreestanding \
-fno-stack-protector \
-fno-pic \
-mno-red-zone

.PHONY: m9-all m9-host-test m9-freestanding m9-audit m9-clean

m9-all: m9-host-test m9-freestanding m9-audit

m9-clean:
>rm -rf $(M9_BUILD_DIR)

$(M9_BUILD_DIR):
>mkdir -p $(M9_BUILD_DIR)

m9-host-test: | $(M9_BUILD_DIR)
>$(CC) $(CFLAGS_HOST_M9) \
>tests/test_scheduler.c \
>kernel/mcsos_thread.c \
>-o $(M9_BUILD_DIR)/m9_host_test
>./$(M9_BUILD_DIR)/m9_host_test | tee $(M9_BUILD_DIR)/test_scheduler.log

m9-freestanding: | $(M9_BUILD_DIR)
>$(CC) $(CFLAGS_KERNEL_M9) \
>-c kernel/mcsos_thread.c \
>-o $(M9_BUILD_DIR)/mcsos_thread.freestanding.o

>$(CC) $(ASFLAGS_KERNEL_M9) \
>-c arch/x86_64/context_switch.S \
>-o $(M9_BUILD_DIR)/context_switch.o

>$(LD) -r \
>$(M9_BUILD_DIR)/mcsos_thread.freestanding.o \
>$(M9_BUILD_DIR)/context_switch.o \
>-o $(M9_BUILD_DIR)/m9_scheduler_combined.o

m9-audit: m9-freestanding
>$(NM) -u $(M9_BUILD_DIR)/m9_scheduler_combined.o | tee $(M9_BUILD_DIR)/nm_undefined.log

>$(READELF) -h $(M9_BUILD_DIR)/m9_scheduler_combined.o | tee $(M9_BUILD_DIR)/readelf_header.log

>$(OBJDUMP) -d $(M9_BUILD_DIR)/m9_scheduler_combined.o | \
>grep -E 'mcsos_context_switch|jmp|ret|hlt' | \
>tee $(M9_BUILD_DIR)/objdump_key.log

>sha256sum \
>$(M9_BUILD_DIR)/m9_host_test \
>$(M9_BUILD_DIR)/m9_scheduler_combined.o | \
>tee $(M9_BUILD_DIR)/sha256.log

# =========================
# M11 TARGETS
# =========================

M11_BUILD_DIR := build/m11

M11_HEADER   := include/mcsos/user/m11_elf_loader.h
M11_LOADER_C := kernel/user/m11_elf_loader.c
M11_TEST_C   := tests/m11/m11_host_test.c

CFLAGS_HOST_M11 := \
-DM11_HOST_TEST \
-std=c17 \
-Wall \
-Wextra \
-Werror \
-O2 \
-g \
-Iinclude/mcsos/user

CFLAGS_KERNEL_M11 := \
--target=x86_64-unknown-none-elf \
-std=c17 \
-Wall \
-Wextra \
-Werror \
-O2 \
-g \
-ffreestanding \
-fno-builtin \
-fno-stack-protector \
-fno-stack-check \
-fno-pic \
-fno-pie \
-mno-red-zone \
-m64 \
-march=x86-64 \
-mabi=sysv \
-Iinclude/mcsos/user

.PHONY: m11-all m11-host-test m11-freestanding m11-audit m11-clean

m11-all: m11-host-test m11-freestanding m11-audit

m11-clean:
>$(RM) -r $(M11_BUILD_DIR)

$(M11_BUILD_DIR):
>mkdir -p $(M11_BUILD_DIR)

m11-host-test: | $(M11_BUILD_DIR)
>$(CC) $(CFLAGS_HOST_M11) \
>$(M11_LOADER_C) \
>$(M11_TEST_C) \
>-o $(M11_BUILD_DIR)/m11_host_test

>./$(M11_BUILD_DIR)/m11_host_test \
>| tee $(M11_BUILD_DIR)/m11_host_test.log

m11-freestanding: | $(M11_BUILD_DIR)
>$(CC) $(CFLAGS_KERNEL_M11) \
>-c $(M11_LOADER_C) \
>-o $(M11_BUILD_DIR)/m11_elf_loader.o \
>2>&1 | tee $(M11_BUILD_DIR)/m11_freestanding.log

m11-audit: m11-freestanding
>$(NM) -u $(M11_BUILD_DIR)/m11_elf_loader.o \
>| tee $(M11_BUILD_DIR)/m11_nm_undefined.txt

>test ! -s $(M11_BUILD_DIR)/m11_nm_undefined.txt

>$(READELF) -h $(M11_BUILD_DIR)/m11_elf_loader.o \
>> $(M11_BUILD_DIR)/m11_readelf_header.txt

>$(OBJDUMP) -dr $(M11_BUILD_DIR)/m11_elf_loader.o \
>> $(M11_BUILD_DIR)/m11_objdump.txt

>sha256sum \
>$(M11_BUILD_DIR)/m11_elf_loader.o \
>$(M11_LOADER_C) \
>$(M11_HEADER) \
>$(M11_TEST_C) \
>> $(M11_BUILD_DIR)/m11_sha256.txt

>grep -q 'ELF64' \
>$(M11_BUILD_DIR)/m11_readelf_header.txt

>grep -q 'm11_elf64_plan_load' \
>$(M11_BUILD_DIR)/m11_objdump.txt

>@echo "[OK] M11 audit selesai"

>@cat $(M11_BUILD_DIR)/m11_sha256.txt


# =========================
# M14 TARGETS
# =========================

M14_BUILD_DIR := build/m14

M14_HEADER := include/mcsos/block.h

M14_SRC := \
kernel/block/block.c \
kernel/block/ramblk.c \
kernel/block/bcache.c

M14_TEST := tests/host/test_m14_block.c

CFLAGS_HOST_M14 := \
-std=c17 \
-Wall \
-Wextra \
-Werror \
-O2 \
-Iinclude

CFLAGS_KERNEL_M14 := \
--target=x86_64-unknown-none-elf \
-std=c17 \
-ffreestanding \
-fno-builtin \
-fno-stack-protector \
-fno-pic \
-mno-red-zone \
-Wall \
-Wextra \
-Werror \
-O2 \
-Iinclude

.PHONY: m14-all m14-host-test m14-freestanding m14-audit m14-clean

m14-all: m14-host-test m14-freestanding m14-audit

m14-clean:
>rm -rf $(M14_BUILD_DIR)

$(M14_BUILD_DIR):
>mkdir -p $(M14_BUILD_DIR)

m14-host-test: | $(M14_BUILD_DIR)
>$(CC) $(CFLAGS_HOST_M14) \
>$(M14_TEST) \
>$(M14_SRC) \
>-o $(M14_BUILD_DIR)/m14_host_test

>./$(M14_BUILD_DIR)/m14_host_test \
>| tee $(M14_BUILD_DIR)/m14_host_test.log

m14-freestanding: | $(M14_BUILD_DIR)
>$(CC) $(CFLAGS_KERNEL_M14) \
>-c kernel/block/block.c \
>-o $(M14_BUILD_DIR)/block.o

>$(CC) $(CFLAGS_KERNEL_M14) \
>-c kernel/block/ramblk.c \
>-o $(M14_BUILD_DIR)/ramblk.o

>$(CC) $(CFLAGS_KERNEL_M14) \
>-c kernel/block/bcache.c \
>-o $(M14_BUILD_DIR)/bcache.o

>$(LD) -r \
>$(M14_BUILD_DIR)/block.o \
>$(M14_BUILD_DIR)/ramblk.o \
>$(M14_BUILD_DIR)/bcache.o \
>-o $(M14_BUILD_DIR)/m14_block_layer.o

m14-audit: m14-freestanding
>$(NM) -u $(M14_BUILD_DIR)/m14_block_layer.o \
>| tee $(M14_BUILD_DIR)/m14_nm_undefined.txt

>test ! -s $(M14_BUILD_DIR)/m14_nm_undefined.txt

>$(READELF) -h $(M14_BUILD_DIR)/m14_block_layer.o \
>> $(M14_BUILD_DIR)/m14_readelf_block.txt

>$(OBJDUMP) -dr $(M14_BUILD_DIR)/m14_block_layer.o \
>> $(M14_BUILD_DIR)/m14_objdump_block.txt

>sha256sum \
>$(M14_BUILD_DIR)/block.o \
>$(M14_BUILD_DIR)/ramblk.o \
>$(M14_BUILD_DIR)/bcache.o \
>$(M14_BUILD_DIR)/m14_block_layer.o \
>> $(M14_BUILD_DIR)/m14_sha256.txt

>@echo "[OK] M14 audit selesai"


# ── M15 MCSFS1 ──────────────────────────────────────────────
HOST_CFLAGS_M15 := -std=c17 -Wall -Wextra -Werror -O2 -g
FREE_CFLAGS_M15 := -target x86_64-elf -std=c17 -ffreestanding \
                   -fno-builtin -fno-stack-protector -fno-pic \
                   -mno-red-zone -Wall -Wextra -Werror -O2 -g

.PHONY: m15-all

m15-all: artifacts/m15/test_mcsfs1 artifacts/m15/mcsfs1.o artifacts/m15/mcsfs1.rel.o
>./artifacts/m15/test_mcsfs1 | tee artifacts/m15/host_test.txt
>nm -u artifacts/m15/mcsfs1.rel.o | tee artifacts/m15/nm_undefined.txt
>test ! -s artifacts/m15/nm_undefined.txt
>readelf -h artifacts/m15/mcsfs1.rel.o | tee artifacts/m15/readelf_header.txt
>objdump -dr artifacts/m15/mcsfs1.rel.o | tee artifacts/m15/objdump.txt >/dev/null
>sha256sum artifacts/m15/* | tee artifacts/m15/SHA256SUMS.txt

artifacts/m15/test_mcsfs1: tests/m15/test_mcsfs1.c fs/mcsfs1/mcsfs1.c fs/mcsfs1/mcsfs1.h
>mkdir -p artifacts/m15
>$(CC) $(HOST_CFLAGS_M15) -I. tests/m15/test_mcsfs1.c fs/mcsfs1/mcsfs1.c -o $@

artifacts/m15/mcsfs1.o: fs/mcsfs1/mcsfs1.c fs/mcsfs1/mcsfs1.h
>mkdir -p artifacts/m15
>$(CC) $(FREE_CFLAGS_M15) -I. -c fs/mcsfs1/mcsfs1.c -o $@

artifacts/m15/mcsfs1.rel.o: artifacts/m15/mcsfs1.o
>ld -r $< -o $@
