# Readiness Review M1 - Toolchain Reproducible

## Identitas

- Nama mahasiswa: Muhammad Rifka Z
- NIM: 25832072009
- Kelas: PTI 1A
- Dosen: Muhaemin Sidiq, S.Pd., M.Pd.
- Program Studi: Pendidikan Teknologi Informasi, Institut Pendidikan Indonesia
- Tanggal: 6 Mei 2026
- Commit hash: 1c6b4ae3cf50d3d62db15272e203234dcc1176c0

---

## Ringkasan hasil

Environment WSL2 Ubuntu 24.04 berhasil dikonfigurasi sebagai environment development reproducible untuk MCSOS. Seluruh toolchain utama berhasil diverifikasi, proof compile freestanding ELF64 x86_64 berhasil dibuat tanpa dependency libc host, reproducibility hash valid, serta QEMU dan OVMF berhasil terdeteksi. Semua acceptance criteria M1 terpenuhi sehingga environment dinyatakan siap untuk M2.

---

## Evidence checklist

| Evidence | Path | Status | Catatan |
|---|---|---|---|
| Toolchain versions | `build/meta/toolchain-versions.txt` | ✅ | Metadata toolchain tersedia |
| Host readiness | `build/meta/host-readiness.txt` | ✅ | CPU, RAM, kernel, path valid |
| QEMU capabilities | `build/meta/qemu-capabilities.txt` | ✅ | q35 dan OVMF tersedia |
| Freestanding object | `build/proof/freestanding_probe.o` | ✅ | ELF64 relocatable |
| Freestanding ELF | `build/proof/freestanding_probe.elf` | ✅ | ELF64 executable |
| ELF header | `build/proof/readelf-header.txt` | ✅ | Target x86_64 valid |
| ELF sections | `build/proof/readelf-sections.txt` | ✅ | Section ELF valid |
| Disassembly | `build/proof/objdump-disassembly.txt` | ✅ | Disassembly berhasil |
| Undefined symbol report | `build/proof/nm-undefined.txt` | ✅ | Tidak ada undefined symbol |
| Reproducibility hash | `build/repro/sha256-run1.txt`, `build/repro/sha256-run2.txt` | ✅ | Hash identik |

---

## Acceptance criteria M1

| Kriteria | Lulus/Gagal | Bukti |
|---|---|---|
| Repository berada di filesystem Linux WSL | ✅ | `/home/zazai16/src/mcsos` |
| Semua tool wajib tersedia | ✅ | `make check` berhasil |
| `make meta` berhasil | ✅ | Metadata berhasil dibuat |
| `make check` berhasil | ✅ | Semua tool tervalidasi |
| `make proof` berhasil | ✅ | ELF freestanding berhasil dibuat |
| `make qemu-probe` berhasil | ✅ | q35 dan OVMF valid |
| `make repro` berhasil | ✅ | Hash reproducible identik |
| `make test` berhasil dari clean checkout | ✅ | Full suite sukses |
| `nm-undefined.txt` kosong | ✅ | Tidak ada dependency libc |
| Hasil `readelf` menunjukkan ELF64 x86_64 | ✅ | Machine: AMD X86-64 |

---

## Known limitations

- Belum menggunakan cross compiler khusus `x86_64-elf-gcc`
- Belum memiliki CI/CD pipeline otomatis
- Belum tersedia bootable kernel image
- Belum dilakukan hardware boot test pada perangkat fisik
- Environment masih terbatas pada WSL2 dan QEMU
- Belum ada integration testing UEFI penuh

---

## Risiko dan mitigasi

| Risiko | Mitigasi |
|---|---|
| Repository berada di `/mnt/c` sehingga muncul issue permission dan performa | Repository ditempatkan di filesystem Linux WSL (`/home/...`) |
| Dependency libc host ikut terlink ke binary kernel | Menggunakan flag `-ffreestanding` dan `-nostdlib` |
| Build tidak reproducible antar environment | Menggunakan reproducibility hash validation (`sha256sum`) |
| Toolchain berbeda versi menyebabkan hasil ELF berubah | Metadata toolchain dicatat pada `toolchain-versions.txt` |
| QEMU atau OVMF tidak tersedia | Menjalankan validasi `make qemu-probe` |

---

## Readiness decision

- [ ] Belum siap lanjut M2.
- [ ] Siap lanjut M2 dengan catatan.
- [x] Siap lanjut M2.

### Alasan keputusan

Seluruh acceptance criteria utama M1 berhasil dipenuhi. Environment development reproducible berhasil dibangun menggunakan WSL2 Ubuntu 24.04, seluruh toolchain utama tervalidasi, proof compile freestanding ELF64 x86_64 berhasil dibuat tanpa dependency libc host, reproducibility hash menunjukkan hasil identik antar build, serta QEMU dan OVMF berhasil diverifikasi. Berdasarkan evidence tersebut, environment dinyatakan siap digunakan untuk tahap M2.
