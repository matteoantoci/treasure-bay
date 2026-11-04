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
