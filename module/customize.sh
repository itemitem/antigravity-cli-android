#!/system/bin/sh
# KernelSU / Magisk / APatch -- dijalankan saat modul di-flash.

SKIPUNZIP=1
ui_print "- Antigravity CLI (Google DeepMind)"

# Arsitektur: hanya arm64.
ARCH=$(getprop ro.product.cpu.abi)
case "$ARCH" in
    arm64*) ;;
    *) abort "  ✗ Arsitektur $ARCH tidak didukung (butuh arm64-v8a)" ;;
esac
ui_print "  ✓ Arsitektur: $ARCH"

ui_print "- Mengekstrak modul"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2

# Izin executable pada semua skrip di system/bin.
for f in "$MODPATH"/system/bin/*; do
    [ -f "$f" ] && chmod 755 "$f"
done

# Label SELinux.
chcon -R u:object_r:system_file:s0 "$MODPATH" 2>/dev/null

# Pool persisten: binary agy + config, jangan hilang kalau modul di-update.
POOL=/data/adb/antigravity
mkdir -p "$POOL"
chmod 755 "$POOL"
chcon -R u:object_r:system_file:s0 "$POOL" 2>/dev/null

ui_print "- Selesai. Reboot, lalu jalankan:  antigravity-setup"
