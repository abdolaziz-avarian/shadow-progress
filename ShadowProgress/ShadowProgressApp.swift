import SwiftUI

/// Owns the shared tracker for the lifetime of the app.
@main
struct ShadowProgressApp: App {
    @StateObject private var store = ProgressStore(defaults: AppPreferences.defaults)
    @AppStorage("appAppearance", store: AppPreferences.defaults) private var appearance = AppAppearance.system

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .defaultAppStorage(AppPreferences.defaults)
                .tint(Theme.gold)
                .preferredColorScheme(appearance.colorScheme)
        }
    }
}

/// UI regression tests use an isolated journal and preferences, never the player's real progress.
@MainActor
enum AppPreferences {
    static let defaults: UserDefaults = {
        let defaults: UserDefaults
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            let suite = "com.abdolazizavarian.ShadowProgress.UITesting"
            defaults = UserDefaults(suiteName: suite)!
            defaults.removePersistentDomain(forName: suite)
        } else { defaults = .standard }
        // Migrate only the navigation preference; achievement IDs and saved progress are untouched.
        if defaults.string(forKey: "currentMissionID") == nil {
            let mission: StoryMission
            if let legacy = defaults.string(forKey: "currentChapter").flatMap(JourneyChapter.init(rawValue:)) {
                mission = StoryMission.from(legacy: legacy)
            } else { mission = .faintLight }
            defaults.set(mission.rawValue, forKey: "currentMissionID")
        }
        return defaults
    }()
}
