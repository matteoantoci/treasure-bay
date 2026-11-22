# 13: Game name in the docs

**What to build:** The project docs name the game "Treasure Bay". They do not call it "the Labyrinth game" any more. The word **Labyrinth** stays as the glossary term for one grid. Source: the Parent, 2026-11-22.

**Blocked by:** 05 (Name and opening screen)

**Status:** ready-for-agent

- [x] `GLOSSARY.md`: the title and the first sentence name the game Treasure Bay.
- [x] The build spec `.scratch/labyrinth-game/spec.md`: the title, the overview, and each other mention of the game name use Treasure Bay, for example the app name and the log file name of `tools/make_app.sh`. Each change that is not only a name change gets an erratum.
- [x] The map `.scratch/labyrinth-game/map.md`, the play-improvements spec and the game-flow spec: the title or the first lines name the game Treasure Bay, where they name the game.
- [x] Code comments, test names and tool output that name the game use Treasure Bay.
- [x] Folder names, file names and links stay as they are, so no link breaks. The dated research files and the closed tickets stay as they are: they record what was true on their date.
- [x] Each use of "Labyrinth" as the glossary term stays.

Build note (gf/13-game-name-in-the-docs): Only names change, so the build spec gets no erratum. Files that change:

- `GLOSSARY.md`: the title is "Treasure Bay", and the first sentence names the game.
- `.scratch/labyrinth-game/spec.md`: the title, the text of the map link, and the overview of section 1. Section 2 and the `project.godot` table already gave `Treasure Bay.app`, `Treasure Bay.log` and the project name from ticket 05.
- `.scratch/labyrinth-game/map.md`: the title and the destination.
- `.scratch/game-flow/spec.md`: the problem statement. The "Labyrinth" user folder in part 3 and in the test list stays: it records the plan that the Parent dropped, and the build spec states the drop.

No change: the play-improvements spec does not name the game. In `src/`, `tests/` and `tools/`, no comment, test name or output names the game. Each "Labyrinth" there is the glossary term or the save field. The `Labyrinth.app` comment in `tools/make_app.sh` names the old app on purpose. A person can check with `rg -i 'labyrinth (game|app)'`.
