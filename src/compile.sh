#!/bin/bash

# Paths
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SRC_DIR/../NoMouse.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
ZIP_PATH="$SRC_DIR/../NoMouse.zip"

# Compile for x86_64 architecture
swiftc -target x86_64-apple-macos13 -o "$SRC_DIR/nomouse_x86_64" "$SRC_DIR/main.swift"

# Compile for arm64 architecture
swiftc -target arm64-apple-macos13 -o "$SRC_DIR/nomouse_arm64" "$SRC_DIR/main.swift"

# Combine the x86_64 and arm64 binaries into a universal binary
lipo -create -output "$SRC_DIR/nomouse" "$SRC_DIR/nomouse_x86_64" "$SRC_DIR/nomouse_arm64"

# Verify the architecture of the universal binary
lipo -info "$SRC_DIR/nomouse"

# Remove arm64 and x86_64 binaries
rm "$SRC_DIR/nomouse_x86_64" "$SRC_DIR/nomouse_arm64"

# Ensure MacOS directory exists
mkdir -p "$MACOS_DIR"

# Move nomouse binary to MacOS directory
mv "$SRC_DIR/nomouse" "$MACOS_DIR/"

# Remove the old zip file
rm -f "$ZIP_PATH"

# Create the new zip file
cd "$SRC_DIR/../" || exit
zip -r "$(basename "$ZIP_PATH")" "$(basename "$APP_DIR")"
