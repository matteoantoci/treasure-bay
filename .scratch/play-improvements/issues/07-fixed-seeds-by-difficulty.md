# 07: Fixed seeds by measured difficulty

**What to build:** Each of Labyrinths 1 to 20 is a little harder than the one before, so the Child does not get stuck at Labyrinth 16. A seed-search tool selects the seed of each Labyrinth by measured difficulty. The Parent can run the tool again to tune the curve. Spec: [spec.md](../spec.md), Part 3 (seed table, seed search, saves of today).

**Blocked by:** 05 (Labyrinth measure), 06 (Items on the main path)

**Status:** ready-for-agent

- [ ] A seed-search tool runs headless. For each slot n, it takes the first seed from 1 upward that meets all conditions of Part 3, and it prints the seed table. With `d = 1 + (n - 1) div 5`:
  - presses = T(n), with T = 3, 5, 5, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  - decisions from d to d + 2,
  - turns ≥ 2 for n ≥ 2,
  - at least 1 Item on the main path,
  - largest side branch ≤ max(6, main path length),
  - the seed has a free dead end and differs from the seed of the other slot with the same size.
- [ ] The Labyrinth plan uses the table of 20 seeds. Labyrinth n uses entry n.
- [ ] The tool output is compared with the review table in the spec. If a value differs, the tool output wins, and the ticket comment records the difference.
- [ ] A test checks for each Labyrinth 1 to 20 that the presses equal T(n) and that the other conditions hold.
- [ ] The Python port gets the seed table. The pinned wall data of Labyrinth 1 and the pinned Item IDs of Labyrinths 1 to 20 come from the port.
- [ ] A save test: a save of Labyrinth 7 from before this change, with collected Items, loads. The Labyrinth number, the Collection and `total_items` stay. Each collected ID without an Item now is dropped, and its square shows an Item again. Each collected ID that matches a new Item square hides that Item. No `save.bak` exists.
- [ ] The sizes, Item counts, Areas and Sea friends of each Labyrinth number do not change. The pinned PRNG outputs stay.
- [ ] The labyrinth-game build spec sections 4.3, 12.3, 14.1 and Open gap 4 describe the seed table.
- [ ] The full test suite passes.

## Comments

**Build note (ticket 07).**
- `tools/seed_search.gd` runs headless (`godot --headless --path . --script res://tools/seed_search.gd`, about 2 s) and prints one row for each Labyrinth in the format of the review table, then `FIXED_SEEDS = [...]`. The conditions and T(n) are in the tool, so the Parent tunes the curve there. The tool goes in number order: Labyrinth 2i does not take the seed of Labyrinth 2i - 1.
- `src/labyrinth_plan.gd`: `FIXED_SEEDS` holds the 20 seeds; `build()` uses entry n. The new `build_from_seed(number, seed)` makes the Labyrinth with its Items; `build()` and the tool use it. Random Labyrinths do not change.
- Final seed table: 1, 17, 2, 9, 85, 10, 12, 9, 8, 23, 1, 69, 29, 73, 9, 28, 73, 127, 167, 30.
- Comparison with the review table: the tool output (seed, presses, decisions, Item IDs) equals all 20 rows of the review table, and the seed search of `tests/spec_port.py` gives the same table. Differences: none.
- `tests/spec_port.py` gets `FIXED_SEEDS`, `meets_conditions()`, `seed_search()`, and `REVIEW_TABLE`. It fails if its own search does not give `FIXED_SEEDS`, and it prints the review-table differences. The k = 0 self-check of ticket 06 now builds seed n directly.
- Tests: new `tests/test_fixed_seeds.gd` (the conditions of Part 3 for Labyrinths 1 to 20, and different seeds for each size). New pins from the port: the Item IDs of Labyrinths 1 to 20, the measure of Labyrinths 1 to 20, the main path and the free dead ends of Labyrinth 2, and the Items of Labyrinth 2 in the rewards scene test. Labyrinth 1 keeps seed 1, so its wall data, decorations, Items, and the Labyrinth 1 scene tests stay. I removed `test_seeds_1_to_20_are_valid`; the new test checks the free dead end of each fixed seed.
- Save across the change: `tests/test_main_save.gd` loads a version 1 save of Labyrinth 7 with the Items of today (2,0, 2,3, and 5,2 collected; integration tip Items 2,0 2,3 5,2 1,2). The test fails on the integration tip and passes now. The old-save tests of Labyrinth 14 (Goal rule) change: now 4,1 is Item 2 and stays collected, and 3,3 and 4,3 are dropped.
- Interpretation: "its square shows an Item again" cannot hold for a dropped ID, because its square has no Item now. The test checks that the Items of the new layout that the save does not name show on the water. The build spec 12.3 errata uses this text.
- A person must check: build spec 4.6 rule 7 still says "A test checks that seeds 1 to 20 are valid". The ticket does not name section 4.6, so I did not change it. Also the manual check of labyrinth-game ticket 30 and the screenshots of Labyrinths 3, 8, 13, and 18 (ticket 08), because each layout except Labyrinth 1 changes.
