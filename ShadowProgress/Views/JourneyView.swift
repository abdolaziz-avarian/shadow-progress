import SwiftUI

/// A mission library replaces the former dashboard and repeated checkpoint checklist.
struct JourneyView: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("currentMissionID") private var current = StoryMission.faintLight
    @Environment(\.dynamicTypeSize) private var textSize
    private var columns: [GridItem] { [GridItem(.adaptive(minimum: textSize.isAccessibilitySize ? 320 : 155), spacing: 14)] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 13) {
                    Image(systemName: "trophy.fill").font(.title2).foregroundStyle(Theme.gold).frame(width: 46, height: 46).background(Theme.gold.opacity(0.09), in: RoundedRectangle(cornerRadius: 13))
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Shadow of the Tomb Raider").font(.subheadline.weight(.semibold))
                        HStack {
                            Text("\(store.completedCount(in: AchievementCatalog.all)) of 99 achievements").font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            Text(store.fraction(in: AchievementCatalog.all), format: .percent.precision(.fractionLength(0))).font(.caption.weight(.medium).monospacedDigit()).foregroundStyle(Theme.gold)
                        }
                        ProgressView(value: store.fraction(in: AchievementCatalog.all))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Continue").font(.title2.bold())
                    NavigationLink { MissionDetail(mission: current) } label: {
                        Image("ExpeditionHero").resizable().scaledToFill()
                            .frame(height: textSize.isAccessibilitySize ? 260 : 150).clipped()
                            .overlay(LinearGradient(colors: [.black.opacity(0.05), .black.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                            .overlay(alignment: .bottomLeading) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("CHAPTER \(current.number) · \(current.region.title.uppercased())").font(.caption2.weight(.semibold)).tracking(0.7)
                                    HStack(alignment: .bottom) {
                                        Text(current.title).font(.title2.bold())
                                        Spacer(); Image(systemName: "arrow.up.right").font(.headline)
                                    }
                                }.foregroundStyle(.white).padding(18)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }.buttonStyle(.plain).accessibilityIdentifier("continueChapter")
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Story chapters").font(.title2.bold())
                        Spacer()
                        Text("21 missions").font(.subheadline).foregroundStyle(.secondary)
                    }
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(MissionRegion.allCases) { region in
                            NavigationLink { RegionChaptersView(region: region) } label: {
                                RegionTile(region: region, isCurrent: current.region == region)
                            }.buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("More to complete").font(.title2.bold())
                    VStack(spacing: 0) {
                        NavigationLink { AcrossGameView() } label: {
                            collectionRow("Across the game", subtitle: "Cumulative, collection & difficulty goals", symbol: "circle.grid.cross", count: AchievementOrganization.acrossGame.count)
                        }
                        Divider().padding(.leading, 52)
                        NavigationLink { ExpansionLibraryView() } label: {
                            collectionRow("Expansions", subtitle: "Seven packs and their achievements", symbol: "square.stack.3d.up", count: 36)
                        }
                        Divider().padding(.leading, 52)
                        NavigationLink { MissableAuditView() } label: {
                            collectionRow("Missable checklist", subtitle: "Review before finishing the story", symbol: "exclamationmark.triangle", count: 14)
                        }
                    }.padding(.horizontal, 16).background(Theme.panel, in: RoundedRectangle(cornerRadius: 22))
                }
            }.padding(.horizontal, 20).padding(.bottom, 30)
        }.background(Theme.background).navigationTitle("Chapters")
    }

    private func collectionRow(_ title: String, subtitle: String, symbol: String, count: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).font(.title3).foregroundStyle(Theme.gold).frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline).foregroundStyle(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(count)").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }.padding(.vertical, 16)
    }
}

