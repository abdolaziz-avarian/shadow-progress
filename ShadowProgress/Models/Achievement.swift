import Foundation

/// Categories are editorial groupings for browsing, rather than platform trophy tiers.
enum AchievementCategory: String, CaseIterable, Codable, Identifiable {
    case story = "Story", exploration = "Exploration", combat = "Combat"
    case skills = "Skills & Gear", challenges = "Challenges", dlc = "DLC"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .story: return "book.closed"
        case .exploration: return "map"
        case .combat: return "scope"
        case .skills: return "hammer"
        case .challenges: return "mountain.2"
        case .dlc: return "square.stack.3d.up"
        }
    }
}

/// Immutable catalog entries have stable IDs, so renaming a title cannot lose saved progress.
struct Achievement: Identifiable, Hashable {
    let id: String
    let title: String
    let requirement: String
    let category: AchievementCategory
    let target: Int
    let isSpoiler: Bool
    let pack: String?
    var isDLC: Bool { pack != nil }
}

/// User-owned data stays separate from the bundled game catalog.
struct AchievementProgress: Codable, Equatable {
    var count = 0
    var isFavorite = false
    var notes = ""
    var completedAt: Date?
}

/// A versioned backup format allows later releases to migrate saved data deliberately.
struct ProgressArchive: Codable {
    var version = 1
    var entries: [String: AchievementProgress]
}
