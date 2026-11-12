import SwiftUI

/// Four focused tabs keep planning, tracking, and maps within a standard iPhone navigation model.
struct ContentView: View {
    @EnvironmentObject private var store: ProgressStore
    @State private var selectedTab = 0
    @State private var selectedFilter = AchievementFilter.all
    @State private var showSettings = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ExpeditionDashboard { filter in selectedFilter = filter; selectedTab = 2 }
                    .toolbar { settingsToolbar }
            }.tabItem { Label("Expedition", systemImage: "mountain.2") }.tag(0)
            NavigationStack {
                JourneyView().toolbar { settingsToolbar }
            }.tabItem { Label("Journey", systemImage: "point.topleft.down.to.point.bottomright.curvepath") }.tag(1)
            NavigationStack {
                AchievementsView(filter: $selectedFilter).toolbar { settingsToolbar }
            }.tabItem { Label("Achievements", systemImage: "trophy") }.tag(2)
            NavigationStack {
                AtlasView().toolbar { settingsToolbar }
            }.tabItem { Label("Atlas", systemImage: "map") }.tag(3)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView().toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showSettings = false } } }
            }.tint(Theme.gold)
        }
        .alert("Storage notice", isPresented: Binding(get: { store.storageMessage != nil }, set: { if !$0 { store.storageMessage = nil } })) {
            Button("OK") { store.storageMessage = nil }
        } message: { Text(store.storageMessage ?? "") }
    }

    private var settingsToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Field Kit", systemImage: "gearshape") { showSettings = true }
        }
    }
}

/// Progress and immediate risks lead the screen, rather than giving every statistic equal weight.
struct ExpeditionDashboard: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("includeDLC") private var includeDLC = true
    @AppStorage("hideSpoilers") private var hideSpoilers = true
    @AppStorage("currentChapter") private var chapter = JourneyChapter.cozumel
    let browse: (AchievementFilter) -> Void
    private var catalog: [Achievement] { AchievementCatalog.all.filter { includeDLC || !$0.isDLC } }
    private var remainingMissables: [Achievement] { AchievementCatalog.all.filter { JourneyGuide.missableIDs.contains($0.id) && !store.isComplete($0) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ExpeditionHero()
                HStack(spacing: 24) {
                    ProgressRing(fraction: store.fraction(in: catalog))
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Every discovery counts.").font(.headline)
                        Text("\(store.completedCount(in: catalog)) of \(catalog.count) unlocked").font(.title3.weight(.semibold).monospacedDigit())
                        Text(includeDLC ? "Base game + DLC" : "Base game").font(.subheadline).foregroundStyle(.secondary)
                        if !remainingMissables.isEmpty {
                            Button { browse(.missable) } label: {
                                Label("\(remainingMissables.count) missable goals left", systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption.weight(.semibold)).foregroundStyle(Theme.warning)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }.frame(maxWidth: .infinity, alignment: .leading).expeditionCard()

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("Your current chapter", systemImage: "location.fill").font(.subheadline.weight(.medium)).foregroundStyle(Theme.jungle)
                        Spacer()
                        Text(chapter.order < 15 ? "\(chapter.order + 1) / 15" : "Extra").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    NavigationLink { ChapterDetail(chapter: chapter) } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chapter.title).font(.title2.bold()).foregroundStyle(.primary)
                                Text(chapter.subtitle).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer(); Image(systemName: "chevron.right").font(.caption.bold())
                        }
                    }.buttonStyle(.plain)
                    Text(chapter.briefing).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    NavigationLink { JourneyView() } label: {
                        Label("Change chapter", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                            .font(.subheadline.weight(.semibold)).padding(.horizontal, 14).padding(.vertical, 10)
                            .expeditionGlass()
                    }.buttonStyle(.plain)
                }.expeditionCard()

                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top) {
                        Image(systemName: remainingMissables.isEmpty ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                            .font(.title2).foregroundStyle(remainingMissables.isEmpty ? Theme.jungle : Theme.warning)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(remainingMissables.isEmpty ? "Combat checklist complete" : "\(remainingMissables.count) missable goals left")
                                .font(.headline)
                            Text(chapter == .cleanup ? "Remaining combat goals may need an earlier save or a new run." : "Check these before the final mission. Enemies are limited; do not leave combat goals for free roam.")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    if !remainingMissables.isEmpty {
                        Button { browse(.missable) } label: {
                            HStack { Text("Review missable achievements"); Spacer(); Image(systemName: "arrow.right") }
                                .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.warning)
                        }
                    }
                }.expeditionCard()

                SectionHeading(title: "Focus for this chapter", subtitle: "Missable objectives come first")
                let focus = JourneyGuide.objectives(in: chapter, catalog: catalog).filter { !store.isComplete($0) }
                if focus.isEmpty {
                    ContentUnavailableView("No unfinished chapter goals", systemImage: "checkmark.seal", description: Text("Explore the Journey for the next checkpoint, or review the full catalog."))
                        .expeditionCard()
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(focus.prefix(3).enumerated()), id: \.element.id) { index, achievement in
                            NavigationLink { AchievementDetail(achievement: achievement) } label: {
                                AchievementRow(achievement: achievement, hideSpoilers: hideSpoilers)
                            }.buttonStyle(.plain)
                            if index < min(focus.count, 3) - 1 { Divider().padding(.vertical, 14) }
                        }
                    }.expeditionCard()
                    Button { browse(.thisStage) } label: { Label("See goals at this stage", systemImage: "arrow.right") }
                        .font(.subheadline.weight(.semibold))
                }

                SectionHeading(title: "Your collection")
                VStack(spacing: 18) {
                    ForEach(AchievementCategory.allCases.filter { includeDLC || $0 != .dlc }) { category in
                        let items = catalog.filter { $0.category == category }
                        NavigationLink { CategoryAchievementsView(category: category) } label: {
                            HStack(spacing: 14) {
                                Image(systemName: category.symbol).font(.title3).foregroundStyle(Theme.gold).frame(width: 28)
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(category.rawValue).foregroundStyle(.primary)
                                        Spacer()
                                        Text("\(store.completedCount(in: items))/\(items.count)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                                    }
                                    ProgressView(value: store.fraction(in: items))
                                }
                            }
                        }.buttonStyle(.plain)
                    }
                }.expeditionCard()
                Text("Manually tracked. Your game’s completion percentage and actual achievement unlocks remain the source of truth.")
                    .font(.footnote).foregroundStyle(.secondary)
            }.padding(.horizontal, 20).padding(.bottom, 30)
        }.background(Theme.background)
            .navigationTitle("Expedition")
    }
}

