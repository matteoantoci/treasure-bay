# Motion and animation

Type: prototype
Status: resolved
Blocked by: 13
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

How do things move and come alive on the screen, in addition to the boat move?

The emoji images have no animation frames, so all motion comes from tweens and particles: move, scale, turn, squash, fade. Decide each one:

- **Idle:** does the boat rock on the water when it does not move? Do the Items and the island bob or shine?
- **Water:** do waves or ripples move on the floor? Does the boat leave a small wake?
- **Item:** how does an Item disappear when the boat collects it, and how does its outline at the top fill?
- **Goal:** how does the celebration move: confetti, sparkles, the boat jumps?
- **Sea friend:** how does the Sea friend arrive at the island and then fly to the Collection?
- **Transitions:** how does one Labyrinth change to the next one, and how does a new Area start?
- **Amount:** how much motion is good for a 5-year-old, and how much is too much?

Make a rough prototype that shows each motion. The Parent chooses what to keep.

## Context

From [Arrow-key movement](03-arrow-key-movement.md): the boat moves with an ease-out tween, about 180 ms for each square, and it bumps at a wall. From [Encouragement without losing](04-encouragement-without-losing.md): the boat stops on each Item, and the Goal plays a celebration of about 3 seconds. From [Choose the tech stack](01-choose-tech-stack.md): Godot `create_tween()` and `CPUParticles2D`.

Consult the `game-feel` and `godot-animation` skills in `.claude/skills/`.

From [Source the sounds](10-source-the-sounds.md): the chosen fanfare is 4.4 s, not about 3 s. Fade it out at 3 s, or use the 3.8 s alternative. The celebration motion must match the length.

From [Polished sea look](13-polished-sea-look.md): the boat is now a top-down Kenney sprite that turns to face each move. It does not flip. The water, foam, wake, and idle rock are already decided there; this ticket decides their amounts and the other motions.

## Prototype

`prototypes/motion-PROTOTYPE/index.html` (HTML stand-in for Godot tweens and particles). The islands are rough shapes. Only the motion is under test.

Open it with `open .scratch/labyrinth-game/prototypes/motion-PROTOTYPE/index.html`. Play with the arrow keys: collect the 3 Items, then sail to the square above the palm island. The game then plays the celebration, the Sea friend, and the change to the next Labyrinth. In the prototype, every 2nd Labyrinth starts a new Area, so that you can see it fast.

- **Amount buttons:** calm, medium, lively. One multiplier scales all motion.
- **On/off buttons:** idle rock and bob, water and foam, wake, Item fly, confetti and hop, Sea friend, fade and Area number.

Motions in the prototype:

| Motion | What happens |
|---|---|
| Idle | The boat rocks and bobs. Items bob and sparkle. The palm sways. |
| Water | Waves drift. A foam ring moves around each island. |
| Wake | Rings spread behind the moving boat. |
| Item | The Item pops, flies to its outline at the top, and the outline fills with a small bounce. |
| Goal | The boat hops 2 times, and confetti falls for about 2.6 s. |
| Sea friend | It grows next to the Goal island, wiggles, then flies to the Collection strip at the bottom. |
| Transition | Fade to dark and back. A new Area shows its number (1 to 4) in the middle of the screen. |

Smoke test on 2026-11-03 (headless browser): a full play from start to the next Labyrinth worked. All 3 outlines filled, the Sea friend joined the Collection, and the next Labyrinth started.

## Answers from the Parent (2026-11-03)

1. Amount: **medium**.
2. Motions switched off: **none**. All 7 motions stay.
3. Area start: **(b)**. The Parent asked for suggestions, and these were the options:
   - (a) The new Area number, big, in the middle of the screen. This is the prototype version.
   - (b) The first Item of the new Area pops up big in the middle, then fades out. It does not fly to the top and does not fill an outline, because that motion means "you found an Item". **Recommended.**
   - (c) No sign. The fade and the new colours are enough.

## Answer

The Parent chose **(b)** on 2026-11-03.

- All 7 motions in the prototype table stay, at the **medium** amount. Medium is the multiplier 1.0 in the prototype (`AMOUNT` in `prototypes/motion-PROTOTYPE/index.html`). The spec uses the values below, not a multiplier.
- At the start of a new Area, the first Item of that Area pops up big in the middle and then fades out. It does not fly and it does not fill an outline. It replaces the Area number in the prototype. The Item scales from 0 to 2× in 400 ms with a back ease, stays for 600 ms, and fades out in 400 ms. This plays while the screen fades in.

Values for the spec. The canvas in the prototype is 960 px wide, and one square is 130 px. The times are from the prototype code.

| Motion | Values |
|---|---|
| Boat idle | Rock ±0.06 rad and bob ±2 px, at 1.6 rad/s. Only when the boat does not move. |
| Item idle | Bob ±4 px at 2 rad/s. A white sparkle at the top right for 15 % of each 1.4 s cycle. |
| Goal island idle | The palm sways ±0.08 rad at 1.5 rad/s. |
| Water | The waves move ±8 px at 1.2 rad/s, at 18 % opacity. The foam ring around each island moves at 20 px/s. |
| Wake | While the boat moves, about 36 rings each second (60 % of frames at 60 fps). Each ring grows to 30 × 16 px and fades in 900 ms. |
| Item collect | 8 splash dots (400 ms). The Item scales to 1.4× in 120 ms, then flies to its outline in 450 ms (ease in-out) and shrinks to 0.55×. The outline fills in 150 ms and bounces from 1.5× to 1× in 350 ms. 10 sparkles (500 ms). |
| Goal | The boat hops at 0 ms and at 600 ms. Each hop is 1.25× tall in 150 ms, then back in 250 ms. 40 confetti pieces fall with gravity for 2.6 s. |
| Sea friend | It appears at 1.4 s, next to the Goal island, and grows to 1.3× in 450 ms (back ease). It wiggles ±0.15 rad for 500 ms at 1.9 s. At 3.0 s it flies to the Collection strip in 700 ms and shrinks to 0.35×. 10 sparkles when it arrives at 3.7 s. |
| Next Labyrinth | At 4.2 s the screen fades to dark in 500 ms. The new Labyrinth shows, and the screen fades in in 500 ms. The input is locked from the Goal to the end of the fade-in. |

**Fanfare:** the celebration runs from 0 to 3.7 s, until the Sea friend arrives in the Collection. Use the 3.8 s fanfare alternative from [Source the sounds](10-source-the-sounds.md). If [Listen to the sounds](12-listen-to-the-sounds.md) replaces it, fade the new fanfare out between 3.2 s and 3.7 s.
