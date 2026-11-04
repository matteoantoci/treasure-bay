# 27: Settings and Parent controls

**What to build:** The Parent opens the settings with the gear, changes the volume, resets progress, and quits. The Child cannot quit by accident. Spec sections 11 and 12.4.

**Blocked by:** 23 (Saved progress), 26 (Sound)

**Status:** ready-for-agent

- [ ] A click on the gear opens and closes the settings panel and pauses play (spec 11.2).
- [ ] The volume buttons change each bus in 5 steps, and the values persist in the settings file (spec 12.4).
- [ ] Reset and quit work only after a 3-second hold, with a ring that fills.
- [ ] Cmd+Q and window close do nothing. If the game leaves fullscreen, it goes back to exclusive fullscreen (spec 11.1).
