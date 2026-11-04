# Phaser 4 facts (checked 2026-11-03)

Version checked: `phaser` 4.2.1, the npm `latest` dist-tag. Source links point at git tag `v4.2.1`.
Base URL for source links: `https://github.com/phaserjs/phaser/blob/v4.2.1/`.
Some checks ran locally: the npm tarball was unpacked into `/tmp` (no project install), then imported with Node 24.18.0 and bundled with esbuild 0.25.10 and Rollup 4.

## 1. npm version, dependencies, official Vite + TS template

- `npm view phaser version dependencies` returns version `4.2.1` with one runtime dependency: `eventemitter3 ^5.0.4`.
  Dist-tags: `latest: 4.2.1`, `beta: 4.0.0-rc.7`. Source: npm registry (`npm view phaser`).
- `package.json` `exports`: `import` and `default` resolve to `./dist/phaser.esm.js`. `require` resolves to `./dist/phaser.js`. Types: `./types/phaser.d.ts`. There is no `sideEffects` field.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/package.json
- Official scaffolder: `npm create @phaserjs/game@latest` (or `npx @phaserjs/create-game@latest`). It is the npm package `@phaserjs/create-game`, version 1.3.2.
  Source: https://docs.phaser.io/phaser/getting-started/installation
- The CLI downloads the chosen template over the network when you run it. Its URL pattern is `https://phaser.io/r/create-game-template/template-{template-name}`. `https://phaser.io/r/create-game-template/template-vite-ts` answers with HTTP 302 to `https://github.com/phaserjs/template-vite-ts/archive/refs/heads/main.zip`.
  Source: https://unpkg.com/@phaserjs/create-game@1.3.2/phaser-creator/index.js and a `curl -I` of that URL.
- Official Vite + TypeScript template: `phaserjs/template-vite-ts`. The repo has no tags. Latest commit checked: `d1d7d58acfcf47f97642bcb8b4967071b85f8db9` (2026-04-21).
  Source: https://github.com/phaserjs/template-vite-ts/blob/d1d7d58acfcf47f97642bcb8b4967071b85f8db9/package.json
  - `dependencies`: `phaser: "4.0.0"` (exact pin, not 4.2.1), `terser: ^5.39.0`.
  - `devDependencies`: `vite: ^6.3.1`, `typescript: ~5.7.2`.
  - The README says "updated for Phaser 4, Vite 6.3.1, TypeScript 5.7.2". The `package.json` description still says "A Phaser 3 TypeScript template".
  - `package-lock.json` is stale. Its root entry still lists `phaser: ^3.88.2`, with `node_modules/phaser` 3.88.2, `vite` 6.3.2 and `typescript` 5.7.3. Expect `npm install` to rewrite the lockfile. `npm ci` will probably fail because the lockfile does not match `package.json`. [INFERENCE, not run]
    Source: https://github.com/phaserjs/template-vite-ts/blob/d1d7d58acfcf47f97642bcb8b4967071b85f8db9/package-lock.json
- Runtime network use in the template: none found. `index.html` loads only `/favicon.png`, `/style.css` and `/src/main.ts`. Scenes load `assets/bg.png` and `assets/logo.png` from `public/`. Fonts are `'Arial Black'`, a system font, with no webfont load.
  Sources: `index.html`, `src/game/scenes/Boot.ts` and `src/game/scenes/Preloader.ts` at the same commit.
- Network use at dev and build time: YES. `npm run dev` and `npm run build` first run `node log.js`. That script sends an HTTPS GET to `gryzor.co/v/{event}/{phaserVersion}/{templateName}`, which the README describes as anonymous telemetry. Use `npm run dev-nolog` and `npm run build-nolog`, or delete `log.js`. This telemetry does not break offline work: on a network error the script exits with code 1, and because the scripts join the commands with `&` Vite still starts. [INFERENCE from the script text]
  Source: https://github.com/phaserjs/template-vite-ts/blob/d1d7d58acfcf47f97642bcb8b4967071b85f8db9/log.js and README.md "About log.js".
- Phaser itself makes no network calls at runtime. The only `https://` strings in `dist/phaser.min.js` are the console banner text and the `gameURL` config default. Its built-in default textures are `data:image/png;base64` URIs. Source: grep of `dist/phaser.min.js` from the 4.2.1 tarball, and `src/core/Config.js`.
- The template's production Vite config uses `manualChunks: { phaser: ['phaser'] }`, `minify: 'terser'` and `base: './'`. Source: `vite/config.prod.mjs` at the same commit.

