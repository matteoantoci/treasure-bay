# 23: Saved progress

**What to build:** The Child quits and starts again at the same Labyrinth with the same Items and Collection. Spec section 12.1 to 12.3.

**Blocked by:** 22 (Labyrinths, Items, and rewards)

**Status:** ready-for-agent

- [x] The game saves after each Item and at each Goal (spec 12.2).
- [x] A restart continues at the saved Labyrinth with its seed and collected Items.
- [x] A missing file starts quietly at Labyrinth 1. A broken or newer file becomes `save.bak` and the game starts at Labyrinth 1.
- [x] Headless tests for save, load, broken file, and Item IDs pass.

## Comments

**Built (ticket 23 worker, 2026-11-04).**
- `src/save_store.gd` (`SaveStore`, `RefCounted`): `SaveStore.new(dir = "user://")` holds `save.json`, `save.json.tmp`, and `save.bak` in one folder. `save(progress) -> Error` writes the `.tmp` file, closes it, then renames it with `DirAccess.rename_absolute()`. `load_progress() -> Progress`: no file gives a new `Progress` (Labyrinth 1) and writes nothing; a broken file (each case of spec 12.3, also a newer `version`) is renamed to `save.bak` (an older `save.bak` is removed first) and gives a new `Progress`. `to_dictionary()` / `from_dictionary()` (null = broken) convert the fields of spec 12.1; the numbers become `int`. `MIGRATIONS` is the empty chain of spec 12.3; `migrate()` runs it. JSON is parsed with a `JSON` instance, so a broken file prints no engine error.
- **Main scene hooks:** `main.save_store` (tests set it before `add_child`), `_ready()` loads the progress after `randomize()`, and `item_collected` and `goal_reached` call `main.save_progress()`. Ticket 27 calls `main.save_progress()` after a Parent reset and before a quit.
- Values that the spec does not give: a `version` below 1 is broken (no older version exists). A number with a fraction (for example `labyrinth: 7.5`) and a list entry that is not a string count as a wrong type. `last_returning_friend` must be `""` or an ID of spec 4.7. A failed save gives a `push_warning` and no message to the Child.
- No reset in this ticket: the line "A reset keeps `settings.json`" of spec 14.1 test 7 is for ticket 27.
- Tests: `tests/test_save.gd` (test 7 of spec 14.1 without the reset line: save and load, the file fields, no file, 26 broken cases with an older `save.bak`, version 2, the `.tmp` write (a folder in place of `save.json` makes the rename fail and leaves the new state in the `.tmp` file), a reloaded Item that does not count again, Goal saves for Labyrinths 3, 20, and 21) and `tests/test_main_save.gd` (the scene starts at saved Labyrinth 7 and at random Labyrinth 25 with seed 4242, a broken file, the save at each Item and at the Goal before the celebration). `tests/fixtures.gd` has `new_save_dir()` / `remove_save_dir()` (a folder in the OS temp folder); `Scene.add_main(t, save_dir = "")` gives each scene its own temp folder and `Scene.remove()` deletes it, so no test touches `user://`.

**Checked.** `godot --headless --path . --import && godot --headless --path . --script res://tests/run.gd` exits 0. The user folder `~/Library/Application Support/Godot/app_userdata/Labyrinth/` has no `save.json` after the test run. `godot --path . --quit-after 120` (windowed, collects nothing) exits 0 with no script errors and writes no save. Not checked: a person quitting and starting `./play` again.
