# 10: Idle hint

**What to build:** When the Child presses no key for a while, the open chest or the nearest uncollected Item hops, to show where to go. Spec: [spec.md](../spec.md), Part 5, fix 10.

**Blocked by:** 06 (Padlock on the chest)

**Status:** ready-for-agent

- [x] If no key is pressed for 6 s while the play is free (no move, no lock, settings closed), the target hops one time: up by 12 % of a tile, with a small squash, in 350 ms.
- [x] The target is the open chest, or else the uncollected Item with the shortest path from the boat.
- [x] The hop repeats after each further 6 s, at most 3 times. A key press starts the count again.
- [x] The 6 s value is one constant, so the Parent can ask to tune it.
- [ ] Main-scene tests: the hop target, the 3-hop limit, and the restart of the count after a key press. No hop on the opening screen, on the Party, or while the settings panel is open.
- [x] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.

Build note (gf/10-idle-hint): The new node `IdleHint` (`src/idle_hint.gd`) in `main.tscn` counts the seconds of free play with no key press. Each key press (any key, not only the arrow keys) sets the time and the hop count to 0. While the play is not free, the time does not count, and it starts again from 0 when the play is free again: after a move, after the fade-in, and after the settings close. The main scene gives the rule of free play in `_is_play_free()`: a Labyrinth shows, no lock, no move, no opening screen, and the settings closed. The Goal celebration, the fades, the opening screen, and the Party keep the input locked, so no hop comes on them. After 6 s (`Motion.HINT_IDLE_SECONDS`) the main scene hops the target and emits `hint_hopped(square)`. At most 3 hops (`Motion.HINT_HOP_COUNT`) come until the next key press. The target is the Goal square while the chest is open, else the uncollected Item with the shortest press path from the boat. `MoveRule.nearest_target()` finds the path with the move rule. It is the breadth-first search that `first_press()` of `tests/scene_helpers.gd` had: that helper now calls it, so the game and the tests use one path finder. Of two paths with the same press count, the first in the order up, right, down, left wins. In Labyrinth 1 the target is the Item on (0, 2), one press down, and not the Item on (1, 1), which is first in the Item list and nearer in a straight line. `LabyrinthView.hop_chest()` and `ItemsView.hop_item()` play the hop. The spec gives no shape for the hop and the squash. The values: in the first 70 % of the 350 ms (245 ms) the target goes up by 12 % of a tile and down again on a sine arc. In the last 30 % (105 ms) it lands with a squash of at most 108 % wide and 92 % tall, with its bottom in place. The Item bob goes on during the hop. A collected Item or a new Labyrinth stops the hop. In the short time from the arrival on the last Item to the pop of the padlock, no target is open: the hop of that time does not show, but it counts as one of the 3. A person must check the feel of the hop and the 6 s value in play. No screenshot shows the hop.