## 2. Tweens

- `this.tweens.add(config)` exists. Its doc comment shows `{ targets, x, ease: 'Power1', duration }`. Tweens are fire-and-forget and destroy themselves when they finish, unless the config sets `persist: true`.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/tweens/TweenManager.js (`add` at line 333; `create` 265, `chain` 436, `addCounter` 524, `killTweensOf` 1068)
- Config fields include `targets`, `delay`, `duration` (default 1000), `ease` (default `'Power0'`), `easeParams`, `hold`, `repeat`, `repeatDelay`, `yoyo`, `loop`, `paused` and `persist`. Callbacks: `onComplete`, `onStart`, `onUpdate`, `onYoyo`, `onRepeat`, `onLoop`, `onStop`, `onActive`, `onPause`, `onResume`, plus `*Params` and `callbackScope`.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/tweens/typedefs/TweenBuilderConfig.js
- Tween chains: `this.tweens.chain({ targets, tweens: [ ... ], loop, delay, onComplete, persist, ... })` returns a `TweenChain`. It plays the tweens in sequence. `@since 3.60.0`.
  Sources: https://github.com/phaserjs/phaser/blob/v4.2.1/src/tweens/typedefs/TweenChainBuilderConfig.js and https://github.com/phaserjs/phaser/blob/v4.2.1/src/tweens/tween/TweenChain.js
- Ease names in EaseMap:
  - Short names: `Power0`..`Power4`, `Linear`, `Quad`, `Cubic`, `Quart`, `Quint`, `Sine`, `Expo`, `Circ`, `Elastic`, `Back`, `Bounce`, `Stepped`. A short name means the Out variant.
  - Full names: `'X.easeIn'`, `'X.easeOut'` and `'X.easeInOut'` for X in Quad, Cubic, Quart, Quint, Sine, Expo, Circ, Elastic, Back, Bounce. `'Back.easeOut'` and `'Sine.easeOut'` are both valid.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/math/easing/EaseMap.js (lines 21 to 73)
- Ease strings resolve loosely. `'quad.in'`, `'quad.out'` and `'quad.inout'` map to `Quad.easeIn` and the like. An unknown string falls back to `Power0` (linear) and does not throw. A custom function is also accepted.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/tweens/builders/GetEaseFunction.js

## 3. Particles

- `this.add.particles(x, y, texture, config)` exists in v4. It returns a `ParticleEmitter` (`@since 3.60.0`). If the first argument is a string, the call warns that the old ParticleEmitterManager API was removed.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/gameobjects/particles/ParticleEmitterFactory.js (line 31)
- `emitter.explode(count, x, y)` exists. It switches the emitter to explode mode (frequency -1), stops any flow, and emits `count` particles at once (default `this.quantity`). It fires the `EXPLODE` event.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/gameobjects/particles/ParticleEmitter.js (line 2653). Other methods in the same file: `emitParticleAt` 2679, `flow` 2623, `start` 2406, `stop` 2448, `setConfig` 983.
- `emitting` defaults to `true` (line 622), so a new emitter starts flowing at once. For a burst-only emitter, pass `emitting: false` in the config and then call `explode()`. [The config key is listed in the same file at line 63.]

## 4. Sound

- The WebAudioSoundManager unlocks on keydown in v4. If the AudioContext is `'suspended'` at boot, `unlock()` adds `touchstart`, `touchend`, `mousedown`, `mouseup` and `keydown` listeners to `document.body`. Each listener calls `context.resume()`, then removes the listeners and sets `unlocked = true`.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/sound/webaudio/WebAudioSoundManager.js (lock check lines 89 to 102; `unlock` lines 348 to 389)
- `SoundConfig` supports `mute`, `volume` (0..1, default 1), `rate` (default 1), `detune` (in cents, default 0), `seek`, `loop`, `delay` and `pan` (-1..1).
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/sound/typedefs/SoundConfig.js
- `this.sound.add(key, config)` is defined in WebAudioSoundManager.js at line 225. `this.sound.play(key, extra)` accepts a SoundConfig or a SoundMarker and returns a boolean. Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/sound/BaseSoundManager.js (line 328)
- Per-sound setters on WebAudioSound: `setRate` 832, `setDetune` 879, `setVolume` 966, `setSeek` 1042, `setLoop` 1094, `setPan` 1152. The effective playback rate combines `rate` and `detune` (`BaseSound#calculateRate`, line 460).
  Sources: https://github.com/phaserjs/phaser/blob/v4.2.1/src/sound/webaudio/WebAudioSound.js and https://github.com/phaserjs/phaser/blob/v4.2.1/src/sound/BaseSound.js
