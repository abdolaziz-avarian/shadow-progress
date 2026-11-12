import Foundation

/// These are walkthrough areas in story order, including the optional manor interlude.
/// They are planning checkpoints, not a claim that the game exposes a numbered chapter API.
enum JourneyChapter: String, CaseIterable, Identifiable, Codable {
    case cozumel, jungle, manor, kuwaqYaku, eagle, paititi, belly, head, mountain
    case cenote, upperPaititi, oilFields, sanJuan, returnPaititi, finale, cleanup, dlc
    var id: String { rawValue }
    var order: Int { Self.allCases.firstIndex(of: self)! }
    var title: String {
        switch self {
        case .cozumel: return "Cozumel"
        case .jungle: return "Peruvian Jungle"
        case .manor: return "Croft Manor"
        case .kuwaqYaku: return "Kuwaq Yaku"
        case .eagle: return "Trial of the Eagle"
        case .paititi: return "The Hidden City"
        case .belly: return "Belly of the Serpent"
        case .head: return "Head of the Serpent"
        case .mountain: return "The Mountain Temple"
        case .cenote: return "Cenote"
        case .upperPaititi: return "Upper Paititi"
        case .oilFields: return "Porvenir Oil Fields"
        case .sanJuan: return "Mission of San Juan"
        case .returnPaititi: return "Return to Paititi"
        case .finale: return "City of the Serpent"
        case .cleanup: return "After the story"
        case .dlc: return "DLC expeditions"
        }
    }
    var subtitle: String {
        switch self {
        case .cozumel: return "Hunter’s Moon · Head Above Water"
        case .jungle: return "Rough Landing"
        case .manor: return "Brave Adventurer · optional interlude"
        case .kuwaqYaku: return "Path of the Living · Path of the Dead"
        case .eagle: return "Path to the Hidden City"
        case .paititi: return "First visit · markets and side missions"
        case .belly, .head: return "The Hidden City · serpent trials"
        case .mountain: return "Eye of the Serpent"
        case .cenote: return "Eye of the Serpent · Empty-Handed"
        case .upperPaititi: return "Rebellion Lives · Last Emperor"
        case .oilFields: return "Downpour"
        case .sanJuan: return "Via Veritas · Via Crucis · Veni Vidi Perdidi"
        case .returnPaititi: return "The final preparation window"
        case .finale: return "The final story mission"
        case .cleanup: return "Free-roam collectibles and tombs"
        case .dlc: return "Seven optional adventures"
        }
    }
    var briefing: String {
        switch self {
        case .cozumel: return "Use early encounters for basic combat goals. Keep a separate save before a fight you want to retry."
        case .jungle: return "Spend your first skill points and explore the crypts. Some routes need equipment earned later."
        case .manor: return "The manor’s optional challenge is not required for achievement completion. Enjoy the interlude."
        case .kuwaqYaku: return "This is a valuable combat checkpoint: mud-wall takedowns and Eagle’s Talon become available during the story here."
        case .eagle: return "A traversal chapter. Continue working toward exploration totals; there is no exclusive combat achievement here."
        case .paititi: return "Meet merchants, begin side missions, and gather tools for later exploration. Plan skill purchases around remaining combat objectives."
        case .belly, .head: return "Follow the serpent trials. These are route checkpoints rather than separate achievement sets."
        case .mountain: return "Review unfinished combat goals before moving deeper into the story. Enemy encounters are limited."
        case .cenote: return "Traversal equipment opens new routes. Return later for collectibles you cannot yet reach."
        case .upperPaititi: return "Continue side missions and equipment upgrades. Keep unfinished combat goals on your checklist."
        case .oilFields: return "Jaguar’s Fear unlocks here. Prioritize the friendly-fire achievement during its tutorial encounters."
        case .sanJuan: return "Use remaining human encounters to finish combat goals. Exploration can wait until free roam."
        case .returnPaititi: return "Audit all 14 missable combat goals before accepting the final mission. An earlier combat save may be needed for anything still locked."
        case .finale: return "This is your final story checkpoint. Combat cleanup is safer before proceeding; do not rely on enemy respawns afterward."
        case .cleanup: return "Continue from the main menu to explore. Collectibles and tombs remain available, while combat goals may require an earlier save or a new run."
        case .dlc: return "Availability depends on the installed pack and story progress. Time and score modes can be replayed separately."
        }
    }
    var symbol: String {
        switch self {
        case .cozumel: return "sun.horizon"
        case .jungle: return "leaf"
        case .manor: return "house"
        case .kuwaqYaku: return "water.waves"
        case .eagle, .mountain: return "mountain.2"
        case .paititi, .upperPaititi, .returnPaititi: return "building.columns"
        case .belly, .head: return "puzzlepiece"
        case .cenote: return "drop"
        case .oilFields: return "flame"
        case .sanJuan: return "bell"
        case .finale: return "sun.max"
        case .cleanup: return "sparkle.magnifyingglass"
        case .dlc: return "square.stack.3d.up"
        }
    }
    /// External maps stay on their publisher's website rather than being copied into the app.
    var mapURL: URL {
        let page: String
        switch self {
        case .cozumel: page = "01-cozumel.html"
        case .jungle: page = "02-peruvian-jungle.html"
        case .manor: page = "03-croft-manor.html"
        case .kuwaqYaku: page = "04-kuwaq-yaku.html"
        case .eagle: page = "05-eagle-trial.html"
        case .paititi: page = "06-hidden-city-west.html"
        case .belly, .head: page = "07-08-serpent.html"
        case .mountain: page = "09-mountain-temple.html"
        case .cenote: page = "10-cenote.html"
        case .upperPaititi: page = "11-hidden-city-east.html"
        case .oilFields: page = "12-porvenir.html"
        case .sanJuan: page = "13-mission-san-juan.html"
        case .returnPaititi: page = "14-hidden-city-revisit.html"
        case .finale: page = "15-city-serpent.html"
        case .cleanup, .dlc: return GuideSource.maps.url
        }
        return URL(string: "https://tombraiders.net/stella/walks/TR11walk/" + page)!
    }
}