/// Category destinations reuse the catalog screen while preserving the tab's own filter state.
struct CategoryAchievementsView: View {
    let category: AchievementCategory
    @State private var filter = AchievementFilter.all
    var body: some View { AchievementsView(filter: $filter, initialCategory: category) }
}

struct AchievementsView: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("includeDLC") private var includeDLC = true
    @AppStorage("hideSpoilers") private var hideSpoilers = true
    @AppStorage("currentChapter") private var chapter = JourneyChapter.cozumel
    @Binding var filter: AchievementFilter
    var initialCategory: AchievementCategory? = nil
    @State private var category: AchievementCategory?
    @State private var search = ""
    @State private var sort = AchievementSort.priority
    private var activeCategory: AchievementCategory? { category ?? initialCategory }
    private var catalog: [Achievement] { AchievementCatalog.all.filter { includeDLC || !$0.isDLC } }

    private var filtered: [Achievement] {
        let result = catalog.filter { item in
            let progress = store.progress(for: item)
            let guide = JourneyGuide.guide(for: item)
            let hidden = hideSpoilers && item.isSpoiler && !store.isComplete(item)
            let searchMatches = search.isEmpty || (!hidden && (item.title.localizedCaseInsensitiveContains(search) || item.requirement.localizedCaseInsensitiveContains(search))) || item.category.rawValue.localizedCaseInsensitiveContains(search) || guide.firstChapter.title.localizedCaseInsensitiveContains(search) || (item.pack?.localizedCaseInsensitiveContains(search) ?? false)
            let status: Bool
            switch filter {
            case .all: status = true
            case .missable: status = guide.risk == .missable && !store.isComplete(item)
            case .thisStage:
                status = !store.isComplete(item) && !item.isDLC && guide.firstChapter.order <= chapter.order && !(guide.risk == .missable && chapter.order > guide.lastSuggestedChapter.order)
            case .remaining: status = !store.isComplete(item)
            case .inProgress: status = progress.count > 0 && !store.isComplete(item)
            case .completed: status = store.isComplete(item)
            case .favorites: status = progress.isFavorite
            }
            return searchMatches && status && (activeCategory == nil || activeCategory == item.category)
        }
        switch sort {
        case .priority:
            return result.sorted { lhs, rhs in
                @MainActor func rank(_ item: Achievement) -> Int {
                    if store.isComplete(item) { return 1000 }
                    return (JourneyGuide.missableIDs.contains(item.id) ? 0 : 100) + JourneyGuide.guide(for: item).firstChapter.order
                }
                return rank(lhs) == rank(rhs) ? lhs.id < rhs.id : rank(lhs) < rank(rhs)
            }
        case .title:
            return result.sorted { title($0).localizedStandardCompare(title($1)) == .orderedAscending }
        case .progress:
            return result.sorted { Double(store.progress(for: $0).count) / Double($0.target) > Double(store.progress(for: $1).count) / Double($1.target) }
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Show", selection: $filter) { ForEach(AchievementFilter.allCases) { Text($0.rawValue).tag($0) } }
                    .tint(.primary)
                    .accessibilityIdentifier("achievementFilter")
                HStack {
                    Text("\(filtered.count) objectives").font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                    Text("\(store.completedCount(in: catalog))/\(catalog.count) unlocked").font(.caption.monospacedDigit()).foregroundStyle(Theme.gold)
                }
            }.listRowBackground(Theme.panel)
            if filter == .missable {
                Section {
                    Label("Finish combat goals during the story. A chapter marker cannot tell whether an encounter is still available in your save.", systemImage: "exclamationmark.triangle")
                        .font(.subheadline).foregroundStyle(Theme.warning)
                }.listRowBackground(Theme.warning.opacity(0.08))
            }
            if filtered.isEmpty {
                ContentUnavailableView.search(text: search)
                    .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(filtered) { achievement in
                        NavigationLink { AchievementDetail(achievement: achievement) } label: {
                            AchievementRow(achievement: achievement, hideSpoilers: hideSpoilers)
                        }
                        .listRowBackground(Theme.panel)
                        .contextMenu {
                            Button(store.isComplete(achievement) ? "Mark incomplete" : "Mark completed", systemImage: "checkmark.circle") { store.toggleComplete(achievement) }
                            Button(store.progress(for: achievement).isFavorite ? "Unpin" : "Pin", systemImage: "pin") { store.toggleFavorite(achievement) }
                        }
                    }
                } footer: {
                    Text("At this stage is a chapter-based shortlist. Skill and equipment prerequisites still apply.")
                }
            }
        }
        .listStyle(.insetGrouped).scrollContentBackground(.hidden).background(Theme.background)
        .navigationTitle(activeCategory?.rawValue ?? "Achievements")
        .searchable(text: $search, prompt: "Achievement, chapter, or region")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Category", selection: $category) {
                        Text("All categories").tag(nil as AchievementCategory?)
                        ForEach(AchievementCategory.allCases.filter { includeDLC || $0 != .dlc }) { Text($0.rawValue).tag(Optional($0)) }
                    }
                    Picker("Order", selection: $sort) { ForEach(AchievementSort.allCases) { Text($0.rawValue).tag($0) } }
                } label: { Label("Sort and filter", systemImage: "line.3.horizontal.decrease") }
            }
        }
        .onChange(of: includeDLC) { _, enabled in if !enabled && category == .dlc { category = nil } }
    }

    private func title(_ item: Achievement) -> String {
        hideSpoilers && item.isSpoiler && !store.isComplete(item) ? "Hidden achievement" : item.title
    }
}

