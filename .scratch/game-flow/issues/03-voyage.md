# 03: Voyage

**What to build:** One Voyage is 20 Labyrinths with new random seeds. The Goal of Labyrinth 20 starts a new Voyage with an empty Collection. The random Labyrinths after Labyrinth 20 and the Sea friends that come back go away. Spec: [spec.md](../spec.md), Part 1, and Testing Decisions, seam 2 and seam 3.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A pure module holds `meets_conditions(number, seed)` and `new_voyage(start_value)`. The game and `tools/seed_search.gd` share it.
- [ ] Each seed of `new_voyage` meets the conditions of its slot. The same `start_value` gives the same seeds. Two different values give different Voyages. The second slot of a size never takes the seed of the first slot of that size.
- [ ] A slot with no seed within its maximum tries uses its seed from the fixed seed table. A test shows this.
- [ ] `tools/seed_search.gd` still prints the fixed table. Its second mode measures the tries of each slot from 1000 random start seeds (largest, median), and the count of different valid seeds for the two 4 × 3 slots. The build note records the results.
- [ ] The maximum tries is at least 3 times the largest measured tries. The build note records the time of one new Voyage on this Mac. It must be 250 ms or less. If it is longer, stop and report before you change the curve.
- [ ] Progress holds the Labyrinth number (1 to 20), the 20 seeds, the collected Items, the Collection, and the total Item count. The Labyrinth plan builds Labyrinth n from the seed of slot n.
- [ ] The Goal of Labyrinth 20 adds the flamingo, then gives a new Voyage: Labyrinth 1, new seeds, no collected Items, an empty Collection, the same total. The game saves it before the celebration.
- [ ] A Parent reset gives a new Voyage with new seeds, an empty Collection and a total of 0. The copy before a reset stays.
- [ ] Save version 2 writes and loads (`version`, `labyrinth`, `seeds`, `collected_items`, `collection`, `total_items`). A `seeds` list of another length, or a seed of 0 or less, is broken.
- [ ] Migration 1 to 2: a save in Labyrinths 1 to 20 keeps its Labyrinth, its Items and its Collection, with the fixed seed table. A save past Labyrinth 20 becomes a new Voyage with the same total.
- [ ] Main-scene tests: the Goal of Labyrinth 20 shows Labyrinth 1 with an empty strip and the same total count. A launch from a version 1 save past Labyrinth 20 shows Labyrinth 1 with an empty strip. (Ticket 05 adds the opening screen in front of these steps.)
- [ ] The random Labyrinths after Labyrinth 20, the returning Sea friend, `random_seed` and `last_returning_friend` are gone, with their tests.
- [ ] `python3 tests/spec_port.py` still pins the fixed seed table and the Item IDs of Labyrinths 1 to 20.
- [ ] `GLOSSARY.md` gets the terms **Voyage**, **Opening screen** and **Party** of the spec, section "General".
- [ ] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.
