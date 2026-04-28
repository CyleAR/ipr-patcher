#!/bin/bash

set -euo pipefail

APP_ID="${1:?APP_ID is required}"
APKPURE_OPTIONS="${APKPURE_OPTIONS:-arch=arm64-v8a}"

if [ -n "$APKPURE_OPTIONS" ]; then
  ./apkeep -a "$APP_ID" -d apk-pure -o "$APKPURE_OPTIONS" .
else
  ./apkeep -a "$APP_ID" -d apk-pure .
fi

xapk_file=$(find . -maxdepth 1 -name '*.xapk' -print | head -n 1)
if [ -n "$xapk_file" ]; then
  unzip -o "$xapk_file" -d .
fi
