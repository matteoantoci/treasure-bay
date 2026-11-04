# 22: Labyrinths, Items, and rewards

**What to build:** The Child plays through the 20 fixed Labyrinths, then random ones. Items fill the outline row. At each Goal a Sea friend joins the Collection strip. After Labyrinth 20, a random Sea friend comes back. Spec sections 4.3, 4.4, 4.6, 4.7, 6.

**Blocked by:** 20 (Skeleton: sail one Labyrinth to the Goal)

**Status:** resolved

- [x] Labyrinths 1 to 20 have the sizes and seeds of spec 4.3, and later ones are 10 × 7 random Labyrinths.
- [x] Items sit on the squares of spec 4.6. Each Item fills one outline and counts only one time.
- [x] At the Goal of Labyrinths 1 to 20, the Sea friend of spec 4.7 joins the Collection strip.
- [x] After Labyrinth 20, a random Sea friend comes back, never the same one two times in a row (spec 6.4).
- [x] Headless tests for sizes, seeds, Item placement, and the Sea friend order pass.

## Comments

**Built (ticket 22 worker, 2026-11-04).**
- Logic (`RefCounted`, `class_name`): `src/area.gd` (`Area`: `for_labyrinth(n)`, `item_kinds(area)`, `item_texture_path(kind)`, `music_path(area)`), `src/sea_friends.gd` (`SeaFriends`: `IDS` in strip order, `for_labyrinth(n)`, `slot_of(id)`, `texture_path(id)`, `pick_returning(collection, last, random_value)`), `src/item.gd` (`Item`: `square`, `kind`, `id` = `"x,y"`), `src/item_placement.gd` (`ItemPlacement`: spec 4.6), `src/progress.gd` (`Progress`, see below).
- `LabyrinthPlan.build(number, random_seed)` now also places the Items (`labyrinth.items`, the PRNG continues after the generator) and records the seed it used in `labyrinth.seed_value` (ticket 24: the wall island decoration uses `seed_value + 1`). `LabyrinthPlan.item_count(n)` gives the Item count. A random seed with no free dead end moves to seed + 1 inside `build()` (`LabyrinthPlan.valid_seed(size, seed)`), so the saved `random_seed` always rebuilds the same Labyrinth. Seeds 1 to 20 are all valid, so Open gap 4 needs no extra seed.
- **Progress model for ticket 23:** `Progress` holds the save fields of spec 12.1: `labyrinth_number` (save field `labyrinth`), `random_seed`, `collected_items` and `collection` (`PackedStringArray`), `total_items`, `last_returning_friend`. `collect_item(id)` counts an Item one time. `reach_goal()` adds the Sea friend (1 to 20) or picks the one that comes back (after 20, never `last_returning_friend`), then moves to the next Labyrinth with no collected Items and a new random seed above 20 (spec 12.2). `build_labyrinth()` makes the current Labyrinth. Item ID check for a load: the IDs of `LabyrinthPlan.build(labyrinth, random_seed).items`. Sea friend ID check: `SeaFriends.IDS`.
- **Main scene hooks:** `main.progress` (replace it, then call `main.show_labyrinth()`); signals `item_collected(item)` (after the count, so ticket 23 saves here), `goal_reached(sea_friend)` (the progress already holds the new Sea friend and Labyrinth + 1, so ticket 23 saves here, before the celebration), `sea_friend_appeared(sea_friend)` (1.4 s, for the Sea friend sound of ticket 26), `labyrinth_started(number)`, `move_finished`. The celebration is one tween in `main._reach_goal()` with the spec 6.3 times (1.4 s, 3.7 s, 4.2 s) and no motion; the input is locked from the Goal to the next Labyrinth. Ticket 25 adds the motion and the fade.
- **Plain views (ticket 24 replaces the look):** `src/items_view.gd` (one Sprite2D for each Item on the water, 60 px × s), `src/item_row.gd` (outlines at 35 % opacity, filled at full opacity; no greyscale yet), `src/collection_strip.gd` (black strip at 25 %, the total count `Label`, 20 slots). HUD math in `ScreenLayout`: `item_outline_centres`, `item_outline_px`, `collection_count_rect`, `collection_count_font_size`, `collection_slot_centres`, `collection_icon_px`, `sprite_rect` (fits the longer side of a sprite), `labyrinth_scale` (s of spec 8.1, `PROTOTYPE_TILE_PX` moved here from `BoatView`).
- Values that the spec does not give: the candidate squares of spec 4.6 rule 3 are in row order (lowest y, then lowest x) before each shuffle. The count area at the left end of the strip is 2 strip heights wide (222 px at 1200); the 20 slots share the rest.
- Tests: 3 (`tests/test_items.gd`, the Item squares of Labyrinths 1 to 20 and of 2 random seeds pinned from an independent Python run of spec 4.1, 4.2, 4.6), 6 (`tests/test_areas_and_sea_friends.gd`; the music part is a table lookup), `tests/test_progress.gd`, `tests/test_hud_layout.gd`, `tests/test_main_rewards.gd` (the scene: Items stop the boat and fill outlines one time, the crab and the flamingo join the strip, a different Sea friend comes back at Labyrinth 25, the input is locked during the celebration). Shared scene helpers moved to `tests/scene_helpers.gd`; `tests/test_main_scene.gd` uses them and waits for the celebration.

**Checked.** `godot --headless --path . --import && godot --headless --path . --script res://tests/run.gd` exits 0. `godot --path . --quit-after 120` exits 0 with no script errors. Two windowed screenshots (Labyrinth 7 with one Item collected and 6 Sea friends; random Labyrinth 21 with all 20) showed the Items, the outlines, the count, and the strip in place. Not checked: a person playing with the keyboard.
