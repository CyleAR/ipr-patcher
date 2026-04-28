#!/bin/bash

set -euo pipefail

PATCH_DIR=font_patch_src
PATCHED_APK="${GAME_FILE_BASE}_fontpatched.apk"
FONT_FILE="${FONT_FILE:-PretendardJP-SemiBold.otf}"
ASSET_DIR="./${PATCH_DIR}/root/assets/bin/Data"
ASSET_PATH="${ASSET_DIR}/sharedassets0.assets"

if [ ! -f "$FONT_FILE" ]; then
  echo "Font file not found: $FONT_FILE"
  exit 1
fi

rm -rf "$PATCH_DIR"

java -jar APKEditor.jar d -i "$GAME_APK_NAME" -o "$PATCH_DIR"

if [ ! -d "$ASSET_DIR" ]; then
  echo "Unity asset directory not found: $ASSET_DIR"
  exit 1
fi

if [ ! -f "$ASSET_PATH" ]; then
  if [ ! -f "${ASSET_PATH}.split0" ]; then
    echo "Unity asset file not found: $ASSET_PATH"
    exit 1
  fi

  echo "Rebuilding split Unity asset: $ASSET_PATH"
  rm -f "$ASSET_PATH"
  while IFS= read -r split_file; do
    cat "$split_file" >> "$ASSET_PATH"
  done < <(find "$ASSET_DIR" -maxdepth 1 -type f -name 'sharedassets0.assets.split*' -print | sort -V)
fi

if [ ! -f "$ASSET_PATH" ]; then
  echo "Unity asset rebuild failed: $ASSET_PATH"
  exit 1
fi

echo "Using Unity asset file: $ASSET_PATH"
python3 patch_font.py "$ASSET_PATH" "$FONT_FILE"

java -jar APKEditor.jar b -i "$PATCH_DIR" -o "$PATCHED_APK"
echo "FONT_PATCHED_APK=$PATCHED_APK" >> "$GITHUB_ENV"
cp "$PATCHED_APK" "$GAME_APK_NAME"
