# Labyrinth game: build spec

This spec overrides older text in the tickets and research files.

Map: [Labyrinth game for a 5-year-old](map.md). Date: 2026-11-04. All decision tickets are closed. The build follows this file and asks no questions. When this file gives a value that no ticket gives, the value comes from [ticket 19](issues/19-gaps-before-the-spec.md) and [research/gap-audit.md](research/gap-audit.md) (defaults 8 to 41), or the "Open gaps" section at the end states it.

Mark in this file: **[trace]** means that the fact comes from a read of the Godot source code. Nobody tested it.

## 1. Purpose and fixed rules

Sources: [map.md](map.md), [ticket 16](issues/16-parent-controls.md), [ticket 17](issues/17-session-limit.md).

The game is a keyboard Labyrinth game for one Child, the Parent's 5-year-old daughter. It is a Godot 4.7 app in a fullscreen window on the Parent's Mac laptop. The Child sails a boat through water channels between islands. She collects Items on the way. At the Goal she gets a Sea friend for her Collection.

Fixed rules. The build must obey each rule:
1. The game shows no words to the Child. Numbers are allowed.
2. The Child cannot lose. The game has no timer, no enemies, no lives, and no score that goes down.
3. The keyboard is the only input for play. The mouse is allowed only for the settings.
4. The game has no recorded voice.
5. The game has no accounts and no ads, and it sends no data over the network.
6. The game has no start screen, no skip, and no session limit ([ticket 16](issues/16-parent-controls.md), [ticket 17](issues/17-session-limit.md)).

## 2. Glossary

Use the terms in [GLOSSARY.md](../../GLOSSARY.md) exactly: **Labyrinth**, **Goal**, **Item**, **Sea friend**, **Collection**, **Area**, **Child**, **Parent**. Do not use the words in its "Avoid" lists in code comments or in docs. Code identifiers use the same words in snake_case: `labyrinth`, `goal`, `item`, `sea_friend`, `collection`, `area`.

This spec also uses these words:
- **Square**: one cell of the Labyrinth grid. Sizes such as 4 × 3 count squares.
- **Tile**: one cell of the drawn grid. Section 4.4 gives the relation between squares and tiles.

## 3. Platform and project setup

Sources: [ticket 01](issues/01-choose-tech-stack.md), [ticket 14](issues/14-clean-sprite-edges.md), [ticket 18](issues/18-screen-layout.md), [research/godot4-facts.md](research/godot4-facts.md) §1 to §3, gap-audit defaults 8 to 11.

### 3.1 Engine

- Godot **4.7** (4.7.2-stable) with GDScript. No C#, no addons, no export. The game runs from source with the editor binary ([godot4-facts §8](research/godot4-facts.md)).
- One-time setup by the Parent: `brew install --cask godot`. The cask puts `godot` on the PATH. Godot 4.7.2 is already at `/opt/homebrew/bin/godot` ([ticket 13](issues/13-polished-sea-look.md)).
- Write every scene and resource as text, or make it in code. An agent has no editor GUI.

### 3.2 Repository layout

The Godot project is the repository root, because `./play` runs `godot --path .`.

```
./play                      start script (section 3.3)
project.godot
main.tscn                   main scene, plain res:// path (not uid://)
credits.txt                 section 9.8
src/                        GDScript files
tests/run.gd                headless test runner (section 14)
assets/kenney/tiles/        31 Kenney tiles, tile_NN.png
assets/kenney/ships/boat_white_sail.png
assets/kenney/License.txt
assets/sprites/friends/     20 Sea friend PNG files
assets/sprites/items/       8 Item PNG files
assets/sprites/goal/        chest_closed.png, chest_open.png
assets/audio/music/         4 MP3 files
assets/audio/effects/       5 WAV files
assets/audio/friends/       13 WAV files
```

Do not commit `.godot/`. It is an import cache ([godot4-facts §2](research/godot4-facts.md)).

Keep all game logic in scripts that need no scene tree: the PRNG, the generator, Item placement, the move rule, Area and Sea friend tables, layout math, and save load and save write. Those scripts extend `RefCounted`. The headless tests load them directly.

### 3.3 The `./play` script

```sh
#!/bin/sh
set -eu
cd "$(dirname "$0")"
v=$(godot --version)
case "$v" in
  4.7.*) ;;
  *) echo "This game needs Godot 4.7. Found: $v" >&2 ;;
esac
godot --headless --path . --import
exec godot --path .
```

- The import step is necessary. Without it, PNG, WAV, and MP3 files do not load, and `class_name` types are unknown ([godot4-facts §2](research/godot4-facts.md)).
- A version other than 4.7 prints the message and the game still starts (gap-audit default 11).
- Make the file executable (`chmod +x play`).

### 3.4 `project.godot` settings

| Key | Value | Source |
|---|---|---|
| `application/config/name` | `"Labyrinth"` | gap-audit default 9. It sets the save folder `~/Library/Application Support/Godot/app_userdata/Labyrinth/`. |
| `application/run/main_scene` | `"res://main.tscn"` | A `uid://` main scene fails on a fresh folder ([godot4-facts §2](research/godot4-facts.md)). |
| `display/window/size/viewport_width` | `1920` | [ticket 18](issues/18-screen-layout.md) |
| `display/window/size/viewport_height` | `1200` | [ticket 18](issues/18-screen-layout.md) |
| `display/window/size/mode` | `4` (`WINDOW_MODE_EXCLUSIVE_FULLSCREEN`) | gap-audit default 8, [godot4-facts §3](research/godot4-facts.md) |
| `display/window/stretch/mode` | `"canvas_items"`. Never `"viewport"`. | [ticket 14](issues/14-clean-sprite-edges.md), [ticket 18](issues/18-screen-layout.md) |
| `display/window/stretch/aspect` | `"expand"` | [ticket 18](issues/18-screen-layout.md) |

Exclusive fullscreen hides the Dock and the menu bar on macOS. Esc does not leave it [trace] ([godot4-facts §3](research/godot4-facts.md)).

### 3.5 Sprite edges: mipmaps and texture filter

Source: [ticket 14](issues/14-clean-sprite-edges.md). The sprites are 512 px, and the game shows them at about 25 to 180 px. Without mipmaps their edges look stepped.

1. Switch on **Mipmaps > Generate** for every PNG texture in `assets/`. The first `--import` writes a `<file>.png.import` file next to each PNG. Set `mipmaps/generate=true` in each of these files, then run `godot --headless --path . --import` again ([godot4-facts §6](research/godot4-facts.md), [raster-pipeline](../../.claude/skills/create-game-assets/references/raster-pipeline.md)).
2. Set `texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` on each top-level `CanvasItem` of the game. The child nodes inherit it.
3. Keep the stretch mode `canvas_items` (section 3.4).

## 4. Labyrinths

Sources: [ticket 01](issues/01-choose-tech-stack.md), [ticket 05](issues/05-levels-and-difficulty.md), [ticket 15](issues/15-reward-after-labyrinth-20.md), [research/tech-stack.md](research/tech-stack.md) (Revision), gap-audit defaults 12 to 20.

### 4.1 PRNG

- Write an own xorshift32 PRNG in GDScript. Do not use `RandomNumberGenerator` for generation ([tech-stack Revision](research/tech-stack.md)).
- One step: `x ^= (x << 13) & 0xFFFFFFFF; x ^= x >> 17; x ^= (x << 5) & 0xFFFFFFFF`. The output is `x`, from 1 to 2^32 − 1. A GDScript `int` has 64 bits, so mask each left shift with `& 0xFFFFFFFF`.
- Seed 0 becomes seed 1, because xorshift32 stays at 0 (gap-audit default 14).
- A test pins the first 5 outputs for seed 1.

### 4.2 Generator

- The generator makes a perfect Labyrinth on W × H squares with the recursive backtracker: an iterative depth-first search with a stack ([tech-stack](research/tech-stack.md)). A perfect Labyrinth has exactly one path between two squares, so the Goal is always reachable.
- Data: one record for each square, with 4 wall bits (north, east, south, west). The view reads this data and never changes it.
- The search starts at square (0, 0). At each step, list the unvisited neighbours in the order north, east, south, west. Pick index `prng.next() % count`. This is the same order as the [movement prototype](prototypes/movement-PROTOTYPE/index.html).
- The generator removes no extra walls. The Labyrinth has no loops.
- **Goal rule:** when the search moves into the Goal square, it opens the wall and marks the Goal square as visited. It does not push the Goal square on the stack, so the search never continues from the Goal square. The Goal square has exactly one open side, and no square is behind the Goal (Resolved conflict 25).
- Reason for the Goal rule: the boat stops at the Goal (section 5.2), and the next Labyrinth starts. The Child cannot reach a square behind the Goal, or an Item on that square. The grid without the Goal square stays connected, so the search visits all squares.
- **Start square:** (0, 0), top-left. **Goal square:** (W − 1, H − 1), bottom-right (gap-audit default 13).
- After the generator, the code checks with a breadth-first search from the start that every square is reachable.

### 4.3 The 20 fixed Labyrinths, sizes, Items, Areas

- Labyrinths 1 to 20 are fixed. Labyrinth n uses seed n (gap-audit default 15). Labyrinth 1 is always the same Labyrinth.
- The size grows by one column or one row after every 2 Labyrinths (gap-audit default 17).
- Item count: `clamp(floor(W * H / 6), 2, 8)` (gap-audit default 18).
- Area: Labyrinths 1 to 5 are Area 1, 6 to 10 Area 2, 11 to 15 Area 3, and 16 to 20 Area 4. For every n: `area = ((n - 1) / 5) % 4 + 1`, with integer division ([ticket 15](issues/15-reward-after-labyrinth-20.md)).

