import SwiftUI

/// Semantic asset colors resolve separately in light and dark appearance.
/// Glass belongs to navigation/controls; content cards remain readable solid surfaces.
enum Theme {
    static let background = Color(uiColor: .systemGroupedBackground)
    static let panel = Color(uiColor: .secondarySystemGroupedBackground)
    static let gold = Color("AccentColor")
    static let jungle = Color("JungleTint")
    static let warning = Color("WarningTint")
    static let muted = Color.secondary
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "System", light = "Light", dark = "Dark"
    var id: String { rawValue }
    var colorScheme: ColorScheme? {
        switch self { case .system: return nil; case .light: return .light; case .dark: return .dark }
    }
}

extension View {
    func expeditionCard() -> some View {
        padding(18)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(.primary.opacity(0.045)))
    }

    /// Standard tab bars/toolbars use the current OS design automatically.
    /// Custom glass is availability-gated so the app still runs on iOS 17+.
    @ViewBuilder func expeditionGlass() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .capsule)
        } else {
            self.background(.regularMaterial, in: Capsule())
        }
    }
}

struct SectionHeading: View {
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.title3.bold()).foregroundStyle(.primary)
            if let subtitle { Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Color plus an icon and a text label communicates risk without relying on color alone.
struct RiskBadge: View {
    let risk: AchievementRisk
    var body: some View {
        Label(risk.rawValue, systemImage: risk == .missable ? "exclamationmark.triangle.fill" : risk == .story ? "book.closed" : "arrow.clockwise")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(risk == .missable ? Theme.warning : Theme.jungle)
            .padding(.horizontal, 9).padding(.vertical, 5)
            .background((risk == .missable ? Theme.warning : Theme.jungle).opacity(0.1), in: Capsule())
    }
}

/// Original generated artwork gives the game atmosphere without imitating its UI.
struct ExpeditionHero: View {
    var compact = false
    var body: some View {
        Image("ExpeditionHero")
            .resizable().scaledToFill()
            .frame(height: compact ? 150 : 228).clipped()
            .overlay(LinearGradient(colors: [.clear, .black.opacity(0.76)], startPoint: .top, endPoint: .bottom))
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("SHADOW OF THE").font(.caption2.weight(.semibold)).tracking(2.4)
                    Text("Tomb Raider").font(.system(compact ? .title2 : .largeTitle, design: .serif).weight(.bold))
                    Text("Your path to every achievement").font(.subheadline).foregroundStyle(.white.opacity(0.85))
                }.foregroundStyle(.white).padding(22)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .accessibilityElement(children: .combine)
    }
}

struct ProgressRing: View {
    let fraction: Double
    var body: some View {
        ZStack {
            Circle().stroke(Theme.gold.opacity(0.13), lineWidth: 8)
            Circle().trim(from: 0, to: fraction)
                .stroke(Theme.gold, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(fraction, format: .percent.precision(.fractionLength(0)))
                .font(.title2.bold().monospacedDigit()).foregroundStyle(.primary)
        }.frame(width: 84, height: 84)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Achievements completed")
            .accessibilityValue(fraction.formatted(.percent.precision(.fractionLength(0))))
    }
}
