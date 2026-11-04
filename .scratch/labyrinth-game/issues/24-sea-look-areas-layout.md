# 24: Sea look, Areas, and layout

**What to build:** The game looks like the polished sea prototype: Kenney islands and coasts, a Goal island with a palm and a chest, and 4 Areas that change every 5 Labyrinths. The screen layout fits the Mac screen. Spec sections 3.4, 3.5, 7, 10.

**Blocked by:** 21 (Sprites), 22 (Labyrinths, Items, and rewards)

**Status:** ready-for-agent

- [x] Islands, coasts, and water use the Kenney tiles (spec 7.1).
- [x] The Goal island has a palm and the closed chest. Wall islands have no palm.
- [x] Each Area has its colours, Items, and decoration from spec 7.2.
- [x] The layout of spec 10 shows on a 16:10 screen with no black bars.
- [x] Screenshots of each Area exist (spec 14.2).

## Comments

**Built (ticket 24 worker, 2026-11-04).**
- Islands (spec 7.1, Open gap 1): `src/island_look.gd` (`IslandLook.build(labyrinth)`, pure logic) gives the Kenney tile of each Kenney cell and the rocks and bushes. Each Labyrinth tile is drawn as **3 x 3 Kenney cells**: the Kenney coast tiles need an island at least 2 tiles thick, and a wall island is 1 tile thick. Each cell faces its neighbour tiles on its side: outer corners 06/09/54/57, coasts 07/25/55/22, inner corners 53/52/37/36 (water only at that diagonal), grass 23. The tile pictures confirm each shape (alpha at the edges and corners). The outside of the Labyrinth is sea, so the border is an island ring.
- A second PRNG with seed `seed_value + 1` gives one output r for each island tile in row order (not the Goal island). r % 6 == 0 places a decoration on the centre of the tile: `(r / 6) % 12` is the bush (tile 70) for 0 to 5, else rock `[49, 50, 51, 65, 66, 67][pick - 6]`. The same PRNG then picks tile variants with the same shape for 1 cell in 3 (08, 41, 56, 38; grass 39, 40, 24). Tiles 71 and 72 never go on a wall island.
- `src/labyrinth_view.gd`: one `TileMapLayer` with a `TileSet` made in code (one `TileSetAtlasSource` for each of the 31 PNGs, source ID = tile number, no texture padding so the imported mipmaps draw), scaled to `tile_px / 3 / 128`. Rocks and bushes are `Sprite2D` nodes at 0.5 tile. **Hooks for ticket 25:** `LabyrinthView.palm` (tile 71, 0.7 tile, at (0.78, 0.42) of the Goal island tile: sway it) and `LabyrinthView.chest` (`chest_closed.png`, 60 px × s, at (0.3, 0.56): set its texture to `chest_open.png`).
- Water (spec 7.1, 7.2): `src/water.gdshader` on the `Water` node (`src/water_view.gd`, `WaterView.show_area(area)`, `layout(visible, labyrinth_rect, tile_px)`) draws the deep colour, the wave lines of spec 8.2 (light colour, 18 %, 3 px, rows 34 px, a line every 90 px, the prototype curve, fixed to the Labyrinth origin and scaled by s), and soft light shapes at 8 % (value noise). It is still: the shader has `t = 0.0` where ticket 25 puts the time.
- Areas: `Area.deep_colour()`, `light_colour()`, `decoration()` (spec 7.2). `src/area_decoration.gd` (`AreaDecoration`, node under the islands) draws still decorations of Open gap 6 on free water tiles (PRNG seed `seed_value + 2`): 6 wave crests, 3 bubbles (ages 0.5, 1.5, 2.5 s of 3 s), 2 droplets (ages 0.3, 1.1 s of 1.5 s), 12 stars (alpha 0.2 to 0.9). `pieces` holds each piece (centre in tiles, a 0..1 value); ticket 25 adds the motion.
- Boat: `BoatView` draws `boat_white_sail.png`, 86 px long × s. Item row: `ItemRow.outlines` (grey and light by `src/item_outline.gdshader`, grayscale then brightness 2×, 35 %) and `ItemRow.fills` (normal sprite, alpha 0 or 1; ticket 25 tweens it).
- Layout (spec 10): `ScreenLayout.gear_rect()` and `src/gear_view.gd` (`GearView`, a `Control`, white gear with a dark outline drawn in code, Open gap 2). It is only the picture: **ticket 27** adds the click. The water covers `get_visible_rect()` on each size change.
- Main scene: new nodes `AreaDecoration` (under `LabyrinthView`) and `Gear`; `main.gd` calls `_water.show_area()` and `_area_decoration.show_labyrinth()` in `show_labyrinth()`, and lays them out in `_layout()`.
- Tests: `tests/test_island_look.gd` (the Kenney cells of a 2 x 1 Labyrinth drawn by hand; the Labyrinth 1 decorations pinned from an independent Python run of the rule; rocks and bush only, never on the Goal island, no palm; the Labyrinth data stays the same), `tests/test_area_look.gd` (spec 7.2 colours and decorations), `tests/test_main_look.gd` (scene: water covers the screen in the Area colours for Labyrinths 1, 5, 6, 11, 16, 21, 26, Kenney cells, palm and closed chest on the Goal island, decorations, grey outlines, gear), test 8 of spec 14.1 in `tests/test_screen_layout.gd` (tile px of all 11 sizes at 1920 x 1200 and 1920 x 1247, worked out by hand; each size fits between the bands and is centred), gear in `tests/test_hud_layout.gd`.
- Screenshots: `tools/take_shots.gd` (`godot --path . --windowed --script res://tools/take_shots.gd`) draws the game into a `SubViewport` of the exact size in a windowed run and writes `shots/area1.png` to `shots/area4.png` (Labyrinths 3, 8, 13, 18 at 1920 x 1200) and `shots/area1-1920x1247.png`. `shots/.gdignore` keeps Godot from importing them.

**Checked.** Full test run exits 0. `godot --path . --quit-after 120` exits 0 with no script errors. The 5 screenshots were read and compared with the motion prototype and the Kenney sample. Not the same as the prototype, on purpose or for later tickets: the islands are Kenney tiles, not the round placeholder islands of the prototype (spec 7.1); no foam line on the coasts, no Item sparkle, and no motion (spec 8.2, ticket 25). The sea-look prototype folder holds only 5 images, no HTML or JS. Not checked: the real fullscreen look on the Parent's Mac (spec 14.3 item 3).
