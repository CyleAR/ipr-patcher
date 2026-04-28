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

# Rebuild Unity asset files that APKEditor split into *.splitN chunks.
while IFS= read -r split_file; do
  base_file="${split_file%.split*}"
  split_dir=$(dirname "$split_file")
  split_name=$(basename "$base_file")
  rm -f "$base_file"
  find "$split_dir" -maxdepth 1 -type f -name "${split_name}.split*" -print | sort -V | xargs cat > "$base_file"
done < <(find "./${PATCH_DIR}" -type f -name '*.split0' -print)

ASSET_PATH=$(find "./${PATCH_DIR}" \( -name 'sharedassets0.assets' -o -name 'resources.assets' -o -name 'globalgamemanagers.assets' \) -print | head -n 1)
if [ -z "$ASSET_PATH" ] || [ ! -f "$ASSET_PATH" ]; then
  echo "Unity asset file not found."
  echo "Candidate files under $PATCH_DIR:"
  find "./${PATCH_DIR}" \( -path '*/assets/bin/Data/*' -o -name '*.assets' -o -name 'globalgamemanagers*' \) -print | sort
  exit 1
fi

echo "Using Unity asset file: $ASSET_PATH"
python3 patch_font.py "$ASSET_PATH" "$FONT_FILE"

java -jar APKEditor.jar b -i "$PATCH_DIR" -o "$PATCHED_APK"
mv "$PATCHED_APK" "$GAME_APK_NAME"