| Labyrinths | Squares W × H | Tiles (2W+1) × (2H+1) | Items |
|---|---|---|---|
| 1, 2 | 4 × 3 | 9 × 7 | 2 |
| 3, 4 | 5 × 3 | 11 × 7 | 2 |
| 5, 6 | 5 × 4 | 11 × 9 | 3 |
| 7, 8 | 6 × 4 | 13 × 9 | 4 |
| 9, 10 | 7 × 4 | 15 × 9 | 4 |
| 11, 12 | 7 × 5 | 15 × 11 | 5 |
| 13, 14 | 8 × 5 | 17 × 11 | 6 |
| 15, 16 | 8 × 6 | 17 × 13 | 8 |
| 17, 18 | 9 × 6 | 19 × 13 | 8 |
| 19, 20 | 9 × 7 | 19 × 15 | 8 |
| 21 and later (random) | 10 × 7 | 21 × 15 | 8 |

### 4.4 Random Labyrinths after Labyrinth 20

- From Labyrinth 21, each Labyrinth is random at 10 × 7 ([ticket 05](issues/05-levels-and-difficulty.md)).
- Call `randomize()` one time at startup. For each new random Labyrinth, the seed is `randi()`. A seed of 0 becomes 1. The game saves this seed in `random_seed` (section 12). Generation uses only the own PRNG (gap-audit default 16).
- The Area changes every 5 Labyrinths in the order of Labyrinths 1 to 20: 21 to 25 is Area 1, 26 to 30 is Area 2, and so on ([ticket 15](issues/15-reward-after-labyrinth-20.md)).

### 4.5 Squares and tiles

Source: [ticket 13](issues/13-polished-sea-look.md): "The islands are the walls, and the water channels are the paths". Gap-audit default 12.

- The game draws a grid of (2W + 1) × (2H + 1) tiles.
- Square (x, y) is tile (2x + 1, 2y + 1). It is always water.
- The tile between two neighbour squares is water if the wall between them is open. Otherwise it is island.
- All other tiles (the corner tiles and the border) are island.
- One move from a square to its neighbour crosses 2 tiles.

### 4.6 Item placement

Source: [ticket 04](issues/04-encouragement-without-losing.md), [ticket 05](issues/05-levels-and-difficulty.md), gap-audit default 19.

1. A dead end is a square with exactly one open side. The start square and the Goal square are not used.
2. Item 1 goes in the dead end farthest from the start (breadth-first search distance). On a tie, take the lowest y, then the lowest x.
3. The PRNG continues after the generator. It shuffles the other dead ends, then the other squares (Fisher-Yates with `prng.next() % (i + 1)`). The next Items go on the dead ends first, then on the other squares.
4. Each Item has its own square. No Item is on the start square or the Goal square.
5. Item i (0-based, in placement order) has kind `area_items[i % len(area_items)]` (section 7.2).
6. The Item ID is `"x,y"` with the square coordinates.
7. If no dead end exists except the start and the Goal, the seed does not give a valid Labyrinth. For a random Labyrinth, add 1 to the seed and generate again. A test checks that seeds 1 to 20 are valid. See Open gap 4.
8. The Child can reach each Item before the Goal, because no square is behind the Goal (section 4.2).

### 4.7 Sea friend for each Labyrinth

Source: [ticket 05](issues/05-levels-and-difficulty.md), gap-audit default 20.

Labyrinth n (1 to 20) gives the n-th Sea friend of this list. The ID is the sprite file name.

| n | Sea friend | ID | n | Sea friend | ID |
|---|---|---|---|---|---|
| 1 | Crab | `crab` | 11 | Shrimp | `shrimp` |
| 2 | Octopus | `octopus` | 12 | Oyster | `oyster` |
| 3 | Spouting whale | `spouting_whale` | 13 | Seal | `seal` |
| 4 | Whale | `whale` | 14 | Turtle | `turtle` |
| 5 | Dolphin | `dolphin` | 15 | Jellyfish | `jellyfish` |
| 6 | Fish | `fish` | 16 | Otter | `otter` |
| 7 | Blowfish | `blowfish` | 17 | Penguin | `penguin` |
| 8 | Shark | `shark` | 18 | Duck | `duck` |
| 9 | Squid | `squid` | 19 | Swan | `swan` |
| 10 | Lobster | `lobster` | 20 | Flamingo | `flamingo` |

## 5. Movement and input

Sources: [ticket 03](issues/03-arrow-key-movement.md), [ticket 11](issues/11-motion-and-animation.md), the [motion prototype](prototypes/motion-PROTOTYPE/index.html) lines 52 to 64, [input-systems skill](../../.claude/skills/input-systems/SKILL.md), gap-audit defaults 21 to 24.

### 5.1 Keys

- Make 4 InputMap actions: `move_up`, `move_down`, `move_left`, `move_right`. Bind them to the arrow keys with `physical_keycode`. Bind no other key.
- Read the actions in `_unhandled_input(event)`. Ignore an event where `event.is_echo()` is true. Those events are the repeats of a held key.
- Do not bind any game action to `ui_cancel`, the action that Esc fires.

### 5.2 The move rule

When the Child presses an arrow key and the boat is free:
1. The boat turns at once to face the pressed direction. It turns in all four directions, also before a bump. The bow of `boat_white_sail.png` points down at rotation 0, so the rotation is `atan2(dy, dx) - PI / 2` (motion prototype line 56).
2. If the side of the current square in that direction is a wall, the boat does a bump (section 5.3) and stays on its square.
3. If not, the boat goes straight in that direction, one square at a time. It stops on the first square where one of these is true:
   - the next side in the same direction is a wall (a dead end, or a bend in the channel),
   - the square has 3 or more open sides (a junction),
   - the square holds an Item that the Child has not collected,
   - the square is the Goal square.
4. The boat does not stop on a square with a collected Item.
5. **Speed:** one tween for the whole slide. Its duration is 180 ms for each tile that the boat crosses (360 ms for each square), with an ease-out curve: `Tween.TRANS_CUBIC`, `Tween.EASE_OUT`.
6. When the boat arrives, the game collects the Item on that square (section 6.1). On the Goal square, the game starts the Goal celebration (section 6.3).

### 5.3 Bump

- The boat moves toward the wall by 0.12 of a tile in 70 ms (ease-out), then back in 110 ms (ease-out) (motion prototype line 62).
- The wall sound plays (section 9.3).

### 5.4 Busy, buffer, and lock

- While the boat moves or bumps, it is busy. The game keeps one early key press. A newer press replaces it. When the boat is free again, the game runs the kept press.
- An Item that flies to the top does not make the boat busy (motion prototype lines 60 to 64).
- The input is locked from the arrival at the Goal to the end of the fade-in of the next Labyrinth (section 8.8). The input is also locked while the settings are open. The game drops presses while the input is locked. It does not keep them.

## 6. Items, Goal, rewards, Collection

Sources: [ticket 04](issues/04-encouragement-without-losing.md), [ticket 05](issues/05-levels-and-difficulty.md), [ticket 11](issues/11-motion-and-animation.md), [ticket 15](issues/15-reward-after-labyrinth-20.md), [ticket 19](issues/19-gaps-before-the-spec.md) Q4 and Q5, gap-audit default 30.

### 6.1 Items

- Each Labyrinth has 2 to 8 Items (section 4.3). The Child does not need any Item to reach the Goal.
- The boat stops on each Item square that it reaches. The Item makes a pop sound and a sparkle, then flies to its outline at the top (section 8.4).
- The Item row at the top shows one outline for each Item of this Labyrinth. Each collected Item fills its outline. The row never gets smaller.
- The total count of all collected Items goes up by 1 for each new Item. It never goes down, except after a Parent reset.
- The game saves after each Item (section 12).

### 6.2 Goal

- The Goal square is the bottom-right square. The Goal island is the border tile to the right of the Goal square, tile (2W, 2H − 1).
- The Goal island has a palm and a treasure chest. The chest is closed while the Child sails. The chest opens at the start of the Goal celebration: the game shows `chest_open.png` in place of `chest_closed.png` (ticket 19 Q5).
- Wall islands have rocks and bushes and no palm (ticket 19 Q5).

### 6.3 Goal celebration and the Sea friend (Labyrinths 1 to 20)

- When the boat arrives on the Goal square, the game saves first (section 12). Then the celebration plays: the boat hops, confetti falls, the fanfare plays, and the chest opens (section 8.5).
- At 1.4 s, the Sea friend of this Labyrinth appears next to the Goal island. Its sound plays. At 3.0 s it flies to its slot in the Collection strip, and it arrives at 3.7 s (section 8.6).
- At 4.2 s the next Labyrinth starts by itself with the fade (section 8.8). The Child does not choose.

### 6.4 Reward after Labyrinth 20

Source: [ticket 15](issues/15-reward-after-labyrinth-20.md), gap-audit default 30.

- At each Goal from Labyrinth 21, a random Sea friend from the Collection comes back. It does the same arrival motion and plays its own sound.
- The game never picks the same Sea friend two times in a row. The save keeps the last one in `last_returning_friend`, so the rule also holds after a restart.
- It flies back to its own slot in the strip. The strip does not grow.

### 6.5 Collection

Source: [ticket 19](issues/19-gaps-before-the-spec.md) Q4.

- The Collection is the strip at the bottom of the play screen. The game has no separate Collection screen.
- The strip has 20 slots in the order of section 4.7. A slot shows its Sea friend after the Child gets it. An empty slot shows nothing.
- The total count of collected Items shows as a number at the left end of the strip.

## 7. Areas and look

Sources: [ticket 08](issues/08-visual-change-between-labyrinths.md), [ticket 13](issues/13-polished-sea-look.md), [ticket 19](issues/19-gaps-before-the-spec.md) Q1, Q2, Q3, Q5, the [motion prototype](prototypes/motion-PROTOTYPE/index.html), gap-audit default 40.

### 7.1 World

