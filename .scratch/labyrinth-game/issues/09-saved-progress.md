# Saved progress

Type: grilling
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

Does the game remember the current Labyrinth, the Collection, and the total count of Items after it closes? If yes:

- Where does it keep the data on the laptop?
- What happens if the data file is missing or broken?
- Can the Parent reset the progress, and how?

## Context

From [Levels and difficulty](05-levels-and-difficulty.md): 20 fixed Labyrinths in 4 Areas, then random ones. From [Encouragement without losing](04-encouragement-without-losing.md): the Collection holds the Sea friends, and the Collection screen shows the total count of Items. Consult the `save-systems` skill in `.claude/skills/`.

## Resolution

The Parent accepted all four recommendations.

1. **Remember progress:** yes. The game saves the current Labyrinth, the Collection, and the total count of Items.
2. **When to save:** after each Item and at each Goal. The save holds the IDs of the Items collected in the current Labyrinth. After a close, the same Labyrinth opens again, and those Items stay collected. So one Item never counts two times.
3. **File:** `user://save.json` (on macOS: `~/Library/Application Support/Godot/app_userdata/<game name>/`). Fields: `version`, current Labyrinth index, seed of the current random Labyrinth (after Labyrinth 20), collected Item IDs in the current Labyrinth, Collection, total Item count.
   - The game writes a temporary file, then renames it.
   - A missing file: start at Labyrinth 1 with no message.
   - A broken file: rename it to `save.bak`, then start at Labyrinth 1 with no message to the Child.
   - An older `version`: migrate it. Do not treat it as broken.
4. **Parent reset:** a reset button in the settings with a circular-arrow picture and no words. The Parent must hold it for 3 seconds. The full design is part of Parent controls.
