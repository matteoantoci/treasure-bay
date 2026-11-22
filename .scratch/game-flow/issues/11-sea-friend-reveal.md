# 11: Sea friend reveal

**What to build:** At the Goal, the Sea friend appears large in the middle of the Labyrinth area, with the screen darker behind it. It flips in, then flies to its slot. Spec: [spec.md](../spec.md), Part 6, "Reveal (fix 5)".

**Blocked by:** 03 (Voyage)

**Status:** ready-for-agent

- [x] At 1.4 s of the Goal celebration, the screen gets darker (black at 55 % in 250 ms). The Collection strip stays above the dark layer.
- [x] A soft light disc appears in the middle of the Labyrinth area.
- [x] The Sea friend flips in at the middle of the Labyrinth area: two halves of 140 ms, the horizontal scale from 0 to full with an ease-out, and at the same time a growth from 50 % to 108 % that settles at 100 %. Its full size is 35 % of the visible height.
- [x] Its sound plays, as now. The wiggle stays, with an angle of 0.08 rad.
- [x] At 3.0 s it flies to its slot, as now, and the dark layer fades out during the flight. The other times of the celebration stay.
- [x] Tests check what the Child can see: the size and the place of the Sea friend at the reveal, the dark layer under the strip, and the slot that fills after the flight.
- [x] The screenshot tool adds a shot of the reveal at about 1.8 s.
- [x] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.

Build note (gf/11-sea-friend-reveal): `ScreenLayout.labyrinth_area(visible)` is the space between the top band and the strip, the full width of the screen. `tile_px` and `labyrinth_rect` use it too, so ticket 08 changes the area in one place. With the top band of now, its middle is (960, 663) at 1920 × 1200. The new node `Reveal` (`src/reveal_view.gd`, `RevealView`) draws the dark layer over the visible rectangle and the light disc. In `main.tscn` it sits after the Item row and the gear, and before the Collection strip, the Sea friend, the Effects, and the Fade. So the Labyrinth, the Items, the boat, the Item row, and the gear get darker. The strip, the Sea friend, the confetti, and the slot sparkles stay clear. The strip node moved after the gear in `main.tscn`. The dark layer covers the whole screen, also the water under the strip, so the strip background looks darker, but the Sea friends in the strip stay clear. The dark layer is black at 55 % (the spec), not the dark blue of the polish mockup. The light disc has values from the polish mockup, because the spec gives none: `#fff0b4` at 55 % in the centre, to 0 at the edge, radius 280 px at 1200 (`Motion.REVEAL_LIGHT_RADIUS_SHARE`). It fades in and out with the dark layer. The Sea friend is 420 px at 1200 (35 % of the visible height, on the longer side of its picture), so it does not use the Labyrinth scale. In the first flip half the horizontal scale and the size go together to 108 %, both `out`. The second half settles both at 100 %, `out`. Godot keeps a scale of 0 at a very small value, so the flip starts at about 0. The dark layer fades out in 700 ms (`inout`), the time and the curve of the flight, and the reveal ends at 3.7 s with the Sea friend in its slot. `Motion.FRIEND_START_PX`, `FRIEND_PX`, `FRIEND_SCALE`, `FRIEND_GROW_*` and `FRIEND_RISE_PX` are gone. The test of the Sea friend place next to the chest is gone too: the reveal covers the chest on purpose. The tool `tools/take_motion_shots.gd` writes `shots/motion-reveal.png` at about 1.8 s. The Parent must check: `shots/motion-reveal.png`, the flip speed in the real game, and the confetti that falls over the dark layer.