- The look is top-down, from the Kenney Pirate Pack. The walls are islands with a sand coast and a grass top. The paths are water channels. The Labyrinth must look like islands in a sea, not like lines. Visual references: [Kenney sample](prototypes/art-PROTOTYPE/ref/kenney-pirate-sample.png) and the [sprite sheet](prototypes/art-PROTOTYPE/sprites/contact-light.png).
- The water is not a tile. A `canvas_item` shader draws it on a full-screen node under the islands ([ticket 13](issues/13-polished-sea-look.md)).
- Make the islands from the 31 Kenney tiles in `assets/kenney/tiles/`. These tiles are 128 × 128 px. Draw them with a `TileMapLayer` and a `TileSet` made in code ([godot4-facts §6](research/godot4-facts.md)). Use one `TileSetAtlasSource` for each tile PNG, with `texture_region_size` 128 × 128. Scale the layer to the tile size of section 10.
- Pick the coast tile for each island tile from its water neighbours, and check the result against the Kenney sample. See Open gap 1.
- Tile groups, identified by eye. The repo has no Kenney tile list.
  - Sand and grass coast pieces: 06, 07, 08, 09, 22, 25, 36, 37, 38, 41, 52, 53, 54, 55, 56, 57.
  - Full grass: 23, 39. Grass with small dots: 24, 40.
  - Rocks: 49, 50, 51, 65, 66, 67.
  - Bush: 70. Palm: 71. Small plant: 72. Grass details: 87, 88.
- Wall islands: place a rock or the bush (tile 70) on some island tiles. Use a second PRNG with seed `labyrinth_seed + 1`, so the Labyrinth data stays the same. Wall islands never get tile 71 or tile 72.
- The Goal island gets the palm (tile 71) and the chest.
- The boat (`boat_white_sail.png`) and the islands are the same in all Areas ([ticket 08](issues/08-visual-change-between-labyrinths.md)).

### 7.2 Areas

The look changes at the start of each Area, every 5 Labyrinths. The music also changes (section 9).

| Area | Labyrinths (and random) | Water deep colour | Water light colour | Items (in list order) | Decoration | Music |
|---|---|---|---|---|---|---|
| 1 Lagoon | 1 to 5 | `#3fb4d8` | `#7fd8ef` | `spiral_shell`, `starfish`, `pearl` | Waves | Ocean Joy |
| 2 Coral reef | 6 to 10 | `#2aa6a0` | `#76d6c4` | `coral`, `sand_dollar` | Bubbles that rise | Marine Melody |
| 3 Open sea | 11 to 15 | `#1f6fb5` | `#5aa0dc` | `gem_stone`, `spiral_shell` | Droplets | Fairy Land |
| 4 Sea at night | 16 to 20 | `#14284f` | `#3a5a92` | `glowing_star`, `star` | Small stars that twinkle | Cloud of Dreams |

- The colours come from line 22 of the motion prototype (ticket 19 Q2). The deep colour fills the water. The light colour draws the wave lines.
- No Sea friend appears as an Item or as a decoration ([ticket 13](issues/13-polished-sea-look.md)).
- Decorations are water effects made with the shader or with `CPUParticles2D`. They are not sprites (ticket 19 Q3). Section 8.2 gives their values.

### 7.3 Asset files

| Asset | Path in the game | Source path or step |
|---|---|---|
| Boat | `assets/kenney/ships/boat_white_sail.png` (108 × 170 px) | `prototypes/style-target/assets/kenney/ships/boat_white_sail.png` |
| Island tiles | `assets/kenney/tiles/tile_NN.png` (31 files) | `prototypes/style-target/assets/kenney/tiles/` |
| Kenney licence | `assets/kenney/License.txt` | `prototypes/style-target/assets/kenney/License.txt` |
| 20 Sea friends | `assets/sprites/friends/<id>.png` (512 px) | `prototypes/art-PROTOTYPE/sprites/friends/` |
| Area 1 Items and the second Spiral shell | `assets/sprites/items/{spiral_shell,starfish,pearl}.png` | `prototypes/art-PROTOTYPE/sprites/items/` |
| New Items | `assets/sprites/items/{coral,sand_dollar,gem_stone,glowing_star,star}.png` | Generate (section 13.2) |
| Chest | `assets/sprites/goal/{chest_closed,chest_open}.png` | Generate (section 13.2) |

Known weak sprites: the crab faces the front; the shrimp antennae are thin; the navy whale has low contrast on dark water; the swan and the pearl are near-white ([ticket 13](issues/13-polished-sea-look.md)). The order in section 4.7 puts the whale in light Area 1 and the swan in dark Area 4.

## 8. Motion

Sources: [ticket 11](issues/11-motion-and-animation.md) (Answer and values table), [ticket 13](issues/13-polished-sea-look.md) (water and boat effects), the [motion prototype](prototypes/motion-PROTOTYPE/index.html), gap-audit defaults 25 to 27 and 40.

All 7 motions stay, at the medium amount. The values below are the spec values. Do not use a multiplier.

### 8.1 Units and curves

- The prototype has one tile of 130 px on a canvas of 960 × 760 px. Multiply each Labyrinth value in px by `s = tile_px / 130`. Multiply each HUD value in px by `h = viewport_height / 760` (gap-audit default 27).
- Curve names from the prototype (line 46):
  - `out` is `Tween.TRANS_CUBIC` with `Tween.EASE_OUT`.
  - `inout` is `Tween.TRANS_CUBIC` with `Tween.EASE_IN_OUT`.
  - `back` is `Tween.TRANS_BACK` with `Tween.EASE_OUT`.
- Make tweens with `create_tween()`. Make bursts with one-shot `CPUParticles2D` nodes: `one_shot = true`, `emitting = false` until the burst, then `restart()` ([godot4-facts §5](research/godot4-facts.md)). For a burst that emits all particles at once, set `explosiveness = 1.0`.
- `t` below is the time in seconds.

### 8.2 Idle and water

| Motion | Values |
|---|---|
| Boat idle | Rock `0.06 * sin(1.6 t)` rad and bob `2 * sin(1.6 t + 1)` px. Only while the boat does not move. |
| Item idle | Bob `4 * sin(2 t + i)` px, where i is the Item index. A white 8-point sparkle of radius 7 px at (+18, −18) px from the Item centre. It shows while `fract(0.7 t + 0.33 i) < 0.15`, with alpha `1 - fract / 0.15` (a cycle of 1.4 s). |
| Goal island idle | The palm sways `0.08 * sin(1.5 t)` rad. |
| Water waves | Short curved lines in the Area light colour, at 18 % opacity, 3 px wide. The rows are 34 px apart. In a row, a line starts every 90 px. Each line moves `8 * sin(1.2 t + 0.02 x + 0.05 y)` px. The shader also moves soft light patterns on the water (Open gap 6). |
| Foam | A white line at 55 % opacity, 4 px wide, along each island coast. Dashes are 10 px on and 9 px off. The dashes move at 20 px/s. The line distance from the coast changes by `2 * sin(2 t)` px. |
| Wake | While the boat moves, a new ring starts in 60 % of the frames at 60 fps (about 36 rings each second). Each ring starts 30 px behind the boat centre, on the move line. The rings start alternately a little to the left and to the right of the move line, so they make a V shape. Each ring is a white 2 px ellipse that grows from 4 × 2 px to 30 × 16 px, turned to the boat direction, and fades out in 900 ms. |
| Area 1 decoration: waves | Small white wave crests drift on the water. Values: Open gap 6. |
| Area 2 decoration: bubbles | Small white circles that rise and fade out. Values: Open gap 6. |
| Area 3 decoration: droplets | Small light-blue drops that fall and fade out. Values: Open gap 6. |
| Area 4 decoration: stars | Small white 4-point stars on the water. Their alpha goes up and down. Values: Open gap 6. |

### 8.3 Boat move and bump

Section 5.2 and section 5.3 give the values: 180 ms for each tile with the `out` curve, and a bump of 0.12 tile in 70 ms then 110 ms.

### 8.4 Item collect

At the arrival on the Item square:
1. 8 splash dots in `#ffffff` and `#bbddff`, speed 90 px/s, life 400 ms.
2. The Item scales to 1.4× in 120 ms (`out`).
3. Then it flies to its outline in 450 ms (`inout`) and shrinks to 0.55×.
4. At the outline: the outline fills in 150 ms. It bounces from 1.5× to 1× in 350 ms (`back`). 10 sparkles in `#ffffff` and `#ffe07a`, speed 120 px/s, life 500 ms.

### 8.5 Goal

The times start at the arrival on the Goal square (0 ms):
- 0 ms: the chest changes to `chest_open.png`. The fanfare starts.
- 0 ms and 600 ms: the boat hops. One hop scales the boat height to 1.25× in 150 ms (`out`), then back to 1× in 250 ms (`back`).
- 0 ms: 40 confetti pieces start 40 px above the Goal island centre. They are rectangles of 10 × 6 px that turn, in `#ff5a5a`, `#ffd54a`, `#5ad1ff`, `#7cff7a`, and `#ff8ad8`. Start speed is 320 px/s times a random factor from 0.4 to 1.2, in all directions, with an upward push. Gravity is 380 px/s². Life is 2.6 s.

### 8.6 Sea friend

- 1.4 s: the Sea friend appears at (−60, +60) px from the Goal island centre. It grows from 0 to 1.3× of 110 px in 450 ms (`back`), and it moves up to 30 px above the island centre in the same 450 ms (`back`).
- 1.9 s: it wiggles. Its rotation goes from −0.15 rad to +0.15 rad in 250 ms (`inout`), then to 0 in 250 ms (`inout`).
- 3.0 s: it flies to its strip slot in 700 ms (`inout`) and shrinks to the strip icon size.
- 3.7 s: 10 sparkles in `#ffffff` and `#ffe07a`, speed 100 px/s, life 500 ms. The slot now shows the Sea friend.
- After Labyrinth 20, the Sea friend that comes back does the same motion and flies to its own slot (section 6.4).

### 8.7 Item outlines

An empty outline is the Item sprite at 35 % opacity, drawn grey and light (greyscale, then brightness 2×). A filled outline draws the normal sprite on top with alpha from 0 to 1 (motion prototype line 114).

### 8.8 Next Labyrinth and new Area

- 4.2 s: the screen fades to dark (`#0a1428`) in 500 ms (`inout`). The new Labyrinth shows. The screen fades in in 500 ms (`inout`).
- The input is locked from the Goal to the end of the fade-in.
- At the start of a new Area, the first Item kind of that Area pops up big in the centre of the screen. It scales from 0 to 2× of the Labyrinth Item size in 400 ms (`back`). It stays for 600 ms, then it fades out in 400 ms. It starts with the fade-in. It does not fly and does not fill an outline. The input unlocks at the end of the fade-in, before the Item fades out (gap-audit default 25).
- At launch and after a Parent reset, the screen fades in from dark in 500 ms. No Area Item shows (gap-audit default 26).