enum GuideSource: String, CaseIterable, Identifiable {
    case roadmap, walkthrough, maps
    var id: String { rawValue }
    var title: String {
        switch self {
        case .roadmap: return "PowerPyx · achievement roadmap"
        case .walkthrough: return "Stella · story walkthrough"
        case .maps: return "Stella · collectible maps"
        }
    }
    var url: URL {
        switch self {
        case .roadmap: return URL(string: "https://www.powerpyx.com/shadow-of-the-tomb-raider-trophy-guide-roadmap/")!
        case .walkthrough: return URL(string: "https://tombraiders.net/stella/shadow.html")!
        case .maps: return URL(string: "https://tombraiders.net/stella/walks/TR11walk/collectibles.html")!
        }
    }
}

enum AchievementRisk: String {
    case missable = "Missable", planning = "Plan ahead", revisit = "Revisitable", story = "Story", dlc = "DLC"
}

/// Guide metadata is separate from saved progress, so this update preserves every existing journal.
struct AchievementGuide {
    let firstChapter: JourneyChapter
    let risk: AchievementRisk
    let timing: String
    let prerequisite: String
    let advice: String
    var lastSuggestedChapter: JourneyChapter = .finale
    var verifiedWindow = false

    func availability(at current: JourneyChapter) -> String {
        if risk == .dlc { return "Depends on pack & story progress" }
        if current == .cleanup && risk == .missable { return "Earlier combat save may be needed" }
        if current.order < firstChapter.order {
            return "Ahead · \(firstChapter.order - current.order) route stops away"
        }
        if risk == .missable && current.order > lastSuggestedChapter.order { return "Check an earlier combat encounter" }
        if risk == .missable { return "Prioritize during available encounters" }
        if current.order > firstChapter.order && risk == .revisit { return "Revisit when the route is accessible" }
        return "At or beyond its suggested chapter"
    }
}

enum JourneyGuide {
    /// Only these 14 enemy-based goals are classified as missable; animal hunting is revisitable.
    static let missableIDs: Set<String> = [6, 7, 14, 19, 20, 21, 22, 23, 24, 26, 27, 28, 36, 37].map { String(format: "base-%02d", $0) }.reduce(into: Set<String>()) { $0.insert($1) }

