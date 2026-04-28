#!/bin/bash

if [ -z "$LOCALIFY_KR_NAME" ]; then
  LOCALIFY_KR_NAME=$(find . -maxdepth 1 -name 'HoshimiLocalify*.apk' -printf '%f\n' | head -n 1)
fi

if [ -z "$LOCALIFY_KR_NAME" ]; then
  LOCALIFY_KR_NAME=$(find . -maxdepth 1 -name '*Localify*.apk' -printf '%f\n' | head -n 1)
fi

APKEEP_LINK=https://github.com/EFForg/apkeep/releases/latest/download/apkeep-x86_64-unknown-linux-gnu
APKEEP_NAME=apkeep

aria2c -j16 $APKEEP_LINK -o $APKEEP_NAME
chmod +x $APKEEP_NAME

if [ -z "$LOCALIFY_KR_NAME" ]; then
  echo "LOCALIFY_KR_NAME is not set and no Localify APK was found in the repo root."
  exit 1
fi

echo "LOCALIFY_KR_NAME=$LOCALIFY_KR_NAME" >> "$GITHUB_ENV"



