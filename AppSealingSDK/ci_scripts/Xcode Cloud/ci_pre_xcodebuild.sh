#!/bin/bash
set -e

echo "========== AppSealing Pre Build =========="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

APPSEALING_KEYCHAIN="/Users/local/Library/Keychains/APPSEALING.keychain"
KEYCHAIN_PASSWORD="0000"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$APPSEALING_KEYCHAIN"
security list-keychains -d user -s login.keychain "$APPSEALING_KEYCHAIN"
security default-keychain -d user -s "$APPSEALING_KEYCHAIN"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$APPSEALING_KEYCHAIN"
security set-keychain-settings "$APPSEALING_KEYCHAIN"

security import "$SCRIPT_DIR/AppleWWDRCAG3.cer" -k "$APPSEALING_KEYCHAIN" -t cert -A -P ""

if [ -f "$SCRIPT_DIR/distribution.p12" ]; then
  security import "$SCRIPT_DIR/distribution.p12" -k "$APPSEALING_KEYCHAIN" -A -P ""
else
  security import "$SCRIPT_DIR/distribution.cer" -k "$APPSEALING_KEYCHAIN" -t cert -A -P ""
  security import "$SCRIPT_DIR/private_key.p12" -k "$APPSEALING_KEYCHAIN" -t priv -A -P ""
fi

security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$APPSEALING_KEYCHAIN" > /dev/null

mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"

install_profile() {
  UUID=$(/usr/libexec/PlistBuddy -c 'Print UUID' /dev/stdin <<< "$(security cms -D -i "$1")")
  cp "$1" "$HOME/Library/MobileDevice/Provisioning Profiles/$UUID.mobileprovision"
}

install_profile "$SCRIPT_DIR/store.mobileprovision"
install_profile "$SCRIPT_DIR/adhoc.mobileprovision"

echo "========== Pre Build Done =========="
