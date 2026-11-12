import SwiftUI

/// A planning card answers when, what is required, and what can be missed before tracking controls.
struct AchievementDetail: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("hideSpoilers") private var hideSpoilers = true
    @AppStorage("currentChapter") private var chapter = JourneyChapter.cozumel
    @State private var revealed = false
    let achievement: Achievement
    private var hidden: Bool { hideSpoilers && achievement.isSpoiler && !revealed && !store.isComplete(achievement) }
    private var guide: AchievementGuide { JourneyGuide.guide(for: achievement) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top) {
                    Image(systemName: hidden ? "eye.slash" : store.isComplete(achievement) ? "checkmark.seal.fill" : achievement.category.symbol)
                        .font(.system(size: 38, weight: .light)).foregroundStyle(Theme.gold)
                    Spacer()
                    RiskBadge(risk: guide.risk)
                }.padding(.top, 16)
                VStack(alignment: .leading, spacing: 10) {
                    Text(hidden ? "A discovery awaits." : achievement.title).font(.largeTitle.bold())
                    Text(achievement.pack ?? achievement.category.rawValue).font(.subheadline.weight(.medium)).foregroundStyle(Theme.jungle)
                }
                if hidden {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("This objective contains story details. Reveal it when you’re ready.").foregroundStyle(.secondary)
                        Button("Reveal objective", systemImage: "eye") { revealed = true }.buttonStyle(.borderedProminent)
                    }.expeditionCard()
                } else {
                    Text(achievement.requirement).font(.title3).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Label("How soon can I earn it?", systemImage: "clock").font(.headline)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(guide.verifiedWindow ? "EARLIEST PRACTICAL WINDOW" : "PLANNING WINDOW")
                            .font(.caption2.bold()).tracking(1).foregroundStyle(Theme.jungle)
                        Text(hidden ? "Story progression · \(guide.firstChapter.title)" : guide.timing).font(.subheadline.weight(.semibold))
                        Text(guide.availability(at: chapter)).font(.caption).foregroundStyle(.secondary)
                    }
                    if !hidden {
                        Divider()
                        VStack(alignment: .leading, spacing: 5) {
                            Text("What you need").font(.subheadline.weight(.semibold))
                            Text(guide.prerequisite).font(.subheadline).foregroundStyle(.secondary)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            Text(guide.risk == .missable ? "Do not leave it too late" : "Plan your route").font(.subheadline.weight(.semibold))
                            Text(guide.advice).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    if guide.risk == .missable && !store.isComplete(achievement) {
                        Label("Limited enemy encounters. Keep an earlier combat save; free roam is not a guaranteed cleanup option.", systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote).foregroundStyle(Theme.warning)
                    }
                    NavigationLink { ChapterDetail(chapter: guide.firstChapter) } label: {
                        Label("View chapter plan", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                            .font(.subheadline.weight(.semibold))
                    }
                }.expeditionCard()

                if !hidden {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Your progress").font(.headline)
                        if achievement.target > 1 {
                            Stepper(value: Binding(get: { store.progress(for: achievement).count }, set: { store.setCount($0, for: achievement) }), in: 0...achievement.target) {
                                Text("\(store.progress(for: achievement).count) of \(achievement.target)").font(.title2.bold().monospacedDigit())
                            }.accessibilityLabel("Progress for \(achievement.title)")
                            ProgressView(value: Double(store.progress(for: achievement).count), total: Double(achievement.target))
                        }
                        Button { store.toggleComplete(achievement) } label: {
                            Label(store.isComplete(achievement) ? "Mark incomplete" : "Mark completed", systemImage: store.isComplete(achievement) ? "arrow.uturn.backward" : "checkmark.circle.fill")
                                .frame(maxWidth: .infinity).padding(.vertical, 7)
                        }.buttonStyle(.borderedProminent)
                        if let date = store.progress(for: achievement).completedAt {
                            Text("Completed \(date.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundStyle(.secondary)
                        }
                        Text("Your manual journal does not unlock achievements in the game.").font(.caption).foregroundStyle(.secondary)
                    }.expeditionCard()
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label("Field notes", systemImage: "note.text").font(.headline)
                    TextField("Locations, reminders, your next step…", text: Binding(get: { store.progress(for: achievement).notes }, set: { store.setNotes($0, for: achievement) }), axis: .vertical)
                        .lineLimit(4...9).accessibilityLabel("Personal achievement notes")
                    Text("Saved automatically on this iPhone.").font(.caption).foregroundStyle(.secondary)
                }.expeditionCard()
                Link("Read the complete achievement guide", destination: GuideSource.roadmap.url)
                    .font(.subheadline)
                Text("Timing depends on skill purchases, the route you take, and your save’s remaining encounters. Verify the actual unlock on your platform.")
                    .font(.footnote).foregroundStyle(.secondary)
            }.padding(.horizontal, 22).padding(.bottom, 32)
        }.scrollDismissesKeyboard(.interactively).background(Theme.background)
            .navigationTitle("Objective").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.progress(for: achievement).isFavorite ? "Unpin objective" : "Pin objective", systemImage: store.progress(for: achievement).isFavorite ? "pin.fill" : "pin") {
                        store.toggleFavorite(achievement)
                    }
                }
            }
    }
}
