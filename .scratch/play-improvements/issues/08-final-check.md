# 08: Final check

**What to build:** A check that all play improvements work together in the real game, before the Parent plays it again. Spec: [spec.md](../spec.md), Testing Decisions and Further Notes.

**Blocked by:** 02 (Safer reset), 03 (Fanfare under the Sea friend sound), 04 (Bigger Items, boat and chest), 07 (Fixed seeds by measured difficulty)

**Status:** ready-for-agent

- [x] The full headless test suite passes, with exit code 0.
- [x] The windowed smoke run prints `SMOKE OK`.
- [x] The screenshot tool makes new screenshots of Labyrinths 3, 8, 13 and 18 and of the settings panel.
- [x] In the screenshots, the boat stays inside the channel, the chest is easy to see, and no Item covers an island. The ticket comment records each result.
- [x] Ticket 30 of the labyrinth-game map gets a comment: do the Parent manual check again, because the layout of each Labyrinth, the sizes and the reset hold changed.
- [x] The play-improvements spec gets a short build report under a `## Comments` heading: what passed and what needs a person.

## Comments

**Final check (agent Impl08FinalCheck, branch `pi/08-final-check`, 2026-11-04).** All runs are on the integration tip of tickets 01 to 07.

- Test suite: `godot --headless --path . --script res://tests/run.gd` prints `Results: 14368 passed, 0 failed`. Exit code 0. The `WARNING:` lines with backtraces come from the tests of newer saves and of the no-write state. They are expected.
- Python port: `python3 tests/spec_port.py` exits with code 0.
- Smoke run: `godot --path . --windowed --script res://tools/smoke_run.gd` prints `SMOKE OK: 3 Goals, no failure`. Exit code 0.
- Screenshot tool: `godot --path . --windowed --script res://tools/take_shots.gd` writes 6 new files to `shots/`: `area1.png` (Labyrinth 3), `area2.png` (Labyrinth 8), `area3.png` (Labyrinth 13), `area4.png` (Labyrinth 18), `area1-1920x1247.png` (Labyrinth 3), and `settings.png`. Exit code 0. The list of the tool already held Labyrinths 3, 8, 13 and 18. The only change to the tool: its header said that the settings shot holds the reset for 1.5 s, but since ticket 02 it holds the reset for half of its hold time (4 s). The header now says this.
- Look of each screenshot:
  - Labyrinth 3 (1920 × 1200): the boat is inside the channel. Its bow and its stern touch the two foam lines of the start square, but they do not go onto the sand. The chest is easy to see. No Item covers an island.
  - Labyrinth 8 (1920 × 1200): the boat is inside the channel. The chest is easy to see. The two sand dollars and the coral are on the water. No Item covers an island.
  - Labyrinth 13 (1920 × 1200): the boat is inside the channel. The chest is smaller but easy to see, gold on green. The shells and the crystals are on the water. No Item covers an island.
  - Labyrinth 18 (1920 × 1200): the boat (smallest tiles) is inside the channel. The chest is small but easy to see, gold on green. All stars are on the water. No Item covers an island.
  - Labyrinth 3 (1920 × 1247): same result as Labyrinth 3 at 1920 × 1200.
  - Settings: the panel is open, and the reset ring is orange and half full (4 s of 8 s). The panel does not hide the gear.
- Chest edge (note of ticket 04): in all four Labyrinths, the left edge of the chest goes over the sand of the Goal island and onto the foam line of the Goal square. It touches the water a little. The chest also hides the left fronds of the palm. It looks like the chest stands on the shore, and it does not hide the boat path. A person must decide if this is correct.
- Not checked: a screenshot shows the boat only at the start, so it does not show the boat when it turns. The boat is 85 % of a tile long, so it is shorter than a tile in each direction, but a person must look at a turn in a real game. The sounds (fanfare under the crab sound) and the 8 s reset hold on screen need a person. Ticket 30 of the labyrinth-game map has the list.
