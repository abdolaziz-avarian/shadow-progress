import SwiftUI

/// The root owns browsing preferences; the store owns all achievement progress.
struct ContentView: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("includeDLC") private var includeDLC = true
    @AppStorage("hideSpoilers") private var hideSpoilers = true
    @State private var selectedTab = 0
    @State private var search = ""
    @State private var filter = AchievementFilter.all
    @State private var category: AchievementCategory?
    @State private var sort = AchievementSort.catalog

    private var catalog: [Achievement] {
        AchievementCatalog.all.filter { includeDLC || !$0.isDLC }
    }

    private var filtered: [Achievement] {
        let result = catalog.filter { achievement in
            let progress = store.progress(for: achievement)
            let visible = !hideSpoilers || !achievement.isSpoiler || store.isComplete(achievement)
            let matchesSearch = search.isEmpty || (visible && (achievement.title.localizedCaseInsensitiveContains(search) || achievement.requirement.localizedCaseInsensitiveContains(search))) || achievement.category.rawValue.localizedCaseInsensitiveContains(search) || (achievement.pack?.localizedCaseInsensitiveContains(search) ?? false)
            let matchesStatus: Bool
            switch filter {
            case .all: matchesStatus = true
            case .remaining: matchesStatus = !store.isComplete(achievement)
            case .inProgress: matchesStatus = progress.count > 0 && !store.isComplete(achievement)
            case .completed: matchesStatus = store.isComplete(achievement)
            case .favorites: matchesStatus = progress.isFavorite
            }
            return matchesSearch && matchesStatus && (category == nil || category == achievement.category)
        }
        switch sort {
        case .catalog: return result
        case .title:
            // Hidden titles must not leak story information through alphabetical ordering.
            return result.sorted { displayTitle($0).localizedStandardCompare(displayTitle($1)) == .orderedAscending }
        case .progress:
            return result.sorted { Double(store.progress(for: $0).count) / Double($0.target) > Double(store.progress(for: $1).count) / Double($1.target) }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { dashboard }
                .tabItem { Label("Expedition", systemImage: "mountain.2") }.tag(0)
            NavigationStack { achievements }
                .tabItem { Label("Achievements", systemImage: "trophy") }.tag(1)
            NavigationStack { SettingsView() }
                .tabItem { Label("Field Kit", systemImage: "backpack") }.tag(2)
        }
        .alert("Storage notice", isPresented: Binding(get: { store.storageMessage != nil }, set: { if !$0 { store.storageMessage = nil } })) {
            Button("OK") { store.storageMessage = nil }
        } message: { Text(store.storageMessage ?? "") }
    }

    private var dashboard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("YOUR EXPEDITION JOURNAL").font(.caption.weight(.semibold)).tracking(2).foregroundStyle(Theme.gold)
                    Text("Every discovery\ncounts.").font(.largeTitle.bold())
                    Text("Shadow of the Tomb Raider").font(.subheadline).foregroundStyle(Theme.muted)
                    ExpeditionLandscape().frame(height: 150)
                }
                .padding(.top, 10)

                HStack(spacing: 24) {
                    ProgressRing(fraction: store.fraction(in: catalog))
                    VStack(alignment: .leading, spacing: 6) {
                        Text("THE ROAD TO 100%").font(.caption2.bold()).tracking(1.2).foregroundStyle(Theme.gold)
                        Text("\(store.completedCount(in: catalog)) / \(catalog.count)").font(.title.bold().monospacedDigit())
                        Text("achievements unlocked").font(.subheadline).foregroundStyle(Theme.muted)
                        Text(includeDLC ? "Base game + all DLC" : "Base game only").font(.caption).foregroundStyle(Theme.muted)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).expeditionCard()

                Button {
                    filter = .remaining; category = nil; search = ""; selectedTab = 1
                } label: {
                    HStack {
                        Image(systemName: "location.north.fill")
                        Text(store.completedCount(in: catalog) == catalog.count ? "Review your expedition" : "Continue the expedition").fontWeight(.semibold)
                        Spacer(); Image(systemName: "arrow.right")
                    }.padding(18).foregroundStyle(Theme.background)
                        .background(Theme.gold, in: RoundedRectangle(cornerRadius: 16))
                }

                Text("EXPLORE YOUR PROGRESS").font(.caption.bold()).tracking(1.5).foregroundStyle(Theme.muted)
                VStack(spacing: 18) {
                    ForEach(AchievementCategory.allCases.filter { includeDLC || $0 != .dlc }) { item in
                        let items = catalog.filter { $0.category == item }
                        Button {
                            category = item; filter = .all; search = ""; selectedTab = 1
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: item.symbol).font(.title3).frame(width: 28).foregroundStyle(Theme.gold)
                                VStack(alignment: .leading, spacing: 7) {
                                    HStack {
                                        Text(item.rawValue).foregroundStyle(.white)
                                        Spacer()
                                        Text("\(store.completedCount(in: items))/\(items.count)").font(.caption.monospacedDigit()).foregroundStyle(Theme.muted)
                                    }
                                    ProgressView(value: store.fraction(in: items))
                                }
                            }
                        }.buttonStyle(.plain)
                    }
                }.expeditionCard()

                let pinned = catalog.filter { store.progress(for: $0).isFavorite && !store.isComplete($0) }
                if !pinned.isEmpty {
                    Text("PINNED OBJECTIVES").font(.caption.bold()).tracking(1.5).foregroundStyle(Theme.muted)
                    ForEach(pinned.prefix(3)) { achievement in
                        NavigationLink { AchievementDetail(achievement: achievement) } label: {
                            AchievementRow(achievement: achievement, hideSpoilers: hideSpoilers)
                        }.buttonStyle(.plain)
                    }
                }
                Text("A manual achievement journal. Your game’s completion percentage is tracked separately in the game.")
                    .font(.caption).foregroundStyle(Theme.muted)
            }.padding(20)
        }
        .background(Theme.background)
        .navigationTitle("Shadow Progress")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var achievements: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(filtered.count) objectives").font(.subheadline).foregroundStyle(Theme.muted)
                    Spacer()
                    if category != nil {
                        Button { category = nil } label: { Label("Clear category", systemImage: "xmark.circle") }.font(.caption)
                    }
                }.padding(.vertical, 4)
                if filtered.isEmpty {
                    ContentUnavailableView("No achievements here", systemImage: "binoculars", description: Text("Try a different search or filter. Hidden story titles are excluded from search until revealed in Field Kit."))
                }
                ForEach(filtered) { achievement in
                    NavigationLink { AchievementDetail(achievement: achievement) } label: {
                        AchievementRow(achievement: achievement, hideSpoilers: hideSpoilers)
                    }.buttonStyle(.plain)
                }
            }.padding(20)
        }
        .background(Theme.background)
        .navigationTitle(category?.rawValue ?? "Achievements")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $search, prompt: "Find an achievement")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Status", selection: $filter) { ForEach(AchievementFilter.allCases) { Text($0.rawValue).tag($0) } }
                    Picker("Category", selection: $category) {
                        Text("All categories").tag(nil as AchievementCategory?)
                        ForEach(AchievementCategory.allCases.filter { includeDLC || $0 != .dlc }) { Text($0.rawValue).tag(Optional($0)) }
                    }
                    Picker("Order", selection: $sort) { ForEach(AchievementSort.allCases) { Text($0.rawValue).tag($0) } }
                } label: { Label("Filter: \(filter.rawValue)", systemImage: filter == .all && category == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill") }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Text(filter.rawValue).fontWeight(.semibold)
                Spacer()
                Text("\(store.completedCount(in: catalog)) of \(catalog.count) unlocked")
            }.font(.caption).foregroundStyle(Theme.muted).padding().background(.ultraThinMaterial)
        }
        .onChange(of: includeDLC) { _, enabled in if !enabled && category == .dlc { category = nil } }
    }

    private func displayTitle(_ achievement: Achievement) -> String {
        hideSpoilers && achievement.isSpoiler && !store.isComplete(achievement) ? "Hidden achievement" : achievement.title
    }
}

