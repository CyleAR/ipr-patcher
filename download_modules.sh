#!/bin/bash

LOCALIFY_KR_NAME=GakumasLocalify_v3.2.0k.apk

APKEEP_LINK=https://github.com/EFForg/apkeep/releases/latest/download/apkeep-x86_64-unknown-linux-gnu
APKEEP_NAME=apkeep

aria2c -j16 $APKEEP_LINK -o $APKEEP_NAME
chmod +x $APKEEP_NAME

echo "LOCALIFY_KR_NAME=$LOCALIFY_KR_NAME" >> "$GITHUB_ENV"



