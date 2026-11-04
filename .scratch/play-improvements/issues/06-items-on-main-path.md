# 06: Items on the main path

**What to build:** The Child gets at least one Item on the way to the Goal in every Labyrinth, also when she sails straight to the chest. The Items in the dead ends stay. Spec: [spec.md](../spec.md), Part 1.

**Blocked by:** 05 (Labyrinth measure)

**Status:** resolved

- [x] The on-path count is `k = min(max(1, count div 3), L - 1)`, where L is the main path length in moves. On-path Item j (1 to k) goes on `P[j * L div (k + 1)]`.
- [x] The placement order is: Item 1 on the farthest free dead end, then the on-path Items from the start to the Goal, then the shuffled other dead ends, then the shuffled other squares. The k path squares leave the list of other squares before the shuffle. The PRNG calls do not change.
- [x] For Labyrinths 1 to 20 and 200 random seeds: at least k Items are on the main path, no Item is on the start or the Goal, all Item squares are different, and Item 1 is on the farthest dead end.
- [x] The Item count and the kinds rule do not change.
- [x] A random Labyrinth keeps its layout for its saved seed. Only its Item squares change.
- [x] The Python port gets the new rule, written from the text of the spec. The pinned Item IDs of Labyrinths 1 to 20 and of the two random seeds come from the port.
- [x] The labyrinth-game build spec sections 4.6 and 14.1 (test 3) describe the new rule.
- [x] The full test suite passes.

## Comments

**Build note (ticket 06).**
- `src/item_placement.gd`: `place()` puts Item 1 on the farthest free dead end, then the k squares `P[j * L div (k + 1)]` of `LabyrinthMeasure.main_path()`, then the shuffled other dead ends, then the shuffled other squares without the k path squares. The PRNG calls stay the same: the same two shuffles in the same order.
- `tests/spec_port.py`: `place()` gets the rule from the spec text, with an optional `k`. `check_placement()` runs first and fails the port if the rule with k = 0 does not give the old Item IDs of Labyrinths 1 to 20 and of seeds 4242 and 123456789, or if a Labyrinth 1 to 20 or a random seed 1 to 200 breaks the placement rules.
- Tests: new pins in `tests/test_items.gd` (Item IDs from the port, and the wall bits of random seed 4242 for "the layout stays"). `_check_items` checks at least k Items on the main path. `tests/test_labyrinth_measure.gd` gets new measure pins from the port (the presses and the Items on the path change with the Items).
- Labyrinth 1 now has its Items on 1,1 and 0,2. The Item 0,2 is on the bend, so the first press down collects it. The scene tests that sailed Labyrinth 1 (input, rewards, motion, save, sound, main scene, quit probe) use the new Item. The old-save tests use Labyrinth 14 with the old Item 4,3, which is still Item 1 now.
- Build spec errata: 4.6 rule 3 has the new rule; the rule numbers stay, so the code references to 4.6 rules 1, 4, and 7 stay true. 14.1 test 3 lists the new checks.
- Values different from the spec: none. The spec Testing Decisions say "equals k" Items on the path; the ticket says "at least k". The test checks "at least k", because the shuffle can put more Items on the path (for example Labyrinth 8, 13, 16, 18).
- A person must check: nothing for this ticket. Ticket 07 changes the layouts of Labyrinths 1 to 20, so these pins and the Labyrinth 1 scene tests change again there.
