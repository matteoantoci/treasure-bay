# 08: Screen layout and HUD

**What to build:** A larger maze with the Item column at its left, clear Item slots, a Collection strip with 20 slots and the total count in the rounded font, a quiet gear, and the settings panel in the cream-and-wood style. Spec: [spec.md](../spec.md), Part 5, fixes 1, 3, 6 and 7, and the outline rule of fix 8. Mockup: [polish-MOCKUP](../prototypes/polish-MOCKUP/index.html) and its real-layout shots.

**Blocked by:** 05 (Name and opening screen; it adds the font)

**Status:** ready-for-agent

- [ ] The top band goes away. All HUD values use the HUD scale h = visible height / 760.
- [ ] The Item column is 100 h wide at the left, with a margin of 12 h. The Labyrinth is centred in the space right of the Item column and above the strip, less the margins.
- [ ] The tile is the largest that fits, with a cap of 121 × visible height / 1200. The Labyrinth width counts one tile more for the Goal island (ticket 09).
- [ ] The boat stays 85 % of a tile long, and an Item stays 69 % of a tile.
- [ ] Item slots: a disc with fill white at 22 % and an outline of 3 px in white at 85 %. The outline contrast against the water is 3:1 or more in all 4 Areas. The diameter is min(120 px, (free height − (count − 1) × 16 px) / count) at 1200 px. The group is centred. An empty slot shows the grey Item at 35 %. A collected Item fills its slot with the bounce.
- [ ] Collection strip: same height, 20 slots (fill white at 14 %, outline 2 px in white at 45 %), a gap of 12 px or more, and 24 px or more from the screen edges. The total count is at the left in the rounded font with an outline and a spiral shell icon.
- [ ] Gear: 48 px, 40 % opacity, its centre 40 px from the top and the right edges. It does not overlap the Labyrinth.
- [ ] Settings panel: black at 50 % behind it, fill `#fff3d6`, border 10 px `#7a4a24`, corner radius 40 px, buttons `#e9c98f` with a bottom edge `#b58a4a`, icons `#5a3416`. The volume bars, the hold rings, the reset ring colour and the hold times stay.
- [ ] Screen layout tests at 1920 × 1200 and at 1512 × 982: the tile cap, the Item column, the slot gaps (16 px in the column with 8 Items, 12 px in the strip, 24 px from the edges), and the gear outside the Labyrinth.
- [ ] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.
