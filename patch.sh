#!/bin/bash

set -euo pipefail

require_single_apk() {
    local directory="$1"
    local -a apks
    mapfile -t apks < <(find "$directory" -maxdepth 1 -type f -name '*.apk' -print)
    if [[ ${#apks[@]} -ne 1 ]]; then
        echo "Expected exactly one APK in $directory, found ${#apks[@]}." >&2
        return 1
    fi
    if [[ ! -s "${apks[0]}" ]]; then
        echo "APK is empty: ${apks[0]}" >&2
        return 1
    fi
    printf '%s\n' "${apks[0]}"
}

GAME_EMBEDDED_BASE="$GAME_FILE_BASE"_embedded
GAME_EMBEDDED_APK="$GAME_EMBEDDED_BASE".apk
GAME_EMBEDDED_CLONED="$GAME_EMBEDDED_BASE"_cloned.apk

# Use the font-patched APK as base if available, otherwise use original
BASE_APK="${FONT_PATCHED_APK:-$GAME_APK_NAME}"
for input_apk in "$BASE_APK" "$LOCALIFY_KR_NAME" "$GAME_CLONED_NAME"; do
    if [[ ! -s "$input_apk" ]]; then
        echo "Required input APK is missing or empty: $input_apk" >&2
        exit 1
    fi
done

rm -rf ls_patched localify localify_cloned localify_cloned_module
rm -f localify_cloned_module.apk
mkdir -p ls_patched localify localify_cloned
echo "Using $BASE_APK as base for LSPatch..."

java -jar lspatch.jar -l 2 --manager "$BASE_APK" -o ls_patched
java -jar lspatch.jar "$BASE_APK" -m "$LOCALIFY_KR_NAME" -o localify --force

patched_apk=$(require_single_apk ./ls_patched)
embed_apk=$(require_single_apk ./localify)
mv "$embed_apk" ./"$GAME_EMBEDDED_APK"

OLD_PACKAGE="game.qualiarts.idolypride"
NEW_PACKAGE="game.qualiarts.idolypride_kr"
OLD_PACKAGE_SLASH="game/qualiarts/idolypride"
NEW_PACKAGE_SLASH="game/qualiarts/idolypride_kr"
LOCALIFY_CLONED_DIR=localify_cloned_module
LOCALIFY_CLONED_APK=localify_cloned_module.apk

java -jar APKEditor.jar d -i "$LOCALIFY_KR_NAME" -o "$LOCALIFY_CLONED_DIR"
{ grep -rIlZ "$OLD_PACKAGE" "./$LOCALIFY_CLONED_DIR" || [[ $? -eq 1 ]]; } | xargs -0 -r sed -i "s/$OLD_PACKAGE/$NEW_PACKAGE/g"
{ grep -rIlZ "$OLD_PACKAGE_SLASH" "./$LOCALIFY_CLONED_DIR" || [[ $? -eq 1 ]]; } | xargs -0 -r sed -i "s|$OLD_PACKAGE_SLASH|$NEW_PACKAGE_SLASH|g"
java -jar APKEditor.jar b -i "$LOCALIFY_CLONED_DIR" -o "$LOCALIFY_CLONED_APK"
if [[ ! -s "$LOCALIFY_CLONED_APK" ]]; then
    echo "Cloned module APK is missing or empty: $LOCALIFY_CLONED_APK" >&2
    exit 1
fi

java -jar lspatch.jar "$GAME_CLONED_NAME" -m "$LOCALIFY_CLONED_APK" -o localify_cloned --force
embed_apk_cloned=$(require_single_apk ./localify_cloned)
mv "$embed_apk_cloned" ./"$GAME_EMBEDDED_CLONED"
{
    echo "PATCHED_APK=$patched_apk"
    echo "EMBED_APK=$GAME_EMBEDDED_APK"
    echo "EMBED_APK_CLONED=$GAME_EMBEDDED_CLONED"
} >> "$GITHUB_ENV"
