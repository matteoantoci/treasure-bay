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
