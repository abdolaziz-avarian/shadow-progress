# Achievement catalog

The bundled checklist includes the **99 Steam/Xbox achievements**: 63 in the base game and 36 across seven DLC packs. PlayStation's extra platinum trophy is outside this version's scope.

Sources checked during implementation:

- [Steam global achievement list](https://steamcommunity.com/stats/750920/achievements)
- [Exophase achievement list and DLC groupings](https://www.exophase.com/game/shadow-of-the-tomb-raider-steam/achievements/)
- [TrueAchievements platform counts](https://www.trueachievements.com/game/shadow-of-the-tomb-raider/achievements)

Titles identify in-game objectives. Requirements are concise factual paraphrases, with original wording for the checklist UI. Categories are editorial groupings. Story objectives and DLC descriptions are hidden by default to limit spoilers. The app does not redistribute game art, achievement icons, or walkthrough text.

Counters help the player keep notes; they are not live game statistics. Single-event objectives, such as three headshots in three seconds, use a single completion toggle because separate actions do not satisfy the requirement. Completing a related objective does not automatically unlock other achievements. Difficulty stacking remains the player's responsibility to verify in the game.

The catalog uses immutable IDs. Preserve existing IDs when editing text so users keep their saved progress. Update the catalog integrity test if a later release deliberately changes scope.