- Audio sprites are supported. Load with `this.load.audioSprite(key, jsonURL, audioURL, audioConfig)`, then call `this.sound.addAudioSprite(key, config)` (line 215) or `this.sound.playAudioSprite(key, spriteName, config)` (line 368). The JSON format is the one produced by `tonistiigi/audiosprite`. Markers are available through `BaseSound#addMarker` (line 196).
  Sources: https://github.com/phaserjs/phaser/blob/v4.2.1/src/loader/filetypes/AudioSpriteFile.js (line 243) and BaseSoundManager.js.

## 5. Loader file types

- `this.load.svg(key, url, svgConfig)`: confirmed. The loader fetches the SVG as text. If `width && height`, or `scale`, is set, it rewrites the root `<svg>` width, height and viewBox. It then builds an `image/svg+xml` Blob, loads it into an `Image`, and adds the result to the Texture Manager as a normal image texture.
  - If you pass only `width` without `height`, no resize happens.
  - `scale` wins over width and height.
  - Doc example: `this.load.svg('morty', 'images/Morty.svg', { width: 300, height: 600 })`.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/loader/filetypes/SVGFile.js (class doc lines 18 to 20; resize lines 97 to 136; cache: `loader.textureManager`, line 61; register line 319)
- `this.load.spritesheet(key, url, { frameWidth, frameHeight, ... })`. Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/loader/filetypes/SpriteSheetFile.js (line 195)
- `this.load.atlas(key, textureURL, atlasURL)` accepts JSON Hash or JSON Array (TexturePacker). A normal map can be added by passing an array as the URL. Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/loader/filetypes/AtlasJSONFile.js (doc line 132; register line 223)
- `this.load.aseprite(key, textureURL, atlasURL)`. The JSON may be Hash or Array. After loading, `this.anims.createFromAseprite(key, [tags])` builds the animations. Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/loader/filetypes/AsepriteFile.js (doc lines 119 to 208; register line 238)

## 6. Graphics for walls

- `this.add.graphics(config)` exists. Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/gameobjects/graphics/GraphicsFactory.js (line 22)
- Methods confirmed in https://github.com/phaserjs/phaser/blob/v4.2.1/src/gameobjects/graphics/Graphics.js:
  - Styles: `lineStyle` 301, `fillStyle` 326.
  - Paths: `beginPath` 430, `moveTo` 1091, `lineTo` 1070, `strokePath` 501.
  - Shapes: `lineBetween` 1047, `strokeLineShape` 1029, `fillRect` 645, `strokeRect` 668, `fillRoundedRect` 711, `strokeRoundedRect` 803, `fillCircle` 572.
  - Other: `clear` 1493, `generateTexture` 1532.
- The class doc says that under WebGL, Graphics are broken into polygons on every render, which is costly. For static shapes such as maze walls, call `generateTexture(key, w, h)` once to bake them into a texture. `generateTexture` draws through the Canvas API, so `fillGradientStyle` will not appear on the baked texture.

## 7. Testing and headless

- Importing Phaser in plain Node without a DOM FAILS. Both `import('phaser')` (ESM) and `require('phaser')` (CJS) on 4.2.1 under Node 24.18.0 throw `ReferenceError: window is not defined`. The cause is `src/device/OS.js`: it runs `init()` at module load (line 186), which reads `navigator.userAgent` (line 69) and `window.cordova` (line 153).
  Source: local run of the 4.2.1 tarball, and https://github.com/phaserjs/phaser/blob/v4.2.1/src/device/OS.js
