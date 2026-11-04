# 05: Labyrinth measure (prefactor)

**What to build:** One pure measure of a Labyrinth, so that the placement rule of ticket 06 and the seed search of ticket 07 use the same numbers. The game behaves the same as today after this ticket. Spec: [spec.md](../spec.md), Part 3 (measure definitions).

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] The measure takes a Labyrinth with its Items and returns:
  - the main path from the start to the Goal, and its length in moves,
  - the presses along the main path with the move rule of build spec 5.2, where each uncollected Item on the path is a stop,
  - the decisions: main-path squares with 3 or more open sides, without the start and the Goal,
  - the turns: direction changes along the main path,
  - the largest side branch: the largest group of off-path squares that connect without a main-path square,
  - the count of Items on the main path.
- [ ] The measure uses the move rule module for the presses. It does not copy the move rule.
- [ ] A cross-check test: for Labyrinths 1 to 20 and 200 random seeds, the presses of the measure equal the count of moves that the move rule gives along the main path.
- [ ] The Python port gets the same measure, written from the text of the spec. A test pins the measure values of Labyrinths 1 to 20 of today from the port.
- [ ] The Item squares and the layouts of all Labyrinths do not change.
- [ ] The full test suite passes.

## Comments

Build note (Impl05Measure):

- New module `src/labyrinth_measure.gd` (`LabyrinthMeasure`), pure and static:
  - `main_path(labyrinth) -> Array[Vector2i]`: P[0] is the start, P[L] is the Goal. It does not read the Items, so ticket 06 can call it before the Items exist.
  - `measure(labyrinth) -> Dictionary` with the keys `path`, `length`, `presses`, `decisions`, `turns`, `largest_side_branch`, `items_on_path`. It reads `labyrinth.items`, all not collected.
- The move rule stop test is now public: `MoveRule.stops_at()`. `MoveRule.plan()` and the measure both use it, so the measure does not copy the move rule. The presses are the main-path squares where the boat stops.
- `largest_side_branch` is 0 when all squares are on the main path.
- `tests/spec_port.py` has `main_path()` and `measure()`, written from the spec text (with its own slide of spec 5.2). `tests/test_labyrinth_measure.gd` pins the values of Labyrinths 1 to 20 of today from the port, and sails the boat with `MoveRule.plan()` along the main path for Labyrinths 1 to 20 and 200 random seeds.
- No Item square, layout or seed changes. The ticket lists no build-spec errata, so I did not edit `.scratch/labyrinth-game/spec.md`.
