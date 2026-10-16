#!/bin/bash
set -euo pipefail

APK_EXTRACT_DIR=IdolyPride_decompile_xml
OLD_PACKAGE_NAME="game.qualiarts.idolypride"
NEW_PACKAGE_NAME="game.qualiarts.idolypride_kr"

IDOLYPRIDE_JP="アイプラ"
IDOLYPRIDE_KR="아이프라"

NAME_FILE="./$APK_EXTRACT_DIR/resources/package_1/res/values/strings.xml"
rm -rf "$APK_EXTRACT_DIR"
BASE_APK="${FONT_PATCHED_APK:-$GAME_APK_NAME}"
echo "Cloning $BASE_APK..."

java -jar APKEditor.jar d -t xml -dex -i "$BASE_APK" -o "$APK_EXTRACT_DIR"

grep -rIlZ "$OLD_PACKAGE_NAME" "./$APK_EXTRACT_DIR" | xargs -0 -r sed -i "s/$OLD_PACKAGE_NAME/$NEW_PACKAGE_NAME/g"
sed -i "s/$IDOLYPRIDE_JP/$IDOLYPRIDE_KR/g" "$NAME_FILE"
java -jar APKEditor.jar b -i "$APK_EXTRACT_DIR" -o "$GAME_CLONED_NAME"
if [[ ! -s "$GAME_CLONED_NAME" ]]; then
    echo "Cloned game APK is missing or empty: $GAME_CLONED_NAME" >&2
    exit 1
fi
