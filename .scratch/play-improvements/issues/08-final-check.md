# 08: Final check

**What to build:** A check that all play improvements work together in the real game, before the Parent plays it again. Spec: [spec.md](../spec.md), Testing Decisions and Further Notes.

**Blocked by:** 02 (Safer reset), 03 (Fanfare under the Sea friend sound), 04 (Bigger Items, boat and chest), 07 (Fixed seeds by measured difficulty)

**Status:** ready-for-agent

- [ ] The full headless test suite passes, with exit code 0.
- [ ] The windowed smoke run prints `SMOKE OK`.
- [ ] The screenshot tool makes new screenshots of Labyrinths 3, 8, 13 and 18 and of the settings panel.
- [ ] In the screenshots, the boat stays inside the channel, the chest is easy to see, and no Item covers an island. The ticket comment records each result.
- [ ] Ticket 30 of the labyrinth-game map gets a comment: do the Parent manual check again, because the layout of each Labyrinth, the sizes and the reset hold changed.
- [ ] The play-improvements spec gets a short build report under a `## Comments` heading: what passed and what needs a person.