enum AchievementFilter: String, CaseIterable, Identifiable {
    case all = "All", remaining = "Remaining", inProgress = "In progress", completed = "Completed", favorites = "Pinned"
    var id: String { rawValue }
}

enum AchievementSort: String, CaseIterable, Identifiable {
    case catalog = "Catalog order", title = "Title", progress = "Most progress"
    var id: String { rawValue }
}

/// A row opens details; its separate completion control has an explicit accessible label.
struct AchievementRow: View {
    @EnvironmentObject private var store: ProgressStore
    let achievement: Achievement
    let hideSpoilers: Bool
    private var hidden: Bool { hideSpoilers && achievement.isSpoiler && !store.isComplete(achievement) }
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: store.isComplete(achievement) ? "checkmark.seal.fill" : hidden ? "eye.slash" : achievement.category.symbol)
                .font(.title2).foregroundStyle(store.isComplete(achievement) ? Theme.gold : Theme.muted)
                .frame(width: 30).padding(.top, 3)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(hidden ? "Hidden achievement" : achievement.title).font(.headline).foregroundStyle(.white)
                    if store.progress(for: achievement).isFavorite { Image(systemName: "pin.fill").font(.caption).foregroundStyle(Theme.gold) }
                }
                Text(hidden ? "Open to reveal this objective" : achievement.requirement)
                    .font(.subheadline).foregroundStyle(Theme.muted).lineLimit(2)
                if achievement.target > 1 {
                    HStack {
                        ProgressView(value: Double(store.progress(for: achievement).count), total: Double(achievement.target))
                        Text("\(store.progress(for: achievement).count)/\(achievement.target)").font(.caption.monospacedDigit()).foregroundStyle(Theme.gold)
                    }.padding(.top, 3)
                }
                Text(achievement.pack ?? achievement.category.rawValue).font(.caption2).foregroundStyle(Theme.gold.opacity(0.8))
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(Theme.muted).padding(.top, 6)
        }.frame(maxWidth: .infinity, alignment: .leading).expeditionCard()
    }
}

#Preview { ContentView().environmentObject(ProgressStore(defaults: UserDefaults(suiteName: "preview")!)) }