## 9. Sound

Sources: [ticket 06](issues/06-sound.md), [ticket 10](issues/10-source-the-sounds.md), [ticket 12](issues/12-listen-to-the-sounds.md) (sections "Final list" and "Clip processing"), [ticket 19](issues/19-gaps-before-the-spec.md) Q6, [research/sounds.md](research/sounds.md) (Final list, Format notes), [godot-audio skill](../../.claude/skills/godot-audio/SKILL.md), [audio-design skill](../../.claude/skills/audio-design/SKILL.md), gap-audit defaults 35 to 38.

### 9.1 Buses

- Create two buses at startup with `AudioServer.add_bus()`, `AudioServer.set_bus_name()`, and `AudioServer.set_bus_send(idx, "Master")`: `Music` and `Effects` ([godot4-facts §4](research/godot4-facts.md)).
- Music players use `Music`. All effects and Sea friend sounds use `Effects`.
- Section 11.2 sets the bus volumes.
- A headless run has no sound (audio driver Dummy). Tests check the sound calls, not the output.

### 9.2 Music

| Area | File | Track | Author | Licence | Page | File URL (no login) | Length |
|---|---|---|---|---|---|---|---|
| 1 | `assets/audio/music/lagoon.mp3` | Ocean Joy | AndriiComposer | Pixabay Content License | https://pixabay.com/music/cartoons-ocean-joy-380628/ | https://cdn.pixabay.com/download/audio/2025/07/26/audio_18320a1070.mp3?filename=andriicomposer-ocean-joy-380628.mp3 | 165.6 s |
| 2 | `assets/audio/music/coral_reef.mp3` | Marine Melody | AndriiComposer | Pixabay Content License | https://pixabay.com/music/happy-childrens-tunes-marine-melody-380629/ | https://cdn.pixabay.com/download/audio/2025/07/26/audio_d159382c1c.mp3?filename=andriicomposer-marine-melody-380629.mp3 | 136.6 s |
| 3 | `assets/audio/music/open_sea.mp3` | Fairy Land | AndriiComposer | Pixabay Content License | https://pixabay.com/music/happy-childrens-tunes-fairy-land-440535/ | https://cdn.pixabay.com/download/audio/2025/11/21/audio_74735d57bc.mp3?filename=andriicomposer-fairy-land-440535.mp3 | 164.6 s |
| 4 | `assets/audio/music/sea_at_night.mp3` | Cloud of Dreams | AndriiComposer | Pixabay Content License | https://pixabay.com/music/acoustic-group-cloud-of-dreams-380619/ | https://cdn.pixabay.com/download/audio/2025/07/26/audio_b540bbd752.mp3?filename=andriicomposer-cloud-of-dreams-380619.mp3 | 152.3 s |

All 4 file URLs returned HTTP 200 to `curl` on 2026-11-04. The lengths come from `ffprobe` on these files. The files are MP3, 44.1 kHz, stereo, 256 kbps.

- Music starts at launch. A native app has no autoplay block ([ticket 01](issues/01-choose-tech-stack.md)).
- Import each MP3 with Loop off. The game loops each track with a crossfade to its own start, so a jump at the loop point is not audible ([ticket 12](issues/12-listen-to-the-sounds.md)).
- Before the import, cut the fade-out at the end of each track: `ffmpeg -i in.mp3 -t <end> -c copy out.mp3` ([sounds.md](research/sounds.md) Format notes). Open gap 7 describes how to find `<end>`.
- **Crossfade** (pattern 3 of the [godot-audio skill](../../.claude/skills/godot-audio/SKILL.md)): use two `AudioStreamPlayer` nodes on `Music`. The crossfade takes 1.5 s. It starts when 1.5 s of the track remain. The new copy goes from −40 dB to the track level, and the old copy goes down to −40 dB, then stops.
- When the Area changes, the same crossfade goes to the new Area track. It starts with the fade to dark (section 8.8).
- Set `process_mode = PROCESS_MODE_ALWAYS` on the music players, so the music continues while the settings pause the game. This setting is correct whether or not a paused tree stops an `AudioStreamPlayer`.

### 9.3 Effects

All effect URLs are the Freesound `-hq.mp3` preview files. They download with no login, and their licence is the licence of the sound ([ticket 19](issues/19-gaps-before-the-spec.md) Q6). All URLs returned HTTP 200 to `curl` on 2026-11-04.

| Event | File | Sound | Author | Licence | Page | Preview URL | Work |
|---|---|---|---|---|---|---|---|
| Each move | `assets/audio/effects/move.wav` | Water Swish | dslrguide | CC0 | https://freesound.org/people/dslrguide/sounds/321489/ | https://cdn.freesound.org/previews/321/321489_5485024-hq.mp3 | Whole file (0.9 s) |
| Bump at a wall | `assets/audio/effects/wall.wav` | Boing 2 | magnuswaker | CC0 | https://freesound.org/people/magnuswaker/sounds/540790/ | https://cdn.freesound.org/previews/540/540790_11537497-hq.mp3 | Whole file (1.1 s) |
| Item collected | `assets/audio/effects/item.wav` | Bubble Pop | YehawSnail | CC0 | https://freesound.org/people/YehawSnail/sounds/683587/ | https://cdn.freesound.org/previews/683/683587_12375565-hq.mp3 | Whole file (0.5 s) |
| Goal | `assets/audio/effects/goal.wav` | Success Fanfare Trumpets | FunWithSound | CC0 | https://freesound.org/people/FunWithSound/sounds/456966/ | https://cdn.freesound.org/previews/456/456966_6456158-hq.mp3 | Cut at 3.7 s, fade out from 3.2 s to 3.7 s |
| Sea friend with no own sound | `assets/audio/effects/splash.wav` | Splash | swordofkings128 | CC0 | https://freesound.org/people/swordofkings128/sounds/398032/ | https://cdn.freesound.org/previews/398/398032_7586736-hq.mp3 | Whole file (1.3 s) |

- The move sound goes in an `AudioStreamRandomizer` with `random_pitch_semitones = 1.0`. Its player has `max_polyphony = 4` ([sounds.md](research/sounds.md), [audio-design skill](../../.claude/skills/audio-design/SKILL.md)).
- The move sound plays one time for each move, not for each square.
- The fanfare cut: `ffmpeg -i goal.mp3 -t 3.7 -af "afade=t=out:st=3.2:d=0.5" -ac 1 -ar 44100 -c:a pcm_s16le goal.wav` (ticket 11, gap-audit default 37).
- The new-Area Item makes no sound (gap-audit default 38).

### 9.4 Sea friend sounds

13 Sea friends have an own sound. 7 use the splash: Spouting whale, Blowfish, Shark, Lobster, Shrimp, Oyster, Turtle ([ticket 12](issues/12-listen-to-the-sounds.md) Final list). The sound plays at 1.4 s, when the Sea friend appears. The own sound replaces the splash (gap-audit default 38).

| Sea friend | File | Sound | Author | Licence | Page | Preview URL | Cut |
|---|---|---|---|---|---|---|---|
| Crab | `assets/audio/friends/crab.wav` | scissors;snips.wav | Abir19 | CC0 | https://freesound.org/people/Abir19/sounds/629513/ | https://cdn.freesound.org/previews/629/629513_11298046-hq.mp3 | Whole file |
| Octopus | `assets/audio/friends/octopus.wav` | Cartoon - Smoochy Squeak + Plop | Breviceps | CC0 | https://freesound.org/people/Breviceps/sounds/444494/ | https://cdn.freesound.org/previews/444/444494_9159316-hq.mp3 | Whole file |
| Whale | `assets/audio/friends/whale.wav` | Whale.wav | claretcanelon | CC0 | https://freesound.org/people/claretcanelon/sounds/458626/ | https://cdn.freesound.org/previews/458/458626_1096807-hq.mp3 | 0:01.3 to 0:03.8 |
| Dolphin | `assets/audio/friends/dolphin.wav` | Dolphin Noise-.wav | jfournier18 | CC0 | https://freesound.org/people/jfournier18/sounds/456151/ | https://cdn.freesound.org/previews/456/456151_9126235-hq.mp3 | Whole file |
| Fish | `assets/audio/friends/fish.wav` | Bubbles Light Short Descend.wav | murraysortz | CC0 | https://freesound.org/people/murraysortz/sounds/192496/ | https://cdn.freesound.org/previews/192/192496_3289374-hq.mp3 | Whole file |
| Squid | `assets/audio/friends/squid.wav` | Bottle Squirt.wav | jimbo555 | CC0 | https://freesound.org/people/jimbo555/sounds/630484/ | https://cdn.freesound.org/previews/630/630484_10616645-hq.mp3 | Whole file |
| Seal | `assets/audio/friends/seal.wav` | Sound of a Seal | florianreichelt | CC0 | https://freesound.org/people/florianreichelt/sounds/450751/ | https://cdn.freesound.org/previews/450/450751_6253486-hq.mp3 | Whole file |
| Jellyfish | `assets/audio/friends/jellyfish.wav` | Bubble.wav | megmcduffee | CC0 | https://freesound.org/people/megmcduffee/sounds/332597/ | https://cdn.freesound.org/previews/332/332597_4357924-hq.mp3 | 0:06.85 to 0:09.35 |
| Otter | `assets/audio/friends/otter.wav` | Otters Squeaking.wav | Motion_S | **CC BY 4.0** (credit necessary) | https://freesound.org/people/Motion_S/sounds/221761/ | https://cdn.freesound.org/previews/221/221761_3299593-hq.mp3 | 0:33.3 to 0:34.8 |
| Penguin | `assets/audio/friends/penguin.wav` | Penguin Squeak | Breviceps | CC0 | https://freesound.org/people/Breviceps/sounds/705839/ | https://cdn.freesound.org/previews/705/705839_9159316-hq.mp3 | Whole file |
| Duck | `assets/audio/friends/duck.wav` | single quack from a duck | Mikes-MultiMedia | CC0 | https://freesound.org/people/Mikes-MultiMedia/sounds/418509/ | https://cdn.freesound.org/previews/418/418509_5632532-hq.mp3 | Whole file |
| Swan | `assets/audio/friends/swan.wav` | Trumpeter Swans little honks 2pm TTP B 180531.mp3 | TRP | CC0 | https://freesound.org/people/TRP/sounds/572743/ | https://cdn.freesound.org/previews/572/572743_97550-hq.mp3 | 0:44.6 to 0:46.1 |
| Flamingo | `assets/audio/friends/flamingo.wav` | Flamingos | Breviceps | CC0 | https://freesound.org/people/Breviceps/sounds/535778/ | https://cdn.freesound.org/previews/535/535778_9159316-hq.mp3 | 0:00.3 to 0:01.8 |

