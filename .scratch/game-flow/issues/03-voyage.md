# 03: Voyage

**What to build:** One Voyage is 20 Labyrinths with new random seeds. The Goal of Labyrinth 20 starts a new Voyage with an empty Collection. The random Labyrinths after Labyrinth 20 and the Sea friends that come back go away. Spec: [spec.md](../spec.md), Part 1, and Testing Decisions, seam 2 and seam 3.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [x] A pure module holds `meets_conditions(number, seed)` and `new_voyage(start_value)`. The game and `tools/seed_search.gd` share it.
- [x] Each seed of `new_voyage` meets the conditions of its slot. The same `start_value` gives the same seeds. Two different values give different Voyages. The second slot of a size never takes the seed of the first slot of that size.
- [x] A slot with no seed within its maximum tries uses its seed from the fixed seed table. A test shows this.
- [x] `tools/seed_search.gd` still prints the fixed table. Its second mode measures the tries of each slot from 1000 random start seeds (largest, median), and the count of different valid seeds for the two 4 × 3 slots. The build note records the results.
- [ ] The maximum tries is at least 3 times the largest measured tries. The build note records the time of one new Voyage on this Mac. It must be 250 ms or less. If it is longer, stop and report before you change the curve.
- [x] Progress holds the Labyrinth number (1 to 20), the 20 seeds, the collected Items, the Collection, and the total Item count. The Labyrinth plan builds Labyrinth n from the seed of slot n.
- [x] The Goal of Labyrinth 20 adds the flamingo, then gives a new Voyage: Labyrinth 1, new seeds, no collected Items, an empty Collection, the same total. The game saves it before the celebration.
- [x] A Parent reset gives a new Voyage with new seeds, an empty Collection and a total of 0. The copy before a reset stays.
- [x] Save version 2 writes and loads (`version`, `labyrinth`, `seeds`, `collected_items`, `collection`, `total_items`). A `seeds` list of another length, or a seed of 0 or less, is broken.
- [x] Migration 1 to 2: a save in Labyrinths 1 to 20 keeps its Labyrinth, its Items and its Collection, with the fixed seed table. A save past Labyrinth 20 becomes a new Voyage with the same total.
- [x] Main-scene tests: the Goal of Labyrinth 20 shows Labyrinth 1 with an empty strip and the same total count. A launch from a version 1 save past Labyrinth 20 shows Labyrinth 1 with an empty strip. (Ticket 05 adds the opening screen in front of these steps.)
- [x] The random Labyrinths after Labyrinth 20, the returning Sea friend, `random_seed` and `last_returning_friend` are gone, with their tests.
- [x] `python3 tests/spec_port.py` still pins the fixed seed table and the Item IDs of Labyrinths 1 to 20.
- [x] `GLOSSARY.md` gets the terms **Voyage**, **Opening screen** and **Party** of the spec, section "General".
- [x] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.

Build note (gf/03-voyage): `src/difficulty_curve.gd` (`DifficultyCurve`) holds `meets_conditions(number, seed)`, `new_voyage(start_value, max_tries = MAX_TRIES)`, `find_seed()` and `tries_from()`. The game and `tools/seed_search.gd` share it. The own PRNG with `start_value` gives one start seed for each slot. Progress holds `seeds`. `Progress.new()` has the fixed seed table, so a first launch with no save and a broken save play the fixed table. `Progress.new_voyage(start_value, total)` gives a new Voyage. `reach_goal(start_value = randi())` starts the new Voyage after Labyrinth 20. The reset uses `Progress.new_voyage(randi())`. Save version 2 and migration `_version_1_to_2` are in `SaveStore`. A version 1 save past Labyrinth 20 gets its new Voyage at the load. The game writes it at the next save, so a quit before an Item or a Goal gives a different new Voyage at the next launch.

Differences from the spec: if the second slot of a size has no seed within its tries, both slots of that size use the fixed seed table, so the two seeds stay different. A `labyrinth` above 20 in a version 2 save is broken. `Area.for_labyrinth()` keeps its rule for numbers above 20, because `src/area.gd` is not in this ticket. No code uses it for those numbers now.

Cost (`godot --headless --path . --script res://tools/seed_search.gd -- --cost`, 1000 random start seeds, one run for each slot with `--slot n`). Largest and median tries for each slot: 1: 1433 / 328, 2: 64 / 2, 3: 76 / 5, 4: 76 / 5, 5: 399 / 44, 6: 82 / 9, 7: 130 / 15, 8: 96 / 8, 9: 119 / 10, 10: 89 / 8, 11: 295 / 27, 12: 192 / 17, 13: 188 / 21, 14: 193 / 14, 15: 294 / 22, 16: 497 / 45, 17: 415 / 40, 18: 468 / 32, 19: 465 / 42, 20: 281 / 32. The largest of all slots is 1433 (slot 1). The 4 × 3 slots: slot 1 finds 1000 different valid seeds but only 3 different Labyrinths (walls and Items). Slot 2 finds 1000 different valid seeds and 16 different Labyrinths. `MAX_TRIES` is 4300 (3 × 1433 = 4299). One try costs about 0.45 ms at 4 × 3 and 2.5 ms at 9 × 7.

**Not done: the time of one new Voyage is too long.** On this Mac (`--cost --voyage-time`, 20 Voyages, MAX_TRIES 4300) one new Voyage takes 1101 ms on average and 1592 ms at most. The limit is 250 ms. Slot 1 alone needs about 150 ms at its median. As the ticket says, the build stops here and does not change the curve. The game calls `new_voyage()` on the main thread at the Goal of Labyrinth 20, at a reset, and at the load of a version 1 save past Labyrinth 20. So the screen stops for about 1 s at these points. The suite waits for the fade-in after a reset, because the first frame after the stop takes the whole timer. A person must decide: change the curve (for example the conditions of slot 1), accept the time, or find the seeds away from the main thread (for example a thread, or the next Voyage at the start of Labyrinth 20).

