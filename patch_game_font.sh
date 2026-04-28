#!/bin/bash

set -euo pipefail

PATCH_DIR=font_patch_src
PATCHED_APK="${GAME_FILE_BASE}_fontpatched.apk"
FONT_FILE="${FONT_FILE:-PretendardJP-SemiBold.otf}"

if [ ! -f "$FONT_FILE" ]; then
  echo "Font file not found: $FONT_FILE"
  exit 1
fi

rm -rf "$PATCH_DIR"

java -jar APKEditor.jar d -i "$GAME_APK_NAME" -o "$PATCH_DIR"

ASSET_PATH=$(find "./${PATCH_DIR}" -path '*/assets/bin/Data/sharedassets0.assets' -print | head -n 1)
if [ ! -f "$ASSET_PATH" ]; then
  echo "Unity asset file not found: $ASSET_PATH"
  exit 1
fi

echo "Using Unity asset file: $ASSET_PATH"
python3 patch_font.py "$ASSET_PATH" "$FONT_FILE"

java -jar APKEditor.jar b -i "$PATCH_DIR" -o "$PATCHED_APK"
mv "$PATCHED_APK" "$GAME_APK_NAME"
