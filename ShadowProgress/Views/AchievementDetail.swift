import SwiftUI

/// The detail screen supports counters, a completion toggle, pinning, and personal notes.
struct AchievementDetail: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("hideSpoilers") private var hideSpoilers = true
    @State private var revealed = false
    let achievement: Achievement
    private var hidden: Bool { hideSpoilers && achievement.isSpoiler && !revealed && !store.isComplete(achievement) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: hidden ? "eye.slash" : store.isComplete(achievement) ? "checkmark.seal.fill" : achievement.category.symbol)
                    .font(.system(size: 42)).foregroundStyle(Theme.gold).padding(.top, 14)
                Text(hidden ? "A discovery awaits." : achievement.title).font(.largeTitle.bold())
                Text(achievement.pack ?? achievement.category.rawValue).font(.subheadline.weight(.medium)).foregroundStyle(Theme.gold)
                if hidden {
                    Text("This objective may reveal story details. Reveal it when you’re ready.").foregroundStyle(Theme.muted)
                    Button("Reveal achievement", systemImage: "eye") { revealed = true }.buttonStyle(.borderedProminent)
                } else {
                    Text(achievement.requirement).font(.title3).foregroundStyle(Theme.muted)
                    VStack(alignment: .leading, spacing: 18) {
                        Text("YOUR PROGRESS").font(.caption.bold()).tracking(1.5).foregroundStyle(Theme.gold)
                        if achievement.target > 1 {
                            Stepper(value: Binding(get: { store.progress(for: achievement).count }, set: { store.setCount($0, for: achievement) }), in: 0...achievement.target) {
                                Text("\(store.progress(for: achievement).count) of \(achievement.target)").font(.title2.bold().monospacedDigit())
                            }.accessibilityLabel("Progress for \(achievement.title)")
                            ProgressView(value: Double(store.progress(for: achievement).count), total: Double(achievement.target))
                        }
                        Button {
                            withAnimation { store.toggleComplete(achievement) }
                        } label: {
                            Label(store.isComplete(achievement) ? "Mark as incomplete" : "Mark as completed", systemImage: store.isComplete(achievement) ? "arrow.uturn.backward" : "checkmark.circle.fill")
                                .frame(maxWidth: .infinity).padding(.vertical, 6)
                        }.buttonStyle(.borderedProminent)
                        if let date = store.progress(for: achievement).completedAt {
                            Text("Completed \(date.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundStyle(Theme.muted)
                        }
                        Text("Update this journal manually as you play.").font(.caption).foregroundStyle(Theme.muted)
                    }.expeditionCard()
                }

                Button { store.toggleFavorite(achievement) } label: {
                    Label(store.progress(for: achievement).isFavorite ? "Remove from pinned objectives" : "Pin this objective", systemImage: store.progress(for: achievement).isFavorite ? "pin.slash" : "pin")
                }.buttonStyle(.bordered)

                VStack(alignment: .leading, spacing: 12) {
                    Text("FIELD NOTES").font(.caption.bold()).tracking(1.5).foregroundStyle(Theme.gold)
                    TextField("Locations, reminders, or your next step…", text: Binding(get: { store.progress(for: achievement).notes }, set: { store.setNotes($0, for: achievement) }), axis: .vertical)
                        .lineLimit(5...10).accessibilityLabel("Personal achievement notes")
                    Text("Notes save automatically on this iPhone.").font(.caption).foregroundStyle(Theme.muted)
                }.expeditionCard()
            }.frame(maxWidth: .infinity, alignment: .leading).padding(22)
        }
        .background(Theme.background)
        .navigationTitle("Objective")
        .navigationBarTitleDisplayMode(.inline)
    }
}