The cut times are times in the preview file. The Parent chose them from clips of the preview files ([ticket 12](issues/12-listen-to-the-sounds.md)), so they apply directly to these files.

### 9.5 Conversion and clip cuts

- Convert each effect and each Sea friend sound to WAV, 16-bit, 44.1 kHz, mono ([sounds.md](research/sounds.md) Format notes): `ffmpeg -i in.mp3 -ac 1 -ar 44100 -c:a pcm_s16le out.wav`.
- Each cut clip (Whale, Jellyfish, Otter, Swan, Flamingo) gets a fade-in of 0.05 s and a fade-out of 0.2 s, and no gain ([ticket 12](issues/12-listen-to-the-sounds.md), section "Clip processing"). Example for the Otter (start 33.3 s, length 1.5 s): `ffmpeg -i otter.mp3 -af "atrim=start=33.3:duration=1.5,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.05,afade=t=out:st=1.3:d=0.2" -ac 1 -ar 44100 -c:a pcm_s16le otter.wav`. For a clip with the start S and the length D, use `-af "atrim=start=S:duration=D,asetpts=PTS-STARTPTS,afade=t=in:st=0:d=0.05,afade=t=out:st=D-0.2:d=0.2"`. Do not put `-ss` after `-i` together with `afade`: that order applies the fades before the seek, and the Otter, Swan, and Jellyfish clips became silent ([ticket 29](issues/29-sounds-and-credits.md)). The Whale and the Jellyfish clips are 2.5 s long, so their fade-out starts at 2.3 s.
- Do not copy the −3 dB peak gain of the clips on the listen pages.
- WAV import options: Edit > Trim off, Loop Mode "Disabled", Compress > Mode "Quite OK Audio" (the default). Import trim removes real sound from the quiet recordings: it cut the Duck from 0.82 s to 0.16 s ([ticket 29](issues/29-sounds-and-credits.md)).

### 9.6 Loudness step

Source: [sounds.md](research/sounds.md) Download and preparation, [audio-design skill](../../.claude/skills/audio-design/SKILL.md), gap-audit default 35.

1. Measure each processed file one time: `ffmpeg -i f.wav -af ebur128=peak=true -f null -`. Read the integrated loudness I (LUFS) and the true peak TP (dBTP).
2. Effects and Sea friend sounds: the player `volume_db` is `-18 - I`. If `TP + volume_db` is more than −1 dBTP, use `-1 - TP`.
3. Music: the player level is `-24 - I`, with the same true-peak limit.
4. Write the values in a table in code (`src/sound_levels.gd`), one line for each file.

### 9.7 Sound events

| Event | Sound |
|---|---|
| Launch | Music of the current Area |
| Move starts | `move.wav` |
| Bump | `wall.wav` |
| Item collected | `item.wav` |
| Goal arrival | `goal.wav` |
| Sea friend appears (1.4 s) | Its own sound, or `splash.wav` |
| Area change | Music crossfade to the new Area track |

### 9.8 `credits.txt`

Write this file at the repository root (gap-audit default 41):

```text
Sounds, music, and art in this game

Only one file below needs a credit by its licence (CC BY 4.0).
The other files are CC0 or Pixabay Content License and need no credit.
We list them all to thank the authors.

== CC BY 4.0 (credit necessary) ==
"Otters Squeaking.wav" by Motion_S
  https://freesound.org/people/Motion_S/sounds/221761/
  Licence: CC BY 4.0, https://creativecommons.org/licenses/by/4.0/
  Change: we cut a short part (0:33.3 to 0:34.8) of the Freesound preview file and converted it to WAV.

== Pixabay Content License (no credit necessary) ==
https://pixabay.com/service/license-summary/
"Ocean Joy" by AndriiComposer - https://pixabay.com/music/cartoons-ocean-joy-380628/
"Marine Melody" by AndriiComposer - https://pixabay.com/music/happy-childrens-tunes-marine-melody-380629/
"Fairy Land" by AndriiComposer - https://pixabay.com/music/happy-childrens-tunes-fairy-land-440535/
"Cloud of Dreams" by AndriiComposer - https://pixabay.com/music/acoustic-group-cloud-of-dreams-380619/

== CC0 1.0 (public domain, no credit necessary) ==
https://creativecommons.org/publicdomain/zero/1.0/
Effects
"Water Swish" by dslrguide - https://freesound.org/people/dslrguide/sounds/321489/
"Boing 2" by magnuswaker - https://freesound.org/people/magnuswaker/sounds/540790/
"Bubble Pop" by YehawSnail - https://freesound.org/people/YehawSnail/sounds/683587/
"Success Fanfare Trumpets.mp3" by FunWithSound - https://freesound.org/people/FunWithSound/sounds/456966/
"Splash" by swordofkings128 - https://freesound.org/people/swordofkings128/sounds/398032/
Sea friends
"scissors;snips.wav" by Abir19 - https://freesound.org/people/Abir19/sounds/629513/
"Cartoon - Smoochy Squeak + Plop" by Breviceps - https://freesound.org/people/Breviceps/sounds/444494/
"Whale.wav" by claretcanelon - https://freesound.org/people/claretcanelon/sounds/458626/
"Dolphin Noise-.wav" by jfournier18 - https://freesound.org/people/jfournier18/sounds/456151/
"Bubbles Light Short Descend.wav" by murraysortz - https://freesound.org/people/murraysortz/sounds/192496/
"Bottle Squirt.wav" by jimbo555 - https://freesound.org/people/jimbo555/sounds/630484/
"Sound of a Seal" by florianreichelt - https://freesound.org/people/florianreichelt/sounds/450751/
"Bubble.wav" by megmcduffee - https://freesound.org/people/megmcduffee/sounds/332597/
"Penguin Squeak" by Breviceps - https://freesound.org/people/Breviceps/sounds/705839/
"single quack from a duck" by Mikes-MultiMedia - https://freesound.org/people/Mikes-MultiMedia/sounds/418509/
"Trumpeter Swans little honks 2pm TTP B 180531.mp3" by TRP - https://freesound.org/people/TRP/sounds/572743/
"Flamingos" by Breviceps - https://freesound.org/people/Breviceps/sounds/535778/

== Art ==
"Pirate Pack" by Kenney (www.kenney.nl), CC0 - https://kenney.nl/assets/pirate-pack
The Sea friends, the Items, and the treasure chest were generated for this family game
with xai-oauth/grok-imagine-image (the Parent's xAI subscription), in the style of the
Kenney Pirate Pack. Their rights follow the xAI terms of that subscription.
```

## 10. Screen layout and HUD

Sources: [ticket 18](issues/18-screen-layout.md), [ticket 19](issues/19-gaps-before-the-spec.md) Q4, the [motion prototype](prototypes/motion-PROTOTYPE/index.html) lines 36, 73, 112 to 116, gap-audit defaults 27 to 29.

Read the visible size from `get_viewport().get_visible_rect().size`. With the aspect `expand`, it is 1920 × 1200 on a 16:10 screen and 1920 × 1247 on a 1512 × 982 screen. Do the layout again on each size change.

- **Top band:** height `round(Hv * 150 / 760)`, 237 px at 1200. It holds the Item row and the gear.
- **Bottom strip:** height `round(Hv * 70 / 760)`, 111 px at 1200, colour black at 25 % opacity (`Color(0, 0, 0, 0.25)`). It is the Collection.
- **Labyrinth:** `tile_px = floor(min((Hv - top - bottom) / (2H + 1), Wv / (2W + 1)))`. The Labyrinth is in the middle of the space between the top band and the strip. A 4 × 3 Labyrinth has 121 px tiles, and a 10 × 7 Labyrinth has 56 px tiles at 1920 × 1200. The water fills the whole screen.
- **Sizes in the Labyrinth** (multiply by `s`): boat 54 × 86 px, Item 60 px, Sea friend 110 px, chest 60 px (Open gap 3).
- **Item row:** the outlines sit in a row at the centre of the top band, at `y = 60 * h`. The distance between outline centres is `90 * h`, and each outline is `56 * h` px. The row is centred left to right.
- **Gear:** 64 px, in the top-right corner. Its centre has the same height as the Item row and the same distance from the right edge.
- **Collection strip:** the total Item count at the left end as a number, in the Godot default font at `64 * h / (1200 / 760)` px (64 px at 1200). The 20 slots fill the rest of the strip with the same distance between their centres. Each slot icon is `44 * h` px (69 px at 1200).
- The game shows no other text and no other numbers.

## 11. Settings and Parent controls

Sources: [ticket 09](issues/09-saved-progress.md), [ticket 16](issues/16-parent-controls.md), [ticket 19](issues/19-gaps-before-the-spec.md) Q7, [map.md](map.md) "Facts for the build", [research/godot4-facts.md](research/godot4-facts.md) §3, gap-audit defaults 32 to 34.

### 11.1 Start and quit

- `./play` opens the game at the saved Labyrinth. The game has no start screen.
- In `_ready()` of the main scene, call `get_tree().set_auto_accept_quit(false)`. Then Cmd+Q and window close do nothing [trace]. The quit button is the only quit path.
- The game ignores `NOTIFICATION_WM_CLOSE_REQUEST`.
- While the game runs, it also blocks a macOS logout or shutdown [trace]. The Parent quits with the door button before a logout.

