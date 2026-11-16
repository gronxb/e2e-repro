#!/bin/sh
# Builds the repro app for the iOS simulator with swiftc (no Xcode project) and installs it.
# usage: ./build.sh <simulator-udid>
set -eu
UDID="$1"
ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/build/TapOriginRepro.app"
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
TARGET="$(uname -m)-apple-ios17.0-simulator"
rm -rf "$ROOT/build"
mkdir -p "$APP"
xcrun --sdk iphonesimulator swiftc -sdk "$SDK" -target "$TARGET" -O -framework WebKit "$ROOT/App/main.swift" -o "$APP/TapOriginRepro"
cp "$ROOT/App/Info.plist" "$APP/Info.plist"
codesign --force --sign - "$APP" >/dev/null 2>&1
xcrun simctl install "$UDID" "$APP"
