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
        guard ProcessInfo.processInfo.arguments.contains("--ui-testing") else { return .standard }
        let suite = "com.abdolazizavarian.ShadowProgress.UITesting"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }()
}
