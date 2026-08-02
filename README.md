# Google Antigravity CLI di Android

Menjalankan **Google Antigravity CLI** (`agy`) di HP Android yang sudah di-root — tanpa Node.js dan tanpa toolchain apa pun. Dikemas sebagai satu modul KernelSU / Magisk / APatch.

Setelah terpasang, perintah `antigravity` atau `agy` bisa dipanggil dari root shell / `adb` (path lengkap atau `su -c`) dan dari Termux (`antigravity` / `agy` langsung di PATH).

> Modul ini mengunduh binary Go `linux_arm64` resmi langsung dari server rilis Google (`antigravity.google`).

**Sejak v1.2.0, modul ini tidak memasang apa pun ke `/system`.** Versi sebelumnya (v1.0.0–v1.1.0) melakukan magic-mount ke `/system/bin`, dan di beberapa device itu bisa bentrok dengan mekanisme mount kustom (mis. `hybrid_mount`) sampai memicu bootloop MIUI (`set_policy_failed:/data/extm`). v1.2.0 menghapus mount itu sepenuhnya — semua file modul tinggal sebagai file biasa di dalam direktori modulnya sendiri (`/data/adb/modules/antigravity-cli/`) dan dipanggil lewat path lengkap, tanpa mount/reboot sama sekali. Trade-off: `antigravity`/`agy` tidak otomatis ada di PATH root/adb (harus path lengkap atau `su -c`), tapi PATH Termux tetap otomatis via wrapper yang di-refresh setiap boot.

## Syarat

- **arm64** (`arm64-v8a`)
- **root**: KernelSU, Magisk, atau APatch
- **~30 MB** ruang kosong untuk binary Go `agy`
- Akun Google / Google AI Studio API key untuk autentikasi

## Pasang

Unduh zip dari [Releases](../../releases) (atau bangun sendiri dengan `./scripts/build-module.sh`), flash lewat manager root Anda. **Tidak perlu reboot** — modul ini tidak memasang apa pun ke `/system`, jadi tidak ada langkah magic-mount yang harus ditunggu. Langsung saja, sebagai root:

```bash
antigravity-setup
```

Kalau perintah `antigravity-setup` belum ada di PATH shell Anda (baru saja diflash, belum ada symlink), panggil path lengkapnya sekali:

```bash
su -c /data/adb/modules/antigravity-cli/bin/antigravity-setup
```

Satu perintah itu mengunduh binary `agy` arm64 langsung dari Google, memverifikasi SHA512 checksum, mencabut blokir adblocker jika ada, dan memasang wrapper Termux.

Tanpa menyentuh HP sama sekali (via `adb`):

```bash
adb push dist/antigravity-cli-v1.2.0.zip /data/local/tmp/a.zip
adb shell su -c "/data/adb/ksu/bin/ksud module install /data/local/tmp/a.zip"
adb shell su -c /data/adb/modules/antigravity-cli/bin/antigravity-setup
```

## Pemakaian

```bash
antigravity                    # Termux: langsung di PATH (wrapper su -c otomatis)
agy                             # sama, alias pendek

su -c antigravity               # root shell / adb: path lengkap atau su -c
su -c /data/adb/modules/antigravity-cli/bin/antigravity-update
su -c /data/adb/modules/antigravity-cli/bin/antigravity-setup
```

| perintah | tugas |
|---|---|
| `antigravity` / `agy` | launcher tunggal Antigravity CLI |
| `antigravity-setup` | setup lengkap sekali jalan (idempoten) |
| `antigravity-update` | unduh & verifikasi binary `agy` terbaru dari Google |
| `antigravity-update --list` | lihat versi `agy` yang terpasang |
| `antigravity-whitelist` | cabut blokir domain Google Antigravity di adblocker hosts |
| `antigravity-link-termux` | tulis ulang wrapper Termux (dipanggil otomatis tiap boot) |

Di root shell/`adb`, `antigravity-setup` dkk. hanya ada di path lengkap
(`/data/adb/modules/antigravity-cli/bin/`) kecuali Anda menambahkan
direktori itu ke `PATH` sendiri — modul ini sengaja tidak menyentuh
`/system/bin` (lihat "Cara kerja"). PATH Termux dikelola otomatis.

## Cara kerja

Antigravity CLI adalah binary **Go** buatan Google (`agy`) -- tapi build-nya cgo-enabled, jadi dinamis terhadap glibc (butuh `ld-linux-aarch64.so.1` + `libc`/`libpthread`/`libdl`/`librt`/`libresolv`/`libm`), bukan statically linked. Bionic (libc Android) tidak menyediakan itu, jadi binary ini tidak bisa langsung di-exec di Android seperti binary Go pada umumnya.

Modul ini:
1. Mengunduh binary `linux_arm64` resmi dari server rilis Google (`antigravity-cli-auto-updater-974169037036.us-central1.run.app`) ke pool persisten `/data/adb/antigravity` (terpisah dari direktori modul, jadi selamat kalau modul di-update/dipasang ulang)
2. Memverifikasi integritas file dengan SHA512 checksum yang ada pada manifest Google
3. Menjalankan `agy` lewat loader glibc yang di-bundle di `$MODDIR/loader/` (diambil dari paket `libc6` Debian 12 arm64), dengan trik yang sama seperti loader musl di modul `claude-code`
4. **Tidak** memasang direktori `system/` -- modul ini tidak pernah diikutsertakan dalam magic-mount / overlay planner device manapun, sehingga tidak bisa lagi jadi penyebab bootloop terkait mount seperti pada v1.0.0/v1.1.0
5. Menyediakan akses via wrapper Termux (`service.sh` menulis ulang tiap boot, self-healing) dan lewat path lengkap untuk root shell/`adb`