- `Phaser.HEADLESS` (value 3): "doesn't create either a Canvas or WebGL Renderer. However, it still absolutely relies on the DOM being present and available. This mode is meant for unit testing, not for running Phaser on the server."
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/const.js (lines 73 to 83). Game uses `headlessStep`: https://github.com/phaserjs/phaser/blob/v4.2.1/src/core/Game.js (lines 422, 523)
- Official pattern (Phaser's own test suite, shipped in the repo and the npm package): Vitest with `environment: 'jsdom'` plus a setup file.
  - The setup file mocks Canvas 2D and WebGL contexts and an `Image` whose `onload` fires, and stubs `self`, `screen` and `window.focus`.
  - The helper boots a real game with `type: Phaser.HEADLESS`, `audio: { noAudio: true }`, `banner: false` and resolves with the scene in `create`.
  - Pure functions are tested by requiring source files directly.
  Sources:
  - https://github.com/phaserjs/phaser/blob/v4.2.1/tests/TESTING.md
  - https://github.com/phaserjs/phaser/blob/v4.2.1/tests/helper.js
  - https://github.com/phaserjs/phaser/blob/v4.2.1/tests/setup.js
  - https://github.com/phaserjs/phaser/blob/v4.2.1/vitest.config.js
  Phaser's devDependencies include `vitest ^4.1.4` and `jsdom ^29.0.2` (package.json).
- The official skill doc says the same: `Phaser.HEADLESS` means "No renderer -- DOM still required. For unit testing only". Source: https://github.com/phaserjs/phaser/blob/v4.2.1/skills/game-setup-and-config/SKILL.md (line 61)
- Playwright: Not confirmed. I found no official Phaser guidance on Playwright. There are no mentions in the v4.2.1 repo, its `skills/` docs or `tests/`, and a docs.phaser.io and phaser.io web search found none. Only third-party material exists.

## 8. Scale manager and fullscreen

- `Phaser.Scale.FIT` (3) is defined, along with `NONE` 0, `WIDTH_CONTROLS_HEIGHT` 1, `HEIGHT_CONTROLS_WIDTH` 2, `ENVELOP` 4, `RESIZE` 5 and `EXPAND` 6. These constants are merged onto `Phaser.Scale`.
  Sources: https://github.com/phaserjs/phaser/blob/v4.2.1/src/scale/const/SCALE_MODE_CONST.js and https://github.com/phaserjs/phaser/blob/v4.2.1/src/scale/index.js (lines 46 to 49)
- `autoCenter` accepts `Phaser.Scale.NO_CENTER` 0, `CENTER_BOTH` 1, `CENTER_HORIZONTALLY` 2 or `CENTER_VERTICALLY` 3. The ScaleManager doc example uses `autoCenter: Phaser.Scale.CENTER_BOTH`.
  Sources: https://github.com/phaserjs/phaser/blob/v4.2.1/src/scale/const/CENTER_CONST.js and https://github.com/phaserjs/phaser/blob/v4.2.1/src/scale/ScaleManager.js (line 104)
- `this.scale.startFullscreen(options)` (line 1323), `stopFullscreen` (1453), `toggleFullscreen` (1508) and `isFullscreen` (1795) exist.
  - The doc says the call "must be called from a `pointerup` user-input gesture (not `pointerdown`)". It emits `FULLSCREEN_UNSUPPORTED` or `FULLSCREEN_FAILED`.
  - If no `fullscreenTarget` is set, Phaser wraps the canvas in a temporary div.
  - The doc does not mention keyboard-triggered fullscreen. Whether a keydown handler works is browser behavior and is Not confirmed from Phaser sources.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/src/scale/ScaleManager.js (doc lines 1290 to 1316)

## 9. Bundle size and tree-shaking

Sizes from the 4.2.1 tarball, matching the unpkg `?meta` listing:

| File | Raw bytes | gzip -9 bytes |
|---|---|---|
| `dist/phaser.min.js` | 1,375,976 | 352,455 |
| `dist/phaser.esm.min.js` | 1,377,611 | 353,385 |
| `dist/phaser.esm.js` (the `import` entry) | 8,800,542 | 1,444,953 |
| `dist/phaser.js` | 8,793,523 | 1,444,014 |

- unpkg sends `phaser.min.js` gzip-encoded as 352,670 bytes.
  Sources: https://unpkg.com/phaser@4.2.1/dist/?meta and https://unpkg.com/phaser@4.2.1/dist/phaser.min.js
- Not tree-shakable in practice. `import` resolves to `dist/phaser.esm.js`, a single prebuilt webpack bundle: the dist config uses `library: { type: 'module' }` and an internal `__webpack_require__` registry. It exports 47 named namespace bindings plus `default`. The `exports` map exposes only `.` and `./package.json`, so deep imports like `phaser/src/...` are blocked.
  Source: https://github.com/phaserjs/phaser/blob/v4.2.1/config/webpack.dist.config.js and `package.json`.
- Measured: `import { AUTO } from 'phaser'` bundled with esbuild (minified) gave 1,394,670 bytes. `import Phaser from 'phaser'` gave 1,394,675 bytes. Rollup 4 (which Vite uses for builds) with only `AUTO` imported kept 8,793,608 bytes unminified. So named imports and the default import both pull in the whole engine.
- Smaller builds need a custom webpack build from `src/` with feature flags. The template does not do this. Out of scope; details Not confirmed.
