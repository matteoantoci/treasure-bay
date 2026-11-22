# 12: Final check

**What to build:** A check that all parts of the game-flow spec work together in the real game, before the Parent plays it again. Spec: [spec.md](../spec.md), "Screenshots for the Parent" and Further Notes.

**Blocked by:** 03, 04, 05, 06, 07, 08, 09, 10, 11

**Status:** ready-for-agent

- [ ] The full headless test suite passes, with exit code 0. `python3 tests/spec_port.py` exits with code 0.
- [ ] The windowed smoke run prints `SMOKE OK`.
- [ ] The screenshot tools make new shots: the opening screen, the Party at about 4 s, the locked chest during its shake, the open chest after the padlock pops, the reveal at about 1.8 s, the play shots of all 4 Areas, and the settings shot.
- [ ] The ticket comment records, for each shot: the slot gaps, the chest fully on land, the boat inside the channel, and the contrast of the slot outlines.
- [ ] Ticket 30 of the labyrinth-game map gets a comment: do the Parent manual check again, because the layout and the flow changed.
- [ ] The spec gets a short build report under a `## Comments` heading: what passed and what needs a person.
