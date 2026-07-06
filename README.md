# MCSOS — Educational x86_64 Operating System (v260502)

MCSOS adalah kernel sistem operasi **pendidikan** untuk mata kuliah **Sistem Operasi Lanjut**, dibangun bertahap dari lingkungan development sampai filesystem persistent dengan journaling. Dikerjakan sebagai rangkaian praktikum **M0 sampai M16**, tiap milestone menambah satu subsistem kernel di atas fondasi milestone sebelumnya.

> **Catatan status:** MCSOS adalah kernel edukasi. Tidak ada milestone di proyek ini yang mengklaim "bebas error", "siap produksi", atau "aman untuk hardware umum". Setiap tahap punya kriteria kelulusan sendiri (host unit test, audit ELF, smoke test QEMU).

## Informasi Akademik

| | |
|---|---|
| Mata kuliah | Sistem Operasi Lanjut / Praktikum Sistem Operasi |
| Dosen | Muhaemin Sidiq, S.Pd., M.Pd. |
| Program Studi | Pendidikan Teknologi Informasi |
| Institusi | Institut Pendidikan Indonesia |
| Versi proyek | MCSOS 260502 |

## Target & Lingkungan

| Aspek | Nilai |
|---|---|
| Arsitektur | x86_64 / AMD64 (long mode) |
| Model kernel | Monolitik pendidikan, boundary modular, subset POSIX-like |
| Bahasa | C17 freestanding + assembly x86_64 minimal |
| Host development | Windows 11 x64 dengan WSL 2 (Ubuntu/Debian-like) |
| Emulator | QEMU system emulation (x86_64) |
| Firmware | OVMF (UEFI) |
| Bootloader | Limine |
| Toolchain | Clang/LLD (target `x86_64-unknown-none-elf`), GNU Binutils / LLVM Binutils (`nm`, `readelf`, `objdump`) |

## Roadmap Milestone & Cara Verifikasi

Setiap milestone di bawah sudah **diverifikasi jalan langsung** di lingkungan pengembang (bukan asumsi dari nama file). Command tercantum adalah command yang benar-benar dites dan menghasilkan `PASS`.

| # | Judul | Ringkasan | Command verifikasi |
|---|---|---|---|
| **M0** | Baseline & Governance | Environment reproducible, struktur repo, risk register, verification matrix | Lihat `docs/reports/M0-laporan.md`, `docs/governance/risk_register.md` |
| **M1** | Toolchain Reproducible | Validasi toolchain (Clang, LLD, QEMU, OVMF, GDB) | `bash tools/scripts/check_toolchain.sh` |
| **M2** | Boot Image & Kernel ELF64 | Kernel ELF64 pertama, boot lewat Limine/OVMF, early serial console | `bash tools/scripts/m2_preflight.sh` |
| **M3** | Panic Path & Debug Workflow | Panic path terkontrol, linker map, disassembly audit, GDB workflow | `bash tools/scripts/m3_preflight.sh` |
| **M4** | IDT & Exception Handling | Interrupt Descriptor Table, trap frame, dispatcher exception | `bash tools/scripts/m4_preflight.sh` |
| **M5** | External Interrupt & Timer | Remap PIC 8259A, konfigurasi PIT 8254, tick timer | `bash scripts/check_m5_static.sh` → `[M5] static build and audit passed.` |
| **M6** | Physical Memory Manager | Bitmap frame allocator berbasis boot memory map | `bash scripts/check_m6_static.sh` → `[PASS] M6 static check selesai` |
| **M7** | Virtual Memory Manager | Page table 4-level x86_64, page fault diagnostics | `bash scripts/m7_preflight.sh` → `[PASS] M7 preflight selesai` |
| **M8** | Kernel Heap | First-fit free-list allocator dinamis | `make m8-all` |
| **M9** | Kernel Thread & Scheduler | Runqueue round-robin kooperatif, context switch x86_64 | `make m9-all` |
| **M10** | Syscall ABI Awal | Dispatcher syscall, validasi argumen, entry `int 0x80` | Lihat `docs/LAPORAN SISTEM OPERASI/laporan_praktikum_M10_MUHAMMAD RIFKA Z_25832072009.md` (audit `nm`/`readelf`/`objdump` lengkap), `logs/m10_preflight_qemu.log`, `logs/m10_serial.log` |
| **M11** | ELF64 User Loader | Parser ELF64, process image plan | `make m11-all` |
| **M12** | Sinkronisasi Kernel | Spinlock, mutex kooperatif, lock-order validator | `make -f Makefile.m12 CC=clang clean all` |
| **M13** | VFS Minimal & RAMFS | VFS, file descriptor table, RAMFS in-memory, syscall file I/O | `make -f Makefile.m13 m13-all` |
| **M14** | Block Device Layer | Block device registry, RAM block driver, buffer cache | `make m14-all` |
| **M15** | Filesystem Persistent (MCSFS1) | Superblock, inode/block bitmap, root directory, fsck-lite | `make m15-all` |
| **M16** | Crash Consistency (MCSFS1J) | Write-ahead journal, recovery, fault-injection test | `bash scripts/m16_preflight.sh && make -C tests/m16 clean all` |

