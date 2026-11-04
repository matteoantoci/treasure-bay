# Graphics sources for the Labyrinth game

Ticket: [07 Source the graphics](../issues/07-source-the-graphics.md). Date of research: 2026-11-03.

## Recommendation

Use **Microsoft Fluent Emoji, 3D style**, for all objects, and **draw the Labyrinth in code**.

- Character, Goal, collectible items, and reward pieces: Fluent Emoji 3D PNG files. Each file is 256×256 px with an alpha channel. The licence is MIT. The set has both themes in one style: a sailboat, an island, fish, and shells for the sea; a rocket, a ringed planet, stars, and comets for space.
- Walls, floor, and background: shapes that the game code draws (rounded rectangles, soft gradients, dots for stars or bubbles). The code takes its colours from a small palette that matches the emoji. This part has no image files, so a new Labyrinth size or shape needs no new art.
- Motion: the emoji are single frames. Tweens give the life: a bob, a tilt, a squash, a scale "pop". Particles of the Sparkles and Star emoji give the reward effect.

Why this option:

1. **Look.** The 3D emoji are soft, round, and bright. They read well at small sizes. A 5-year-old knows these shapes from phones and tablets.
2. **One consistent style.** Microsoft made the set as one family, with one light direction, one shade style, and one palette. Both themes come from the same family, so the theme choice in ticket 02 does not change the art pipeline.
3. **Licence and cost.** MIT, free. The only duty: keep the copyright and licence text with the files. The game shows no text, so the notice goes in a `LICENSE` file next to the images, not on the screen.
4. **More items later.** The set has more than 1,500 emoji. A new collectible is one more PNG file from the same family, with no drift.
5. **Engine fit.** PNG works in every candidate engine: Godot 4.7 (`Sprite2D`, `TileSet`), Phaser 4 (`load.image`), and SVG in the DOM (`<image>`). See [Engine fit](#engine-fit).

Fallback when the set has no good object: pick a near emoji from the same set first. The set has no lighthouse, for example. Use AI image generation only for an object that the set does not have, and give the model a Fluent PNG as the style reference. Expect drift (see option D).

## Comparison

| Option | Look for a 5-year-old girl | One consistent style | Licence | Cost | Work to add items later | Engine fit |
|---|---|---|---|---|---|---|
| **A. Fluent Emoji 3D + code-drawn Labyrinth (recommended)** | Soft 3D, bright, friendly. Known shapes. | High. One family for both themes. Risk: code-drawn walls must match the soft palette. | [MIT](https://github.com/microsoft/fluentui-emoji/blob/main/LICENSE) | Free | Low: copy one more PNG. | PNG: all engines. |
| B. Kenney CC0 packs | Sea: good top-down islands and water. Space: plain, shooter style, dark. Pirate ships have skulls and cannons. | High in one pack. Low between the sea packs and the space packs. | [CC0](https://creativecommons.org/publicdomain/zero/1.0/), no credit needed | Free (donation optional) | Medium: the pack has a fixed item list. | PNG + Starling XML atlas + one SVG sheet per pack. Fish Pack has one SVG per item. |
| C. Other emoji sets (OpenMoji, Twemoji, Noto) | Flat 2D. Less depth than Fluent 3D. | High in one set. | [OpenMoji: CC BY-SA 4.0](https://github.com/hfg-gmuend/openmoji); [Twemoji: CC BY 4.0](https://github.com/jdecked/twemoji); [Noto images: Apache 2.0](https://github.com/googlefonts/noto-emoji) | Free | Low | SVG + PNG. |
| D. AI image generation | Any style we ask for. Can match a picture book. | Low to medium. Each new image can drift in line, light, and palette. Needs a locked reference image and a cleanup pass. | OpenAI Terms of Use: "you … own the Output" ([terms](https://openai.com/policies/row-terms-of-use/)). Output "may not be unique". | Pay per image. Rates: $30 per 1M image output tokens for `gpt-image-2.5-*` ([pricing](https://developers.openai.com/api/docs/pricing)). A full set of about 30 images with retries probably costs under $10 [INFERENCE]. | Medium: each new item needs a new prompt, a check, and a cleanup. | PNG with `background: "transparent"` ([guide](https://developers.openai.com/api/docs/guides/image-generation)): all engines. |
| E. Agent-drawn vector art (SVG or engine draw calls) | Simple, flat, clean. Can have cute faces. Quality depends on the agent. | High: one palette and one stroke width in code. | Our own work | Free | Low to medium: one new shape in code. | SVG DOM: native. Phaser: `load.svg` rasterizes at load. Godot: SVG import with ThorVG (simple shapes only). |
| F. Paid packs (itch.io) | Kawaii Space pack: very cute faces on planets and stars. Most other sea packs are pirate combat. | High in one pack. No sea pack in the same style found. | Per pack. Kawaii Space: use in any project, no redistribution. | $2 to $20 per pack | Medium: fixed item list. | PNG + SVG (Kawaii Space). |

## Sources to look at

### A. Fluent Emoji 3D (recommended)

Repository: [microsoft/fluentui-emoji](https://github.com/microsoft/fluentui-emoji). Each emoji has a folder with `3D` (PNG), `Color` (SVG), `Flat` (SVG), and `High Contrast` (SVG) versions.

Sea examples (direct images):

- Character: [Sailboat](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Sailboat/3D/sailboat_3d.png)
- Goal: [Desert island](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Desert%20island/3D/desert_island_3d.png)
- Items: [Tropical fish](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Tropical%20fish/3D/tropical_fish_3d.png), [Spiral shell](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Spiral%20shell/3D/spiral_shell_3d.png), [Dolphin](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Dolphin/3D/dolphin_3d.png)
- Background detail: [Water wave](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Water%20wave/3D/water_wave_3d.png)

Space examples (direct images):

- Character: [Rocket](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Rocket/3D/rocket_3d.png)
- Goal: [Ringed planet](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Ringed%20planet/3D/ringed_planet_3d.png)
- Items: [Glowing star](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Glowing%20star/3D/glowing_star_3d.png), [Comet](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Comet/3D/comet_3d.png), [Crescent moon](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Crescent%20moon/3D/crescent_moon_3d.png)

Reward pieces for both themes: [Sparkles](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Sparkles/3D/sparkles_3d.png), [Rainbow](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Rainbow/3D/rainbow_3d.png), [Party popper](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Party%20popper/3D/party_popper_3d.png), [Trophy](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Trophy/3D/trophy_3d.png), [Shooting star](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Shooting%20star/3D/shooting_star_3d.png), [Gem stone](https://raw.githubusercontent.com/microsoft/fluentui-emoji/main/assets/Gem%20stone/3D/gem_stone_3d.png).

I checked that each link above returns HTTP 200. I looked at the rocket, sailboat, island, and planet images.

Limits:

- **Size.** The 3D files are 256 px. A sprite larger than 256 physical screen pixels gets upscaled and looks a little soft. Keep each sprite at or below this size, or accept slight softness.
- **Fixed view.** The rocket points up and to the right (45°). The sailboat is a side view with water at its base. Ticket 03 must handle the direction of the character (see below).
- **No animation frames.** All motion comes from tweens and particles.
- **No tiles.** The set has no walls or floor. The code draws them.

### B. Kenney CC0 packs

Each pack page states "License: Creative Commons CC0". I downloaded each zip and read its `License.txt` and its file list.

| Pack | Page | Example image | Contents |
|---|---|---|---|
| Pirate Pack | [kenney.nl/assets/pirate-pack](https://kenney.nl/assets/pirate-pack) | [sample](https://kenney.nl/media/pages/assets/pirate-pack/872e1ae7d4-1677579015/sample.png) | 97 top-down 64×64 tiles (water, sand, grass islands), ships, dinghies, sails. PNG at two sizes, Starling XML atlas, one SVG sheet. |
| Fish Pack | [kenney.nl/assets/fish-pack](https://kenney.nl/assets/fish-pack) | [preview](https://kenney.nl/media/pages/assets/fish-pack/087a70e885-1747237949/preview.png) | Side-view fish, seaweed, rocks, sand tiles. PNG, XML atlas, and one SVG per item (version 2.0). |
| Simple Space | [kenney.nl/assets/simple-space](https://kenney.nl/assets/simple-space) | [sample](https://kenney.nl/media/pages/assets/simple-space/489b432d65-1677578140/sample.png) | 48 white icon-style ships, rocks, stars on dark. PNG, XML atlas, one SVG sheet. |
| Planets | [kenney.nl/assets/planets](https://kenney.nl/assets/planets) | [preview](https://kenney.nl/media/pages/assets/planets/87a3d58caf-1677495381/preview.png) | 50 planet images and parts. PNG only. |
| Space Shooter Remastered | [kenney.nl/assets/space-shooter-remastered](https://kenney.nl/assets/space-shooter-remastered) | [preview](https://kenney.nl/media/pages/assets/space-shooter-remastered/41561bfade-1677669432/preview.png) | Shooter ships, lasers, meteors. Weapons do not suit a game with no enemies. |

Judgement: the Pirate Pack is a strong sea option, because its island tiles can be the walls and its water can be the paths. Use only the plain hulls and white sails, not the skull flags or cannons. The Kenney space packs look plain and adult. No Kenney space pack matches the Pirate Pack style.

### C. Other emoji sets

Flat 2D alternatives to Fluent. Two of them need attribution (CC BY), and OpenMoji also requires share-alike. The game shows no text, so a `CREDITS` file in the repository must hold the attribution.

- [OpenMoji](https://openmoji.org/): CC BY-SA 4.0. Line-art style with outlines.
- [Twemoji (jdecked fork)](https://github.com/jdecked/twemoji): graphics CC BY 4.0.
- [Noto Emoji](https://github.com/googlefonts/noto-emoji): "most image resources are under the Apache license, version 2.0".

### D. AI image generation

- Tool: the OpenAI Image API. The current models are `gpt-image-2.5-sunburst` (precise edits) and `gpt-image-2.5-flare` (fast). `gpt-image-1` was shut down on 23 October 2026 ([guide](https://developers.openai.com/api/docs/guides/image-generation)).
- Transparency: set `background: "transparent"` with `output_format: "png"` or `"webp"`. The `create-game-assets` skill says: always check the alpha channel after generation.
- Ownership: under the OpenAI Terms of Use for individuals, "you … own the Output". The API falls under the Business Terms, which I did not read.
- No image generation tool is available in this workspace. The `create-game-assets` skill says: with no generation tool, source licensed assets or keep greybox placeholders.
- Consistency: the skill requires one approved reference image, a fixed prompt card, small batches, and a check at game scale. Each step adds work for each new item.

### E. Agent-drawn vector art

- The agent writes SVG paths or engine draw calls for each object, with one palette and one stroke width.
- Strong for walls, floor, background, and simple items (stars, bubbles, dots).
- Weak for a detailed, attractive character. A simple shape with a face (round eyes, a smile) is in reach.
- Godot note: ThorVG has "limited" SVG support ([Godot 4.7 docs](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_images.html)). Keep shapes simple: paths, fills, and plain gradients, no filters.

### F. Paid packs

- [Kawaii Space Match-3 Asset Pack](https://monixxy.itch.io/kawaii-space-asset-pack) by monixxy, $20 or more. Planets, stars, and suns with 12 face expressions, plus a rocket, a UFO, and backgrounds, in PNG and SVG. [Example image](https://img.itch.zone/aW1nLzI2ODI1NDkucG5n/original/gGN237.png). Licence on the page: use in any project, edit freely, "You CANNOT share or redistribute this asset per se". The repository must therefore stay private. I found no sea pack in the same style.
- [Space Game Icons](https://assetsfactory.itch.io/space-game-icons) by AssetsFactory, $3.99 ($1.99 in a sale). 125 cartoon icons. The page discloses "AI Assisted" graphics. I did not look at its images or licence file.
- [Simple 2D Cute Sea Pirate Characters](https://jovialgamesofficial.itch.io/pirates) by Jovial Games, $20 ($10 in a sale). Not suitable: enemy characters with attack and death animations.

## Style candidates for ticket 02

Only one theme ships, so each theme needs consistency only with itself. Ticket 02 can mock up one candidate per theme, or two if time allows. Candidate 1 is the recommendation.

### Sea

1. **Soft 3D emoji.** Fluent Sailboat is the character. The Fluent Desert island is the Goal. Shells and tropical fish are the items. The paths are light turquoise water. The walls are rounded sand-coloured islands that the code draws. Reward: Rainbow, Sparkles, and Party popper with a bounce.
2. **Kenney top-down islands.** Pirate Pack tiles: the water is the path, and the sand and grass islands are the walls. A small ship with a white sail (no skull flag) is the character. A Fish Pack fish or a gold coin is an item. An island with a palm tree is the Goal.
3. **Kawaii flat, agent-drawn.** A round pastel boat with a happy face. Islands and fish with faces. Thick soft outlines, pastel palette. This is the sea partner of the Kawaii Space pack look.

### Space

1. **Soft 3D emoji.** Fluent Rocket is the character. The Fluent Ringed planet is the Goal. Glowing stars and comets are the items. The background is a deep blue to purple gradient with small dots. The walls are rounded lavender bands that the code draws. Reward: Shooting star, Sparkles, and Trophy.
2. **Kawaii Space pack ($20).** The pack rocket is the character. A planet with a happy face is the Goal. Stars with happy faces are the items. The pack backgrounds fill the screen. The pack has no wall tiles, so the code draws the walls in the pack palette.
3. **Kawaii flat, agent-drawn.** The same drawn style as sea candidate 3: a round rocket with a face, planets and stars with faces.

## Engine fit

TechStackRevise chose **Godot 4.7** (4.7.2-stable, GDScript, native macOS window). The PNG recommendation fits Godot. The Phaser and DOM notes stay here as a record.

- **Godot 4.7 (chosen).** PNG imports as `Texture2D`. SVG imports through ThorVG, which rasterizes at import time at a chosen scale (`SVG > Scale`), or at run time as a `DPITexture`. The Godot docs warn that ThorVG support is limited. The Fluent `Color` SVG files use `feGaussianBlur` filters, so ship the PNG files. Godot loads a PNG or SVG file only after an import. Run `godot --headless --path . --import` one time before the first start (from TechStackRevise, `research/godot4-facts.md`). ([Godot 4.7: Importing images](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_images.html))
- **Phaser 4.2.1.** `load.image` for PNG. `load.atlasXML` reads the Kenney Starling XML atlases. `load.svg` rasterizes an SVG at load time, at a set width, height, or scale. ([AtlasXMLFile.js](https://github.com/phaserjs/phaser/blob/v4.2.1/src/loader/filetypes/AtlasXMLFile.js), [SVGFile.js](https://github.com/phaserjs/phaser/blob/v4.2.1/src/loader/filetypes/SVGFile.js))
- **SVG in the DOM.** PNG goes in an `<image>` element. SVG files go inline.

All image files must be in the repository. The game loads no file from the network.

## Facts that affect other tickets

- **Ticket 02 (theme):** use the style candidates above. Each candidate covers the character, the Goal, the walls, and the reward.
- **Ticket 03 (movement):** emoji have a fixed view. The rocket points at 45°, so the code rotates it to the move direction (subtract 45° from the move angle). The sailboat is a side view: flip it horizontally for left and right moves, and do not rotate it for up and down moves. Tweens give all motion, because the art has no animation frames.
- **Ticket 04 (encouragement):** the Fluent set has many reward images: Trophy, 1st place medal, Glowing star, Sparkles, Party popper, Confetti ball, Rainbow, Gem stone, Crown. Collectibles can be stars, shells, fish, or gems.
- **Ticket 05 (levels):** the code draws walls and floor, so any Labyrinth size works with no new art. Keep each sprite at or below 256 physical screen pixels, so that the 256 px emoji stay sharp. A Retina screen has 2 physical pixels for each logical point, so this limit is about 128 points.
- **Ticket 06 (sound):** no change. The Kenney Space Shooter pack contains laser and "lose" sounds, which do not suit this game.

## Licence duties for the build

- Fluent Emoji (MIT): copy the `LICENSE` text into the folder with the PNG files.
- Kenney (CC0): no duty. Keep `License.txt` as a record.
- Any CC BY or CC BY-SA file: add the author, title, source link, and licence to a `CREDITS` file.
- Paid packs: do not publish the repository with the pack files in it.
- Record each shipped file in an asset manifest (source URL, licence, date), as the `create-game-assets` skill requires.

## Sources

Skills in this repo:

- `.claude/skills/create-game-assets/SKILL.md`, `references/art-direction.md`, `references/raster-pipeline.md`, `references/provenance.md`

Web sources (all read on 2026-11-03):

- [microsoft/fluentui-emoji](https://github.com/microsoft/fluentui-emoji) and its [LICENSE](https://github.com/microsoft/fluentui-emoji/blob/main/LICENSE); file names and sizes checked through the GitHub API and direct downloads.
- Kenney pack pages listed in section B, and the downloaded zip files (`License.txt`, `Tilesheet/tilesheets.txt`, file lists).
- [OpenMoji README](https://github.com/hfg-gmuend/openmoji), [Twemoji README](https://github.com/jdecked/twemoji), [Noto Emoji README](https://github.com/googlefonts/noto-emoji).
- [OpenAI image generation guide](https://developers.openai.com/api/docs/guides/image-generation), [OpenAI pricing](https://developers.openai.com/api/docs/pricing), [OpenAI Terms of Use](https://openai.com/policies/row-terms-of-use/).
- itch.io pages for [Kawaii Space](https://monixxy.itch.io/kawaii-space-asset-pack), [Space Game Icons](https://assetsfactory.itch.io/space-game-icons), [Simple 2D Cute Sea Pirate Characters](https://jovialgamesofficial.itch.io/pirates).
- [Godot 4.7: Importing images](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_images.html); Phaser 4.2.1 loader source files linked above.

## Not checked

- I did not put any asset in a game or engine and run it.
- I did not render the Fluent `Color` SVG files in ThorVG. The filter risk comes from the file contents and the Godot docs.
- I did not read the OpenAI Business Terms, which govern the API.
- I did not compute an exact cost for each AI image. The under $10 figure is an estimate from the token rates.
- I did not open the licence files inside the paid packs. I read only the licence text on the itch.io pages.
- I did not search Craftpix, GameDev Market, or stock image sites in depth.
