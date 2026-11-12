import SwiftUI

/// Selecting a story checkpoint changes planning recommendations, never achievement completion.
struct JourneyView: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("currentChapter") private var current = JourneyChapter.cozumel
    @AppStorage("includeDLC") private var includeDLC = true

    var body: some View {
        List {
            Section {
                Picker("I’m playing", selection: $current) {
                    ForEach(JourneyChapter.allCases.filter { includeDLC || $0 != .dlc }) { chapter in
                        Text(chapter.title).tag(chapter)
                    }
                }.tint(Theme.jungle)
            } footer: { Text("Set your position manually. Route stops are walkthrough areas, not automatic game detection.") }
                .listRowBackground(Theme.panel)

            Section("Story route") {
                ForEach(JourneyChapter.allCases.filter { $0.order < 15 }) { chapter in
                    NavigationLink { ChapterDetail(chapter: chapter) } label: {
                        ChapterRow(chapter: chapter, current: current)
                    }.listRowBackground(Theme.panel)
                }
            }
            Section("Beyond the story") {
                ForEach(JourneyChapter.allCases.filter { $0.order >= 15 && (includeDLC || $0 != .dlc) }) { chapter in
                    NavigationLink { ChapterDetail(chapter: chapter) } label: {
                        ChapterRow(chapter: chapter, current: current)
                    }.listRowBackground(Theme.panel)
                }
            }
            Section {
                Label("Combat first. Exploration later.", systemImage: "exclamationmark.shield")
                    .font(.headline).foregroundStyle(Theme.warning)
                Text("The 14 combat goals need human encounters. Keep useful saves and check your platform’s unlocks before leaving the story behind.")
                    .font(.subheadline).foregroundStyle(.secondary)
                Link("Read the achievement roadmap", destination: GuideSource.roadmap.url)
            }.listRowBackground(Theme.panel)
        }
        .listStyle(.insetGrouped).scrollContentBackground(.hidden).background(Theme.background)
        .navigationTitle("Journey")
    }
}

struct ChapterRow: View {
    @EnvironmentObject private var store: ProgressStore
    let chapter: JourneyChapter
    let current: JourneyChapter
    private var goals: [Achievement] { JourneyGuide.objectives(in: chapter) }
    private var risks: Int { goals.filter { JourneyGuide.missableIDs.contains($0.id) && !store.isComplete($0) }.count }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill((chapter == current ? Theme.gold : Theme.jungle).opacity(0.12))
                if chapter.order < 15 { Text("\(chapter.order + 1)").font(.subheadline.bold().monospacedDigit()) }
                else { Image(systemName: chapter.symbol) }
            }.foregroundStyle(chapter == current ? Theme.gold : Theme.jungle).frame(width: 38, height: 38)
            VStack(alignment: .leading, spacing: 6) {
                Text(chapter.title).font(.headline)
                Text(chapter.subtitle).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    if chapter == current { Text("CURRENT").font(.caption2.bold()).foregroundStyle(Theme.jungle) }
                    if risks > 0 { Label("\(risks) combat goals to review", systemImage: "exclamationmark.triangle.fill").font(.caption2).foregroundStyle(Theme.warning) }
                    else if !goals.isEmpty { Text("\(store.completedCount(in: goals))/\(goals.count) goals completed").font(.caption2).foregroundStyle(.secondary) }
                }
            }
        }.padding(.vertical, 6)
    }
}

