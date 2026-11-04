# 02: Safer reset

**What to build:** The Child cannot reset the game by accident, and the Parent can restore the progress after a reset by mistake. The reset needs a longer hold and has its own ring colour. Before each reset, the game keeps a copy of the save. Spec: [spec.md](../spec.md), Part 5 (hold time, ring colour, copy before a reset).

**Blocked by:** 01 (Migration chain and newer save files)

**Status:** resolved

- [x] The hold time and the full ring colour are values of each hold button.
- [x] A reset hold of 7.9 s does nothing, and the ring goes back to empty. A reset hold of 8 s resets.
- [x] The reset ring fills in `#ff7a59`. The quit ring stays `#ffd447`.
- [x] A quit hold of 3 s still quits.
- [x] Before the reset writes the new save, `save.before-reset.json` holds the old progress. The copy uses a temporary file and then a rename.
- [x] The reset makes the copy only when the progress is not fresh. Fresh progress is Labyrinth 1, an empty Collection and `total_items` 0.
- [x] Two resets in a row keep the first copy: the copy still holds the progress from before the first reset.
- [x] A reset after new play (for example one collected Item) replaces the older copy.
- [x] With no save file, the reset makes no copy.
- [x] In the no-write state of ticket 01, the reset makes no copy and writes no save.
- [x] The labyrinth-game build spec section 11.2 gives the 8 s hold, the ring colours, the copy, and the steps for the Parent to restore it: quit, then rename the copy to `save.json`.
- [x] The full test suite passes.

## Comments

Build note (pi/02-safer-reset):

- `HoldButton.new(kind, hold_seconds, ring_full_colour)`: the hold time and the full ring colour are values of each button. `SettingsPanel` gives the reset 8 s and `#ff7a59`, and the quit 3 s and `#ffd447`. The constant `HoldButton.HOLD_SECONDS` is gone; tests and `tools/take_shots.gd` use `panel.reset_button.hold_seconds`, and `tests/quit_probe.gd` holds the quit for 3.0 s.
- `SaveStore.copy_before_reset(progress)` copies the bytes of save.json to `save.before-reset.json` through `save.before-reset.json.tmp` and a rename (new `JsonFile.write_text`, which `JsonFile.write` now uses). It makes no copy for fresh progress (`Progress.is_fresh()`), with no save.json, or when `no_write` is true. `main.gd` `_reset_progress()` calls it before the new save.
- Decision not in the spec: if the copy fails, the game logs one warning and the reset goes on (the Parent held the button for 8 s). Build spec 11.2 says this.
- Tests: `tests/test_hold_button.gd` (own hold time and colour of each button), `tests/test_parent_controls.gd` (reset 7.9 s does nothing, 8 s resets; ring colours; quit probe 3 s), `tests/test_save.gd` (copy, restore by rename, .tmp first, two resets, reset after new play, no save file, no-write state).
- A person must check: in the build spec, section 14.3 check 10 and section 15 criterion 17 still say "a hold of 3 s" for the reset. This ticket edits only section 11.2. No windowed run was done, so the orange ring on screen is not checked by eye.
