#!/bin/bash

set -euo pipefail

GAME_ID="${GAME_ID:-game.qualiarts.idolypride}"
APKEEP_NAME=apkeep
APKEEP_LINK=https://github.com/EFForg/apkeep/releases/latest/download/apkeep-x86_64-unknown-linux-gnu

if [ ! -x "./$APKEEP_NAME" ]; then
  aria2c -j16 "$APKEEP_LINK" -o "$APKEEP_NAME"
  chmod +x "$APKEEP_NAME"
fi

version_list=$(./"$APKEEP_NAME" -l -a "$GAME_ID" -d apk-pure 2>/dev/null | tr -d '\r')
apk_version=$(printf '%s\n' "$version_list" | grep -Eo '[0-9]+([.][0-9A-Za-z_-]+)+' | sort -V | tail -n 1)

if [ -z "$apk_version" ]; then
  echo "Could not determine latest version for $GAME_ID from APKPure."
  exit 1
fi

GAME_FILE_BASE=IdolyPride_$apk_version

echo "Latest app version: $apk_version"

if [ "${1:-}" = "--env-only" ]; then
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


