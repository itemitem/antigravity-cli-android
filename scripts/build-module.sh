#!/usr/bin/env bash
# Bundle module/ into a flashable zip for KernelSU / Magisk / APatch.
#
#   ./scripts/build-module.sh            -> dist/antigravity-cli-<version>.zip
set -euo pipefail

cd "$(dirname "$0")/.."
SRC=module
OUT=dist

[ -f "$SRC/module.prop" ] || { echo "build-module: $SRC/module.prop tidak ada" >&2; exit 1; }

VER=$(sed -n 's/^version=//p' "$SRC/module.prop" | head -1)
ID=$(sed -n 's/^id=//p' "$SRC/module.prop" | head -1)
[ -n "$VER" ] && [ -n "$ID" ] || { echo "build-module: module.prop kurang id/version" >&2; exit 1; }

# Syntax-check every shell script before shipping.
fail=0
while IFS= read -r f; do
    sh -n "$f" || { echo "build-module: sintaks gagal: $f" >&2; fail=1; }
done < <(find "$SRC" -type f \( -name '*.sh' -o -path '*/system/bin/*' \))
[ "$fail" = 0 ] || exit 1

mkdir -p "$OUT"
ZIP="$OUT/$ID-$VER.zip"
rm -f "$ZIP"

( cd "$SRC" && zip -qr "../$ZIP" . -x '.DS_Store' )

echo "$ZIP"
unzip -l "$ZIP" | tail -n +4 | head -20
