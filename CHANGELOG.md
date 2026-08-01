# Changelog

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
