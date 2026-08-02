#!/system/bin/sh
# KernelSU / Magisk / APatch -- dijalankan saat modul di-flash.
#
# Modul ini TIDAK punya direktori system/ -- artinya tidak ada apa pun untuk
# di-magic-mount, jadi mekanisme mount kustom di device ini (hybrid_mount)
# tidak pernah menyentuh modul ini sama sekali. Semua file modul (launcher,
# loader glibc) tinggal sebagai file biasa di $MODPATH dan dipanggil lewat
# path lengkap -- tidak butuh reboot supaya "aktif".

SKIPUNZIP=1
ui_print "- Antigravity CLI (Google DeepMind)"
ui_print "  (modul tanpa /system mount -- tidak perlu reboot)"

# Arsitektur: hanya arm64.
ARCH=$(getprop ro.product.cpu.abi)
case "$ARCH" in
    arm64*) ;;
    *) abort "  ✗ Arsitektur $ARCH tidak didukung (butuh arm64-v8a)" ;;
esac
ui_print "  ✓ Arsitektur: $ARCH"

ui_print "- Mengekstrak modul"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2

# Izin executable pada semua skrip di bin/.
for f in "$MODPATH"/bin/*; do
    [ -f "$f" ] && chmod 755 "$f"
done
[ -f "$MODPATH/loader/ld-linux-aarch64.so.1" ] && chmod 755 "$MODPATH/loader/ld-linux-aarch64.so.1"
[ -f "$MODPATH/loader/libc.so.6" ] && chmod 755 "$MODPATH/loader/libc.so.6"

# Pool persisten: binary agy + config, terpisah dari $MODPATH supaya
# selamat kalau modul di-update/dipasang ulang.
POOL=/data/adb/antigravity
mkdir -p "$POOL"
chmod 755 "$POOL"

ui_print "- Selesai. Sebagai root, jalankan:  antigravity-setup"
