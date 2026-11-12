import AppKit

// Run with `swift Scripts/GenerateAppIcon.swift` from the repository root on macOS.
// The icon is original geometric artwork; no game assets or network downloads are used.
let size = 1024
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
                              bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                              isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
let forest = NSColor(srgbRed: 0.035, green: 0.075, blue: 0.065, alpha: 1)
let gold = NSColor(srgbRed: 0.88, green: 0.73, blue: 0.43, alpha: 1)
forest.setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()
gold.setStroke()
let ring = NSBezierPath(ovalIn: NSRect(x: 155, y: 155, width: 714, height: 714))
ring.lineWidth = 16
ring.stroke()
gold.setFill()
NSBezierPath(ovalIn: NSRect(x: 475, y: 585, width: 185, height: 185)).fill()
forest.setFill()
NSBezierPath(ovalIn: NSRect(x: 440, y: 610, width: 185, height: 185)).fill()
// Three stone steps and a doorway form a small temple silhouette.
gold.setFill()
for (x, y, w, h) in [(285, 300, 454, 80), (335, 380, 354, 78), (385, 458, 254, 78), (435, 536, 154, 55)] {
    NSBezierPath(rect: NSRect(x: x, y: y, width: w, height: h)).fill()
}
forest.setFill()
NSBezierPath(rect: NSRect(x: 482, y: 300, width: 60, height: 112)).fill()
NSGraphicsContext.restoreGraphicsState()
let output = URL(fileURLWithPath: "ShadowProgress/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
try bitmap.representation(using: .png, properties: [:])!.write(to: output)
print("Generated \(output.path)")
