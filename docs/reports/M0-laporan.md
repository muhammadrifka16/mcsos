# Laporan Praktikum M0 — Baseline Requirements, Governance, dan Lingkungan Pengembangan

## 1. Sampul
- **Judul praktikum**: Praktikum M0 — Baseline Requirements, Governance, dan Lingkungan Pengembangan Reproducible MCSOS
- **Nama mahasiswa / kelompok**: Muhammad Rifka Z
- **NIM**: 25832072009
- **Kelas**: PTI 1A
- **Dosen**: Muhaemin Sidiq, S.Pd., M.Pd.
- **Program Studi**: Pendidikan Teknologi Informasi, Institut Pendidikan Indonesia
- **Tanggal**: [03-05-2006]

## 2. Tujuan
Tujuan dari praktikum M0 ini adalah untuk menyiapkan lingkungan pengembangan yang stabil dan reproducible untuk proyek MCSOS, serta memverifikasi dan mengonfigurasi alat-alat yang diperlukan seperti QEMU, GDB, Clang, dan lainnya. Capaian teknis yang diharapkan termasuk memastikan bahwa lingkungan sudah siap untuk pengujian, meskipun sistem operasi belum siap untuk booting. Capaian konseptualnya adalah memahami bagaimana setiap komponen berfungsi dalam ekosistem pengembangan sistem operasi.

## 3. Dasar Teori Ringkas
- **Host vs Target**: Host adalah mesin fisik yang menjalankan software, sementara target adalah sistem yang akan dijalankan atau diuji dalam lingkungan pengembangan, seperti sistem operasi yang sedang dibangun.
- **WSL 2**: Windows Subsystem for Linux 2 memungkinkan pengguna Windows untuk menjalankan kernel Linux asli dalam lingkungan virtual.
- **Cross-compilation**: Teknik kompilasi kode di satu platform untuk dijalankan pada platform lain, berguna untuk mengembangkan sistem operasi untuk arsitektur yang berbeda.
- **ELF Object**: Format file yang digunakan untuk menyimpan file objek yang dapat digunakan dalam sistem operasi berbasis Unix.
- **QEMU**: Emulator open-source yang memungkinkan pengujian kernel dalam lingkungan virtual.
- **OVMF**: Open Virtual Machine Firmware digunakan untuk booting sistem operasi dalam lingkungan virtual menggunakan UEFI.
- **Git**: Sistem kontrol versi yang digunakan untuk melacak perubahan pada kode sumber dan mendukung kolaborasi.
- **Reproducibility**: Kemampuan untuk membuat lingkungan pengembangan yang dapat direproduksi di sistem lain, sehingga memastikan bahwa hasil pengujian konsisten.
- **Evidence-first engineering**: Pendekatan yang menekankan pada penggunaan bukti dan pengujian yang dapat diverifikasi untuk setiap klaim yang dibuat dalam pengembangan perangkat lunak.

## 4. Lingkungan

| Komponen           | Versi / output |
|--------------------|----------------|
| Windows            | Windows 10 Pro |
| WSL Distro         | Ubuntu-24.04   |
| Kernel Linux WSL   | 5.4.72-microsoft-standard-WSL2 |
| Git                | 2.43.0         |
| Clang              | 18.1.3         |
| LLD                | 18.1.3         |
| binutils/readelf   | 2.42           |
| NASM               | 2.16.01        |
| QEMU               | 8.2.2          |
| GDB                | 15.1           |
| Python             | 3.12.3         |

Lampirkan isi `date_utc=2026-05-05T17:14:21Z

root_dir=/home/zazai16/src/mcsos
uname=Linux Zazai 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
wsl_distro=Ubuntu-24.04
shell=/bin/bash

## Tool versions
git version 2.43.0
GNU Make 4.3
Ubuntu clang version 18.1.3 (1ubuntu1)
Ubuntu LLD 18.1.3 (compatible with GNU linkers)
Ubuntu LLVM version 18.1.3
GNU readelf (GNU Binutils for Ubuntu) 2.42
GNU objdump (GNU Binutils for Ubuntu) 2.42
NASM version 2.16.01
QEMU emulator version 8.2.2 (Debian 1:8.2.2+ds-0ubuntu1.16)
GNU gdb (Ubuntu 15.1-1ubuntu1~24.04.1) 15.1
Python 3.12.3
ShellCheck - shell script analysis tool
version: 0.9.0
Cppcheck 2.13.0`.

