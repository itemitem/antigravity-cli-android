#!/system/bin/sh
# Late-start service: runs once after every boot.
#
# This module has no /system overlay, so there is nothing here that
# participates in the device's magic-mount / hybrid_mount planner at
# post-fs-data time -- this script only does ordinary /data housekeeping,
# safely deferred to late boot (after boot_completed), well clear of the
# early-boot window where a stuck mount can trip Android's Rescue Party.

MODDIR=/data/adb/modules/antigravity-cli
POOL=/data/adb/antigravity

mkdir -p "$POOL"
chmod 755 "$POOL"

# Self-heal the Termux wrapper every boot (survives Termux reinstall/data
# wipe without needing a manual antigravity-setup rerun).
[ -x "$MODDIR/bin/antigravity-link-termux" ] && "$MODDIR/bin/antigravity-link-termux" >/dev/null 2>&1

# Optional partial wakelock
[ -f "$POOL/.keep-awake" ] && [ -w /sys/power/wake_lock ] &&
    echo antigravity-net > /sys/power/wake_lock 2>/dev/null

# Whitelist Google domains if adblocker is blocking them
[ -x "$MODDIR/bin/antigravity-whitelist" ] && "$MODDIR/bin/antigravity-whitelist" >/dev/null 2>&1 &
