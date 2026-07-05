#!/bin/bash
# make-app.sh — builds OhWell.app and installs it to /Applications
# Usage: bash make-app.sh
set -e

APP_NAME="OhWell"
BINARY_NAME="ohwell"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"

echo "▸ Building release binary..."
swift build --configuration release

echo "▸ Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$BINARY_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "Sources/ohwell/Info.plist"  "$APP_BUNDLE/Contents/"

# Copy SPM resource bundle if present (Assets.xcassets, Sounds, etc.)
RESOURCE_BUNDLE=$(find "$BUILD_DIR" -maxdepth 1 -name "*.bundle" 2>/dev/null | head -1)
if [ -n "$RESOURCE_BUNDLE" ]; then
    cp -r "$RESOURCE_BUNDLE" "$APP_BUNDLE/Contents/Resources/"
    echo "  ✓ Resources bundle included"
fi

echo "▸ Ad-hoc signing..."
codesign --deep --force --sign - "$APP_BUNDLE"

echo "▸ Installing to /Applications..."
rm -rf "/Applications/$APP_BUNDLE"
cp -r "$APP_BUNDLE" /Applications/

echo ""
echo "✓ OhWell.app is in /Applications"
echo "  First launch: right-click → Open (bypasses Gatekeeper for unsigned builds)"
