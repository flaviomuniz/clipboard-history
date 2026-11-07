#!/bin/bash
set -euo pipefail

# Oldest macOS the app supports. Used for the compiler target and Info.plist.
MINIMUM_MACOS_VERSION="13.0"

echo "🔨 Building ClipboardHistory..."

# Compile the app
swiftc ClipboardHistorySimple.swift \
    -o ClipboardHistory \
    -target "$(uname -m)-apple-macos${MINIMUM_MACOS_VERSION}" \
    -framework SwiftUI \
    -framework AppKit \
    -framework ServiceManagement \
    -O

# Create app bundle
rm -rf ClipboardHistory.app
mkdir -p ClipboardHistory.app/Contents/MacOS
mkdir -p ClipboardHistory.app/Contents/Resources

# Move executable
mv ClipboardHistory ClipboardHistory.app/Contents/MacOS/

# Create Info.plist
cat > ClipboardHistory.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ClipboardHistory</string>
    <key>CFBundleIdentifier</key>
    <string>com.clipboardhistory.app</string>
    <key>CFBundleName</key>
    <string>ClipboardHistory</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MINIMUM_MACOS_VERSION}</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Copy the app icon
if [ -f ClipboardHistory.icns ]; then
    cp ClipboardHistory.icns ClipboardHistory.app/Contents/Resources/AppIcon.icns
    echo "✅ Icon added to app bundle"
else
    echo "⚠️  No icon file found"
fi

echo "✅ Build complete!"
echo ""
echo "To run:"
echo "  open ClipboardHistory.app"
echo ""
echo "To install:"
echo "  cp -r ClipboardHistory.app /Applications/"