struct ChapterDetail: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("currentChapter") private var current = JourneyChapter.cozumel
    @AppStorage("hideSpoilers") private var hideSpoilers = true
    @AppStorage("includeDLC") private var includeDLC = true
    let chapter: JourneyChapter
    private var goals: [Achievement] { JourneyGuide.objectives(in: chapter, catalog: AchievementCatalog.all.filter { includeDLC || !$0.isDLC }) }
    private var missables: [Achievement] { goals.filter { JourneyGuide.missableIDs.contains($0.id) } }
    private var otherGoals: [Achievement] { goals.filter { !JourneyGuide.missableIDs.contains($0.id) } }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: chapter.symbol).font(.largeTitle).foregroundStyle(Theme.gold)
                    Text(chapter.subtitle).font(.headline)
                    Text(chapter.briefing).font(.subheadline).foregroundStyle(.secondary)
                    Button {
                        current = chapter
                    } label: {
                        Label(current == chapter ? "Your current checkpoint" : "I’m at this chapter", systemImage: current == chapter ? "location.fill" : "location")
                    }.buttonStyle(.borderedProminent).disabled(current == chapter)
                }.padding(.vertical, 8)
            }.listRowBackground(Theme.panel)

            if !missables.isEmpty {
                Section {
                    ForEach(missables) { item in
                        NavigationLink { AchievementDetail(achievement: item) } label: {
                            AchievementRow(achievement: item, hideSpoilers: hideSpoilers)
                        }.listRowBackground(Theme.panel)
                    }
                } header: { Label("Missable · review before moving on", systemImage: "exclamationmark.triangle.fill").foregroundStyle(Theme.warning) }
                footer: { Text("Some goals begin in earlier chapters. Check prerequisites and remaining encounter access; the chapter selection alone does not prove a goal is still obtainable.") }
            }
            if !otherGoals.isEmpty {
                Section("Milestones & exploration") {
                    ForEach(otherGoals) { item in
                        NavigationLink { AchievementDetail(achievement: item) } label: {
                            AchievementRow(achievement: item, hideSpoilers: hideSpoilers)
                        }.listRowBackground(Theme.panel)
                    }
                }
            }
            if goals.isEmpty {
                Section {
                    ContentUnavailableView("A route checkpoint", systemImage: chapter.symbol, description: Text("No exclusive achievement is assigned to this section. Your exploration totals continue across regions."))
                }.listRowBackground(Theme.panel)
            }
            if [.returnPaititi, .finale, .cleanup].contains(chapter) {
                Section {
                    NavigationLink { MissableAuditView() } label: {
                        Label("Review all 14 missable achievements", systemImage: "checklist")
                    }
                } header: { Text("Final combat audit") } footer: { Text("If a needed encounter is already gone, use an earlier combat save or another playthrough. This journal does not mark anything irreversibly missed.") }
                    .listRowBackground(Theme.panel)
            }
            Section("Reference") {
                Link("Walkthrough and region maps", destination: chapter.mapURL)
                Link("Achievement roadmap", destination: GuideSource.roadmap.url)
                Text("Earliest practical windows are labeled explicitly in achievement details. Other chapter placements are planning suggestions, not fixed unlock guarantees.")
                    .font(.footnote).foregroundStyle(.secondary)
            }.listRowBackground(Theme.panel)
            if let next = JourneyChapter.allCases.first(where: { $0.order == chapter.order + 1 }) {
                Section {
                    NavigationLink { ChapterDetail(chapter: next) } label: {
                        HStack { Text("Next · \(next.title)"); Spacer(); Image(systemName: "arrow.right") }
                    }
                }.listRowBackground(Theme.panel)
            }
        }.listStyle(.insetGrouped).scrollContentBackground(.hidden).background(Theme.background)
            .navigationTitle(chapter.title).navigationBarTitleDisplayMode(.inline)
    }
}

struct MissableAuditView: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("hideSpoilers") private var hideSpoilers = true
    private var goals: [Achievement] { AchievementCatalog.all.filter { JourneyGuide.missableIDs.contains($0.id) } }
    var body: some View {
        List {
            Section {
                Text("\(store.completedCount(in: goals)) of 14 completed").font(.title2.bold())
                Text("Confirm each unlock on your gaming platform. Human enemies are not a reliable post-story resource.")
                    .foregroundStyle(.secondary)
            }.listRowBackground(Theme.panel)
            ForEach(goals) { item in
                NavigationLink { AchievementDetail(achievement: item) } label: {
                    AchievementRow(achievement: item, hideSpoilers: hideSpoilers)
                }.listRowBackground(Theme.panel)
            }
        }.scrollContentBackground(.hidden).background(Theme.background)
            .navigationTitle("Before the finale")
    }
}
