import SwiftUI

/// Shared colors keep the expedition theme consistent across screens.
enum Theme {
    static let background = Color(red: 0.035, green: 0.075, blue: 0.065)
    static let panel = Color(red: 0.075, green: 0.13, blue: 0.11)
    static let gold = Color(red: 0.88, green: 0.73, blue: 0.43)
    static let muted = Color(red: 0.62, green: 0.72, blue: 0.66)
}

extension View {
    /// A reusable card supports Dynamic Type without fixed text heights.
    func expeditionCard() -> some View {
        padding(18)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(.white.opacity(0.06)))
    }
}

/// Original vector scenery avoids using copyrighted game artwork or network images.
struct ExpeditionLandscape: View {
    var body: some View {
        Canvas { context, size in
            let sun = CGRect(x: size.width * 0.66, y: 16, width: 72, height: 72)
            context.fill(Path(ellipseIn: sun), with: .color(Theme.gold.opacity(0.9)))
            context.fill(Path(ellipseIn: sun.offsetBy(dx: -14, dy: -9)), with: .color(Theme.background))
            for layer in 0..<3 {
                var ridge = Path()
                let baseline = size.height * (0.42 + Double(layer) * 0.19)
                ridge.move(to: CGPoint(x: 0, y: size.height))
                ridge.addLine(to: CGPoint(x: 0, y: baseline + 30))
                for step in 0...8 {
                    let x = size.width * Double(step) / 8
                    let y = baseline + (step % 2 == 0 ? 30.0 : -22.0) + Double((step + layer) % 3) * 12
                    ridge.addLine(to: CGPoint(x: x, y: y))
                }
                ridge.addLine(to: CGPoint(x: size.width, y: size.height))
                ridge.closeSubpath()
                context.fill(ridge, with: .color(Color(red: 0.12 - Double(layer) * 0.03, green: 0.24 - Double(layer) * 0.045, blue: 0.18 - Double(layer) * 0.03)))
            }
            // A stepped temple silhouette anchors the landscape in the exploration theme.
            let x = size.width * 0.25
            var temple = Path()
            temple.addRect(CGRect(x: x - 38, y: size.height - 35, width: 76, height: 35))
            temple.addRect(CGRect(x: x - 27, y: size.height - 48, width: 54, height: 16))
            temple.addRect(CGRect(x: x - 16, y: size.height - 62, width: 32, height: 17))
            context.fill(temple, with: .color(Theme.gold.opacity(0.28)))
        }
        .accessibilityHidden(true)
    }
}

/// The center label exposes the percentage as one accessible element.
struct ProgressRing: View {
    let fraction: Double
    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.08), lineWidth: 8)
            Circle().trim(from: 0, to: fraction)
                .stroke(Theme.gold, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(fraction, format: .percent.precision(.fractionLength(0)))
                .font(.title2.bold().monospacedDigit())
        }
        .frame(width: 88, height: 88)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Achievements completed")
        .accessibilityValue(fraction.formatted(.percent.precision(.fractionLength(0))))
    }
}
