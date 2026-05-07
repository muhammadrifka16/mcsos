# Readiness Review M2 - Boot Image dan Early Serial Console

## Identitas

- Proyek: MCSOS 260502
- Praktikum: M2
- Target: x86_64, QEMU, OVMF, Limine
- Nama: Muhammad Rifka Z
- Commit hash: 69c82e5a05316ae8b2d472e02094f4f60afe420e
- Tanggal: 2026-05-07

---

## Ringkasan Status

Status yang diajukan: siap uji QEMU tahap M2.

Alasan ringkas:

Kernel ELF64 berhasil dibangun menggunakan Clang dan LLD sebagai freestanding kernel x86_64. ISO bootable berhasil dibuat menggunakan Limine dan xorriso. QEMU berhasil menjalankan kernel melalui OVMF dan serial log memuat marker boot M2 secara lengkap.

---

## Evidence Matrix

| Evidence | Lokasi | Status | Catatan |
|---|---|---|---|
| Preflight M2 | `build/meta/m2-preflight.txt` | PASS | Semua tools terdeteksi |
| Kernel ELF | `build/kernel.elf` | PASS | ELF64 x86_64 |
| Kernel map | `build/kernel.map` | PASS | Symbol kernel valid |
| readelf header | `build/inspect/readelf-header.txt` | PASS | Entry point valid |
| readelf PHDR | `build/inspect/readelf-program-headers.txt` | PASS | Segment load valid |
| objdump | `build/inspect/objdump-disassembly.txt` | PASS | Disassembly tersedia |
| ISO | `build/mcsos.iso` | PASS | ISO bootable berhasil dibuat |
| ISO checksum | `build/mcsos.iso.sha256` | PASS | SHA256 valid |
| Serial log | `build/qemu-serial.log` | PASS | Marker M2 muncul |
| Git commit | `build/meta/m2-commit.txt` | PASS | Commit hash tersedia |

---

## Invariants yang Diperiksa

1. Kernel adalah ELF64 x86_64.
2. Entry point sesuai linker script.
3. Kernel tidak memakai hosted libc.
4. Source dikompilasi dengan `-ffreestanding` dan `-mno-red-zone`.
5. Serial console tersedia sebelum subsistem kompleks.
6. Kernel tidak kembali setelah `kmain`.
7. Output QEMU disimpan sebagai log file.

---

## Failure Modes yang Diuji atau Dianalisis

| Failure mode | Pernah terjadi? | Diagnosis | Perbaikan |
|---|---|---|---|
| Toolchain salah | Tidak | - | - |
| OVMF tidak ditemukan | Tidak | - | - |
| Limine gagal fetch | Ya | URL repository Limine salah | Mengganti URL menjadi `Limine-Bootloader` |
| ISO gagal dibuat | Tidak | - | - |
| QEMU log kosong | Tidak | - | - |
| Entry point salah | Tidak | - | - |
| Reboot loop | Tidak | - | - |
| CRLF script | Tidak | - | - |

---

## Keputusan Readiness

- [x] Lulus M2: siap uji QEMU tahap M2.
- [ ] Belum lulus M2: perlu perbaikan.

---

## Catatan Reviewer

Kernel berhasil boot melalui Limine pada QEMU/OVMF dan menghasilkan serial marker M2 sesuai acceptance criteria praktikum.
