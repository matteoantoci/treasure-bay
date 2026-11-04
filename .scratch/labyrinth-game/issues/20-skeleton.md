# 20: Skeleton: sail one Labyrinth to the Goal

**What to build:** The Parent runs `./play`. Godot opens in exclusive fullscreen and shows Labyrinth 1 with plain water and island tiles. The arrow keys move the boat by the move rule. At the Goal, the next Labyrinth starts. Spec sections 3, 4.1, 4.2, 4.5, 5.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] `./play` starts the game on the Parent's Mac and checks the Godot version (spec 3.3).
- [ ] The seeded PRNG and the generator give the same Labyrinth for the same seed.
- [ ] One arrow press moves the boat to the next junction, bend, dead end, or Goal. At a wall, the boat bumps and stays.
- [ ] Reaching the Goal starts the next Labyrinth.
- [ ] Headless tests for the PRNG, the generator, and the move rule pass (spec 14.1).
