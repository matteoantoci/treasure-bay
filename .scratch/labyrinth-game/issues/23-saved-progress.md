# 23: Saved progress

**What to build:** The Child quits and starts again at the same Labyrinth with the same Items and Collection. Spec section 12.1 to 12.3.

**Blocked by:** 22 (Labyrinths, Items, and rewards)

**Status:** ready-for-agent

- [ ] The game saves after each Item and at each Goal (spec 12.2).
- [ ] A restart continues at the saved Labyrinth with its seed and collected Items.
- [ ] A missing file starts quietly at Labyrinth 1. A broken or newer file becomes `save.bak` and the game starts at Labyrinth 1.
- [ ] Headless tests for save, load, broken file, and Item IDs pass.
