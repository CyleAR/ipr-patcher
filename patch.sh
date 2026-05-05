#!/bin/bash

GAME_EMBEDDED_BASE="$GAME_FILE_BASE"_embedded
GAME_EMBEDDED_APK="$GAME_EMBEDDED_BASE".apk
GAME_EMBEDDED_CLONED="$GAME_EMBEDDED_BASE"_cloned.apk

rm -rf ls_patched localify
mkdir -p ls_patched localify

# Use the font-patched APK as base if available, otherwise use original
BASE_APK="${FONT_PATCHED_APK:-$GAME_APK_NAME}"
echo "Using $BASE_APK as base for LSPatch..."

java -jar lspatch.jar -l 2 --manager "$BASE_APK" -o ls_patched
java -jar lspatch.jar "$BASE_APK" -m "$LOCALIFY_KR_NAME" -o localify --force

patched_apk=$(find ./ls_patched/*.apk | head -n 1)
embed_apk=$(find ./localify/*.apk | head -n 1)

if [ -f "$embed_apk" ]; then
    mv "$embed_apk" ./"$GAME_EMBEDDED_APK"
fi

{
    echo "PATCHED_APK=$patched_apk";
    echo "EMBED_APK=$GAME_EMBEDDED_APK";
} >> "$GITHUB_ENV"

if [ -f "$GAME_CLONED_NAME" ]
then
OLD_PACKAGE="game.qualiarts.idolypride"
NEW_PACKAGE="game.qualiarts.idolypride_kr"
OLD_PACKAGE_SLASH="game/qualiarts/idolypride"
NEW_PACKAGE_SLASH="game/qualiarts/idolypride_kr"
LOCALIFY_CLONED_DIR=localify_cloned_module
LOCALIFY_CLONED_APK=localify_cloned_module.apk

java -jar APKEditor.jar d -i "$LOCALIFY_KR_NAME" -o $LOCALIFY_CLONED_DIR
grep -rIl "$OLD_PACKAGE" ./$LOCALIFY_CLONED_DIR | xargs sed -i "s/$OLD_PACKAGE/$NEW_PACKAGE/g"
grep -rIl "$OLD_PACKAGE_SLASH" ./$LOCALIFY_CLONED_DIR | xargs sed -i "s|$OLD_PACKAGE_SLASH|$NEW_PACKAGE_SLASH|g"
java -jar APKEditor.jar b -i $LOCALIFY_CLONED_DIR -o $LOCALIFY_CLONED_APK

java -jar lspatch.jar "$GAME_CLONED_NAME" -m "$LOCALIFY_CLONED_APK" -o localify_cloned --force
embed_apk_cloned=$(find ./localify_cloned/*.apk)
mv "$embed_apk_cloned" ./"$GAME_EMBEDDED_CLONED"
echo "EMBED_APK_CLONED=$GAME_EMBEDDED_CLONED" >> "$GITHUB_ENV"
fi
