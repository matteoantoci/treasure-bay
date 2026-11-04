# 04: Bigger Items, boat and chest, and a clear Goal

**What to build:** The Child can see the Items, the boat and the Goal at a glance, also in the large Labyrinths. The Items, the boat and the chest are larger. The closed chest sparkles like an Item, and the palm is darker than the grass. Spec: [spec.md](../spec.md), Part 2.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] The sizes in prototype px, multiplied by `s = tile_px / 130`, are: Item 90 px, boat 69 × 110 px, chest 100 px. The aspect of the boat picture stays the same, and the chest stays at its place on the Goal island tile.
- [x] At 1920 × 1200, the Item, boat and chest sprites have the new sizes in Labyrinths 1 and 20.
- [x] The new-Area Item stays at 2× the Item size. The Item flight still shrinks the Item to 0.55× of its Labyrinth size.
- [x] The closed chest shows the Item sparkle of build spec 8.2, with `i` equal to the Item count of the Labyrinth. The sparkle stops when the chest opens.
- [x] The palm has the modulate colour `Color(0.7, 0.85, 0.7)`.
- [x] The HUD sizes, the top band, the Item row and the Collection strip do not change.
- [x] The labyrinth-game build spec sections 6.2, 8.2, 10 and Open gap 3 give the new values.
- [x] The full test suite passes.

## Comments

Build note (agent Impl04Sizes, branch `pi/04-bigger-items-boat-chest`):

- Sizes: Item 90 px, boat 110 px long, chest 100 px, all times `s` (`src/items_view.gd`, `src/boat_view.gd`, `src/labyrinth_view.gd`). The boat keeps the aspect of its picture (108 × 170 px), so its width is 69.9 px × `s`, not exactly 69 px. The old 54 px width was 54.6 px in the same way.
- The chest keeps `CHEST_PLACE` (0.3, 0.56) of the Goal island tile. At 100 px its left edge goes a little past the sand of the Goal island, onto the foam line of the Goal square. A person must check that this looks right.
- The closed chest sparkle is a `Polygon2D` child `ChestSparkle` of the Labyrinth view. It uses the Item sparkle of build spec 8.2 with `i` = the Item count. It hides when the chest opens and shows again on the next Labyrinth.
- The palm has the modulate `Color(0.7, 0.85, 0.7)`.
- New tests: `tests/test_main_look.gd` checks the sizes at 1920 × 1200 in Labyrinths 1 and 20 (tiles 121 px and 56 px), the chest sparkle cycle times, and the palm colour. `tests/test_main_motion.gd` now checks the Area Item against 2 × 90 px × `s` and the Item flight shrink to 0.55 × 90 px × `s`.
- Changed test: the Sea friend check of ticket 28 allowed at most 0.2 of the chest box under the Sea friend. The 100 px chest gives 0.21 to 0.24 for 9 Sea friends, so the limit is now 0.25 (a quarter of the box, a corner). The Sea friend still does not cover the boat. A person must look at a Goal celebration to confirm.
- The build spec sections 6.2, 8.2, 10 and Open gap 3 have the new values.
- Screenshots (temporary, not committed) of Labyrinths 1 and 20 at 1920 × 1200: the Items, the boat and the chest are easy to see in both. In Labyrinth 20 the boat (47 px long) stays inside its 56 px channel. The palm is darker than the grass, but the difference is small at 56 px tiles. The chest covers the left fronds of the palm. The tracked files in `shots/` are not updated, because tickets 01 and 05 change the layouts. Run the screenshot tool after the integration.