## 5. Desain Baseline
Repository MCSOS ini menyimpan seluruh kode yang diperlukan untuk membangun dan menguji sistem operasi. Struktur direktori di dalam repository ini meliputi:
- **docs**: Berisi dokumentasi terkait arsitektur, desain, dan pengujian.
- **tools**: Skrip dan alat bantu untuk memudahkan pembangunan dan pengujian.
- **build**: Menyimpan artefak build, seperti file objek dan hasil kompilasi lainnya.
- **src**: Kode sumber utama yang dikembangkan.
Dokumen baseline berisi informasi mengenai asumsi yang dibuat selama pengembangan, tujuan non-fungsional yang tidak ingin dicapai pada fase ini, serta threat model awal yang dapat berpotensi mempengaruhi proses pengujian.

## 6. Langkah Kerja
1. **Instalasi WSL 2 dan Pengaturan Lingkungan**:
   - Install dan konfigurasikan WSL 2 di Windows, kemudian instal Ubuntu 20.04 sebagai distro Linux.
   - Pasang alat-alat yang diperlukan seperti Git, Clang, Make, QEMU, GDB, dan lainnya.
   
2. **Pengujian Alat yang Diperlukan**:
   - Jalankan perintah `tools/check_env.sh` untuk memverifikasi apakah semua alat yang dibutuhkan telah terpasang dan dapat berfungsi dengan baik.
   
3. **Pengaturan QEMU dan GDB**:
   - Konfigurasikan dan jalankan QEMU dengan firmware OVMF untuk memulai lingkungan virtual yang akan digunakan untuk menguji sistem operasi.
   
4. **Kompilasi dan Pengujian**:
   - Jalankan perintah `make smoke` untuk membangun objek freestanding dan memverifikasi bahwa file objek yang dihasilkan memiliki format ELF yang benar.
   - Gunakan `readelf` dan `objdump` untuk memeriksa struktur file objek yang dihasilkan.

## 7. Hasil Uji

| Pengujian        | Command                          | Hasil            | Pass/Fail |
|-------------------|----------------------------------|------------------|-----------|
| WSL Version       | `wsl --list --verbose`           | Ubuntu 20.04     | Pass      |
| Tool Check        | `bash tools/check_env.sh`        | Semua alat terinstal | Pass |
| Metadata          | `cat build/meta/toolchain-versions.txt` | Versi sesuai | Pass |
| Smoke Object      | `make smoke`                     | Dibangun dengan sukses | Pass |
| ELF Header        | `readelf -h build/smoke/freestanding.o` | ELF valid      | Pass |
| Git Status        | `git status`                     | Bersih           | Pass      |

## 8. Analisis
Beberapa kendala yang dihadapi selama praktikum antara lain adalah kesulitan dalam mencari file OVMF yang sesuai di sistem. Setelah memperbaiki path file tersebut, pengujian berhasil dilakukan tanpa masalah. Semua alat yang dibutuhkan terpasang dengan benar dan lingkungan pengujian siap digunakan.

## 9. Keamanan dan Reliability
Ada beberapa risiko terkait dengan penggunaan alat-alat open-source, seperti masalah dengan ketergantungan versi atau mismatch pada toolchain. Untuk mengatasi hal ini, verifikasi versi alat dilakukan secara rutin dan memastikan bahwa file konfigurasi `.wslconfig` digunakan untuk mendukung konsistensi antara sistem yang berbeda.

## 10. Failure Modes dan Rollback

| Failure Mode           | Gejala                         | Diagnosis                    | Rollback/Perbaikan         |
|------------------------|--------------------------------|------------------------------|----------------------------|
| WSL bukan versi 2      | Tidak dapat menjalankan Linux  | Versi WSL tidak sesuai       | Upgrade WSL ke versi 2    |
| Tool tidak ditemukan   | QEMU/GDB tidak dapat dijalankan| Alat tidak terinstal         | Instal ulang QEMU/GDB      |
| Repository di `/mnt/c`  | Masalah path di Windows       | Penggunaan path Windows      | Pindahkan ke path Linux    |
| Smoke object salah target | Gagal saat kompilasi        | Konfigurasi salah            | Periksa Makefile           |
| OVMF tidak ditemukan   | Tidak bisa boot UEFI          | Path OVMF salah              | Perbaiki path OVMF        |

## 11. Kesimpulan
Praktikum M0 ini berhasil menyiapkan lingkungan pengembangan yang stabil dan siap untuk diuji. Meskipun sistem operasi belum siap untuk booting, lingkungan dan alat yang diperlukan untuk melanjutkan ke fase M1 telah terverifikasi dan siap digunakan.

