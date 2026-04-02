#!/bin/bash

GAME_EMBEDDED_BASE="$GAME_FILE_BASE"_embedded
GAME_EMBEDDED_APK="$GAME_EMBEDDED_BASE".apk
GAME_EMBEDDED_CLONED="$GAME_EMBEDDED_BASE"_cloned.apk

java -jar lspatch.jar -l 2 --manager "$GAME_APK_NAME" -o ls_patched

java -jar lspatch_embed.jar "$GAME_APK_NAME" -m "$LOCALIFY_KR_NAME" -o localify --force

patched_apk=$(find ./ls_patched/*.apk)
embed_apk=$(find ./localify/*.apk)

mv "$embed_apk" ./"$GAME_EMBEDDED_APK"

{
    echo "PATCHED_APK=$patched_apk";
    echo "EMBED_APK=$GAME_EMBEDDED_APK";
} >> "$GITHUB_ENV"

if [ -f "$GAME_CLONED_NAME" ] 
then
java -jar lspatch_embed.jar "$GAME_CLONED_NAME" -m "$LOCALIFY_KR_NAME" -o localify_cloned --force
embed_apk_cloned=$(find ./localify_cloned/*.apk)
mv "$embed_apk_cloned" ./"$GAME_EMBEDDED_CLONED"
echo "EMBED_APK_CLONED=$GAME_EMBEDDED_CLONED" >> "$GITHUB_ENV"
fi