private struct RegionTile: View {
    @EnvironmentObject private var store: ProgressStore
    let region: MissionRegion
    let isCurrent: Bool
    private var goals: [Achievement] { AchievementOrganization.goals(in: region) }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: region.route.symbol).font(.title2).foregroundStyle(Theme.gold)
                Spacer()
                if isCurrent { Image(systemName: "location.fill").font(.caption).foregroundStyle(Theme.jungle) }
                else { Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary) }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(region.title).font(.headline).foregroundStyle(.primary).fixedSize(horizontal: false, vertical: true)
                Text("Chapters \(region.missions.first!.number)–\(region.missions.last!.number)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            HStack {
                Text("\(store.completedCount(in: goals))/\(goals.count) chapter goals").font(.caption2).foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            ProgressView(value: store.fraction(in: goals)).tint(Theme.jungle)
        }.padding(16).frame(maxWidth: .infinity, minHeight: 158, alignment: .leading)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct RegionChaptersView: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("currentMissionID") private var current = StoryMission.faintLight
    let region: MissionRegion
    var body: some View {
        List {
            Section {
                ForEach(region.missions) { mission in
                    let goals = AchievementOrganization.goals(in: mission)
                    NavigationLink { MissionDetail(mission: mission) } label: {
                        HStack(alignment: .top, spacing: 14) {
                            Text(String(format: "%02d", mission.number)).font(.title3.weight(.medium).monospacedDigit())
                                .foregroundStyle(current == mission ? Theme.gold : .secondary).frame(width: 32)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(mission.title).font(.headline)
                                Text(goals.isEmpty ? "Story progression" : "\(store.completedCount(in: goals)) of \(goals.count) chapter goals completed")
                                    .font(.subheadline).foregroundStyle(.secondary)
                                if current == mission { Label("Current chapter", systemImage: "location.fill").font(.caption).foregroundStyle(Theme.jungle) }
                            }
                        }.padding(.vertical, 10)
                    }.listRowBackground(Theme.panel)
                }
            } footer: {
                Text("Chapter totals include only goals assigned to that mission. Cumulative goals have their own collection.")
            }
        }.scrollContentBackground(.hidden).background(Theme.background)
            .navigationTitle(region.title)
    }
}

/// Only owned mission goals count toward chapter progress. Contextual goals are clearly separate.
struct MissionDetail: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("currentMissionID") private var current = StoryMission.faintLight
    let mission: StoryMission
    private var goals: [Achievement] { AchievementOrganization.goals(in: mission) }
    private var ongoing: [Achievement] { AchievementOrganization.ongoing(at: mission) }
    private var risks: Int { goals.filter { JourneyGuide.missableIDs.contains($0.id) }.count }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Chapter \(mission.number) of 21").font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                        if current == mission { Label("Current", systemImage: "location.fill").font(.caption.weight(.medium)).foregroundStyle(Theme.jungle) }
                        else { Button("Set as current") { current = mission }.font(.subheadline.weight(.medium)) }
                    }
                    if !goals.isEmpty {
                        HStack {
                            Text("\(store.completedCount(in: goals)) of \(goals.count) chapter goals").font(.headline)
                            Spacer()
                            if risks > 0 { Label("\(risks) missable", systemImage: "exclamationmark.triangle.fill").font(.caption).foregroundStyle(Theme.warning) }
                        }
                        ProgressView(value: store.fraction(in: goals))
                    } else {
                        Text("A story chapter with no dedicated achievement unlock. Ongoing goals are listed separately below.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }.padding(.vertical, 6)
            }.listRowBackground(Color.clear).listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            if !goals.isEmpty {
                Section {
                    ForEach(goals) { AchievementLink(achievement: $0) }
                } header: { Text("In this chapter") }
                footer: { Text("Story unlocks, side missions, and specific encounter opportunities associated with this chapter.") }
            }
            if !ongoing.isEmpty {
                Section {
                    ForEach(ongoing) { AchievementLink(achievement: $0) }
                } header: { Text("Ongoing combat goals") }
                footer: { Text("These cumulative goals can span several chapters. They are kept in Across the game and do not affect this chapter’s progress.") }
            }
            Section {
                NavigationLink { AcrossGameView() } label: { Label("Across the game", systemImage: "circle.grid.cross") }
                NavigationLink { MissableAuditView() } label: { Label("Full missable checklist", systemImage: "exclamationmark.triangle") }
            }.listRowBackground(Theme.panel)
            if let next = StoryMission.allCases.first(where: { $0.number == mission.number + 1 }) {
                Section {
                    NavigationLink { MissionDetail(mission: next) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Next chapter").font(.caption).foregroundStyle(.secondary)
                            Text(next.title).font(.headline)
                        }.padding(.vertical, 6)
                    }
                }.listRowBackground(Theme.panel)
            }
        }.scrollContentBackground(.hidden).background(Theme.background)
            .navigationTitle(mission.title).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Set as current", systemImage: "location") { current = mission }
                        Link("Chapter walkthrough", destination: mission.sourceURL)
                        Link("Region map & guide", destination: mission.route.mapURL)
                    } label: { Label("Chapter options", systemImage: "ellipsis") }
                }
            }
    }
}