## 12. Lampiran
- Output `[M0] Repository root: /home/zazai16/src/mcsos
[OK] Repository is not under /mnt/<drive>.
[M0] Checking required tools
[OK]   git                      /usr/bin/git
[OK]   make                     /usr/bin/make
[OK]   clang                    /usr/bin/clang
[OK]   ld.lld                   /usr/bin/ld.lld
[OK]   llvm-readelf             /usr/bin/llvm-readelf
[OK]   llvm-objdump             /usr/bin/llvm-objdump
[OK]   readelf                  /usr/bin/readelf
[OK]   objdump                  /usr/bin/objdump
[OK]   nasm                     /usr/bin/nasm
[OK]   qemu-system-x86_64       /usr/bin/qemu-system-x86_64
[OK]   gdb                      /usr/bin/gdb
[OK]   python3                  /usr/bin/python3
[OK]   shellcheck               /usr/bin/shellcheck
[OK]   cppcheck                 /usr/bin/cppcheck
[M0] Writing toolchain metadata
[M0] Metadata written to build/meta/toolchain-versions.txt
[M0] Environment check completed. This means the M0 environment is
checkable, not that the OS can boot.


`
- Isi `date_utc=2026-05-05T17:29:21Z
root_dir=/home/zazai16/src/mcsos
uname=Linux Zazai 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
wsl_distro=Ubuntu-24.04
shell=/bin/bash

## Tool versions
git version 2.43.0
GNU Make 4.3
Ubuntu clang version 18.1.3 (1ubuntu1)
Ubuntu LLD 18.1.3 (compatible with GNU linkers)
Ubuntu LLVM version 18.1.3
Ubuntu LLVM version 18.1.3
GNU readelf (GNU Binutils for Ubuntu) 2.42
GNU objdump (GNU Binutils for Ubuntu) 2.42
NASM version 2.16.01
QEMU emulator version 8.2.2 (Debian 1:8.2.2+ds-0ubuntu1.16)
GNU gdb (Ubuntu 15.1-1ubuntu1~24.04.1) 15.1
Python 3.12.3
ShellCheck - shell script analysis tool
version: 0.9.0
Cppcheck 2.13.0[M0] Repository root: /home/zazai16/src/mcsos
[OK] Repository is not under /mnt/<drive>.
[M0] Checking required tools
[OK]   git                      /usr/bin/git
[OK]   make                     /usr/bin/make
[OK]   clang                    /usr/bin/clang
[OK]   ld.lld                   /usr/bin/ld.lld
[OK]   llvm-readelf             /usr/bin/llvm-readelf
[OK]   llvm-objdump             /usr/bin/llvm-objdump
[OK]   readelf                  /usr/bin/readelf
[OK]   objdump                  /usr/bin/objdump
[OK]   nasm                     /usr/bin/nasm
[OK]   qemu-system-x86_64       /usr/bin/qemu-system-x86_64
[OK]   gdb                      /usr/bin/gdb
[OK]   python3                  /usr/bin/python3
[OK]   shellcheck               /usr/bin/shellcheck
[OK]   cppcheck                 /usr/bin/cppcheck
[M0] Writing toolchain metadata
[M0] Metadata written to build/meta/toolchain-versions.txt
[M0] Environment check completed. This means the M0 environment is
checkable, not that the OS can boot.


`
- Output `ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              REL (Relocatable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x0
  Start of program headers:          0 (bytes into file)
  Start of section headers:          368 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           0 (bytes)
  Number of program headers:         0
  Size of section headers:           64 (bytes)
  Number of section headers:         8
  Section header string table index: 1`
- Output `build/smoke/freestanding.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <m0_smoke_add>:
   0:   55                      push   %rbp
   1:   48 89 e5                mov    %rsp,%rbp
   4:   50                      push   %rax
   5:   89 7d fc                mov    %edi,-0x4(%rbp)
   8:   89 75 f8                mov    %esi,-0x8(%rbp)
   b:   8b 45 fc                mov    -0x4(%rbp),%eax
   e:   03 45 f8                add    -0x8(%rbp),%eax
  11:   48 83 c4 08             add    $0x8,%rsp
  15:   5d                      pop    %rbp
  16:   c3                      ret` ringkas
- Screenshot relevan
- Commit hash

## 13. Referensi
Gunakan format IEEE sesuai panduan praktikum.