### Catatan penting hasil verifikasi

- **Host test membutuhkan flag khusus.** Beberapa modul (mis. VMM di M7) punya jalur kode privileged (`invlpg`, akses `CR3`) yang di-guard dengan `#if !defined(MCSOS_HOST_TEST)`. Saat compile manual untuk host test, **wajib** tambahkan `-DMCSOS_HOST_TEST`, jika tidak host test akan segfault (bukan bug logic, tapi instruksi CPU privileged yang dijalankan di ring 3 userspace host).
- **`scripts/demo_m0_m16.sh`** — script demo lengkap M0-M16 dengan banner dan progress bar per milestone. Sempat memiliki label yang tidak sinkron di versi lama, tetapi sudah diperbaiki: setiap section sekarang menampilkan deskripsi cek yang sesuai milestone-nya masing-masing (dikonfirmasi ulang: 17/17 milestone PASS, label M5=timer/PIC/PIT, M8=kernel heap, dst., sesuai tabel roadmap di atas). Jalankan dengan `bash scripts/demo_m0_m16.sh` untuk demo visual lengkap.
- **`make meta`** bukan target Makefile. Metadata toolchain dikumpulkan lewat script terpisah: `bash tools/scripts/collect_meta.sh`, hasil di `build/meta/host-readiness.txt` dan `build/meta/toolchain-versions.txt`.
- Dua script sempat ditemukan out-of-sync dengan Makefile terbaru dan sudah diperbaiki: `scripts/check_m5_static.sh` (target `make grade` → `make check`) dan `scripts/m7_preflight.sh` (path `build/vmm.o` → `build/normal/src/vmm.o`).
- **M9 sempat melanggar scope resmi**: `mcsos_thread.c` sebelumnya extern-reference langsung ke `g_sched` (didefinisikan di `kmain.c`) dan menginisialisasi `fd_table` (fitur M13) di dalam `mcsos_thread_prepare()`, menyebabkan `nm -u` pada `m9_scheduler_combined.o` tidak kosong — melanggar kriteria wajib panduan M9. Sudah diperbaiki di commit `8a1f14b`: `fd_table` dihapus dari `mcsos_thread_t` (dead code, tidak pernah dibaca), dan `g_sched` di-encapsulate jadi `g_active_sched` file-local di `mcsos_thread.c` dengan setter `mcsos_sched_set_active()` yang dipanggil sekali dari `kmain.c`. `nm -u` sekarang kosong; full kernel relink diverifikasi ulang lewat `check_m5_static.sh` tanpa regresi.
- **M10 diverifikasi ulang manual**: repo tidak memiliki target `make m10-*` (Makefile utama hanya punya `m8/m9/m11/m14/m15`), tetapi panduan M10 mengizinkan validasi manual sebagai fallback. Reproduksi manual (`nm -u` object gabungan `syscall.o` + `syscall_entry.o`, `readelf -h`, `objdump -dr`) mengonfirmasi seluruh kriteria wajib: `nm -u` kosong, ELF64 x86_64, `x86_64_syscall_int80_stub` dan `iretq` ada pada disassembly. Detail lengkap ada di laporan M10.

## Build & Run (kernel utama)

```bash
make check   # build kernel + audit ELF/symbol/disassembly
make run     # build ISO dan jalankan di QEMU (interaktif)
make clean   # bersihkan build
```

Pre-commit hook otomatis menjalankan validasi environment M0 dan ShellCheck setiap `git commit`.

## Struktur Direktori Penting

| Folder | Isi |
|---|---|
| `kernel/` | Source kernel (arch, core, mm, vfs, block, sync, syscall, user, boot) |
| `src/` | PMM, VMM, PIT (linked langsung ke kernel utama) |
| `fs/mcsfs1/`, `kernel/fs/mcsfs1j/` | Filesystem persistent (M15) dan journaling (M16) |
| `tests/` | Host unit test per milestone |
| `scripts/`, `tools/scripts/` | Script preflight, audit, dan grading per milestone |
| `docs/` | Governance, readiness, requirements, security, arsitektur |
| `evidence/`, `artifacts/`, `logs/` | Bukti build/test/audit historis (lokasi bervariasi per milestone) |

## Disclaimer

Setiap klaim kelulusan milestone bersifat terbatas pada scope praktikum masing-masing (lihat dokumen panduan `OS_panduan_MX.md`). Validasi runtime QEMU/OVMF tetap perlu dijalankan ulang di lingkungan lokal karena bergantung pada versi toolchain, bootloader, dan konfigurasi host.
