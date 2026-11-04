# 01: Migration chain and newer save files

**What to build:** The Child's progress stays safe when an older build opens a save from a newer build. The migration chain can hold its first entry, so a later change to the save schema can migrate version 1 saves. Spec: [spec.md](../spec.md), Part 5 (newer save, migration chain, settings file).

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] The migration runner takes the chain and the target version as inputs. A test runs a chain of one test migration from version 1 to version 2 and gets the migrated fields.
- [ ] A save with a version above the current version is not broken. It stays in place with the same bytes, and no `save.bak` exists.
- [ ] With a newer save, the game plays Labyrinth 1 in memory. The save store is in a no-write state for the session: a collect and a Goal write nothing, and each save call logs one warning.
- [ ] A save with version 0 or less is still broken and becomes `save.bak`, as today.
- [ ] A settings file with a version above the current version gives the default steps in memory. It stays in place with the same bytes, and the game does not write it in that session.
- [ ] A settings file with version 0 or less is broken and gives the default steps. An older settings version goes through its own migration chain, which is empty now.
- [ ] The test "`version` 2 counts as broken" is replaced by the newer-save test.
- [ ] The labyrinth-game build spec sections 12.3, 12.4 and 14.1 (test 7) describe the new rules.
- [ ] The full test suite passes.

## Comments

Build note (pi/01-migration-chain-and-newer-saves):

- `JsonFile.migrate(data, version, chain, target)` is the shared migration runner. `JsonFile.version_of(data)` gives the version, or 0 for a file with no whole-number version.
- `SaveStore.migrations` and `SettingsStore.migrations` are the two chains (static vars, both empty now). A schema change raises `VERSION` and appends its migration.
- No-write state: `SaveStore.no_write` and `SettingsStore.no_write` become true when the load finds a newer file. Then `save()` writes nothing, logs one warning, and returns `OK`, so `main.gd` and the settings panel log no second warning. Ticket 02: the copy before a reset must check `save_store.no_write` and make no copy when it is true.
- A newer file is not broken even when its other fields are not valid for version 1 (a newer build can change them).
- New test helper `tests/warning_log.gd` (a `Logger` added with `OS.add_logger`) counts the warnings for the "one warning per save call" checks.
- Tests: newer save at store level (`tests/test_save.gd`) and in the main scene (`tests/test_main_save.gd`), migration chain of one (`tests/test_save.gd`), newer settings at store level (`tests/test_settings.gd`) and through the volume buttons (`tests/test_parent_controls.gd`). Broken cases add `version -1`; the `version 2` broken cases are gone.
- A person can check: no windowed run was done for this ticket.
