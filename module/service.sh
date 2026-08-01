#!/system/bin/sh
# Late-start service: runs once after every boot.

POOL=/data/adb/antigravity
MNT=/system/bin/.antigravity-pool

mkdir -p "$POOL"
chmod 755 "$POOL"
chcon -R u:object_r:system_file:s0 "$POOL" 2>/dev/null

if [ -d "$MNT" ]; then
    mount -o bind "$POOL" "$MNT" 2>/dev/null
fi

# Optional partial wakelock
[ -f "$POOL/.keep-awake" ] && [ -w /sys/power/wake_lock ] &&
    echo antigravity-net > /sys/power/wake_lock 2>/dev/null

# Whitelist Google domains if adblocker is blocking them
/system/bin/antigravity-whitelist >/dev/null 2>&1 &