    static func guide(for achievement: Achievement) -> AchievementGuide {
        if achievement.isDLC {
            return AchievementGuide(firstChapter: .dlc, risk: .dlc, timing: "Optional expedition · \(achievement.pack ?? "DLC")", prerequisite: "Own this pack and unlock its entry point. Individual DLC story gates vary.", advice: "Check the pack’s mission marker. Replay its tomb in Time Attack or Score Attack for medal objectives.")
        }
        let number = Int(achievement.id.suffix(2)) ?? 0
        if let guide = combat[number] { return guide }
        let chapter = suggestedChapters[number] ?? .cleanup
        let story = achievement.category == .story || number == 31
        let finish = [3, 5, 13, 16, 17, 57, 58, 59, 60, 62, 63].contains(number)
        var prerequisite = story ? "Advance the story in this area." : "Explore accessible routes and use the equipment you have unlocked."
        var advice = story ? "A story milestone; the journal still needs your manual confirmation." : "You can revisit for exploration cleanup. The suggested chapter is a planning recommendation, not a guaranteed first unlock."
        if number == 32 { prerequisite = "Both knife upgrades."; advice = "Buy the reinforced knife in Paititi and finish the Hakan side mission for the other upgrade." }
        if number == 17 { prerequisite = "Lockpick and access to the relevant regions." }
        if number == 43 { prerequisite = "Flare-round skill, ammunition, and a turkey."; advice = "This animal objective is not one of the 14 missable human-combat goals." }
        if number == 16 { prerequisite = "All required skills in one branch, including story and tomb rewards." }
        if number == 2 { advice = "Via Crucis gives a story-linked collection; optional collection work can produce an earlier unlock." }
        if number == 63 { prerequisite = "The game’s full completion checklist, not just this app’s achievement counter." }
        let timing = story ? "Story milestone · \(chapter.title)" : finish ? "Finish later · \(chapter.title)" : "Suggested starting area · \(chapter.title)"
        return AchievementGuide(firstChapter: chapter, risk: story ? .story : .revisit, timing: timing, prerequisite: prerequisite, advice: advice)
    }

    static func objectives(in chapter: JourneyChapter, catalog: [Achievement] = AchievementCatalog.all) -> [Achievement] {
        catalog.filter { achievement in
            let info = guide(for: achievement)
            if info.firstChapter == chapter { return true }
            // Carry unfinished combat planning into later encounter chapters, not peaceful interludes.
            let encounters: Set<JourneyChapter> = [.kuwaqYaku, .mountain, .upperPaititi, .oilFields, .sanJuan, .returnPaititi, .finale]
            return info.risk == .missable && encounters.contains(chapter) && chapter.order >= info.firstChapter.order
        }.sorted { (missableIDs.contains($0.id) ? 0 : 1) < (missableIDs.contains($1.id) ? 0 : 1) }
    }

    private static let suggestedChapters: [Int: JourneyChapter] = [
        1: .jungle, 2: .sanJuan, 3: .cleanup, 4: .kuwaqYaku, 5: .returnPaititi,
        8: .jungle, 9: .paititi, 10: .kuwaqYaku, 11: .paititi, 12: .kuwaqYaku,
        13: .returnPaititi, 15: .jungle, 16: .cleanup, 17: .cleanup, 18: .kuwaqYaku,
        25: .returnPaititi, 29: .paititi, 30: .cenote, 31: .cenote, 32: .upperPaititi,
        33: .jungle, 34: .jungle, 35: .jungle, 38: .kuwaqYaku, 39: .upperPaititi,
        40: .returnPaititi, 41: .kuwaqYaku, 42: .kuwaqYaku, 43: .sanJuan, 44: .paititi,
        45: .cozumel, 46: .cozumel, 47: .cozumel, 48: .jungle, 49: .kuwaqYaku,
        50: .paititi, 51: .cenote, 52: .upperPaititi, 53: .sanJuan, 54: .sanJuan,
        55: .returnPaititi, 56: .finale, 57: .finale, 58: .finale, 59: .finale,
        60: .finale, 61: .kuwaqYaku, 62: .finale, 63: .cleanup
    ]

