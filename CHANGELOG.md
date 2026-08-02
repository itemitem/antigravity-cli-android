# Changelog

## v1.1.0 — 2026-08-02

### Perbaikan

- **`agy` tidak pernah bisa jalan** ("No such file or directory" padahal filenya ada): `agy` ternyata bukan binary Go statis seperti asumsi rilis pertama -- ini build cgo yang dinamis terhadap glibc (`/lib/ld-linux-aarch64.so.1` + `libc`/`libpthread`/`libdl`/`librt`/`libresolv`/`libm`). Bionic Android tidak punya dynamic linker glibc itu, jadi exec langsung selalu ENOENT. Fix: bundle loader + shared library glibc (dari Debian 12 arm64) di `system/bin/.antigravity-loader/`, launcher `antigravity` sekarang exec lewat loader itu (pola sama seperti loader musl di modul claude-code).
- **Pool tidak pernah ter-magic-mount** (`/system/bin/.antigravity-pool` tidak pernah muncul walau sudah reboot): direktori itu kosong di zip modul (git tidak melacak direktori kosong), dan mekanisme magic-mount kustom di beberapa device (`hybrid_mount`) diam-diam melewati direktori kosong saat snapshot boot. Fix: tambah placeholder `.gitkeep` supaya direktori benar-benar ada di dalam zip.

## v1.0.0 — 2026-08-01

Rilis pertama modul Google Antigravity CLI (`agy`) untuk Android.

### Fitur

- Modul KernelSU/Magisk/APatch untuk menjalankan Google Antigravity CLI di Android arm64
- Perintah `antigravity` dan `agy` tersedia secara global (root, adb, Termux)
- `antigravity-setup`: setup otomatis sekali jalan (idempoten)
- `antigravity-update`: mengunduh binary Go `linux_arm64` resmi dari Google dengan verifikasi SHA512 checksum
- `antigravity-mount`: bind ulang pool tanpa reboot
- `antigravity-whitelist`: cabut blokir domain Google Antigravity di adblocker hosts
- Integrasi Termux otomatis
