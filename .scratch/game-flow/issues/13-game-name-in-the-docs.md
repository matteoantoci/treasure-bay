# 13: Game name in the docs

**What to build:** The project docs name the game "Treasure Bay". They do not call it "the Labyrinth game" any more. The word **Labyrinth** stays as the glossary term for one grid. Source: the Parent, 2026-11-22.

**Blocked by:** 05 (Name and opening screen)

**Status:** ready-for-agent

- [ ] `GLOSSARY.md`: the title and the first sentence name the game Treasure Bay.
- [ ] The build spec `.scratch/labyrinth-game/spec.md`: the title, the overview, and each other mention of the game name use Treasure Bay, for example the app name and the log file name of `tools/make_app.sh`. Each change that is not only a name change gets an erratum.
- [ ] The map `.scratch/labyrinth-game/map.md`, the play-improvements spec and the game-flow spec: the title or the first lines name the game Treasure Bay, where they name the game.
- [ ] Code comments, test names and tool output that name the game use Treasure Bay.
- [ ] Folder names, file names and links stay as they are, so no link breaks. The dated research files and the closed tickets stay as they are: they record what was true on their date.
- [ ] Each use of "Labyrinth" as the glossary term stays.
