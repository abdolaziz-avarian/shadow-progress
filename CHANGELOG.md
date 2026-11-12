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
