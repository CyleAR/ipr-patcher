#!/bin/bash
APK_EXTRACT_DIR=IdolyPride_decompile_xml
OLD_PACKAGE_NAME="game.qualiarts.idolypride"
NEW_PACKAGE_NAME="game.qualiarts.idolypride_kr"

IDOLYPRIDE_JP="アイプラ"
IDOLYPRIDE_KR="아이프라"

NAME_FILE="./$APK_EXTRACT_DIR/resources/package_1/res/values/strings.xml"
java -jar APKEditor.jar d -t xml -dex -i "$GAME_APK_NAME" -o $APK_EXTRACT_DIR

grep -rIl "$OLD_PACKAGE_NAME" ./$APK_EXTRACT_DIR | xargs sed -i "s/$OLD_PACKAGE_NAME/$NEW_PACKAGE_NAME/g"
sed -i "s/$IDOLYPRIDE_JP/$IDOLYPRIDE_KR/g" $NAME_FILE
java -jar APKEditor.jar b -i $APK_EXTRACT_DIR -o "$GAME_CLONED_NAME"