/// Existing map and timing links resolve to the new hierarchy without breaking saved route IDs.
struct ChapterDetail: View {
    let chapter: JourneyChapter
    @ViewBuilder var body: some View {
        if chapter == .cleanup { AcrossGameView() }
        else if chapter == .dlc { ExpansionLibraryView() }
        else { RegionChaptersView(region: StoryMission.from(legacy: chapter).region) }
    }
}

struct AcrossGameView: View {
    var body: some View {
        List {
            Section {
                Text("Cumulative combat, collectibles, crafting, and whole-playthrough goals live here. Each achievement is counted once, separately from chapter goals.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }.listRowBackground(Color.clear)
            ForEach(AchievementCategory.allCases) { category in
                let goals = AchievementOrganization.acrossGame.filter { $0.category == category }
                if !goals.isEmpty {
                    Section(category.rawValue) { ForEach(goals) { AchievementLink(achievement: $0) } }
                }
            }
        }.scrollContentBackground(.hidden).background(Theme.background).navigationTitle("Across the game")
    }
}

struct ExpansionLibraryView: View {
    @EnvironmentObject private var store: ProgressStore
    var body: some View {
        List {
            Section("DLC packs") {
                ForEach(AchievementOrganization.expansionNames, id: \.self) { pack in
                    let goals = AchievementOrganization.goals(inExpansion: pack)
                    NavigationLink { ExpansionAchievementsView(pack: pack) } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(pack).font(.headline)
                            Text("\(store.completedCount(in: goals)) of \(goals.count) achievements").font(.subheadline).foregroundStyle(.secondary)
                        }.padding(.vertical, 7)
                    }.listRowBackground(Theme.panel)
                }
            }
            Section("Across the expansions") {
                ForEach(AchievementOrganization.goals(inExpansion: "Across all DLC")) { AchievementLink(achievement: $0) }
            }
        }.scrollContentBackground(.hidden).background(Theme.background).navigationTitle("Expansions")
    }
}

struct ExpansionAchievementsView: View {
    let pack: String
    var body: some View {
        List { ForEach(AchievementOrganization.goals(inExpansion: pack)) { AchievementLink(achievement: $0) } }
            .scrollContentBackground(.hidden).background(Theme.background).navigationTitle(pack)
    }
}

struct MissableAuditView: View {
    @EnvironmentObject private var store: ProgressStore
    private var goals: [Achievement] { AchievementCatalog.all.filter { JourneyGuide.missableIDs.contains($0.id) } }
    var body: some View {
        List {
            Section {
                LabeledContent("Completed", value: "\(store.completedCount(in: goals)) of 14")
                Text("Finish these during the story. An earlier combat save may be needed when the relevant enemies are gone.").font(.subheadline).foregroundStyle(.secondary)
            }.listRowBackground(Theme.panel)
            Section("Missable achievements") { ForEach(goals) { AchievementLink(achievement: $0) } }
        }.scrollContentBackground(.hidden).background(Theme.background).navigationTitle("Missable checklist")
    }
}
