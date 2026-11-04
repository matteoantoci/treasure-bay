# 06: Items on the main path

**What to build:** The Child gets at least one Item on the way to the Goal in every Labyrinth, also when she sails straight to the chest. The Items in the dead ends stay. Spec: [spec.md](../spec.md), Part 1.

**Blocked by:** 05 (Labyrinth measure)

**Status:** ready-for-agent

- [ ] The on-path count is `k = min(max(1, count div 3), L - 1)`, where L is the main path length in moves. On-path Item j (1 to k) goes on `P[j * L div (k + 1)]`.
- [ ] The placement order is: Item 1 on the farthest free dead end, then the on-path Items from the start to the Goal, then the shuffled other dead ends, then the shuffled other squares. The k path squares leave the list of other squares before the shuffle. The PRNG calls do not change.
- [ ] For Labyrinths 1 to 20 and 200 random seeds: at least k Items are on the main path, no Item is on the start or the Goal, all Item squares are different, and Item 1 is on the farthest dead end.
- [ ] The Item count and the kinds rule do not change.
- [ ] A random Labyrinth keeps its layout for its saved seed. Only its Item squares change.
- [ ] The Python port gets the new rule, written from the text of the spec. The pinned Item IDs of Labyrinths 1 to 20 and of the two random seeds come from the port.
- [ ] The labyrinth-game build spec sections 4.6 and 14.1 (test 3) describe the new rule.
- [ ] The full test suite passes.
