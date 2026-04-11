#!/bin/bash

#headers=$(wget -q -S -U "$USER_AGENT" --start-pos 999999999 "$GAME_XAPK_LINK" 2>&1)
#xapk_name=${headers##*=}
#apk_version=${xapk_name%_*};apk_version=${apk_version##*_}

apk_version=$(python play_ver_check/app.py)

GAME_FILE_BASE=Gaku_$apk_version

echo "Latest app version: $apk_version"

if [ "$1" = "--env-only" ]; then
  {
    echo "APK_VERSION=$apk_version"
    echo "GAME_FILE_BASE=$GAME_FILE_BASE"
    echo "GAME_APK_NAME=$GAME_FILE_BASE.apk"
    echo "GAME_CLONED_NAME=${GAME_FILE_BASE}_cloned.apk"
  } >> "$GITHUB_ENV"
  exit 0
fi

LATEST_TAG="$(git describe --tags "$(git rev-list --tags --max-count=1)" 2>/dev/null || echo "")"

echo "Latest tag: $LATEST_TAG"

if [ "$LATEST_TAG" != "$apk_version" ]; then
  echo "New version detected. Proceeding."
  {
    echo "continue=true"
    echo "apk_version=$apk_version"
    echo "game_file_base=$GAME_FILE_BASE"
    echo "game_apk_name=$GAME_FILE_BASE.apk"
    echo "game_cloned_name=${GAME_FILE_BASE}_cloned.apk"
  } >> "$GITHUB_OUTPUT"
else
  echo "No new version found. Stopping gracefully."
  echo "continue=false" >> "$GITHUB_OUTPUT"
fi


