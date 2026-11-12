import SwiftUI

/// Titles, requirements, and guidance are always visible. Spoilers are an informational flair only.
struct AchievementDetail: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("currentMissionID") private var current = StoryMission.faintLight
    let achievement: Achievement
    private var guide: AchievementGuide { JourneyGuide.guide(for: achievement) }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    AchievementFlairs(achievement: achievement)
                    Text(achievement.title).font(.largeTitle.bold())
                    Text(achievement.requirement).font(.title3).foregroundStyle(.secondary)
                }.padding(.vertical, 8)
            }.listRowBackground(Color.clear).listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))

            Section("Progress") {
                if achievement.target > 1 {
                    Stepper(value: Binding(get: { store.progress(for: achievement).count }, set: { store.setCount($0, for: achievement) }), in: 0...achievement.target) {
                        Text("\(store.progress(for: achievement).count) of \(achievement.target)").font(.headline.monospacedDigit())
                    }.accessibilityLabel("Progress for \(achievement.title)")
                }
                Button {
                    store.toggleComplete(achievement)
                } label: {
                    Label(store.isComplete(achievement) ? "Mark incomplete" : "Mark completed", systemImage: store.isComplete(achievement) ? "arrow.uturn.backward" : "checkmark.circle")
                }
                if let date = store.progress(for: achievement).completedAt {
                    LabeledContent("Completed", value: date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                }
            }.listRowBackground(Theme.panel)

            Section("Where it belongs") {
                switch AchievementOrganization.home(for: achievement) {
                case .mission(let mission):
                    NavigationLink { MissionDetail(mission: mission) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mission.title)
                            Text("Chapter \(mission.number) · \(mission.region.title)").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                case .acrossGame:
                    NavigationLink { AcrossGameView() } label: { Label("Across the game", systemImage: "circle.grid.cross") }
                case .expansion(let pack):
                    NavigationLink { ExpansionAchievementsView(pack: pack) } label: { Label(pack, systemImage: "square.stack") }
                }
            }.listRowBackground(Theme.panel)

            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(guide.verifiedWindow ? "Earliest practical opportunity" : "Suggested timing").font(.subheadline.weight(.semibold))
                    Text(guide.timing).font(.subheadline)
                    Text(guide.availability(at: current.route)).font(.caption).foregroundStyle(.secondary)
                }.padding(.vertical, 4)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Prerequisites").font(.subheadline.weight(.semibold))
                    Text(guide.prerequisite).font(.subheadline).foregroundStyle(.secondary)
                }.padding(.vertical, 4)
                VStack(alignment: .leading, spacing: 6) {
                    Text(guide.risk == .missable ? "Missable opportunity" : "Planning note").font(.subheadline.weight(.semibold))
                    Text(guide.advice).font(.subheadline).foregroundStyle(.secondary)
                }.padding(.vertical, 4)
            } header: { Text("When to get it") } footer: {
                if guide.risk == .missable {
                    Text("Enemy encounters are limited. Keep an earlier save and confirm the actual unlock on your gaming platform.")
                        .foregroundStyle(Theme.warning)
                }
            }.listRowBackground(Theme.panel)

            Section {
                TextField("Locations, reminders, your next step…", text: Binding(get: { store.progress(for: achievement).notes }, set: { store.setNotes($0, for: achievement) }), axis: .vertical)
                    .lineLimit(4...10).accessibilityLabel("Personal achievement notes")
            } header: { Text("Notes") } footer: { Text("Saved automatically on this iPhone.") }
                .listRowBackground(Theme.panel)
            Section {
                Link("Achievement guide", destination: GuideSource.roadmap.url)
            }.listRowBackground(Theme.panel)
        }.scrollDismissesKeyboard(.interactively).scrollContentBackground(.hidden).background(Theme.background)
            .navigationTitle("Achievement").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.progress(for: achievement).isFavorite ? "Unpin achievement" : "Pin achievement", systemImage: store.progress(for: achievement).isFavorite ? "pin.fill" : "pin") {
                        store.toggleFavorite(achievement)
                    }
                }
            }
    }
}
