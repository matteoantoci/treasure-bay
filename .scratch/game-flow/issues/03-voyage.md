# 03: Voyage

**What to build:** One Voyage is 20 Labyrinths with new random seeds. The Goal of Labyrinth 20 starts a new Voyage with an empty Collection. The random Labyrinths after Labyrinth 20 and the Sea friends that come back go away. Spec: [spec.md](../spec.md), Part 1, and Testing Decisions, seam 2 and seam 3.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] A pure module holds `meets_conditions(number, seed)` and `new_voyage(start_value)`. The game and `tools/seed_search.gd` share it.
- [x] Each seed of `new_voyage` meets the conditions of its slot. The same `start_value` gives the same seeds. Two different values give different Voyages. The second slot of a size never takes the seed of the first slot of that size.
- [x] A slot with no seed within its maximum tries uses its seed from the fixed seed table. A test shows this.
- [x] `tools/seed_search.gd` still prints the fixed table. Its second mode measures the tries of each slot from 1000 random start seeds (largest, median), and the count of different valid seeds for the two 4 × 3 slots. The build note records the results.
- [x] The maximum tries is at least 3 times the largest measured tries. The build note records the time of one new Voyage on this Mac. It must be 250 ms or less. If it is longer, stop and report before you change the curve.
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

Build note (gf/03-voyage): `src/difficulty_curve.gd` (`DifficultyCurve`) holds `meets_conditions(number, seed)` and `new_voyage(start_value)`, plus `find_seed()` and `tries_from()` for the tool. The game and `tools/seed_search.gd` share it. `new_voyage` picks one seed for each slot from the seed pool `src/seed_pool.gd` with the own PRNG (`prng.next() % 100`). On the seed of the first slot of its size, the second slot takes the next seed of its row. Progress holds `seeds`. `Progress.new()` has the fixed seed table, so a first launch with no save and a broken save play the fixed table. `Progress.new_voyage(start_value, total)` gives a new Voyage. `reach_goal(start_value = randi())` starts the new Voyage after Labyrinth 20. The reset uses `Progress.new_voyage(randi())`. Save version 2 and migration `_version_1_to_2` are in `SaveStore`. A version 1 save past Labyrinth 20 gets its new Voyage at the load. The game writes it at the next save, so a quit before an Item or a Goal gives a different new Voyage at the next launch.

**Decision (Parent, 2026-11-22): seed pool.** The search from a random start seed took 1101 ms on average and 1592 ms at most for one new Voyage, above the 250 ms limit. The Parent chose a seed pool. `tools/seed_search.gd -- --pool` finds the first 100 seeds from 1 upward that meet the conditions of each slot, and writes them to `src/seed_pool.gd` as a const table (no load cost). The run takes about 1.6 min. The pool rows end at seeds 1686, 439, 678, 678, 6011, 1308, 1835, 1307, 1551, 910, 3063, 2423, 2630, 2423, 3822, 5205, 6088, 4132, 6147, 4049 (slots 1 to 20). Slots 3 and 4 have the same conditions, so their rows are the same, and the second-slot rule takes the next seed. Pool size: 20 × 100 seeds. **Time of one new Voyage with the pool:** 0.009 ms on average, 0.031 ms at most (1000 Voyages, `-- --cost --voyage-time`). The maximum tries and the fallback to the fixed seed table are gone, because the pool cannot miss. A test checks each of the 2000 pool seeds against its conditions (about 3 s).

Differences from the spec: the spec says a search from a random start seed with a maximum of tries and a fallback to the fixed seed table. By the Parent decision, the build picks from the seed pool and has no tries and no fallback. The ticket box "The maximum tries is at least 3 times the largest measured tries" is ticked as replaced by the pool. A `labyrinth` above 20 in a version 2 save is broken. `Area.for_labyrinth()` keeps its rule for numbers above 20, because `src/area.gd` is not in this ticket. No code uses it for those numbers now.

Cost of the search (`-- --cost`, 1000 random start seeds, one run for each slot with `--slot n`), kept for a later curve change. Largest and median tries for each slot: 1: 1433 / 328, 2: 64 / 2, 3: 76 / 5, 4: 76 / 5, 5: 399 / 44, 6: 82 / 9, 7: 130 / 15, 8: 96 / 8, 9: 119 / 10, 10: 89 / 8, 11: 295 / 27, 12: 192 / 17, 13: 188 / 21, 14: 193 / 14, 15: 294 / 22, 16: 497 / 45, 17: 415 / 40, 18: 468 / 32, 19: 465 / 42, 20: 281 / 32. One try costs about 0.45 ms at 4 × 3 and 2.5 ms at 9 × 7. The 4 × 3 slots: slot 1 finds 1000 different valid seeds but only 3 different Labyrinths (walls and Items). Slot 2 finds 16 different Labyrinths. Slot 1 with only 3 Labyrinths is a property of the curve (T(1) = 3 presses at 4 × 3). The Parent keeps it with no change.

