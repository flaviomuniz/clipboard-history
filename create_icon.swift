#!/usr/bin/env swift

import AppKit
import CoreGraphics

// Create icon image
func createAppIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    // Background gradient
    let gradient = NSGradient(colors: [
        NSColor(red: 0.2, green: 0.4, blue: 1.0, alpha: 1.0),
        NSColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)
    ])
    
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let path = NSBezierPath(roundedRect: rect, xRadius: size * 0.225, yRadius: size * 0.225)
    gradient?.draw(in: path, angle: -45)
    
    // Add clipboard symbol
    let symbolConfig = NSImage.SymbolConfiguration(pointSize: size * 0.4, weight: .medium)
    
    if let symbolImage = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)?
        .withSymbolConfiguration(symbolConfig) {
        
        let symbolRect = NSRect(
            x: (size - symbolImage.size.width) / 2,
            y: (size - symbolImage.size.height) / 2,
            width: symbolImage.size.width,
            height: symbolImage.size.height
        )
        
        // Draw white symbol
        symbolImage.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }
    
    image.unlockFocus()
    return image
}

// Save image as PNG
func saveAsPNG(_ image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for \(path)")
        return
    }
    
    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("Created: \(path)")
    } catch {
        print("Failed to save \(path): \(error)")
    }
}

// Create iconset directory
let iconsetPath = "ClipboardHistory.iconset"
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true, attributes: nil)

// Icon sizes needed for macOS
let iconSizes: [(size: Int, name: String)] = [
    (16, "icon_16x16"),
    (32, "icon_16x16@2x"),
    (32, "icon_32x32"),
    (64, "icon_32x32@2x"),
    (128, "icon_128x128"),
    (256, "icon_128x128@2x"),
    (256, "icon_256x256"),
    (512, "icon_256x256@2x"),
    (512, "icon_512x512"),
    (1024, "icon_512x512@2x")
]

// Generate all icon sizes
for (size, name) in iconSizes {
    let icon = createAppIcon(size: CGFloat(size))
    saveAsPNG(icon, to: "\(iconsetPath)/\(name).png")
}

print("\nNow run: iconutil -c icns \(iconsetPath)")
print("This will create ClipboardHistory.icns")