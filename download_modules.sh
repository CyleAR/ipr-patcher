#!/bin/bash

set -euo pipefail

if [[ -n "${LOCALIFY_KR_NAME:-}" ]]; then
  if [[ "$LOCALIFY_KR_NAME" != HoshimiLocalify_v*_full.apk || ! -f "$LOCALIFY_KR_NAME" ]]; then
    echo "LOCALIFY_KR_NAME must name an existing HoshimiLocalify_v*_full.apk file." >&2
    exit 1
  fi
else
  mapfile -t full_apks < <(find . -maxdepth 1 -type f -name 'HoshimiLocalify_v*_full.apk' -printf '%f\n' | sort)
  if [[ ${#full_apks[@]} -eq 0 ]]; then
    echo "Downloading the latest Full management APK for embedding..."
    gh release download --repo CyleAR/Hoshimi-localify --pattern 'HoshimiLocalify_v*_full.apk' --dir .
    mapfile -t full_apks < <(find . -maxdepth 1 -type f -name 'HoshimiLocalify_v*_full.apk' -printf '%f\n' | sort)
  fi
  if [[ ${#full_apks[@]} -ne 1 ]]; then
    echo "Expected exactly one Full management APK, found ${#full_apks[@]}." >&2
    exit 1
  fi
  LOCALIFY_KR_NAME="${full_apks[0]}"
fi

LOCALIFY_LITE_NAME="${LOCALIFY_KR_NAME%_full.apk}_lite.apk"
LOCALIFY_VERSION="${LOCALIFY_KR_NAME#HoshimiLocalify_}"
LOCALIFY_VERSION="${LOCALIFY_VERSION%_full.apk}"
if [[ ! -f "$LOCALIFY_LITE_NAME" ]]; then
  echo "Downloading the matching Lite management APK for distribution..."
  gh release download "$LOCALIFY_VERSION" --repo CyleAR/Hoshimi-localify --pattern "$LOCALIFY_LITE_NAME" --dir .
fi

python3 - "$LOCALIFY_KR_NAME" "$LOCALIFY_LITE_NAME" <<'PY'
import sys
from zipfile import ZipFile

with ZipFile(sys.argv[1]) as apk:
    assert apk.read("assets/hoshimi-local/version.txt").strip(), "Full APK has no translation version"
    assert any(name.startswith("assets/hoshimi-local/local-files/") and not name.endswith("/") for name in apk.namelist()), "Full APK has no translation data"
with ZipFile(sys.argv[2]) as apk:
    assert not any(name.startswith("assets/hoshimi-local/") for name in apk.namelist()), "Lite APK contains translation data"
PY

APKEEP_LINK=https://github.com/EFForg/apkeep/releases/latest/download/apkeep-x86_64-unknown-linux-gnu
APKEEP_NAME=apkeep

aria2c -j16 "$APKEEP_LINK" -o "$APKEEP_NAME"
chmod +x "$APKEEP_NAME"

{
  echo "LOCALIFY_KR_NAME=$LOCALIFY_KR_NAME"
  echo "LOCALIFY_LITE_NAME=$LOCALIFY_LITE_NAME"
} >> "$GITHUB_ENV"



