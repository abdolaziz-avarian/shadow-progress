import SwiftUI

/// Owns the shared tracker for the lifetime of the app.
@main
struct ShadowProgressApp: App {
    @StateObject private var store = ProgressStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .tint(Theme.gold)
                .preferredColorScheme(.dark)
        }
    }
}
