# Arrow-key movement

Type: prototype
Status: resolved
Blocked by: 01
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

How does the character move with the arrow keys?

- One press moves the character one square.
- One press moves the character to the next junction.
- The character moves while the Child holds the key.

What happens when the Child presses a key toward a wall?

Make a rough playable prototype with one small Labyrinth. The Parent tries each option and judges which one a 5-year-old controls best. The Child does not test the prototype. Record the choice and the reason.

## Context

From [Choose the tech stack](01-choose-tech-stack.md) (Godot 4.7) and [Source the graphics](07-source-the-graphics.md):

- Move with `create_tween()`, and lock input until the tween finishes. Keep one early key press.
- Read named InputMap actions. Use `event.is_echo()` to find the repeats of a held key.
- The emoji have no animation frames. Tweens give all motion. Turn the rocket to the move direction, because it points at 45°. Flip the sailboat for left and right, and do not turn it for up and down.

## Answer

- Mode B: one press moves the boat until it reaches a junction, a dead end, or the Goal. In the prototype, the boat collects an item as it moves past and does not stop on it. This item rule is still open in [Encouragement without losing](04-encouragement-without-losing.md).
- Wall: a small bump and shake toward the wall. The boat does not move.
- Speed: medium, about 180 ms for each square, with an ease-out curve.
- Input: one early key press is kept while the boat moves. The repeats of a held key are ignored (`is_echo()`).
- ~~The sailboat flips for left and right moves, and does not turn for up and down moves.~~ Replaced on 2026-11-03 by [Polished sea look](13-polished-sea-look.md): the boat is a top-down sprite and turns to face each move, in all four directions. The Parent accepted this change on 2026-11-03.

The Parent chose these values in the prototype. Prototype (throwaway): [prototypes/movement-PROTOTYPE/index.html](../prototypes/movement-PROTOTYPE/index.html). To view it, run `python3 -m http.server` in that directory.
