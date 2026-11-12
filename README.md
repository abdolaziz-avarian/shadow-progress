# Shadow Progress

A native SwiftUI iPhone companion for tracking achievements in **Shadow of the Tomb Raider**.

## Development

Open `ShadowProgress.xcodeproj` in Xcode. The app targets iOS 17 or later and iPhone only. No third-party packages, API keys, or game account are required. Select an iPhone Simulator and run the **ShadowProgress** scheme. For a physical iPhone, select your Apple development team in Signing & Capabilities.

Progress is entered manually and stored on the device; it does not sync with Steam, Xbox, or PlayStation. Achievement completion is separate from the game's own completion percentage. This is an independent fan project; game names belong to their respective owners.

Code comments explain each model, persistence operation, and screen. `CHANGELOG.md` records implementation milestones; Git commit messages describe each update.

## Features

- A chapter library with the game's 21 actual story missions, grouped into region collections.
- One primary collection per achievement: a specific story mission, Across the game, or a DLC pack.
- Chapter completion counts exclude cumulative combat goals; relevant ongoing goals appear in a separate section.
- All 99 achievement titles and requirements remain visible, with Spoiler, Missable, and DLC flairs.
- A native search tab, All/Missable/Pinned segments, progress/category filters, and swipe actions for completion and pinning.
- Manual counters, completion dates, personal notes, validated backups, and local persistence.
- System, Light, and Dark appearance with current native navigation and system content surfaces.
- An offline route map and attributed detailed game maps inside the app (internet required).
- Original jungle artwork and standard, dark, and tinted app icons.

## Build and test

Run `bash Scripts/verify.sh` on a Mac with Xcode and an installed iPhone simulator. Alternatively, open the shared **ShadowProgress** scheme and choose Product → Test. Data tests cover catalog integrity, counter bounds, completion dates, persistence after relaunch, backup round trips, rejected imports, DLC totals, recovery of unreadable saved data, and the new chapter/missable guide. UI tests cover chapter selection, the Atlas map viewer, light/dark preferences, and missable filtering, using a separate test journal.

GitHub Actions runs the same script on pushes to `main` or `codex/**` and on pull requests. Running on a physical iPhone requires your own Apple development team; simulator builds need no signing credentials.

## Project guide

| Location | Purpose |
| --- | --- |
| `ShadowProgress/Models/` | Catalog definitions, user progress, save/load, and backup validation |
| `ShadowProgress/Views/ContentView.swift` | Dashboard, achievement list, search, and filters |
| `ShadowProgress/Views/AchievementDetail.swift` | Counters, completion, pinning, and notes |
| `ShadowProgress/Views/SettingsView.swift` | Spoilers, DLC scope, backup tools, and reset |
| `ShadowProgress/Views/Theme.swift` | Semantic system surfaces and game accents |
| `ShadowProgress/Models/JourneyGuide.swift` | Chapter order, missable classifications, timing, and prerequisites |
| `ShadowProgress/Views/JourneyView.swift` | Chapter library, real story missions, global goals, and expansions |
| `ShadowProgress/Views/AtlasView.swift` | Offline route diagram and native viewer for published maps |
| `ShadowProgressTests/` | Persistence and data-integrity regression tests |
| `ShadowProgressUITests/` | Theme, chapter, map, and filter interaction checks |
| `Docs/CATALOG.md` | Achievement sources and platform scope |
| `Docs/JOURNEY.md` | Timing confidence, guide references, and map behavior |
| `Docs/ARTWORK.md` | Asset provenance and the image-generation prompt |
| `Scripts/GenerateAppIcon.swift` | Reproducible original icon artwork |

Backups include your personal notes. Export one before uninstalling the app or resetting your journal. Appearance and current-chapter preferences remain device-local and are not part of the progress backup. The PlayStation platinum trophy is not included.

The layout uses current system components when running on iOS 27, with iOS 26+ custom glass and a material fallback on older versions. Local verification uses Xcode 27.2 and the installed iOS 26.5 iPhone simulator. Chapter timing is guidance rather than a live check of your skills or remaining enemies. The Atlas route diagram is schematic; full annotated maps load directly from Stella's website and are not bundled.

Latest local validation: **17 tests passed** (15 data tests and 2 UI tests), covering mission collections, unique achievement ownership, cumulative-goal counts, visible spoiler search, themes, filters, and maps.
