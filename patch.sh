#!/bin/bash
set -e

# 기본 변수 설정
GAME_EMBEDDED_BASE="${GAME_FILE_BASE}_embedded"
GAME_EMBEDDED_APK="${GAME_EMBEDDED_BASE}.apk"
GAME_EMBEDDED_CLONED="${GAME_EMBEDDED_BASE}_cloned.apk"

# 1. [버전 1] 폰트만 패치된 버전 (이미 patch_game_font.sh에서 생성됨)
# FONT_PATCHED_APK 변수는 이미 환경변수에 등록되어 있음

# 2. [버전 2] 매니저 모드 (LSPatch Manager 앱 필요)
# 기존 명령어 유지
java -jar lspatch.jar "$GAME_APK_NAME" --manager -o out_manager --force
MANAGER_APK=$(find ./out_manager/*.apk)
cp "$MANAGER_APK" "./${GAME_FILE_BASE}_lspatch_manager.apk"
echo "MANAGER_APK=${GAME_FILE_BASE}_lspatch_manager.apk" >> "$GITHUB_ENV"

# 3. [버전 3] 로컬 모드 (Managerless - 매니저 앱 불필요, 플러그인 설치 필요)
java -jar lspatch.jar "$GAME_APK_NAME" -m "$LOCALIFY_KR_NAME" -l -o out_local --force
LOCAL_APK=$(find ./out_local/*.apk)
cp "$LOCAL_APK" "./${GAME_FILE_BASE}_lspatch_local.apk"
echo "LOCAL_APK=${GAME_FILE_BASE}_lspatch_local.apk" >> "$GITHUB_ENV"

# 4. [버전 4] 내장 모드 (Integrated - 현재 방식)
java -jar lspatch.jar "$GAME_APK_NAME" -m "$LOCALIFY_KR_NAME" -o out_embed --force
EMBED_APK_FILE=$(find ./out_embed/*.apk)
cp "$EMBED_APK_FILE" "./$GAME_EMBEDDED_APK"
echo "EMBED_APK=$GAME_EMBEDDED_APK" >> "$GITHUB_ENV"

# 5. Cloned 버전 처리 (선택 사항 - 기존 로직 유지)
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

    # Cloned 버전은 주로 내장 모드로 생성
    java -jar lspatch.jar "$GAME_CLONED_NAME" -m "$LOCALIFY_CLONED_APK" -o out_cloned --force
    EMBED_APK_CLONED_FILE=$(find ./out_cloned/*.apk)
    cp "$EMBED_APK_CLONED_FILE" "./$GAME_EMBEDDED_CLONED"
    echo "EMBED_APK_CLONED=$GAME_EMBEDDED_CLONED" >> "$GITHUB_ENV"
fi
