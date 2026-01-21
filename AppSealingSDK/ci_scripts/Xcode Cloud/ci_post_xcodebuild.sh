#!/bin/zsh
set -e

echo "========== AppSealing Post Build =========="

# -------------------------------------------------------------------
# [0] Basic paths
# -------------------------------------------------------------------
REPO_ROOT="/Volumes/workspace/repository"
CI_SCRIPTS_DIR="$REPO_ROOT/ci_scripts"
APPSEALING_SDK_DIR="$REPO_ROOT/AppSealingSDK"
GENERATE_HASH="$APPSEALING_SDK_DIR/Tools/generate_hash"

EXPORT_DIR="$CI_APP_STORE_SIGNED_APP_PATH"
PRODUCT_NAME="$CI_PRODUCT"
IPA_PATH="$EXPORT_DIR/$PRODUCT_NAME.ipa"

PROFILE_SRC="$CI_SCRIPTS_DIR/store.mobileprovision"

# -------------------------------------------------------------------
# [1] Validate inputs
# -------------------------------------------------------------------
if [ ! -f "$IPA_PATH" ]; then
  echo "[ERROR] IPA not found: $IPA_PATH"
  ls -al "$EXPORT_DIR"
  exit 1
fi

if [ ! -f "$GENERATE_HASH" ]; then
  echo "[ERROR] generate_hash not found: $GENERATE_HASH"
  exit 1
fi

if [ ! -f "$PROFILE_SRC" ]; then
  echo "[ERROR] profile.mobileprovision not found: $PROFILE_SRC"
  exit 1
fi

chmod +x "$GENERATE_HASH"

# -------------------------------------------------------------------
# [2] Ruby environment (Xcode Cloud safe)
# -------------------------------------------------------------------
echo "[INFO] Setting up Ruby user gem environment"

export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"

# Install required gem (user install only)
if ! gem list xcodeproj -i >/dev/null 2>&1; then
  echo "[INFO] Installing xcodeproj gem (user install)"
  gem install xcodeproj --user-install --no-document
fi

# -------------------------------------------------------------------
# [3] Extract IPA
# -------------------------------------------------------------------
WORK_DIR="$(mktemp -d)"
echo "[INFO] Working directory: $WORK_DIR"

unzip -q "$IPA_PATH" -d "$WORK_DIR"

APP_PATH=$(find "$WORK_DIR/Payload" -maxdepth 1 -name "*.app" | head -n 1)

if [ ! -d "$APP_PATH" ]; then
  echo "[ERROR] App bundle not found after unzip"
  exit 1
fi

# -------------------------------------------------------------------
# [4] Embed provisioning profile
# -------------------------------------------------------------------
echo "[INFO] Embedding provisioning profile into app bundle"
cp "$PROFILE_SRC" "$APP_PATH/embedded.mobileprovision"

# -------------------------------------------------------------------
# [5] Run generate_hash (IPA-based, as designed)
# -------------------------------------------------------------------
echo "[INFO] Running generate_hash"
ruby "$GENERATE_HASH" "$IPA_PATH"

# -------------------------------------------------------------------
# [6] Upload to App Store Connect
# (generate_hash internally resigns & overwrites IPA)
# -------------------------------------------------------------------
echo "[INFO] Uploading IPA to App Store Connect"

xcrun altool --upload-app -t ios -f "$IPA_PATH" -u "$APPLE_ID" -p "$APPLE_APP_PASSWORD"

echo "========== AppSealing Post Build Done =========="
