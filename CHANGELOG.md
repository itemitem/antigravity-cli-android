# Changelog

## v1.2.1 — 2026-08-02

### Perbaikan

- **`antigravity-update` selalu error "No such file or directory" di langkah verifikasi binary**, meski instalasinya tetap berhasil (harmless, tidak `die`, jadi tidak ketahuan sampai diuji langsung di device): langkah itu meng-exec binary hasil unduhan (`$BIN --version`) langsung di bionic sebelum dipindah ke pool, padahal binary itu glibc-linked (cgo) dan harus lewat loader yang dibundel -- persis bug yang sama seperti kenapa `antigravity`/`agy` sendiri butuh loader. Fix: verifikasi dilakukan setelah binary dipindah ke `$POOL/agy`, lewat loader glibc, sama seperti launcher `antigravity`. Ditemukan & diperbaiki saat uji-pasang end-to-end modul v1.2.0 di device.

## v1.2.0 — 2026-08-02

### Perubahan besar: modul tanpa mount

- **Bootloop MIUI berulang** (`--reason=set_policy_failed:/data/extm`) terjadi lagi setelah v1.1.0 di-reboot, meski MIUI Memory Extension sudah dimatikan (`persist.miui.extm.enable=0`) -- yang seharusnya sudah jadi fix. Root cause pastinya di level mount-mechanism tidak pernah berhasil dipastikan (logcat boot yang gagal keburu tertimpa boot recovery berikutnya), tapi mekanisme mount kustom device ini (`hybrid_mount`, magic-mount ke `/system/bin`) tetap satu-satunya hal yang berubah di setiap kejadian.
- Fix: **hapus total direktori `system/` dari modul.** Modul v1.2.0 tidak memasang apa pun ke `/system` -- semua file (launcher, loader glibc) tinggal sebagai file biasa di `$MODPATH` (`/data/adb/modules/antigravity-cli/`), dipanggil lewat path lengkap. Karena tidak ada `system/` tree, modul ini tidak pernah lagi jadi input ke magic-mount/overlay planner device manapun -- kelas bootloop ini secara struktural tidak mungkin lagi disebabkan modul ini.
- Konsekuensi: **tidak perlu reboot setelah flash** (dulu wajib, supaya magic-mount berjalan). `antigravity-setup` bisa langsung dijalankan setelah instal.
- Trade-off: `antigravity`/`agy` tidak lagi otomatis ada di PATH untuk root shell/`adb` (dulu lewat symlink `/system/bin`) -- sekarang perlu path lengkap atau `su -c`. PATH Termux tetap otomatis, malah lebih tangguh: wrapper-nya ditulis ulang oleh `service.sh` setiap boot (self-healing), bukan hanya sekali saat `antigravity-setup` manual.
- `antigravity-mount` dihapus (tidak relevan lagi, tidak ada lagi yang perlu di-mount).
- Semua `chcon ... system_file` dihapus dari `customize.sh`/`service.sh`/`antigravity-update` -- itu hanya perlu untuk file yang di-magic-mount ke `/system`; untuk file biasa di `/data/adb` itu tidak diperlukan dan hanya menambah SELinux-policy churn saat boot yang tidak perlu.

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
