# Parent controls

Type: decision
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

How does the Parent start, quit, and skip a Labyrinth with no words on the screen? Facts about the keys are in the map and in [research/godot4-facts.md](../research/godot4-facts.md). The reset button is decided in [Saved progress](09-saved-progress.md). Do not decide it again.

Recommendation:
- **Start:** `./play` opens the game at the saved Labyrinth. The game has no start screen.
- **Settings:** a small gear picture in a corner opens the settings with a mouse click. The settings hold the volume buttons, the reset button, and a quit button (a door picture). The Parent holds the quit button for 3 seconds, the same as reset.
- **Quit keys:** the game calls `get_tree().set_auto_accept_quit(false)`, so Cmd+Q and window close do nothing. The quit button is the only quit path. The spec requires a manual test of each key.
- **Skip:** no skip. Each Labyrinth is easy to finish.

## Decision

The Parent accepted the recommendation on 2026-11-03.
