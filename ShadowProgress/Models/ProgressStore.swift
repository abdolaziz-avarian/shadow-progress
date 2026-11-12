import Foundation
import Combine

/// All mutations run on the main actor so SwiftUI and persistence see the same state.
@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var entries: [String: AchievementProgress] = [:]
    @Published var storageMessage: String?
    private let defaults: UserDefaults
    private let key = "shadow-progress.archive.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        guard let data = defaults.data(forKey: key) else { return }
        do {
            entries = try Self.validatedEntries(from: data)
        } catch {
            // Keep the original bytes so an unreadable archive is never silently discarded.
            defaults.set(data, forKey: key + ".recovery")
            storageMessage = "Saved progress could not be read. A recovery copy was kept on this device."
        }
    }

    func progress(for achievement: Achievement) -> AchievementProgress {
        entries[achievement.id] ?? AchievementProgress()
    }

    func isComplete(_ achievement: Achievement) -> Bool {
        progress(for: achievement).count >= achievement.target
    }

    /// Counts are manual observations; updating one never unlocks another achievement automatically.
    func setCount(_ count: Int, for achievement: Achievement) {
        var entry = progress(for: achievement)
        entry.count = min(max(count, 0), achievement.target)
        if entry.count == achievement.target {
            entry.completedAt = entry.completedAt ?? Date()
        } else {
            entry.completedAt = nil
        }
        entries[achievement.id] = entry
        save()
    }

    func toggleComplete(_ achievement: Achievement) {
        setCount(isComplete(achievement) ? 0 : achievement.target, for: achievement)
    }

    func toggleFavorite(_ achievement: Achievement) {
        var entry = progress(for: achievement)
        entry.isFavorite.toggle()
        entries[achievement.id] = entry
        save()
    }

    /// Save notes on each edit so dismissing the detail screen cannot lose a draft.
    func setNotes(_ notes: String, for achievement: Achievement) {
        var entry = progress(for: achievement)
        entry.notes = notes
        entries[achievement.id] = entry
        save()
    }

    func completedCount(in catalog: [Achievement]) -> Int {
        catalog.filter(isComplete).count
    }

    func fraction(in catalog: [Achievement]) -> Double {
        guard !catalog.isEmpty else { return 0 }
        return Double(completedCount(in: catalog)) / Double(catalog.count)
    }

    func exportData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(ProgressArchive(entries: entries))
    }

    /// Validate the entire import before replacing anything, including unknown IDs and invalid counts.
    func importData(_ data: Data) throws {
        let imported = try Self.validatedEntries(from: data)
        entries = imported
        save()
    }

    func reset() {
        entries = [:]
        save()
    }

    private func save() {
        do { defaults.set(try exportData(), forKey: key) }
        catch { storageMessage = "Your latest change could not be saved. Please export a backup before closing the app." }
    }

    private static func validatedEntries(from data: Data) throws -> [String: AchievementProgress] {
        let archive = try JSONDecoder().decode(ProgressArchive.self, from: data)
        guard archive.version == 1 else { throw ArchiveError.unsupportedVersion }
        let catalog = Dictionary(uniqueKeysWithValues: AchievementCatalog.all.map { ($0.id, $0) })
        for (id, entry) in archive.entries {
            guard let achievement = catalog[id], (0...achievement.target).contains(entry.count),
                  (entry.completedAt == nil || entry.count == achievement.target) else {
                throw ArchiveError.invalidProgress
            }
        }
        return archive.entries
    }

    enum ArchiveError: LocalizedError {
        case unsupportedVersion, invalidProgress
        var errorDescription: String? {
            switch self {
            case .unsupportedVersion: return "This backup uses an unsupported version. Your existing progress was kept."
            case .invalidProgress: return "This backup contains invalid progress. Your existing progress was kept."
            }
        }
    }
}
