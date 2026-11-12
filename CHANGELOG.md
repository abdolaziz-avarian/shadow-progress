# Development log

## 0.1 — Project foundation

- Named the iPhone app **Shadow Progress**.
- Created a native SwiftUI project targeting iOS 17+ without external dependencies.
- Added documentation and ignored personal Xcode state and build products.

Subsequent milestones are committed separately with explanatory Git messages.

## 0.2 — Achievement journal

- Added 63 base-game and 36 DLC achievements with stable identifiers and source documentation.
- Built an expedition dashboard, category summaries, searchable/filterable achievement list, and detailed objectives.
- Added manual counters, completion dates, pins, notes, and local persistence.
- Added spoiler hiding and a DLC scope toggle that preserves hidden progress.
- Added validated JSON backup import/export, confirmation dialogs, and recovery copies for unreadable saves.
- Created original icon artwork and landscape illustrations without using game assets.
- Verified a Debug build for the iPhone simulator.

## 0.3 — Validation and maintenance

- Added regression tests for persistence, backups, counts, and catalog integrity.
- Enabled Debug testability for the unit-test target.
- Kept pending import data separate from confirmation-dialog presentation state.
- Made the completed expedition button open the completed-achievement view.
- Added a portable simulator verification script and GitHub Actions workflow.
- Documented project structure and how to run the app on an iPhone.

## 1.1 — Themed chapter planner and Atlas

- Reworked navigation into Expedition, Journey, Achievements, and Atlas using native iPhone components.
- Added semantic jungle/stone/gold colors for System, Light, and Dark appearance, with availability-gated glass controls.
- Added original jungle-temple header artwork and refreshed standard, dark, and tinted app icons.
- Added the 15-area story route, chapter plans, prerequisites, and a persistent current-checkpoint preference.
- Emphasized all 14 missable human-combat achievements with a priority filter, early/late opportunity guidance, and a pre-finale audit.
- Distinguished verified practical encounter windows from suggested planning chapters; preserved all existing achievement identifiers and backups.
- Added a zoomable offline region-route diagram and attributed detailed game maps in the in-app Safari viewer.
- Expanded data tests and added isolated UI tests for chapter selection, map presentation, theme switching, and filtering.
- Added source/provenance documentation and made newer GitHub pushes supersede older CI runs.
- Verified the iPhone Simulator build, 12 data tests, and 2 UI tests. Reviewed light/dark, chapter, filter, and Atlas screenshots.


## 1.2 — Mission library and visible achievement flairs

- Replaced the four-tab dashboard layout with Chapters, Map, and the native Search tab.
- Replaced the 15-area checklist with the 21 actual story missions in browsable region collections.
- Assigned every achievement one primary home and separated ongoing combat goals from chapter completion counts.
- Moved global collections, difficulty runs, and cumulative tasks into Across the game; grouped DLC by pack with a separate cross-pack goal.
- Removed all spoiler concealment and the DLC visibility toggle. All names and descriptions are visible with informational flairs.
- Used native system content surfaces, restrained glass navigation, a compact Continue card, and adaptive collection tiles.
- Added swipe completion/pinning, search over spoiler titles and requirements, organization integrity tests, and updated UI regression checks.
- Preserved saved progress and migrated the current navigation checkpoint into the new mission hierarchy.
- Verified the simulator build and all 17 tests, including visible spoiler titles/requirements and correct chapter-only progress counts.
