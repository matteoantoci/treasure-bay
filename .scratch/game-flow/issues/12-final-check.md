# 12: Final check

**What to build:** A check that all parts of the game-flow spec work together in the real game, before the Parent plays it again. Spec: [spec.md](../spec.md), "Screenshots for the Parent" and Further Notes.

**Blocked by:** 03, 04, 05, 06, 07, 08, 09, 10, 11

**Status:** ready-for-agent

- [x] The full headless test suite passes, with exit code 0. `python3 tests/spec_port.py` exits with code 0.
- [x] The windowed smoke run prints `SMOKE OK`.
- [x] The screenshot tools make new shots: the opening screen, the Party at about 4 s, the locked chest during its shake, the open chest after the padlock pops, the reveal at about 1.8 s, the play shots of all 4 Areas, and the settings shot.
- [x] The ticket comment records, for each shot: the slot gaps, the chest fully on land, the boat inside the channel, and the contrast of the slot outlines.
- [x] Ticket 30 of the labyrinth-game map gets a comment: do the Parent manual check again, because the layout and the flow changed.
- [x] The spec gets a short build report under a `## Comments` heading: what passed and what needs a person.

Build note (gf/12-final-check): No code changes. Results on 2026-11-23, base `game-flow`:

- Suite: `Results: 54652 passed, 0 failed`, exit 0. `python3 tests/spec_port.py` exits 0.
- Smoke run in a window: `SMOKE OK: 3 Goals, no failure`.
- `tools/take_shots.gd` and `tools/take_motion_shots.gd` in a window make all 18 shots again (1920 × 1200, and `area1-1920x1247.png`).

Shot check (a person looked at each shot):

| Shot | Slot gaps | Chest on land | Boat in channel | Slot outline contrast | Other |
|---|---|---|---|---|---|
| opening | - | yes, on the island | - | - | Title, chest logo and Play button are correct. |
| party (about 4 s) | - | yes | - | - | 26 Sea friends in a ring, star "20", confetti. Correct. |
| area1 (L3) | equal, column and strip | yes, on the stub; left part on the rim land | yes | good (white edge on light blue) | - |
| area1-1920x1247 | equal | yes | yes | good | HUD scales correctly. |
| area2 (L8) | equal | yes | yes | good | **Problem:** the empty sand dollar slots show no ghost icon. They look like blank circles. The coral ghost is visible. |
| area3 (L13) | equal, 6 Item slots | yes | yes | good on the dark blue sea; shell and gem ghosts are pale but visible | - |
| area4 (L18) | equal, 8 Item slots fill the column from top to bottom | yes, the chest is small | yes | good on the night sea | - |
| settings | equal | yes | yes | dimmed, as expected | Panel is correct. |
| motion-locked (shake) | equal | yes | yes, the boat turns into the Goal square | good | Padlock on the chest. |
| motion-unlocked (padlock pops) | equal | yes | yes | good | Padlock is gone. |
| motion-goal | equal | yes | yes | good | Lid open, confetti. |
| motion-reveal (1.8 s) | equal | yes | yes | dimmed | Crab large, light behind it. |
| motion-sea-friend, -fly, -fade, -item-fly, -wake, -new-area | equal | yes | yes | good | Correct. In new-area (L6) the sand dollar slot is blank again (same problem as area2). |

Problem for a fix (not fixed here): the empty-slot ghost of the sand dollar Item is not visible, in Area 2 (shots area2 and motion-new-area). Probably the ghost tint of a near-white sprite is the same colour as the slot fill. A person must also look at the ghost of other pale Items (pearl) on the real screen.

A person must check: the Parent manual check of ticket 30, on the real 1512 × 982 screen, with sound.