    /// Short original planning notes summarize factual unlock gates; linked guides provide full walkthroughs.
    private static let combat: [Int: AchievementGuide] = [
        6: AchievementGuide(firstChapter: .kuwaqYaku, risk: .missable, timing: "After buying Serpent’s Strike → Serpent’s Fury", prerequisite: "1 + 2 skill points; a close enemy pair.", advice: "Reserve points before a human encounter. Count completed double takedowns, not individual enemies."),
        7: AchievementGuide(firstChapter: .cozumel, risk: .missable, timing: "Start at the first stealth encounter", prerequisite: "Unaware human enemies.", advice: "Build the total across encounters while preserving a useful combat save.", verifiedWindow: true),
        14: AchievementGuide(firstChapter: .kuwaqYaku, risk: .missable, timing: "Path of the Dead · Eagle’s Talon tutorial", prerequisite: "Story-awarded Eagle’s Talon and a usable branch.", advice: "The tutorial is an early repeatable opportunity. Confirm the platform unlock before moving on.", lastSuggestedChapter: .sanJuan, verifiedWindow: true),
        19: AchievementGuide(firstChapter: .cozumel, risk: .missable, timing: "Early human encounters", prerequisite: "An enemy search state after losing sight of Lara.", advice: "Break line of sight, wait for searching, then defeat a searching enemy."),
        20: AchievementGuide(firstChapter: .cozumel, risk: .missable, timing: "Early distraction opportunities", prerequisite: "A distractible enemy and a noise source.", advice: "Lure a guard, then take them down while investigating."),
        21: AchievementGuide(firstChapter: .oilFields, risk: .missable, timing: "Downpour · Jaguar’s Fear tutorial", prerequisite: "Story-awarded Jaguar’s Fear and fear-arrow materials.", advice: "Let a frenzied enemy defeat other enemies. This is a late unlock: plan around the tutorial.", lastSuggestedChapter: .sanJuan, verifiedWindow: true),
        22: AchievementGuide(firstChapter: .cozumel, risk: .missable, timing: "Hunter’s Moon · dig-site encounter", prerequisite: "A crafted Molotov and two close enemies.", advice: "A bottle near the early forklift encounter provides an opportunity.", verifiedWindow: true),
        23: AchievementGuide(firstChapter: .cozumel, risk: .missable, timing: "Hunter’s Moon · dig-site encounter", prerequisite: "Pistol; three quick headshots.", advice: "Use a separate save before attempting all three. Clearing a group can advance the autosave.", verifiedWindow: true),
        24: AchievementGuide(firstChapter: .cozumel, risk: .missable, timing: "Early encounters where you can hide", prerequisite: "A detected enemy losing track of Lara.", advice: "Wait for the search state before counting an escape."),
        26: AchievementGuide(firstChapter: .kuwaqYaku, risk: .missable, timing: "Once Eye of the Eagle and herbs are available", prerequisite: "Eye of the Eagle; Perception herbs.", advice: "Favor takedowns while the effect is active; guides report ordinary weapon kills can fail to count."),
        27: AchievementGuide(firstChapter: .kuwaqYaku, risk: .missable, timing: "Once Scales of the Serpent and herbs are available", prerequisite: "Scales of the Serpent; Focus herbs.", advice: "Use active-effect takedowns and verify progress on your gaming platform."),
        28: AchievementGuide(firstChapter: .kuwaqYaku, risk: .missable, timing: "Once Heart of the Jaguar and herbs are available", prerequisite: "Heart of the Jaguar; Endurance herbs.", advice: "Take down enemies before the effect wears off."),
        36: AchievementGuide(firstChapter: .cozumel, risk: .missable, timing: "Start with the first bow encounters", prerequisite: "Bow, arrows, and human enemies.", advice: "Prioritize headshots through the story rather than leaving this for free roam."),
        37: AchievementGuide(firstChapter: .kuwaqYaku, risk: .missable, timing: "Path of the Living · mud-wall tutorial", prerequisite: "Mud camouflage and a mud-covered wall.", advice: "Use the tutorial wall to ambush a passing guard. Ordinary foliage stealth does not count.", lastSuggestedChapter: .oilFields, verifiedWindow: true)
    ]
}
