# 04: Bigger Items, boat and chest, and a clear Goal

**What to build:** The Child can see the Items, the boat and the Goal at a glance, also in the large Labyrinths. The Items, the boat and the chest are larger. The closed chest sparkles like an Item, and the palm is darker than the grass. Spec: [spec.md](../spec.md), Part 2.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] The sizes in prototype px, multiplied by `s = tile_px / 130`, are: Item 90 px, boat 69 × 110 px, chest 100 px. The aspect of the boat picture stays the same, and the chest stays at its place on the Goal island tile.
- [ ] At 1920 × 1200, the Item, boat and chest sprites have the new sizes in Labyrinths 1 and 20.
- [ ] The new-Area Item stays at 2× the Item size. The Item flight still shrinks the Item to 0.55× of its Labyrinth size.
- [ ] The closed chest shows the Item sparkle of build spec 8.2, with `i` equal to the Item count of the Labyrinth. The sparkle stops when the chest opens.
- [ ] The palm has the modulate colour `Color(0.7, 0.85, 0.7)`.
- [ ] The HUD sizes, the top band, the Item row and the Collection strip do not change.
- [ ] The labyrinth-game build spec sections 6.2, 8.2, 10 and Open gap 3 give the new values.
- [ ] The full test suite passes.
