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

if [ -f "${ASSET_PATH}.split0" ]; then
  echo "Targeting split asset starting with: ${ASSET_PATH}.split0"
  TARGET_PATH="${ASSET_PATH}.split0"
elif [ -f "$ASSET_PATH" ]; then
  echo "Single Unity asset detected: $ASSET_PATH"
  TARGET_PATH="$ASSET_PATH"
else
  echo "Unity asset not found: $ASSET_PATH"
  exit 1
fi

echo "Using target path: $TARGET_PATH"
python3 patch_font.py "$TARGET_PATH" "$FONT_FILE"

# Build the font-patched APK
java -jar APKEditor.jar b -i "$PATCH_DIR" -o "$PATCHED_APK"

# Export the path for GitHub Actions
if [ -n "${GITHUB_ENV:-}" ]; then
  echo "FONT_PATCHED_APK=$PATCHED_APK" >> "$GITHUB_ENV"
fi

echo "Font-patched APK created: $PATCHED_APK"
# DO NOT overwrite GAME_APK_NAME here to keep it pure for font-only release
# We will use a separate working copy for subsequent patching if needed
