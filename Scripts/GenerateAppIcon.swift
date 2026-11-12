import AppKit

// Reproducible vector-drawn eclipse/temple icon with standard, dark, and tinted variants.
// Run with `swift Scripts/GenerateAppIcon.swift` from the repository root on macOS.
// All geometry is original; no game logo or achievement artwork is redistributed.
let directory = URL(fileURLWithPath: "ShadowProgress/Assets.xcassets/AppIcon.appiconset")
for variant in ["AppIcon", "AppIcon-Dark", "AppIcon-Tinted"] {
    let tinted = variant.hasSuffix("Tinted")
    let dark = variant.hasSuffix("Dark")
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024,
                                  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                  isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let forest = tinted ? NSColor(white: 0.10, alpha: 1) : NSColor(srgbRed: 0.025, green: dark ? 0.055 : 0.14, blue: dark ? 0.045 : 0.105, alpha: 1)
    let gold = tinted ? NSColor(white: 0.93, alpha: 1) : NSColor(srgbRed: 0.94, green: 0.79, blue: 0.47, alpha: 1)
    forest.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1024, height: 1024)).fill()
    let glow = tinted ? NSColor(white: 0.24, alpha: 1) : NSColor(srgbRed: 0.07, green: dark ? 0.15 : 0.28, blue: dark ? 0.11 : 0.20, alpha: 1)
    // Discrete vector bands avoid a noisy/dithered bitmap and keep bundled PNGs small.
    for band in 0..<128 {
        forest.blended(withFraction: Double(band) / 127, of: glow)!.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: band * 8, width: 1024, height: 8)).fill()
    }
    // Fine rings and a deliberate gap frame the silhouette at small home-screen sizes.
    gold.withAlphaComponent(0.18).setStroke()
    let outer = NSBezierPath(ovalIn: NSRect(x: 125, y: 125, width: 774, height: 774))
    outer.lineWidth = 3; outer.stroke()
    gold.withAlphaComponent(0.72).setStroke()
    let ring = NSBezierPath()
    ring.appendArc(withCenter: NSPoint(x: 512, y: 512), radius: 350, startAngle: 20, endAngle: 340)
    ring.lineWidth = 10; ring.lineCapStyle = .round; ring.stroke()
    gold.setFill()
    NSBezierPath(ovalIn: NSRect(x: 476, y: 608, width: 174, height: 174)).fill()
    glow.setFill()
    NSBezierPath(ovalIn: NSRect(x: 439, y: 634, width: 174, height: 174)).fill()
    // The stepped pyramid remains legible as a single geometric mark.
    gold.setFill()
    for (x, y, w, h) in [(284, 290, 456, 75), (334, 365, 356, 73), (384, 438, 256, 73), (434, 511, 156, 59)] {
        NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: 3, yRadius: 3).fill()
    }
    forest.setFill()
    NSBezierPath(rect: NSRect(x: 481, y: 290, width: 62, height: 108)).fill()
    // Subtle stair lines add depth without fragile illustration detail.
    forest.withAlphaComponent(0.25).setStroke()
    for y in [328, 401, 474] {
        let step = NSBezierPath(); step.move(to: NSPoint(x: 455, y: y)); step.line(to: NSPoint(x: 569, y: y)); step.lineWidth = 3; step.stroke()
    }
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .png, properties: [:])!.write(to: directory.appendingPathComponent(variant + ".png"))
    print("Generated \(variant).png")
}