### 11.2 The settings panel

- A click on the gear opens the settings panel. The mouse pointer stays visible. The Child can use the settings too.
- When the panel opens, call `get_tree().paused = true`, and set `process_mode = PROCESS_MODE_ALWAYS` on the panel ([game-ui-ux layout](../../.claude/skills/game-ui-ux/references/layout-and-flow.md)). The input for play is locked. A second click on the gear closes the panel and unpauses.
- The panel shows pictures only (Open gap 2):
  - Music row: a music-note picture, a minus button, a level display of 4 bars, and a plus button.
  - Effects row: a speaker picture, a minus button, a level display of 4 bars, and a plus button.
  - A reset button with a circular-arrow picture.
  - A quit button with a door picture.
- **Volume:** each bus has 5 steps, 0 to 4. The value is `step / 4`. Set the bus with `AudioServer.set_bus_volume_linear(bus, value * value)` ([sounds.md](research/sounds.md)). At step 0, call `AudioServer.set_bus_mute(bus, true)` in place of a volume of 0, because `linear_to_db(0)` is `-inf` ([godot-audio skill](../../.claude/skills/godot-audio/SKILL.md)). The default steps are music 2 (0.5) and effects 3 (0.75). The game saves the steps in `user://settings.json` (section 12.4).
- **Hold buttons (reset and quit):** use `Button.button_down` and `Button.button_up`. A ring around the button fills in 3 s. If the Parent lets go before 3 s, the ring goes back to empty and nothing happens.
- **Reset after 3 s:** the panel closes and the game unpauses. The progress goes back to Labyrinth 1 with an empty Collection and a total of 0. The game writes the save. The screen fades in from dark (section 8.8). The volume steps stay.
- **Quit after 3 s:** the game writes the save, then calls `get_tree().quit()`.

### 11.3 Facts about keys that can end play

These facts come from a read of the Godot 4.7.2 source and from Apple docs. Nobody tested them ([godot4-facts §3](research/godot4-facts.md), [map.md](map.md)):

| Key | Fact [trace] |
|---|---|
| Esc | Godot does not leave fullscreen on Esc. Esc only fires `ui_cancel`. |
| Cmd+Q, window close | Blocked when the game calls `get_tree().set_auto_accept_quit(false)`. |
| Cmd+W | The Window menu has no Cmd+W item, so Cmd+W does nothing. |
| Ctrl+Cmd+F, Globe+F | Not known. |
| Cmd+Tab, Cmd+Option+Esc | Godot cannot block them. |
| Cmd+H, Cmd+Option+H, Cmd+M | Godot cannot block them. |
| Cmd+Space, Mission Control, Ctrl+Cmd+Q, Cmd+Shift+3, Cmd+Shift+4, Cmd+Shift+5 | Not confirmed. These are system keys. Godot gives no API for them. |

The Parent accepts that Cmd+Tab, Cmd+H, Cmd+M, and Cmd+Option+Esc cannot be blocked (ticket 19 Q7). If Ctrl+Cmd+F leaves fullscreen, the game must go back to exclusive fullscreen. Open gap 5 gives the API.

### 11.4 Required manual key test

The spec states no key as blocked before this test. The build runs the test on the Parent's Mac and writes the result for each key (blocked, not blocked, or other effect) in a table in its build report. Test each key of the table in 11.3, one at a time, with `./play`:
1. Start the game and wait for the fade-in.
2. Press the key or the key combination.
3. Record: does the game stay fullscreen? Does it stay in front? Does it quit? Does a macOS screen show?
4. Bring the game back if necessary, then go to the next key.

## 12. Saved progress

Sources: [ticket 09](issues/09-saved-progress.md), [save-systems skill](../../.claude/skills/save-systems/SKILL.md), gap-audit defaults 30 and 31.

### 12.1 File and fields

- File: `user://save.json` (on macOS: `~/Library/Application Support/Godot/app_userdata/Labyrinth/save.json`).
- Fields:

```json
{
  "version": 1,
  "labyrinth": 7,
  "random_seed": 0,
  "collected_items": ["3,1", "0,2"],
  "collection": ["crab", "octopus", "spouting_whale", "whale", "dolphin", "fish"],
  "total_items": 23,
  "last_returning_friend": ""
}
```

| Field | Content |
|---|---|
| `version` | Schema version. Now 1. |
| `labyrinth` | Current Labyrinth number, from 1. |
| `random_seed` | Seed of the current random Labyrinth when `labyrinth` > 20. Otherwise 0. |
| `collected_items` | IDs (`"x,y"`) of the Items collected in the current Labyrinth. |
| `collection` | Sea friend IDs in the order the Child got them. |
| `total_items` | Total count of collected Items. |
| `last_returning_friend` | ID of the last Sea friend that came back after Labyrinth 20, or `""`. |

- Godot JSON reads every number as a float. Convert `version`, `labyrinth`, `random_seed`, and `total_items` with `int()` after the load ([save-systems skill](../../.claude/skills/save-systems/SKILL.md)).

### 12.2 When to save

- After each collected Item.
- At each Goal, before the celebration. This save has the new Sea friend in `collection` (Labyrinths 1 to 20) or the new `last_returning_friend` (after 20), `labyrinth` + 1, an empty `collected_items`, and a new `random_seed` when the next Labyrinth is above 20. A quit during the celebration keeps the Sea friend.
- After a Parent reset, and before a quit.
- The boat position is not saved. After a restart, the boat starts on the start square. The collected Items of the current Labyrinth stay collected, so one Item never counts two times.

### 12.3 Write and load

- **Write:** write `user://save.json.tmp`, close it, then rename it to `user://save.json` with `DirAccess.rename_absolute()` ([save-systems skill](../../.claude/skills/save-systems/SKILL.md)). Do not keep a last good copy as `.bak`. In this game `save.bak` holds only a broken file (Resolved conflict 17).
- **No file:** start at Labyrinth 1 with no message.
- **Broken file:** rename it to `user://save.bak`. Replace an older `save.bak`. Then start at Labyrinth 1 with no message to the Child. A file is broken when:
  - the JSON does not parse, or it is not a dictionary,
  - a field is absent or has the wrong type,
  - `version` is higher than 1,
  - `labyrinth` is below 1,
  - `labyrinth` is above 20 and `random_seed` is 0,
  - an Item ID is not `"x,y"` of a square of the current Labyrinth, or it is the start square or the Goal square,
  - a Sea friend ID is not in the list of section 4.7.
- **Old Item ID:** an Item ID of a square with no Item does not make the file broken. The load removes this ID and keeps all other fields, also the total count. A save from before the Goal rule of section 4.2 can have such an ID (Resolved conflict 25).
- **Older version:** migrate it with a chain of functions, version by version. Do not treat an older version as broken. Version 1 is the first version, so the chain is empty now.

### 12.4 Settings file

- `user://settings.json` holds `{"version": 1, "music_step": 2, "effects_step": 3}`.
- A Parent reset does not change this file.
- An absent or broken settings file gives the default steps.

## 13. Asset acquisition steps

Sources: [ticket 12](issues/12-listen-to-the-sounds.md), [ticket 13](issues/13-polished-sea-look.md), [ticket 19](issues/19-gaps-before-the-spec.md), [PROVENANCE.md](prototypes/art-PROTOTYPE/sprites/PROVENANCE.md). No step needs a login or an action from the Parent.

### 13.1 Copy the files that the repo already has

1. `prototypes/style-target/assets/kenney/` to `assets/kenney/`: the 31 tiles, `ships/boat_white_sail.png`, and `License.txt`. The rest of `prototypes/style-target/` is an abandoned project. Do not use it.
2. `prototypes/art-PROTOTYPE/sprites/friends/*.png` (20 files) to `assets/sprites/friends/`.
3. `prototypes/art-PROTOTYPE/sprites/items/*.png` (3 files: `spiral_shell`, `starfish`, `pearl`) to `assets/sprites/items/`. The Spiral shell is also an Area 3 Item, so it needs no new sprite.

### 13.2 Generate 7 new sprites with the Grok method

Generate 5 new Items (`coral`, `sand_dollar`, `gem_stone`, `glowing_star`, `star`) and 2 chest sprites (`chest_closed`, `chest_open`). The method is the method of [ticket 13](issues/13-polished-sea-look.md) and [PROVENANCE.md](prototypes/art-PROTOTYPE/sprites/PROVENANCE.md). It runs on the Parent's xAI subscription through `omp` (`/opt/homebrew/bin/omp`). The full set of 23 sprites used about 2 % of the weekly quota.

Do these steps in `.scratch/labyrinth-game/prototypes/art-PROTOTYPE/`:
1. Add 7 entries to `SUBJECTS` in `tools/make_batch.py`, each with kind `"item"`. The "item" kind adds "no face, no eyes, no mouth" to the prompt. The subject sentences are the spec's own text (Open gap 3):
   - `coral`: "A small branch of pink coral with rounded tips, seen from the side."
   - `sand_dollar`: "A round flat sand dollar seen from above, pale cream with a five-petal flower pattern in the middle."
   - `gem_stone`: "One blue gem stone with large flat facets and one bright white highlight. Only the gem, nothing else."
   - `glowing_star`: "A yellow five-point star with soft rounded points and short light rays around it."
   - `star`: "A plain yellow five-point star with soft rounded points and no rays."
   - `chest_closed`: "A small wooden treasure chest with gold metal bands and a gold lock, lid closed, seen in three-quarter view."
   - `chest_open`: "The same small wooden treasure chest with gold metal bands, lid open, gold coins inside, seen in three-quarter view."
