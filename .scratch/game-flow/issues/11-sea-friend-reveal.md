# 11: Sea friend reveal

**What to build:** At the Goal, the Sea friend appears large in the middle of the Labyrinth area, with the screen darker behind it. It flips in, then flies to its slot. Spec: [spec.md](../spec.md), Part 6, "Reveal (fix 5)".

**Blocked by:** 03 (Voyage)

**Status:** ready-for-agent

- [ ] At 1.4 s of the Goal celebration, the screen gets darker (black at 55 % in 250 ms). The Collection strip stays above the dark layer.
- [ ] A soft light disc appears in the middle of the Labyrinth area.
- [ ] The Sea friend flips in at the middle of the Labyrinth area: two halves of 140 ms, the horizontal scale from 0 to full with an ease-out, and at the same time a growth from 50 % to 108 % that settles at 100 %. Its full size is 35 % of the visible height.
- [ ] Its sound plays, as now. The wiggle stays, with an angle of 0.08 rad.
- [ ] At 3.0 s it flies to its slot, as now, and the dark layer fades out during the flight. The other times of the celebration stay.
- [ ] Tests check what the Child can see: the size and the place of the Sea friend at the reveal, the dark layer under the strip, and the slot that fills after the flight.
- [ ] The screenshot tool adds a shot of the reveal at about 1.8 s.
- [ ] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.
