import SwiftUI

/// Chapters lead the experience. Maps and the full searchable catalog are separate destinations.
struct ContentView: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("currentMissionID") private var mission = StoryMission.faintLight
    @AppStorage("currentChapter") private var legacyChapter = JourneyChapter.cozumel
    @State private var tab = 0
    @State private var settings = false

    var body: some View {
        navigation
            .sheet(isPresented: $settings) {
                NavigationStack {
                    SettingsView().toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { settings = false } } }
                }
            }
            .onChange(of: mission, initial: true) { _, value in legacyChapter = value.route }
            .alert("Storage notice", isPresented: Binding(get: { store.storageMessage != nil }, set: { if !$0 { store.storageMessage = nil } })) {
                Button("OK") { store.storageMessage = nil }
            } message: { Text(store.storageMessage ?? "") }
    }

    @ViewBuilder private var navigation: some View {
        if #available(iOS 26.0, *) {
            TabView(selection: $tab) {
                Tab("Chapters", systemImage: "square.grid.2x2", value: 0) { chapters }
                Tab("Map", systemImage: "map", value: 1) { atlas }
                Tab("Search", systemImage: "magnifyingglass", value: 2, role: .search) { achievements }
            }.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            TabView(selection: $tab) {
                chapters.tabItem { Label("Chapters", systemImage: "square.grid.2x2") }.tag(0)
                atlas.tabItem { Label("Map", systemImage: "map") }.tag(1)
                achievements.tabItem { Label("Search", systemImage: "magnifyingglass") }.tag(2)
            }
        }
    }
    private var chapters: some View { NavigationStack { JourneyView().toolbar { settingsButton } } }
    private var atlas: some View { NavigationStack { AtlasView().toolbar { settingsButton } } }
    private var achievements: some View { NavigationStack { AchievementsView().toolbar { settingsButton } } }
    private var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) { Button("Settings", systemImage: "gearshape") { settings = true } }
    }
}

enum CatalogFilter: String, CaseIterable, Identifiable {
    case all = "All", missable = "Missable", pinned = "Pinned"
    var id: String { rawValue }
}

enum CompletionFilter: String, CaseIterable, Identifiable {
    case all = "Any progress", remaining = "Unfinished", completed = "Completed"
    var id: String { rawValue }
}

/// All 99 titles and requirements are searchable, including story spoilers and DLC.
struct AchievementsView: View {
    @EnvironmentObject private var store: ProgressStore
    @State private var search = ""
    @State private var filter = CatalogFilter.all
    @State private var completion = CompletionFilter.all
    @State private var category: AchievementCategory?

    private var matches: [Achievement] {
        AchievementCatalog.all.filter { item in
            let home = AchievementOrganization.subtitle(for: item)
            let query = search.isEmpty || [item.title, item.requirement, home, item.category.rawValue].contains { $0.localizedCaseInsensitiveContains(search) }
            let scope = filter == .all || (filter == .missable && JourneyGuide.missableIDs.contains(item.id)) || (filter == .pinned && store.progress(for: item).isFavorite)
            let status = completion == .all || (completion == .completed ? store.isComplete(item) : !store.isComplete(item))
            return query && scope && status && (category == nil || category == item.category)
        }.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    var body: some View {
        List {
            Section {
                Picker("Achievement collection", selection: $filter) {
                    ForEach(CatalogFilter.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented).accessibilityIdentifier("catalogScope")
                    .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                    .listRowBackground(Color.clear)
            }
            Section {
                ForEach(matches) { AchievementLink(achievement: $0) }
            } header: {
                HStack {
                    Text("\(matches.count) achievements")
                    Spacer()
                    if completion != .all || category != nil {
                        Button("Clear filters") { completion = .all; category = nil }
                    }
                }
            } footer: {
                Text("All names and descriptions are shown. Flairs identify spoilers and missable goals.")
            }
            if matches.isEmpty {
                ContentUnavailableView("No matching achievements", systemImage: "magnifyingglass", description: Text("Try another search or reset the filters."))
                    .listRowBackground(Color.clear)
            }
        }.scrollContentBackground(.hidden).background(Theme.background)
            .navigationTitle("Achievements")
            .searchable(text: $search, prompt: "Achievement, chapter, or DLC")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Progress", selection: $completion) { ForEach(CompletionFilter.allCases) { Text($0.rawValue).tag($0) } }
                        Picker("Category", selection: $category) {
                            Text("Every category").tag(nil as AchievementCategory?)
                            ForEach(AchievementCategory.allCases) { Text($0.rawValue).tag(Optional($0)) }
                        }
                    } label: { Label("Filter achievements", systemImage: "line.3.horizontal.decrease") }
                }
            }
    }
}

/// One link implementation gives chapter, global, and DLC lists the same swipe and completion behavior.
struct AchievementLink: View {
    @EnvironmentObject private var store: ProgressStore
    let achievement: Achievement
    var body: some View {
        NavigationLink { AchievementDetail(achievement: achievement) } label: {
            AchievementRow(achievement: achievement)
        }.listRowBackground(Theme.panel)
            .accessibilityIdentifier("achievement.\(achievement.id)")
            .swipeActions(edge: .trailing) {
                Button {
                    store.toggleComplete(achievement)
                } label: {
                    Label(store.isComplete(achievement) ? "Undo" : "Complete", systemImage: "checkmark")
                }.tint(Theme.jungle)
            }
            .swipeActions(edge: .leading) {
                Button { store.toggleFavorite(achievement) } label: {
                    Label(store.progress(for: achievement).isFavorite ? "Unpin" : "Pin", systemImage: "pin")
                }.tint(Theme.gold)
            }
    }
}

/// Flairs annotate content; none of them control whether an achievement can be read.
struct AchievementFlairs: View {
    let achievement: Achievement
    var body: some View {
        HStack(spacing: 6) {
            if JourneyGuide.missableIDs.contains(achievement.id) {
                flair("Missable", symbol: "exclamationmark.triangle.fill", color: Theme.warning)
            }
            if achievement.isSpoiler { flair("Spoiler", symbol: "eye", color: .purple) }
            if achievement.isDLC { flair("DLC", symbol: "square.stack", color: Theme.jungle) }
        }
    }
    private func flair(_ title: String, symbol: String, color: Color) -> some View {
        Label(title, systemImage: symbol).font(.caption2.weight(.medium))
            .foregroundStyle(color).padding(.horizontal, 7).padding(.vertical, 4)
            .background(color.opacity(0.09), in: Capsule())
    }
}

struct AchievementRow: View {
    @EnvironmentObject private var store: ProgressStore
    let achievement: Achievement
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: store.isComplete(achievement) ? "checkmark.circle.fill" : "circle")
                .font(.title3).foregroundStyle(store.isComplete(achievement) ? Theme.jungle : Color.secondary.opacity(0.35))
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(achievement.title).font(.headline).foregroundStyle(.primary)
                    Spacer(minLength: 4)
                    if store.progress(for: achievement).isFavorite { Image(systemName: "pin.fill").font(.caption2).foregroundStyle(Theme.gold) }
                    if achievement.target > 1 {
                        Text("\(store.progress(for: achievement).count)/\(achievement.target)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }
                }
                Text(achievement.requirement).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                AchievementFlairs(achievement: achievement)
                if store.progress(for: achievement).count > 0 && !store.isComplete(achievement) {
                    ProgressView(value: Double(store.progress(for: achievement).count), total: Double(achievement.target))
                }
            }
        }.padding(.vertical, 5)
    }
}

#Preview { ContentView().environmentObject(ProgressStore(defaults: UserDefaults(suiteName: "preview")!)) }