2. `python3 tools/make_batch.py batch09-items coral sand_dollar gem_stone glowing_star star`
3. `python3 tools/make_batch.py batch10-chest chest_closed chest_open`
4. `tools/run_batch.sh batch09-items` and `tools/run_batch.sh batch10-chest`. The raw images go to `gen/raw/<name>.jpg`, and the logs go to `gen/logs/`. One run takes about 1 minute for 2 images.
5. Cut out each image with the default options: `.venv/bin/python tools/cutout.py gen/raw/<name>.jpg sprites/items/<name>.png` for the Items, and `.venv/bin/python tools/cutout.py gen/raw/<name>.jpg sprites/goal/<name>.png` for the chests.
6. Check each new file: `.venv/bin/python ../../../../.claude/skills/create-game-assets/scripts/asset_report.py sprites/items/*.png sprites/goal/*.png --require-alpha`. Look at each sprite on light water and on dark water. The dark outline must be complete. The two chests must show the same chest. If a sprite fails, run its batch again.
7. Run `.venv/bin/python tools/contact_sheets.py`, and add one line for each new sprite to `sprites/PROVENANCE.md`.
8. Copy the new files to `assets/sprites/items/` and `assets/sprites/goal/`.

### 13.3 Download and process the sounds

1. Download the 4 music files and the 18 preview files with `curl -sS -A 'Mozilla/5.0' -o <file>.mp3 '<URL>'`. The URLs are in section 9.2, section 9.3, and section 9.4. Freesound and Pixabay need no login for these URLs (ticket 19 Q6).
2. Check each download: HTTP 200, and `ffprobe` shows a duration close to the length in the tables.
3. Cut the fade-out of each music file (section 9.2).
4. Convert and cut the effects and the Sea friend sounds (section 9.5).
5. Measure the loudness and write `src/sound_levels.gd` (section 9.6).
6. Write `credits.txt` (section 9.8).

### 13.4 Import

Run `godot --headless --path . --import`. Set `mipmaps/generate=true` in every PNG `.import` file. Set Edit > Trim off (`edit/trim=false`) in every WAV `.import` file, because import trim cut the Duck from 0.82 s to 0.16 s (section 9.5). Run the import again (section 3.5).

## 14. Tests

Sources: [ticket 01](issues/01-choose-tech-stack.md), [godot-gdscript-headless-testing skill](../../.claude/skills/godot-gdscript-headless-testing/SKILL.md), [godot4-facts §7](research/godot4-facts.md).

### 14.1 Headless GDScript tests

- Runner: `tests/run.gd`. It extends `SceneTree`. It counts passed and failed checks with an `assert_eq()` helper. It does not use bare `assert()`. Each test function returns `true` at its end, and the runner counts any other return value as a failure. The runner prints `Results: N passed, M failed` and calls `quit(1 if failed > 0 else 0)`. A test that waits for a signal also waits on a timeout timer.
- Commands:

```sh
godot --headless --path . --import
godot --headless --path . --script res://tests/run.gd
```

- The process exit code must be 0.

Tests:
1. **PRNG:** the first 5 outputs for seed 1 are pinned. Seed 0 gives the same outputs as seed 1. All outputs are from 1 to 2^32 − 1.
2. **Generator:** for Labyrinths 1 to 20 and for 200 random seeds:
   - the size matches the table of section 4.3,
   - exactly W × H − 1 walls are open,
   - each square is reachable from the start,
   - the wall bits of neighbour squares agree,
   - the Goal square has exactly one open side,
   - each square is reachable from the start with a breadth-first search that does not continue from the Goal square. No Labyrinth has a square behind the Goal.
   The full wall data of Labyrinth 1 is pinned. The pinned values of the tests come from `tests/spec_port.py`, a separate Python port of section 4.
3. **Items:**
   - the count matches section 4.3,
   - at least one Item is in a dead end,
   - no Item is on the start square or the Goal square,
   - all Item squares are different,
   - the kinds follow the Area list.
   Seeds 1 to 20 are all valid. A random seed with no valid dead end moves to seed + 1.
4. **Move rule:** on fixed small Labyrinths, the boat stops at:
   - a junction,
   - a bend,
   - a dead end,
   - an Item not yet collected,
   - the Goal.
   It passes a collected Item. A move toward a wall gives a bump and no move. The duration is 180 ms × tiles.
5. **Input:**
   - Feed `InputEventKey` events with `Input.parse_input_event()` ([godot4-facts §7](research/godot4-facts.md)). That this also works in `--headless` is a source-trace fact.
   - An echo event does nothing.
   - While the boat is busy, the game keeps only the last press.
   - While the input is locked, it drops each press.
6. **Areas and Sea friends:**
   - The Area of n = 1 to 45 matches section 4.3.
   - The music track matches the Area.
   - The Sea friend of n = 1 to 20 matches section 4.7.
   - In 1000 draws after Labyrinth 20, the Sea friend that comes back is never the same two times in a row, and it is always in the Collection.
7. **Save:**
   - A save and a load give the same state.
   - No file gives Labyrinth 1.
   - A broken file (each case of section 12.3) becomes `save.bak` and gives Labyrinth 1.
   - `version` 2 counts as broken.
   - The write goes to the `.tmp` file first.
   - After a reload, a collected Item does not count again.
   - An old Item ID of a square with no Item is removed. The other fields stay, and the file does not become `save.bak`.
   - A Goal save holds the new Sea friend and `labyrinth` + 1.
   - A reset keeps `settings.json`.
8. **Layout:** the tile size for each size of section 4.3 at 1920 × 1200 and at 1920 × 1247 matches the formula of section 10. The Labyrinth fits between the top band and the strip.
9. **Sound calls:** each event of section 9.7 calls the right stream on the right bus. Each sound file has a level in `src/sound_levels.gd`.
10. **Assets:** each path of section 7.3 and section 9 exists and loads. Each PNG `.import` file has `mipmaps/generate=true`. The length of each imported WAV file is the length of its source file, ±20 ms. `credits.txt` has a line for each sound file.
11. **Project settings:** the values of section 3.4 load from `ProjectSettings.get_setting()`.

### 14.2 Screenshots

A headless run has no pixels [trace]. For a screenshot, run the game in a window: `godot --path . --write-movie shots/frame.png --quit-after <N>`, or save `get_viewport().get_texture().get_image()` after `await RenderingServer.frame_post_draw` ([godot4-facts §7](research/godot4-facts.md)).

### 14.3 Manual test checklist

The build does these checks on the Parent's Mac and reports each result:
1. `./play` opens the game in fullscreen at the saved Labyrinth, with no start screen and no words.
2. The key test of section 11.4, for each key.
3. Sprite edges are smooth on light water (Area 1) and on dark water (Area 4). The dark outline of each sprite is complete ([ticket 14](issues/14-clean-sprite-edges.md)).
4. The water moves, foam moves along the coasts, the boat leaves a V-shaped wake, and the boat rocks when it does not move.
5. Each of the 7 motions of section 8 plays: idle, water, wake, Item collect, Goal hop and confetti, Sea friend arrival, fade and new-Area Item.
6. The chest opens at the Goal.
7. Each Area shows its colours, Items, decoration, and music.
8. The music loops with no audible jump, and the Area change crossfades.
9. The volume buttons change music and effects separately. Step 0 is silent.
10. Reset needs a hold of 3 s. A shorter hold does nothing. The same check for quit.
11. Cmd+Q does nothing.
12. After a quit and `./play`, the game opens at the same Labyrinth, with the collected Items still collected.
13. With Wi-Fi off, the game starts and plays.

## 15. Acceptance criteria

The build is complete when each criterion is true:
1. `./play` on the Parent's Mac starts the game in exclusive fullscreen at the saved Labyrinth, with no start screen.
2. The game shows no words. The only text is the total Item count number in the Collection strip.
3. The arrow keys are the only keys that act in play. A held arrow key moves the boat one time.
4. One arrow press moves the boat in a straight line to the next junction, bend, dead end, Item, or Goal, at 180 ms for each tile, with the `out` curve.
5. A press toward a wall makes a bump of 0.12 tile (70 ms, then 110 ms), plays the wall sound, and does not move the boat.
6. Labyrinth 1 is 4 × 3 squares with 2 Items and is the same at each new start. Labyrinths 1 to 20 match the table of section 4.3. Labyrinths from 21 are random at 10 × 7 with 8 Items.
7. Each Labyrinth has at least one Item in a dead end. No Item is on the start square or the Goal square.
8. The boat stops on each Item square. The Item pops, plays the pop sound, flies to its outline, and the outline fills.
9. At the Goal of Labyrinth n (1 to 20): the chest opens, the boat hops 2 times, confetti falls, the fanfare plays and fades out by 3.7 s, Sea friend n of section 4.7 arrives with its sound and flies to its slot, and the next Labyrinth starts by itself after the fade.
10. After Labyrinth 20, a random Sea friend from the Collection comes back at each Goal, never the same one two times in a row, also after a restart.
11. The Area look and the music change at Labyrinths 6, 11, 16, 21, and every 5 Labyrinths after that, in the order Area 1, 2, 3, 4, 1. The first Item kind of the new Area pops up big in the centre, then fades.
12. The islands are Kenney tiles with sand coasts. The water moves, the foam moves, the boat leaves a wake, and the boat rocks when it does not move.
13. The Goal island has a palm and a chest. No wall island has a palm.
14. Every PNG `.import` file has `mipmaps/generate=true`, the top-level canvas items use `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`, and the stretch mode is `canvas_items` with aspect `expand` at 1920 × 1200.
15. The Item row is at the top in the middle, the gear is in the top-right corner, and the Collection strip with the total count is at the bottom.
16. A click on the gear opens the settings and pauses play. Music and effects each have 5 volume steps, and step 0 mutes the bus. The volume steps stay after a restart and after a reset.
17. A hold of 3 s on the reset button starts Labyrinth 1 with an empty Collection and a total of 0. A shorter hold does nothing.
18. A hold of 3 s on the door button saves and quits. Cmd+Q and window close do not quit the game.
19. After a quit, `./play` opens the same Labyrinth, with the same collected Items, Collection, and total count.
20. If no save file exists, the game starts Labyrinth 1 with no message. A broken save becomes `save.bak` and the game starts Labyrinth 1 with no message.
21. The game sends no data over the network and runs with Wi-Fi off.
22. All 22 audio files and the 7 new sprites are in the project. `credits.txt` lists every sound and the art, with the Otter credit.
23. `godot --headless --path . --script res://tests/run.gd` exits with code 0, and all tests of section 14.1 pass.
24. The build report has the manual key test table of section 11.4 and the result of each item of section 14.3.