## Follow-up 03b

**Problem:** the pool held 100 seeds for each slot, but different seeds can give the same Labyrinth. The second-slot rule compared seed numbers, so slots 3 and 4 could show the same Labyrinth. No test ran the Item placement rules over the pool seeds.

- [x] `DifficultyCurve.layout_key(labyrinth)` gives the layout of a built Labyrinth: the wall bits of each square row by row, then the Item IDs in placement order (the ID of an Item is its square). The pool tool and the curve module share it.
- [x] `tools/seed_search.gd -- --pool` keeps, for each slot, only seeds with a layout that is new in that slot, up to 100 layouts. It scans the seeds 1 to 50000 of each slot (`POOL_SCAN_LIMIT`). It also writes `SeedPool.LAYOUTS`: a layout number for each seed. The two slots of a size share the numbers.
- [x] The second-slot rule of `new_voyage` compares layout numbers: on the layout of the first slot of the size, the second slot takes the next seed of its row. No two seeds of a row have the same layout, so the next seed has a different layout.
- [x] Tests: no two seeds of one pool row have the same layout. The layout numbers match the layouts. For the start values 1 to 300, the two slots of each size have different layouts. Each Labyrinth of the pool follows the Item placement rules (the checks that ran over 200 random seeds before ticket 03).
- [x] One new Voyage stays far under 250 ms.

Build note (gf/03b-pool-by-layout): the pool run takes 3 min 18 s on this Mac. Layouts for each slot (scan up to seed 50000, and the seed of the last new layout):

| Slot | Layouts | Scan ends at seed | Last new layout at seed |
|---|---|---|---|
| 1 | 3 | 50000 | 9 |
| 2 | 16 | 50000 | 576 |
| 3 | 26 | 50000 | 1088 |
| 4 | 26 | 50000 | 1088 |
| 5 | 68 | 50000 | 49679 |
| 6 | 100 | 1623 | 1623 |
| 7 | 100 | 1953 | 1953 |
| 8 | 100 | 1307 | 1307 |
| 9 | 100 | 1551 | 1551 |
| 10 | 100 | 910 | 910 |
| 11 | 100 | 3063 | 3063 |
| 12 | 100 | 2423 | 2423 |
| 13 | 100 | 2630 | 2630 |
| 14 | 100 | 2423 | 2423 |
| 15 | 100 | 3822 | 3822 |
| 16 | 100 | 5205 | 5205 |
| 17 | 100 | 6088 | 6088 |
| 18 | 100 | 4132 | 4132 |
| 19 | 100 | 6147 | 6147 |
| 20 | 100 | 4049 | 4049 |

Slots 1 to 4 find no new layout for more than 48000 seeds, so these counts are the layouts of their conditions. Slot 5 still finds new layouts slowly (61 layouts up to seed 30000, 68 up to seed 50000). The old pool had seeds with the same layout in slots 1 to 7. Slots 8 to 20 had none: their rows did not change.

Slots that share a size: the layout is a function of the seed, the size and the Item count, and the two slots of a size have the same size and Item count. Slots with different presses T(n) cannot share a layout, because the measure of a layout is fixed. Slots 3 and 4 have the same conditions (T = 5, d = 1), so their rows are the same 26 layouts. The pool tool prints the shared layouts: 26 for slots 3 and 4, 0 for the other pairs. Before this follow-up, slots 3 and 4 of a Voyage could have the same Labyrinth. The rule on layout numbers stops this.

**Time of one new Voyage:** 0.008 ms on average, 0.028 ms at most, over 1000 new Voyages (`-- --cost --voyage-time`). The new tests add about 2.7 s to the suite (1.0 s for the layouts of the 300 Voyages and of the pool, 1.6 s for the placement rules over the 1639 pool seeds).

A person must check: a Voyage repeats a Labyrinth 1 of an earlier Voyage often, because slot 1 has only 3 layouts (the Parent kept this). The Python port does not read the pool. It still checks the placement rules only for the fixed seed table.
