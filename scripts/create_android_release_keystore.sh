#!/usr/bin/env bash
# Creates android/upload-keystore.jks and prints lines for android/key.properties.
# Usage:
#   export KEYSTORE_PASSWORD='...'
#   export KEY_PASSWORD='...'   # often same as KEYSTORE_PASSWORD
#   ./scripts/create_android_release_keystore.sh
# Or run interactively (will prompt for passwords).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$ROOT/android"
KEYSTORE="$ANDROID_DIR/upload-keystore.jks"
ALIAS="${KEY_ALIAS:-upload}"

if [[ -f "$KEYSTORE" ]]; then
  echo "Keystore already exists: $KEYSTORE"
  echo "Remove it first if you want to regenerate."
  exit 1
fi

if [[ -z "${KEYSTORE_PASSWORD:-}" || -z "${KEY_PASSWORD:-}" ]]; then
  read -r -s -p "Keystore password: " KEYSTORE_PASSWORD
  echo
  read -r -s -p "Key password (enter for same): " KEY_PASSWORD
  echo
  KEY_PASSWORD="${KEY_PASSWORD:-$KEYSTORE_PASSWORD}"
fi

keytool -genkeypair -v \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "$KEYSTORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  -dname "CN=Personal Library, OU=Mobile, O=Personal, L=Unknown, ST=Unknown, C=US"

chmod 600 "$KEYSTORE"

cat <<EOF

Created: $KEYSTORE

Add android/key.properties (never commit):

storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$ALIAS
storeFile=upload-keystore.jks

Then: flutter build appbundle --release
EOF
