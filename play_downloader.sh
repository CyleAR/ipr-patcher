#!/bin/bash

set -euo pipefail

APP_ID="${1:?APP_ID is required}"
APKPURE_OPTIONS="${APKPURE_OPTIONS:-arch=arm64-v8a}"
DOWNLOAD_DIR="$APP_ID"

rm -rf "$DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR"

if [ -n "$APKPURE_OPTIONS" ]; then
  ./apkeep -a "$APP_ID" -d apk-pure -o "$APKPURE_OPTIONS" .
else
  ./apkeep -a "$APP_ID" -d apk-pure .
fi

xapk_file=$(find . -maxdepth 1 -name '*.xapk' -print | head -n 1)
if [ -n "$xapk_file" ]; then
  unzip -o "$xapk_file" -d "$DOWNLOAD_DIR"
  rm -f "$xapk_file"
else
  apk_file=$(find . -maxdepth 1 -name "${APP_ID}*.apk" -print | head -n 1)
  if [ -z "$apk_file" ]; then
    echo "Could not find downloaded APK for $APP_ID"
    exit 1
  fi

  mv "$apk_file" "$DOWNLOAD_DIR/"
fi
