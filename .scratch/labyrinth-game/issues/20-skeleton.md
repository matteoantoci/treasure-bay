# 20: Skeleton: sail one Labyrinth to the Goal

**What to build:** The Parent runs `./play`. Godot opens in exclusive fullscreen and shows Labyrinth 1 with plain water and island tiles. The arrow keys move the boat by the move rule. At the Goal, the next Labyrinth starts. Spec sections 3, 4.1, 4.2, 4.5, 5.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [x] `./play` starts the game on the Parent's Mac and checks the Godot version (spec 3.3).
- [x] The seeded PRNG and the generator give the same Labyrinth for the same seed.
- [x] One arrow press moves the boat to the next junction, bend, dead end, or Goal. At a wall, the boat bumps and stays.
- [x] Reaching the Goal starts the next Labyrinth.
- [x] Headless tests for the PRNG, the generator, and the move rule pass (spec 14.1).

## Comments

**Built (ticket 20 worker, 2026-11-04).**
- `./play` (spec 3.3, executable), `project.godot` (spec 3.4 values, plus the 4 move actions on the physical arrow keys of spec 5.1), `main.tscn` (plain `res://` main scene; the root `Main` has `texture_filter = 4`, LINEAR_WITH_MIPMAPS, spec 3.5).
- Logic in `RefCounted` scripts with `class_name`: `src/prng.gd` (`Prng`, xorshift32, spec 4.1), `src/labyrinth.gd` (`Labyrinth`: wall bits, open sides, BFS distances, squares and tiles of spec 4.5, Goal island tile), `src/labyrinth_generator.gd` (`LabyrinthGenerator`, recursive backtracker, spec 4.2; the caller keeps the PRNG for Item placement), `src/labyrinth_plan.gd` (`LabyrinthPlan`: sizes and seeds of spec 4.3 and 4.4, `build(number, random_seed)`), `src/move_rule.gd` (`MoveRule.plan()`: spec 5.2 stops, bump, rotation, 180 ms per tile), `src/screen_layout.gd` (`ScreenLayout`: Labyrinth tile size and place of spec 10).
- View: `src/main.gd` (tweens for the slide and the bump, one kept press while busy, next Labyrinth at the Goal; signals `labyrinth_started(number)` and `move_finished`), `src/labyrinth_view.gd` and `src/boat_view.gd` (plain colours; ticket 24 replaces them with the Kenney look).
- `tests/run.gd` finds every `tests/test_*.gd`. The test file shape is documented at its top: `func test_x(t) -> bool`, `t.assert_eq`, `t.assert_true`, `await t.wait_for(signal, timeout)`. Shared helpers: `tests/fixtures.gd` (Labyrinth from a tile picture).
- Tests: 1 (`test_prng.gd`), 2 (`test_generator.gd`, Labyrinth 1 walls pinned from an independent Python run), 4 (`test_move_rule.gd`), 11 (`test_project_settings.gd`), plus `test_labyrinth.gd`, `test_screen_layout.gd`, and `test_main_scene.gd` (arrow keys through `Input.parse_input_event` sail Labyrinths 1 to 3 to their Goals).

**Checked.** `godot --headless --path . --import && godot --headless --path . --script res://tests/run.gd` exits 0 (`Results: 1399 passed, 0 failed`, with the tests of tickets 21 and 29 merged). `./play` ran through a `godot` shim that adds `--quit-after 120`: exit 0, no script errors; with a fake version 4.6.1 it printed the message and still started. `godot --path . --quit-after 120` (exclusive fullscreen) exits 0 with no errors. A `--write-movie` frame showed Labyrinth 1 as drawn in `test_generator.gd`. Not checked: a person playing with the keyboard.