## 16. Out of scope

Sources: [map.md](map.md) Out of scope, [ticket 16](issues/16-parent-controls.md), [ticket 17](issues/17-session-limit.md), [ticket 19](issues/19-gaps-before-the-spec.md).

- Mouse, trackpad, and touch input for play.
- A recorded voice.
- Multiplayer, online accounts, and a public release.
- A web or browser version.
- An exported app bundle and export templates. The game runs from source.
- A start screen, a skip, a Labyrinth choice for the Child, and a session limit.
- Loops in the Labyrinths.
- A separate Collection screen.
- Music generation. The Parent chose 4 tracks.
- Changes to the tickets and research files. This spec overrides their older text.

## Resolved conflicts

Each line names the sources and the winner. "Later" means the later ticket or decision.
1. Fanfare: [ticket 11](issues/11-motion-and-animation.md) "Use the 3.8 s fanfare alternative" against [ticket 12](issues/12-listen-to-the-sounds.md) "Effects: the 5 first picks". Ticket 12 wins: Success Fanfare Trumpets, cut at 3.7 s with a fade-out from 3.2 s.
2. Celebration length: [ticket 04](issues/04-encouragement-without-losing.md) "about 3 seconds" against [ticket 11](issues/11-motion-and-animation.md) 0 to 3.7 s, then the fade at 4.2 s. Ticket 11 wins.
3. Sea friend sounds: [ticket 10](issues/10-source-the-sounds.md) and the map (15 own sounds, 5 splashes) against [ticket 12](issues/12-listen-to-the-sounds.md) (13 own sounds, 7 splashes). Ticket 12 wins.
4. Music: [ticket 06](issues/06-sound.md) "calm" and [ticket 10](issues/10-source-the-sounds.md) (Under the Sea, Midnight Reef Sleep, CC0 backups) against [ticket 12](issues/12-listen-to-the-sounds.md) (joyful, Fairy Land, Cloud of Dreams, no backups). Ticket 12 wins.
5. `credits.txt`: the draft in [research/sounds.md](research/sounds.md) against its Final list. The Final list wins (section 9.8).
6. Volume buttons: [ticket 06](issues/06-sound.md) "buttons on the screen" against [ticket 16](issues/16-parent-controls.md) "The settings hold the volume buttons". Ticket 16 wins.
7. Area Items and colours: [ticket 08](issues/08-visual-change-between-labyrinths.md) (emoji Items and colours) against [ticket 13](issues/13-polished-sea-look.md) and [ticket 19](issues/19-gaps-before-the-spec.md). Tickets 13 and 19 win (section 7.2).
8. Goal and boat art: [ticket 08](issues/08-visual-change-between-labyrinths.md) "sailboat… desert island" against [ticket 13](issues/13-polished-sea-look.md) "No emoji remain" and `boat_white_sail.png`. Ticket 13 wins.
9. Collection: [ticket 04](issues/04-encouragement-without-losing.md) "a screen with pictures only" against [ticket 11](issues/11-motion-and-animation.md) "the Collection strip at the bottom". Ticket 11 and ticket 19 Q4 win: the strip is the Collection.
10. Wake and water: [ticket 13](issues/13-polished-sea-look.md) "V-shaped wake and small ripples", "light patterns" against [ticket 11](issues/11-motion-and-animation.md) rings and waves. Both apply: ticket 13 gives the shape, and ticket 11 gives the amounts.
11. Palms: [ticket 13](issues/13-polished-sea-look.md) "some palms" on the wall islands against [ticket 19](issues/19-gaps-before-the-spec.md) Q5. Ticket 19 wins: the palm and the chest are on the Goal island only.
12. Bump: the [movement prototype](prototypes/movement-PROTOTYPE/index.html) (14 px of a 110 px square, 90 ms, then 120 ms) against the [motion prototype](prototypes/motion-PROTOTYPE/index.html) (0.12 tile, 70 ms, then 110 ms). The motion prototype (ticket 11) wins. Neither prototype has the "shake" of [ticket 03](issues/03-arrow-key-movement.md), so the spec has no shake.
13. Move tween: the movement prototype (one 180 ms tween for each square) against the motion prototype (one tween of 180 ms × n). The motion prototype wins.
14. The boat at the Goal: the movement prototype and [GLOSSARY.md](../../GLOSSARY.md) (the Goal is a square) against the motion prototype (the boat stops next to the Goal island). Both apply: the Goal is a square, and the island is the tile next to it (section 6.2).
15. New-Area sign: the motion prototype (the Area number) against the Answer of [ticket 11](issues/11-motion-and-animation.md) (the first Item, big). The Answer wins.
16. Area-start times: [ticket 11](issues/11-motion-and-animation.md) "plays while the screen fades in" (1.4 s), the 500 ms fade-in, and the 900 ms delay in the prototype. The ticket text wins: the Item starts with the fade-in, and the input unlocks at the end of the fade-in.
17. `save.bak`: [ticket 09](issues/09-saved-progress.md) "A broken file: rename it to save.bak" against the [save-systems skill](../../.claude/skills/save-systems/SKILL.md) (keep the last good save as `.bak`). The ticket wins.
18. Random Labyrinth size: [ticket 05](issues/05-levels-and-difficulty.md) "at the largest size" against its own step rule, which reaches only 9 × 7 at Labyrinth 20. Gap-audit default 17 decides: random Labyrinths are 10 × 7.
19. Tile size: [research/graphics.md](research/graphics.md) "64×64 tiles" against the repo tiles at 128 × 128. The repo files win.
20. Speed unit: [ticket 03](issues/03-arrow-key-movement.md) "180 ms for each square" was set on a thin-wall grid. The motion prototype, which the Parent judged last, moves 180 ms for each 130 px tile. With the tile grid of section 4.5, one square is 2 tiles. The motion prototype wins: 180 ms for each tile.
21. Sound downloads: [ticket 10](issues/10-source-the-sounds.md) and [research/sounds.md](research/sounds.md) ("Downloads from Freesound need a free account", "do not use" the preview files) against [ticket 19](issues/19-gaps-before-the-spec.md) Q6 (use the `-hq.mp3` previews, no login). Ticket 19 wins.
22. Clip times: [ticket 12](issues/12-listen-to-the-sounds.md) "Check them against the original file before the cut" and gap-audit default 39 (cross-correlation). Ticket 19 Q6 removes the original files, so the preview times apply directly. Default 39 does not apply.
23. Music loop: [ticket 10](issues/10-source-the-sounds.md) "music … with the Loop import option" against [ticket 12](issues/12-listen-to-the-sounds.md) "Every track uses the crossfade to its start". Ticket 12 wins: Loop off and a crossfade.
24. Wall islands: gap-audit default 12 says "Wall islands get rocks and bushes". The tile list has one bush (tile 70) and a small plant (tile 72) that can look like a palm. The spec uses tile 70 only.
25. Goal in a path: the recursive backtracker of section 4.2 (first text) against the Parent's report "Items are optional, but the Child must be able to reach each of them". The first generator put the Goal square in the middle of a path in 17 of the 20 fixed Labyrinths. The squares behind the Goal and their Items were lost, because the boat stops at the Goal. The Parent's report wins: the search does not continue from the Goal square (section 4.2). The Labyrinth shapes and Item squares changed, so section 12.3 removes old Item IDs on load.

## Open gaps

No source decides these facts. The build uses the stated value. The Parent can change each value later.
1. **Coast tile rules.** No source maps the 31 Kenney tiles to the water neighbours of an island tile, and the repo has only 31 of the 97 Pirate Pack tiles. The build picks the tiles by eye and checks the result against the Kenney sample. If a coast case has no tile in the repo, download the full pack from https://kenney.nl/assets/pirate-pack (CC0) and copy only the needed tiles.
2. **Settings pictures.** No source gives the art for the gear, the door, the circular arrow, the music note, the speaker, minus, plus, the level bars, and the hold ring. The build draws them in code (`_draw()` on `Control` nodes) as simple white shapes with a dark outline, 64 px.
3. **New sprite text and sizes.** The 7 subject sentences of section 13.2 and the chest size (60 px × `s`, the Item size) are spec values. The palm (tile 71) is at the far side of the Goal island tile, and the chest is at the side next to the Goal square.
4. **A Labyrinth with no free dead end.** A perfect Labyrinth can have only 2 dead ends: the start and the Goal. Then the rule "one Item in a dead end" cannot work. The spec value: such a seed is not valid. A random seed moves to seed + 1. A test checks that seeds 1 to 20 are valid. If one of them is not valid, the build uses the next free number above 20 for that Labyrinth and pins it in the test.
5. **The API to go back to fullscreen.** No ticket names it. The spec value: on `get_window().size_changed`, if `DisplayServer.window_get_mode()` is not `DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN`, call `DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)`.
6. **Decoration and light-pattern values.** Ticket 19 Q3 names the decorations, but no source gives their counts, sizes, or speeds, and no source gives values for the light patterns on the water. The spec values, in prototype px (multiply by `s`):
   - Area 1 waves: 6 crests, 24 × 8 px, drift at 15 px/s.
   - Area 2 bubbles: 1 bubble each second, 6 to 12 px, rise at 30 px/s, life 3 s.
   - Area 3 droplets: 1 drop each second, 6 × 9 px, fall at 40 px/s, life 1.5 s.
   - Area 4 stars: 12 stars, 6 to 10 px, alpha from 0.2 to 0.9 with a cycle of 2 s.
   - Light patterns: soft light shapes at 8 % opacity that move at 10 px/s.
   The decorations and the light patterns are drawn under the islands, the Items, and the boat, so they never hide them.
7. **The end point of each music track.** No source gives the point where the fade-out of each Pixabay track starts. The spec value: read the momentary loudness with `ffmpeg -i f.mp3 -af ebur128 -f null -`. In the last 20 s of the track, find the first time from which the momentary loudness stays more than 6 dB below the integrated loudness. Cut the track there.
8. **The size of the total count number.** The spec value: the Godot default font at 64 px (at 1200 px height), white with a dark outline.
