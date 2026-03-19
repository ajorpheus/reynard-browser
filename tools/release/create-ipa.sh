#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ROOT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"
ARCHIVE_DIR="$ROOT_DIR/dist/Reynard.xcarchive"
APP_DIR="$ARCHIVE_DIR/Products/Applications"
WORK_DIR="$ROOT_DIR/dist/Reynard"

cd "$ROOT_DIR"

if [ ! -d "$APP_DIR" ]; then
	echo "Missing archive output at $APP_DIR"
	echo "Run tools/release/build-app.sh first."
	exit 1
fi

APP_PATH="$(find "$APP_DIR" -maxdepth 1 -type d -name '*.app' | head -n 1)"
if [ -z "$APP_PATH" ]; then
	echo "No .app found in $APP_DIR"
	exit 1
fi

VERSION=$(sed -n 's/^CURRENT_VERSION *= *//p' "$ROOT_DIR/browser/Configuration/Reynard.xcconfig" | tr -d '[:space:]')
GIT_SHORT=$(git -C "$ROOT_DIR" describe --tags --always 2>/dev/null || git -C "$ROOT_DIR" rev-parse --short HEAD)
IPA_NAME="Reynard-${VERSION}-${GIT_SHORT}"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/Payload"

cp -R "$APP_PATH" "$WORK_DIR/Payload/"

cd "$WORK_DIR"
zip -r "../${IPA_NAME}.ipa" Payload -x "._*" -x ".DS_Store" -x "__MACOSX"
echo "Created: dist/${IPA_NAME}.ipa"
