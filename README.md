# Google Antigravity CLI di Android

Menjalankan **Google Antigravity CLI** (`agy`) di HP Android yang sudah di-root — tanpa Termux, tanpa Node.js, dan tanpa toolchain apa pun. Dikemas sebagai satu modul KernelSU / Magisk / APatch.

Setelah terpasang, perintah `antigravity` atau `agy` bisa dipanggil dari mana saja di HP: shell root, `adb`, atau Termux.

> Modul ini mengunduh binary Go `linux_arm64` resmi langsung dari server rilis Google (`antigravity.google`).

## Syarat

- **arm64** (`arm64-v8a`)
- **root**: KernelSU, Magisk, atau APatch
- **~30 MB** ruang kosong untuk binary Go `agy`
- Akun Google / Google AI Studio API key untuk autentikasi

## Pasang

Unduh zip dari [Releases](../../releases) (atau bangun sendiri dengan `./scripts/build-module.sh`), flash lewat manager root Anda, **reboot**, lalu sebagai root:

```bash
antigravity-setup
```

Satu perintah itu mengunduh binary `agy` arm64 langsung dari Google, memverifikasi SHA512 checksum, mencabut blokir adblocker jika ada, dan menautkan Termux.

Tanpa menyentuh HP sama sekali (via `adb`):

```bash
adb push dist/antigravity-cli-v1.0.0.zip /data/local/tmp/a.zip
adb shell su -c "/data/adb/ksu/bin/ksud module install /data/local/tmp/a.zip"
adb reboot
```

## Pemakaian

```bash
antigravity            # atau 'agy' -- jalan sebagai siapa pun, termasuk Termux
su -c antigravity-update # perbarui binary agy ke versi terbaru dari Google
su -c antigravity-setup  # jalankan ulang setup (idempoten)
```

| perintah | tugas |
|---|---|
| `antigravity` / `agy` | launcher tunggal Antigravity CLI |
| `antigravity-setup` | setup lengkap sekali jalan (idempoten) |
| `antigravity-update` | unduh & verifikasi binary `agy` terbaru dari Google |
| `antigravity-update --list` | lihat versi `agy` yang terpasang |
| `antigravity-mount` | pasang ulang bind mount pool tanpa reboot |
| `antigravity-whitelist` | cabut blokir domain Google Antigravity di adblocker hosts |

## Cara kerja

Antigravity CLI adalah binary **Go** standalone buatan Google DeepMind (`agy`). Binary ini bersifat statically linked sehingga dapat berjalan langsung di Android arm64 tanpa memerlukan glibc, musl loader, atau Node.js.

Modul ini:
1. Mengunduh binary `linux_arm64` resmi dari server rilis Google (`antigravity-cli-auto-updater-974169037036.us-central1.run.app`)
2. Memverifikasi integritas file dengan SHA512 checksum yang ada pada manifest Google
3. Memaparkan binary lewat bind mount `/data/adb/antigravity` → `/system/bin/.antigravity-pool`
4. Menyediakan perintah `antigravity` dan `agy` yang dapat dipanggil dari seluruh sistem
