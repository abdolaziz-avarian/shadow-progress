import XCTest
@testable import ShadowProgress

/// These tests exercise saved user data and catalog integrity, where regressions could lose progress.
@MainActor
final class ProgressStoreTests: XCTestCase {
    private var suite: String!
    private var defaults: UserDefaults!
    private var store: ProgressStore!

    override func setUp() async throws {
        suite = "ShadowProgressTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
        store = ProgressStore(defaults: defaults)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suite)
        store = nil
        defaults = nil
    }

    func testCatalogHasUniqueStableIdentifiersAndExpectedPlatformCounts() {
        XCTAssertEqual(AchievementCatalog.all.count, 99)
        XCTAssertEqual(AchievementCatalog.all.filter { !$0.isDLC }.count, 63)
        XCTAssertEqual(Set(AchievementCatalog.all.map(\.id)).count, 99)
        XCTAssertTrue(AchievementCatalog.all.allSatisfy { $0.target > 0 && !$0.requirement.isEmpty })
    }

    func testCounterClampsAndCompletionDateChangesOnlyAtTheTarget() {
        let achievement = AchievementCatalog.all.first { $0.target == 25 }!
        store.setCount(-1, for: achievement)
        XCTAssertEqual(store.progress(for: achievement).count, 0)
        store.setCount(100, for: achievement)
        XCTAssertTrue(store.isComplete(achievement))
        XCTAssertEqual(store.progress(for: achievement).count, 25)
        let date = store.progress(for: achievement).completedAt
        XCTAssertNotNil(date)
        store.setCount(25, for: achievement)
        XCTAssertEqual(store.progress(for: achievement).completedAt, date)
        store.setCount(24, for: achievement)
        XCTAssertNil(store.progress(for: achievement).completedAt)
    }

    func testNotesPinsAndCountsSurviveRelaunch() {
        let achievement = AchievementCatalog.all[0]
        store.toggleComplete(achievement)
        store.toggleFavorite(achievement)
        store.setNotes("Return to this monolith", for: achievement)
        let restored = ProgressStore(defaults: defaults)
        XCTAssertEqual(restored.progress(for: achievement), store.progress(for: achievement))
    }

    func testBackupRoundTripAndReset() throws {
        let achievement = AchievementCatalog.all[6]
        store.setCount(12, for: achievement)
        store.setNotes("Check the jungle camp", for: achievement)
        let backup = try store.exportData()
        store.reset()
        XCTAssertEqual(store.completedCount(in: AchievementCatalog.all), 0)
        XCTAssertTrue(store.entries.isEmpty)
        try store.importData(backup)
        XCTAssertEqual(store.progress(for: achievement).count, 12)
        XCTAssertEqual(store.progress(for: achievement).notes, "Check the jungle camp")
    }

    func testInvalidImportsLeaveExistingProgressUntouched() throws {
        let achievement = AchievementCatalog.all[0]
        store.toggleComplete(achievement)
        let before = store.entries
        for data in [Data("not json".utf8), try JSONEncoder().encode(ProgressArchive(version: 2, entries: [:])), try JSONEncoder().encode(ProgressArchive(entries: ["unknown": AchievementProgress()]))] {
            XCTAssertThrowsError(try store.importData(data))
            XCTAssertEqual(store.entries, before)
        }
        let invalid = AchievementProgress(count: achievement.target + 1)
        XCTAssertThrowsError(try store.importData(JSONEncoder().encode(ProgressArchive(entries: [achievement.id: invalid]))))
        XCTAssertEqual(store.entries, before)
    }

    func testDLCProgressDoesNotAffectBaseGameTotals() {
        let dlc = AchievementCatalog.all.first { $0.isDLC }!
        store.toggleComplete(dlc)
        XCTAssertEqual(store.completedCount(in: AchievementCatalog.all), 1)
        XCTAssertEqual(store.completedCount(in: AchievementCatalog.all.filter { !$0.isDLC }), 0)
        XCTAssertEqual(store.fraction(in: []), 0)
    }

    func testCorruptSavedDataIsPreservedForRecovery() {
        let corrupt = Data("broken archive".utf8)
        defaults.set(corrupt, forKey: "shadow-progress.archive.v1")
        let restored = ProgressStore(defaults: defaults)
        XCTAssertNotNil(restored.storageMessage)
        XCTAssertEqual(defaults.data(forKey: "shadow-progress.archive.v1.recovery"), corrupt)
    }
}
