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

    func testMissableGuideContainsExactlyTheEnemyCombatGoals() {
        let missable = AchievementCatalog.all.filter { JourneyGuide.guide(for: $0).risk == .missable }
        XCTAssertEqual(missable.count, 14)
        XCTAssertEqual(Set(missable.map(\.id)), JourneyGuide.missableIDs)
        // Animal objectives remain obtainable in free roam; do not alarm players unnecessarily.
        for id in ["base-29", "base-33", "base-34", "base-43"] {
            XCTAssertEqual(JourneyGuide.guide(for: AchievementCatalog.all.first { $0.id == id }!).risk, .revisit)
        }
    }

    func testStoryGatedCombatIsNotSuggestedBeforeItsUnlockChapter() {
        let friendlyFire = AchievementCatalog.all.first { $0.id == "base-21" }!
        let eagleTalon = AchievementCatalog.all.first { $0.id == "base-14" }!
        XCTAssertEqual(JourneyGuide.guide(for: friendlyFire).firstChapter, .oilFields)
        XCTAssertEqual(JourneyGuide.guide(for: eagleTalon).firstChapter, .kuwaqYaku)
        XCTAssertFalse(JourneyGuide.objectives(in: .cozumel).contains { $0.id == eagleTalon.id })
        XCTAssertFalse(JourneyGuide.objectives(in: .kuwaqYaku).contains { $0.id == friendlyFire.id })
        XCTAssertTrue(JourneyGuide.objectives(in: .oilFields).contains { $0.id == friendlyFire.id })
    }

    func testFinalAuditIncludesAllMissablesWithoutTurningThemIntoCleanupGoals() {
        let finalReview = JourneyGuide.objectives(in: .returnPaititi)
        XCTAssertTrue(JourneyGuide.missableIDs.isSubset(of: Set(finalReview.map(\.id))))
        XCTAssertFalse(JourneyGuide.objectives(in: .cleanup).contains { JourneyGuide.missableIDs.contains($0.id) })
    }

    func testDLCPlanningIsSeparateFromTheMainStory() {
        for item in AchievementCatalog.all where item.isDLC {
            let guide = JourneyGuide.guide(for: item)
            XCTAssertEqual(guide.firstChapter, .dlc)
            XCTAssertEqual(guide.risk, .dlc)
        }
        XCTAssertEqual(JourneyGuide.objectives(in: .dlc).count, 36)
    }

    func testGuideUpdateKeepsExistingBackupIdentifiers() throws {
        let saved = ProgressArchive(entries: ["base-21": AchievementProgress(count: 3, isFavorite: true, notes: "Keep the combat save")])
        try store.importData(JSONEncoder().encode(saved))
        let item = AchievementCatalog.all.first { $0.id == "base-21" }!
        XCTAssertEqual(store.progress(for: item).count, 3)
        XCTAssertEqual(store.progress(for: item).notes, "Keep the combat save")
        XCTAssertTrue(store.progress(for: item).isFavorite)
    }

    func testEveryAchievementHasExactlyOnePrimaryCollection() {
        let chapterGoals = StoryMission.allCases.flatMap { AchievementOrganization.goals(in: $0) }
        let expansionGoals = (AchievementOrganization.expansionNames + ["Across all DLC"]).flatMap { AchievementOrganization.goals(inExpansion: $0) }
        let all = chapterGoals + AchievementOrganization.acrossGame + expansionGoals
        XCTAssertEqual(all.count, 99)
        XCTAssertEqual(Set(all.map(\.id)), Set(AchievementCatalog.all.map(\.id)))
        XCTAssertEqual(expansionGoals.count, 36)
    }

    func testChapterProgressExcludesCumulativeCombatGoals() {
        let owned = AchievementOrganization.goals(in: .pathLiving)
        XCTAssertEqual(Set(owned.map(\.id)), ["base-37", "base-49"])
        let stealth = AchievementCatalog.all.first { $0.id == "base-07" }!
        XCTAssertEqual(AchievementOrganization.home(for: stealth), .acrossGame)
        store.toggleComplete(stealth)
        XCTAssertEqual(store.completedCount(in: owned), 0)
        XCTAssertTrue(AchievementOrganization.ongoing(at: .pathLiving).contains { $0.id == stealth.id })
    }

    func testRealStoryMissionOrderAndDLCMetaGoal() {
        XCTAssertEqual(StoryMission.allCases.count, 21)
        XCTAssertEqual(StoryMission.allCases.first, .faintLight)
        XCTAssertEqual(StoryMission.allCases.last, .citySerpent)
        XCTAssertEqual(StoryMission.downpour.number, 16)
        XCTAssertEqual(AchievementOrganization.goals(inExpansion: "The Path Home").count, 5)
        XCTAssertEqual(AchievementOrganization.goals(inExpansion: "Across all DLC").map(\.id), ["dlc-seasoned-pro"])
    }
}
