# Choose the tech stack

Type: research
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

Which tech stack gives the simplest reliable build for this game?

Candidates: TypeScript with Canvas 2D and Vite, PixiJS, Phaser, or plain DOM/SVG.

Criteria:

- A grid Labyrinth with smooth animation from one square to the next.
- Simple sound effects and music.
- The Parent starts it with `npm` on a laptop. It works with no network connection.
- Few dependencies.
- An agent can build it and test it easily.

Also decide: use a library to generate Labyrinths, or write the generator in the game code.

Primary sources: the game skills in `.claude/skills/` of this repo. Start with `router`, then read `phaser-core`, `pixijs-rendering`, `puzzle`, `procedural-gen`, `input-systems`, and `audio-design`. Use web sources only to check facts that the skills do not cover.

## Answer

Use TypeScript, Vite, and SVG in the DOM, with no runtime dependencies. The Web Animations API moves the character, and the Web Audio API plays the sound.
Dev tools: `vite`, `typescript`, `vitest` for the logic, and `@playwright/test` for browser tests. Phaser 4 is the second choice, for a theme with many sprite animations.
Write the Labyrinth generator in the game code: the recursive backtracker with a small seeded PRNG of our own. It gives the fewest dead ends and always a path to the Goal.
Browsers block audio until the first key press (not Esc), so music cannot start at page load.
Details, sources, and open risks: [research/tech-stack.md](../research/tech-stack.md).

## Revised answer

Use **Godot 4.7** (4.7.2-stable) with GDScript, in a native fullscreen window. Phaser 4 is the second choice, only for a browser target.
Godot gives the least build work: tweens, particles, sprite sheets, sound buses, named key actions, and exclusive fullscreen are in the engine. The browser stacks need our own code for buses, the audio unlock, and focus, and the Child can leave a browser with Esc, Cmd+W, or Cmd+R.
One-time setup: `brew install --cask godot`. One command to play: `./play` (runs `godot --headless --path . --import`, then `godot --path .`). Tests: `godot --headless --path . --script res://tests/run.gd`.
Keep the generator decision: own recursive backtracker and own seeded PRNG, now in GDScript. Music can start at launch, because a native app has no autoplay block.
Details, the comparison table, and the effects on other tickets: [research/tech-stack.md, Revision 2026-11-03](../research/tech-stack.md#revision-2026-11-03).

## Comments

- Parent, 2026-11-03: prefer a ready-built engine if it removes work. Re-evaluate the answer with this criterion first.
- Parent, 2026-11-03: chose Godot over Phaser. A web version is not needed.
