# Tech stack for the Labyrinth game

Ticket: [01 Choose the tech stack](../issues/01-choose-tech-stack.md). Date of research: 2026-11-03.

> **Revised on 2026-11-03.** The [Revision 2026-11-03](#revision-2026-11-03) section at the end replaces the Recommendation below. The old text stays as a record.

## Recommendation

Use **TypeScript, Vite, and SVG in the DOM**, with no runtime dependencies.

- Draw the Labyrinth as one inline `<svg>` with a `viewBox`. Draw walls as `<path>` or `<line>` elements. Draw the character and the Goal as `<g>` groups.
- Move the character with the Web Animations API (`element.animate()`). Wait for `animation.finished` before the game accepts the next move.
- Play sound with the Web Audio API. Use one `AudioContext` and three `GainNode` buses: master, music, and effects.
- Keep the game logic (Labyrinth data, seeded random numbers, moves, the Goal check) in plain TypeScript modules. These modules do not touch the DOM.
- Dev dependencies: `vite`, `typescript`, `vitest`, and `@playwright/test`. The game ships no runtime package.

Write the Labyrinth generator in the game code. Use the **recursive backtracker** (an iterative depth-first search with a stack) and a small seeded PRNG of our own.

## Candidates against the criteria

| Criterion | TS + Canvas 2D + Vite | PixiJS 8.22 | Phaser 4.2.1 | TS + DOM/SVG + Vite (chosen) |
|---|---|---|---|---|
| Smooth move from one square to the next | Yes. We write a `requestAnimationFrame` loop and our own tween with an ease curve. | Yes. The ticker loop gives `deltaMS`. No tween system is in the package, so we write one or add a library. | Yes. Tweens, scenes, and a game loop are in the package. | Yes. `element.animate()` gives ease curves and a `finished` promise. The browser runs the loop. |
| Simple sound effects and music | Web Audio API, written by us. | Not in the package. Needs `@pixi/sound` 6.0.2 or our own Web Audio code. | Yes. The sound manager unlocks audio on the first key press. | Web Audio API, written by us. |
| `npm` start, works with no network | Yes. `npm run dev` or `npm run preview` serves local files. | Yes. | Yes. | Yes. |
| Few dependencies | 0 runtime packages. | 1 runtime package with 10 direct dependencies. Full minified file: 841 KB (237 KB gzip). | 1 runtime package with 1 dependency (`eventemitter3`). Minified file: 1.38 MB (355 KB gzip). | 0 runtime packages. |
| An agent can build and test it easily | Logic tests are easy. Screen checks need pixel screenshots, because the canvas has no inspectable structure. | Same as Canvas. Agents must also avoid v7 tutorial code: the v8 API changed (async `init`, `Assets`, `app.canvas`). | Logic is tied to Scene classes unless we separate it. Agents must avoid Phaser 3 tutorial code. A known keyboard pitfall can leave a key stuck down. | Logic tests are easy. Playwright can read the DOM and the `data-` attributes, so screen checks do not need pixel comparisons. |
| Scale to the laptop screen | We must handle `devicePixelRatio` and resize by hand. | `resizeTo: window` helps. | `Phaser.Scale.FIT` helps. | The `viewBox` scales the image sharp to any size. |

### Why not Phaser

Phaser has the most features in one package: tweens, sound, keyboard, and scenes. This game needs one character, one grid, and a small number of sounds. Phaser adds 1.38 MB of engine for features that the browser already gives. The `phaser-core` skill lists many Phaser 3 to Phaser 4 renames, and an agent can easily copy old code. The skill also documents a keyboard fault: when a host listener cancels `keyup`, the key stays down. Phaser is the second choice. Use it if the theme ticket asks for many sprite animations or particle effects.

### Why not PixiJS

PixiJS draws fast with WebGL. A grid of about 100 squares does not need this speed. PixiJS has no sound and no tween system, so it gives the most packages for the least benefit.

### Why SVG and not Canvas 2D

Both have zero runtime dependencies. SVG is better on two criteria. First, the browser runs the animation, so we write no render loop. Second, an agent can test the screen with DOM queries, for example "the character element is at square (3, 2)". Canvas only gives pixels. The risk of SVG is speed when many elements move at the same time. At this size (one character and short effects) the risk is low.

### Why not Godot

The `router` skill tells an agent to use Godot for a new project with no engine preference. The Parent's rule is different: the Parent starts the game with `npm` in a laptop browser. A web stack obeys this rule directly, so the Godot default does not apply.

## Labyrinth generator decision

**Decision: write the generator in the game code. Use the recursive backtracker.**

### Library or own code

| Option | For | Against |
|---|---|---|
| `generate-maze` 1.1.0 (npm) | Small (83 KB unpacked), MIT, accepts a seed. | Uses Eller's algorithm, which gives many short dead ends (see below). Last publish: June 2022. 29 GitHub stars. We do not control its random numbers. |
| `rot-js` 2.2.1 (npm) | Has several generators and a seeded RNG. | A full roguelike toolkit (2.5 MB unpacked) for one function. |
| Own code | About 40 lines. We control the RNG and the output format. Tests pin the output. | We write and test it ourselves. |

The `procedural-gen` skill gives the reason for own code. Library RNGs can change their sequence between versions, so a saved seed can give a different Labyrinth after an update. The skill says: "ship your own small PRNG (PCG32, xorshift, SplitMix64) with a test that pins its first outputs". A 32-bit PRNG such as xorshift32 needs no `BigInt` in JavaScript.

### Which algorithm

The recursive backtracker makes a perfect Labyrinth. A perfect Labyrinth has exactly one path between any two squares, so the Goal is always reachable. This supports the "cannot lose" rule.

Walter Pullen's comparison table ([Think Labyrinth: Maze Algorithms](https://www.astrolog.org/labyrnth/algrithm.htm)) gives these values:

| Algorithm | Dead ends (% of cells) | Solution length (% of cells) |
|---|---|---|
| Recursive backtracker | 10 | 19.0 |
| Eller's algorithm | 28 | 4.2 |
| Wilson's algorithm | 29 | 4.5 |
| Kruskal's algorithm | 30 | 4.1 |

The recursive backtracker has the fewest dead ends of the general algorithms. Its passages are long and turn often ("high river factor"). A 5-year-old meets fewer dead ends, and the path to the Goal is clear and long. Pullen also says that it "runs fast", and that it needs only a stack, not real recursion.

Rules for the generator, from the `procedural-gen` and `puzzle` skills:

1. Pass one seeded RNG instance to every function that makes a choice. Never call `Math.random()` in generation code.
2. Generate into plain data first (for example, a wall bit set for each cell). The SVG view reads this data. The view never changes it.
3. Validate each Labyrinth with a flood fill or a breadth-first search from the start square. The Goal must be reachable.
4. Add a unit test that pins the first outputs of the PRNG and the Labyrinth for one fixed seed.

If ticket 05 chooses hand-made Labyrinths, store them as the same plain data. The generator then becomes optional, but the data format and the validation stay the same.

## Facts that affect other tickets

### Sound (ticket 06)

- Browsers block audio until the user activates the page. An `AudioContext` that the page creates before this starts in the `suspended` state. The code must call `resume()` after a user gesture ([Chrome autoplay policy](https://developer.chrome.com/blog/autoplay)).
- A `keydown` event activates the page, but not the Esc key and not keys that the browser reserves for shortcuts ([HTML standard, user activation](https://html.spec.whatwg.org/multipage/interaction.html#activation-triggering-input-event)). Thus music cannot start at page load. It starts on the first arrow key press. MDN gives the same rule for the Web Audio API ([MDN autoplay guide](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Autoplay)).
- All sound files must be in the project. The game loads no file from a network address.
- The Web Audio API can make simple tones with an `OscillatorNode`, so the effects can have no audio files. Music probably needs a file or a short note sequence.
- From the `audio-design` skill: route every sound through a bus; map a 0 to 1 volume value to gain by its square; give small random pitch changes to repeated effects (for example, footsteps); keep the master peak below 0 dBFS.

### Movement (ticket 03)

- From the `puzzle` skill: the Labyrinth data is the single source of truth. The view only shows it. Lock new moves until the current move animation ends.
- From the `input-systems` and `game-feel` skills: buffer one early key press, so that a press during an animation is not lost. The lock must not make the game feel slow.
- From the `input-systems` skill: read named actions, not raw keys. Use `KeyboardEvent.code` (the physical key). Desktop Chrome 48, Firefox 38, and Safari 10.1 support it ([MDN browser compat data](https://github.com/mdn/browser-compat-data/blob/main/api/KeyboardEvent.json)).
- A held key sends repeated `keydown` events. `KeyboardEvent.repeat` marks them ([MDN](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/repeat)). Ticket 03 must decide: does a held key move the character again and again, or one time only?
- From the `game-feel` skill: use an ease-out curve for the move. Use a small overshoot only for a "pop" at the Goal. Effects must return to rest and must not block input.
- `element.animate()` and `Animation.finished` are "Baseline Widely available" ([MDN Element.animate](https://developer.mozilla.org/en-US/docs/Web/API/Element/animate), [MDN Animation.finished](https://developer.mozilla.org/en-US/docs/Web/API/Animation/finished)).

### Parent controls and screen layout

- Phaser and our own code both need `keydown` listeners on `window`. The `phaser-core` skill reference gives a contract for own listeners: track keys by `event.code`, keep each press until the game reads it, and clear held keys on window blur. The SVG stack uses this contract.
- A child who presses many keys can press browser shortcuts (for example, Esc leaves fullscreen). The Keyboard Lock API (`navigator.keyboard.lock()`) can capture more keys, but MDN marks it "Experimental" and "Limited availability" ([MDN Keyboard.lock](https://developer.mozilla.org/en-US/docs/Web/API/Keyboard/lock)). The Parent controls ticket must handle this.

## Build and test commands for the spec

- `npm install` needs the network one time. After this, the game works offline.
- `npm run dev` starts the Vite dev server. `npm run build` then `npm run preview` serves the production build at `http://localhost:4173` ([Vite static deploy guide](https://vite.dev/guide/static-deploy)). Vite says that `vite preview` is for local use only. This matches the Parent's use.
- Vite only transpiles TypeScript. It does not check types ([Vite features: Transpile Only](https://vite.dev/guide/features#transpile-only)). The spec must add `tsc --noEmit` to the build or test script, and set `"isolatedModules": true`.
- `vitest` tests the logic modules (PRNG, generator, moves, Goal check) with no browser.
- `@playwright/test` opens the game in a real browser, presses arrow keys, and reads the DOM state. Playwright downloads its browsers one time, with a network connection.

## Package versions checked

Checked with `npm view` on 2026-11-03. Bundle sizes are the gzip size of the `dist/*.min.js` file from unpkg.

| Package | Version | Notes |
|---|---|---|
| `vite` | 8.3.5 | Uses the Oxc transformer for TypeScript. |
| `typescript` | 7.0.2 | |
| `vitest` | 5.1.0 | |
| `@playwright/test` | 1.64.1 | |
| `phaser` | 4.2.1 | `dist/phaser.min.js`: 1,375,976 bytes, 354,596 bytes gzip. |
| `pixi.js` | 8.22.0 | `dist/pixi.min.js`: 840,663 bytes, 237,364 bytes gzip. |
| `@pixi/sound` | 6.0.2 | |
| `generate-maze` | 1.1.0 | Eller's algorithm ([GitHub](https://github.com/bestguy/generate-maze)). |
| `rot-js` | 2.2.1 | |

The spec should pin the major versions of the dev tools. It must not copy these numbers as fact for a later date.

## Open risks

1. **No game library.** We write the tween wait, the input buffer, and the sound buses ourselves. Each part is small, but the spec must state them clearly. If the theme ticket asks for rich sprite animation or many particles, review Phaser again.
2. **SVG speed for effects.** A reward effect with many elements in motion (for example, confetti) can be slow in SVG. Keep effects small, or draw them on a separate `<canvas>` layer.
3. **Recursive backtracker paths are long.** The solution covers about 19% of the cells. On a large grid this can be too long for a 5-year-old. Ticket 05 must choose small sizes. It can also remove some walls to add loops (a "braid"), which gives more than one path to the Goal.
4. **Audio starts late.** Music cannot start before the first key press. Ticket 06 must accept this.
5. **Browser shortcuts.** The game cannot block every reserved shortcut. The Parent controls ticket must plan for this.
6. **TypeScript 7 is new.** The spec must check that `vitest` and the Vite starter template accept TypeScript 7. Pin TypeScript 5.x if they do not. I did not check this.

## Sources

Skills in this repo (primary):

- `.claude/skills/router/SKILL.md` and `references/engine-detection.md`, `references/routing-table.md`
- `.claude/skills/phaser-core/SKILL.md` and `references/scene-flow.md` (keyboard section)
- `.claude/skills/pixijs-rendering/SKILL.md`
- `.claude/skills/puzzle/SKILL.md`
- `.claude/skills/procedural-gen/SKILL.md` and `references/dungeon-generation.md`
- `.claude/skills/input-systems/SKILL.md`
- `.claude/skills/audio-design/SKILL.md`
- `.claude/skills/game-feel/SKILL.md`
- `.claude/skills/prototype-fast/SKILL.md` (for ticket 03: keep the prototype in a separate `prototypes/` folder and rewrite it for the real build)

Web sources:

- Walter D. Pullen, [Think Labyrinth: Maze Algorithms](https://www.astrolog.org/labyrnth/algrithm.htm)
- [Chrome autoplay policy](https://developer.chrome.com/blog/autoplay)
- [HTML standard: activation-triggering input event](https://html.spec.whatwg.org/multipage/interaction.html#activation-triggering-input-event)
- [MDN: Autoplay guide for media and Web Audio APIs](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Autoplay)
- [MDN: Element.animate()](https://developer.mozilla.org/en-US/docs/Web/API/Element/animate), [Animation.finished](https://developer.mozilla.org/en-US/docs/Web/API/Animation/finished), [KeyboardEvent.repeat](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/repeat), [Keyboard.lock()](https://developer.mozilla.org/en-US/docs/Web/API/Keyboard/lock)
- [MDN browser compat data: KeyboardEvent](https://github.com/mdn/browser-compat-data/blob/main/api/KeyboardEvent.json)
- Phaser 4.2.1 source: [WebAudioSoundManager.js](https://github.com/phaserjs/phaser/blob/v4.2.1/src/sound/webaudio/WebAudioSoundManager.js) (unlock on `keydown`, `mousedown`, `touchstart`)
- [Vite: Static deploy guide](https://vite.dev/guide/static-deploy), [Vite: Features](https://vite.dev/guide/features)
- [bestguy/generate-maze](https://github.com/bestguy/generate-maze)
- npm registry (`npm view`) and [unpkg](https://unpkg.com/) for versions and file sizes

## Not checked

- I did not build or run any candidate stack.
- I did not measure SVG animation speed on the Parent's laptop.
- I did not check whether TypeScript 7 works with Vitest 5 and the Vite 8 template.
- I did not check Godot web export in detail. The `npm` rule excludes it first.

## Revision 2026-11-03

The Parent changed two criteria. First, a ready-built engine is better if it removes work. Second, the Parent starts the game with one command, and this command does not have to be `npm`. The new top criterion is **the least build work**. The other criteria stay: offline play, keyboard only, and an agent can build and test the game.

### Revised recommendation

Use **Godot 4.7** (4.7.2-stable) with GDScript. The game runs in a native window on the Parent's laptop, not in a browser.

- One-time setup: `brew install --cask godot`. The cask is at 4.7.2 and puts the `godot` command on PATH ([godot4-facts.md §1](godot4-facts.md)).
- One command to play: a `play` script in the repo root runs `godot --headless --path . --import`, then `godot --path .`. The import is necessary. Godot does not load PNG, SVG, or audio files until the import has run one time ([godot4-facts.md §2](godot4-facts.md)).
- One command to test: `godot --headless --path . --script res://tests/run.gd`, with the runner contract of the `godot-gdscript-headless-testing` skill (count failures, call `quit(1)`, no bare `assert()`).
- No export and no export templates (about 1.28 GB). The game runs from its source folder ([godot4-facts.md §8](godot4-facts.md)).
- The game uses no network and no local server.

**Phaser 4.2.1 is the second choice.** Use it only if the game must run in a browser.

### What each candidate gives for free

| Need of this game | Godot 4.7 (chosen) | Phaser 4.2.1 | TS + Vite + SVG (old pick) |
|---|---|---|---|
| Move tween with an ease and an end signal | Built in: `create_tween()`, `TRANS_BACK`/`EASE_OUT`, `await tween.finished`. | Built in: `this.tweens.add`, `onComplete`, `tweens.chain`. An unknown ease name becomes linear with no error. | Browser: `element.animate()` and its `finished` promise. |
| Reward burst (particles) | Built in: `CPUParticles2D` with `one_shot`. `emitting` is `true` by default, so set it to `false` until the reward. | Built in: `this.add.particles` and `explode()`. Set `emitting: false`. | Our code, on a separate `<canvas>`. |
| Sprite sheet animation | Built in: `AnimatedSprite2D` and `SpriteFrames`. Code can make them with no editor. | Built in: `load.spritesheet`, `load.atlas`, `load.aseprite`. | Our code. |
| Sound buses (master, music, effects) | Built in: `default_bus_layout.tres` or `AudioServer.add_bus`. | One global volume and a volume for each sound. The buses are our code. | Our code with Web Audio. |
| Music at start | Yes. A native app has no autoplay block. | No. Sound starts after the first key press. | No. The same browser rule. |
| Named key actions and held keys | Built in: InputMap actions, `is_action_just_pressed`, `event.is_echo()`. | Keyboard plugin. Named actions are our code. A known fault can leave a key down. | Our code. |
| Fullscreen, and random key presses by the Child | Exclusive fullscreen from `project.godot` (`display/window/size/mode=4`). Esc does not leave it. Cmd+Q comes to the game as a close request, and `set_auto_accept_quit(false)` ignores it. Cmd+W does nothing ([godot4-facts.md §3](godot4-facts.md)). | Browser fullscreen. Esc leaves it. Cmd+W closes the tab and Cmd+R reloads it. The Phaser docs start fullscreen from a pointer event. A key press is not confirmed. | The same as Phaser. |
| Labyrinth floor and walls | `TileMapLayer` and `TileSet`, made in code. | Tilemap, or `graphics` then `generateTexture` one time. | SVG paths. |
| Start with one command | `./play`, after one Godot install. | `npm run dev -- --open`, after `npm install`. The official template sends a ping to gryzor.co, so delete `log.js` ([phaser4-facts.md §1](phaser4-facts.md)). | `npm run dev -- --open`. |
| Tests by an agent | Headless GDScript runner for logic and key input (`Input.parse_input_event` with `InputEventAction`). Screenshots need a windowed run (`--write-movie`, or `get_image().save_png()` after `frame_post_draw`). | Vitest for logic. Phaser does not import in Node with no DOM. Playwright for the browser, with no official Phaser guide ([phaser4-facts.md §7](phaser4-facts.md)). | Vitest, and Playwright with DOM queries. |
| Skills in this repo | 16 Godot skills, all pinned to 4.7. The `router` default for a new game. | 2 Phaser skills. | No engine skill. |

### Why Godot gives the least build work

Godot and Phaser both give tweens, particles, sprite sheets, scenes, and an asset loader. Godot also gives four parts that Phaser leaves to us: sound buses, music at start, named key actions, and a fullscreen that the Child cannot leave with Esc, Cmd+W, or Cmd+R. A native window also removes the browser parts of the work: the audio unlock, the page focus, the local server, and the telemetry ping. These parts also close most of the "browser shortcuts" and "audio starts late" risks of the old pick.

The old SVG pick needs the most own code: the particles, the sprite animation, the sound buses, and the input layer.

### Why not the other engines

- **Phaser 4.2.1:** the best browser engine for this game (see the table). The browser adds work that a native app does not have. Its one setup advantage is that Node is already on the laptop.
- **PixiJS 8.22:** a renderer only. It has no tweens and no sound.
- **Ebitengine:** Go is on the laptop, and `go run .` is one command. But tweens, particles, and sprite animation are our code (`ebitengine-game` skill, `references/gameplay-systems.md`).
- **LÖVE:** not installed. It has particles but no tween system, and pygame has neither.
- **Defold:** `bob.jar` needs OpenJDK 25 (`defold-core` skill, `references/build-and-run.md`). Its resource files are usually made in the Defold editor, so an agent writes more files by hand.

### Generator decision (kept)

Keep the decision: write the generator in the game code, with the recursive backtracker and a small PRNG of our own. Write both in GDScript. Do not use Godot's `RandomNumberGenerator` for generation, because the `procedural-gen` skill says to ship our own PRNG with a test that pins its first outputs. A GDScript `int` is a signed 64-bit value, so mask each xorshift32 step with `& 0xFFFFFFFF`. The headless runner runs the generator tests.

### Changes for other tickets

- **02 theme:** ship PNG art (see `research/graphics.md`). Godot makes SVG files into textures at import time with ThorVG, which has limited SVG support.
- **03 movement:** move with `create_tween()` and `await tween.finished`. Read InputMap actions. `event.is_echo()` marks the repeats of a held key. Keep the buffer of one early press.
- **04 encouragement:** use a one-shot `CPUParticles2D` burst and a Tween "pop" with `TRANS_BACK`.
- **05 levels:** keep Labyrinths as plain data. The generator and its tests are GDScript.
- **06 sound:** music can start when the game starts. Put the buses in `default_bus_layout.tres`. A headless run has no sound, so tests check the calls, not the output.
- **Map:** the Destination says "runs in a laptop browser" and "starts it with `npm`". These words are no longer correct. Parent controls: Esc, Cmd+W, Cmd+R, and Cmd+Q are no longer a risk. Cmd+Tab, Cmd+H, Cmd+M, and Cmd+Option+Esc stay, because no app can block them. Saved progress can use files in `user://` (the `save-systems` skill).
- These sections above no longer apply: browser autoplay, the Keyboard Lock API, the Vite build and test commands, and Playwright.

### New risks

1. **An agent writes Godot code with no editor.** Agents can copy Godot 3 code. Use the 4.7 skills, and make scenes in code where possible.
2. **The import must run first.** The `play` script and the test script both run `--import` first. On a fresh folder, a `uid://` main scene and `class_name` types fail until the import has run.
3. **Screen checks need a window.** The headless renderer is a dummy, so a screenshot needs a windowed run on the laptop.
4. **Godot version.** The Homebrew cask follows the newest Godot. The spec must state 4.7 and tell the build to check `godot --version`.
5. Not confirmed: whether Ctrl+Cmd+F leaves Godot's fullscreen on macOS.

### Sources for this revision

- [godot4-facts.md](godot4-facts.md): Godot 4.7.2 docs, source at tag `4.7.2-stable`, and the Homebrew cask.
- [phaser4-facts.md](phaser4-facts.md): Phaser source at tag `v4.2.1`, the npm registry, and the official template.
- Skills: `phaser-core` (and `references/scene-flow.md`), `pixijs-rendering`, `create-game-assets` (and `references/raster-pipeline.md`), `game-feel` (and `references/feedback-recipes.md`), `godot-animation`, `godot-audio`, `godot-gdscript-headless-testing`, `defold-core`, `ebitengine-game`, `router`.
- Local check: `command -v` shows `node`, `go`, `java`, and `brew` on this laptop. Godot and LÖVE are not installed.

### Not checked in this revision

- I did not install Godot or run any Godot or Phaser command for the game. The facts files mark the claims that come only from the source code.
- I did not test a key press that starts browser fullscreen, because the browser is no longer the target.
