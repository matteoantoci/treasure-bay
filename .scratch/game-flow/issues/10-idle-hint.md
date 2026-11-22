# 10: Idle hint

**What to build:** When the Child presses no key for a while, the open chest or the nearest uncollected Item hops, to show where to go. Spec: [spec.md](../spec.md), Part 5, fix 10.

**Blocked by:** 06 (Padlock on the chest)

**Status:** ready-for-agent

- [ ] If no key is pressed for 6 s while the play is free (no move, no lock, settings closed), the target hops one time: up by 12 % of a tile, with a small squash, in 350 ms.
- [ ] The target is the open chest, or else the uncollected Item with the shortest path from the boat.
- [ ] The hop repeats after each further 6 s, at most 3 times. A key press starts the count again.
- [ ] The 6 s value is one constant, so the Parent can ask to tune it.
- [ ] Main-scene tests: the hop target, the 3-hop limit, and the restart of the count after a key press. No hop on the opening screen, on the Party, or while the settings panel is open.
- [ ] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.
