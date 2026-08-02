#!/system/bin/sh
# No /system mount to tear down (this module ships no system/ overlay).
# Only remove the Termux wrapper we wrote into another app's data dir.

TP=/data/data/com.termux/files/usr
for f in "$TP/bin/antigravity" "$TP/bin/agy"; do
    [ -f "$f" ] && grep -q '/data/adb/modules/antigravity-cli/bin/antigravity' "$f" 2>/dev/null && rm -f "$f"
done
exit 0