enum AchievementFilter: String, CaseIterable, Identifiable {
    case all = "All achievements", missable = "Missable · unfinished", thisStage = "At this stage"
    case remaining = "Remaining", inProgress = "In progress", completed = "Completed", favorites = "Pinned"
    var id: String { rawValue }
}

enum AchievementSort: String, CaseIterable, Identifiable {
    case priority = "Priority & chapter", title = "Title", progress = "Most progress"
    var id: String { rawValue }
}

/// Shared rows support light/dark appearance, Dynamic Type, and spoiler-safe titles.
struct AchievementRow: View {
    @EnvironmentObject private var store: ProgressStore
    let achievement: Achievement
    let hideSpoilers: Bool
    private var hidden: Bool { hideSpoilers && achievement.isSpoiler && !store.isComplete(achievement) }
    private var guide: AchievementGuide { JourneyGuide.guide(for: achievement) }

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: store.isComplete(achievement) ? "checkmark.seal.fill" : hidden ? "eye.slash" : achievement.category.symbol)
                .font(.title3).foregroundStyle(store.isComplete(achievement) ? Theme.jungle : Theme.gold)
                .frame(width: 27).padding(.top, 3)
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline) {
                    Text(hidden ? "Hidden achievement" : achievement.title).font(.headline).foregroundStyle(.primary)
                    if store.progress(for: achievement).isFavorite { Image(systemName: "pin.fill").font(.caption2).foregroundStyle(Theme.gold) }
                }
                Text(hidden ? "Reveal the objective when you’re ready." : achievement.requirement)
                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 7) { RiskBadge(risk: guide.risk); timingCaption }
                    VStack(alignment: .leading, spacing: 5) { RiskBadge(risk: guide.risk); timingCaption }
                }
                if achievement.target > 1 {
                    HStack(spacing: 10) {
                        ProgressView(value: Double(store.progress(for: achievement).count), total: Double(achievement.target))
                        Text("\(store.progress(for: achievement).count)/\(achievement.target)")
                            .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }
                }
            }
        }.padding(.vertical, 7)
    }

    private var timingCaption: some View {
        Text(achievement.pack ?? guide.firstChapter.title).font(.caption).foregroundStyle(.secondary).lineLimit(1)
    }
}

#Preview { ContentView().environmentObject(ProgressStore(defaults: UserDefaults(suiteName: "preview")!)) }
