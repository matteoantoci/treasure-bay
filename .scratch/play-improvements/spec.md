# Play improvements after the game review

Status: ready-for-agent

Source: the five-axis review of 2026-11-04 (child play, Labyrinth design, look and motion, sound, code). The Parent accepted review items 1 to 5.

## Problem Statement

The game is complete and follows its build spec, but the review found five problems for the Child and the Parent:

1. In 11 of the 20 fixed Labyrinths, no Item is on the path to the Goal. A Child who sails straight to the chest gets no Item. Ticket 04 of the labyrinth-game map asked for Items "on the path".
2. From Labyrinth 19 on, the chest and the Items are 26 px and the boat is 23 px wide at 1920 × 1200. The palm is green on green grass. The Child cannot find the Goal at a glance.
3. The difficulty does not rise smoothly. The fewest presses to the Goal are 13, 7 and 5 for Labyrinths 13 to 15, and then 26 for Labyrinth 16. The Child can get stuck at Labyrinth 16.
4. The Goal fanfare is still loud when the Sea friend sound starts. The Crab sound of Labyrinth 1 is 10 dB quieter than the fanfare, so the Child does not hear her reward.
5. A 3 s hold on the reset button deletes the whole Collection, and no undo exists. The spec says that the Child can use the settings too. Also, a save file from a newer build counts as broken, and the game replaces it with Labyrinth 1.

## Solution

1. Each Labyrinth puts 1 or 2 Items on the main path. The Child gets at least one Item on the way to the Goal. The shuffle can put more Items on the path.
2. The Items, the boat and the chest are larger. The chest sparkles like an Item, and the palm is darker.
3. The 20 fixed Labyrinths use seeds that a measured search selected. Their fewest presses to the Goal rise from 3 to 20.
4. When the Sea friend appears, the fanfare becomes 12 dB quieter. The Sea friend sound is then clear.
5. The reset needs an 8 s hold, and its ring has a different colour. Before a reset, the game keeps a copy of the save. A save from a newer build stays on disk, and the game does not write over it.

## User Stories

### Items on the path

1. As the Child, I want an Item on the path to the Goal, so that I get an Item even when I sail straight to the chest.
2. As the Child, I want more Items on the path in the large Labyrinths, so that a long trip gives me more than one Item.
3. As the Child, I want the Items in the dead ends to stay, so that I still have a reason to explore.
4. As the Child, I want the boat to stop on each Item on the path, so that I see each Item pop and fly to its outline.
5. As the Child, I want the same number of Items in each Labyrinth as before, so that the Item row at the top looks the same.
6. As the Parent, I want the Item placement to stay deterministic, so that Labyrinth n always looks the same.

### Sizes and the Goal

7. As the Child, I want larger Items, so that I can see them in the large Labyrinths.
8. As the Child, I want a larger boat, so that I can see where I am.
9. As the Child, I want a larger chest, so that I can find the Goal at a glance.
10. As the Child, I want the chest to sparkle like the Items, so that I see that the chest is a special place.
11. As the Child, I want the palm to be darker than the grass, so that I can see the Goal island.
12. As the Child, I want the new-Area Item in the centre of the screen to grow with the Item size, so that it stays clear.
13. As the Child, I want the chest to stop its sparkle when it opens, so that the open chest looks different from the closed chest.

### Difficulty curve

14. As the Child, I want each Labyrinth to be a little harder than the one before, so that I do not get stuck.
15. As the Child, I want the first Labyrinths to be short, so that I understand the game in the first minute.
16. As the Child, I want more choices at junctions in each Area, so that the game stays interesting.
17. As the Child, I want no wrong turn to be much longer than the path to the Goal, so that a mistake does not take a long time.
18. As the Child, I want Labyrinths 1 to 20 not to look the same as each other, so that each one feels new.
19. As the Child, I want the random Labyrinths after Labyrinth 20 to have an Item on the path too, so that each Labyrinth gives me an Item on the way.
20. As the Parent, I want the seed selection to be repeatable with a tool in the repo, so that I can tune the curve again later.
21. As the Parent, I want a saved random Labyrinth to rebuild the same Labyrinth after a restart, so that the Child sees the same Labyrinth.

### Sound

22. As the Child, I want to hear the sound of each Sea friend clearly, so that each reward feels different.
23. As the Child, I want the fanfare to start at its full level at each Goal, so that the celebration stays the same.
24. As the Parent, I want the music and the volume settings to work as before, so that the change has no other effect.

### Saved progress and reset

25. As the Parent, I want the reset to need a hold of 8 s, so that the Child does not reset the game by accident.
26. As the Parent, I want the reset ring to have a different colour from the quit ring, so that I can see which button I hold.
27. As the Parent, I want the quit to stay at a 3 s hold, so that I can quit quickly.
28. As the Parent, I want a copy of the save before each reset, so that I can restore the Child's Collection after a reset by mistake.
29. As the Parent, I want a reset of fresh progress to keep the older copy, so that a second reset by mistake does not replace the Collection with an empty save.
30. As the Parent, I want a save from a newer build to stay on disk, so that an older build does not delete the Child's progress.
31. As the Parent, I want an older build to play without a write when the save is newer, so that the newer save stays correct.
32. As the Parent, I want the settings file to follow the same version rules, so that an older build keeps my volume steps on disk.
33. As the next developer, I want the migration chain to accept its first migration, so that a save schema change can migrate version 1 saves.
34. As the Child, I want my current Collection and my Labyrinth number to stay after this update, so that I do not lose my progress.

## Implementation Decisions

### General

- The labyrinth-game build spec stays the source of truth. Each change below also updates that spec as errata: sections 4.3, 4.4, 4.6, 6.2, 8.2, 9.3, 10, 11.2, 12.3, 12.4, 14.1, and Open gaps 3 and 4.
- Use the glossary words: Labyrinth, Goal, Item, Sea friend, Collection, Area, Child, Parent.
- Do the parts in this order: 1 (placement), then 3 (seeds). The seed search depends on the new placement rule. Parts 2, 4 and 5 are independent.
- Part 5 (the migration fix) must land before any later change to the save schema, for example the gold stars of the review.

### Part 1: Items on the main path (Item placement module)

- The main path P is the only chain of squares from the start to the Goal. P[0] is the start, and P[L] is the Goal. L counts moves from square to square.
- The on-path count is `k = min(max(1, count div 3), L - 1)`. So 2 to 5 Items give 1 on-path Item, and 6 to 8 Items give 2 on-path Items.
- On-path Item j (1 to k) goes on `P[j * L div (k + 1)]`, with integer division. This index is from 1 to L − 1 and never repeats. It is never the start or the Goal. A junction gets no special case.
- The new placement order:
  1. Item 1: the farthest free dead end, as today.
  2. Items 2 to k + 1: the on-path squares, in order from the start to the Goal.
  3. The shuffled other dead ends.
  4. The shuffled other squares.
- Before the shuffle, remove the k path squares from the list of other squares. A main-path square is never a dead end, so the dead-end list does not change. The PRNG calls do not change.
- The Item count and the kinds rule (`kinds[i % len]`) do not change.
- The review checked that this rule with k = 0 gives the placement of today for Labyrinths 1 to 20.

### Part 3: Measured difficulty (new Labyrinth measure module and the Labyrinth plan)

- Add one pure module that measures a Labyrinth. It takes a Labyrinth with its Items and returns these values:
  - **main path length** in moves.
  - **presses:** the arrow presses along the main path with the move rule of build spec 5.2. Each uncollected Item on the path is a stop.
  - **decisions:** main-path squares with 3 or more open sides. The start and the Goal never count.
  - **turns:** direction changes along the main path.
  - **largest side branch:** the largest group of off-path squares that connect without a main-path square.
  - **Items on the path:** the count of Items on main-path squares.
- The measure module uses the move rule module for the presses. It does not copy the move rule.
- The Labyrinth plan gets a table of 20 fixed seeds. Labyrinth n uses entry n. This replaces the rule "Labyrinth n uses seed n".
- The seed of each slot is the first seed from 1 upward that meets all of these conditions. Here `d = 1 + (n - 1) div 5`:
  - presses = T(n), with T = 3, 5, 5, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20.
  - decisions from d to d + 2.
  - turns ≥ 2 for n ≥ 2.
  - at least 1 Item on the main path.
  - largest side branch ≤ max(6, main path length).
  - the seed has a free dead end, and it is not the seed of the other slot with the same size.
- Add a seed-search tool in the tools folder. It runs headless, applies these conditions, and prints the seed table. The Parent can run it again to tune the curve.
- The review probe found these seeds with the new placement rule. The build must confirm each value with the seed-search tool and with the Python port. If a value differs, the tool output wins, and the build reports the difference. (Table from the review probe.)

| n | size | seed | presses | decisions | Item IDs in placement order |
|---|---|---|---|---|---|
| 1 | 4×3 | 1 | 3 | 1 | 1,1 0,2 |
| 2 | 4×3 | 17 | 5 | 2 | 0,1 2,1 |
| 3 | 5×3 | 2 | 5 | 1 | 1,1 4,1 |
| 4 | 5×3 | 9 | 5 | 1 | 2,1 3,2 |
| 5 | 5×4 | 85 | 5 | 2 | 4,0 2,1 1,1 |
| 6 | 5×4 | 10 | 6 | 2 | 0,3 2,1 4,0 |
| 7 | 6×4 | 12 | 7 | 2 | 5,2 2,2 0,3 1,0 |
| 8 | 6×4 | 9 | 8 | 2 | 0,3 3,1 4,3 1,1 |
| 9 | 7×4 | 8 | 9 | 2 | 0,1 3,1 6,0 5,3 |
| 10 | 7×4 | 23 | 10 | 2 | 6,0 1,3 0,1 6,2 |
| 11 | 7×5 | 1 | 11 | 3 | 3,2 3,1 6,0 1,0 2,4 |
| 12 | 7×5 | 69 | 12 | 4 | 4,3 2,1 6,0 0,4 1,2 |
| 13 | 8×5 | 29 | 13 | 3 | 0,2 3,3 6,0 4,1 6,1 2,3 |
| 14 | 8×5 | 73 | 14 | 4 | 1,0 4,1 2,4 7,0 6,2 1,3 |
| 15 | 8×6 | 9 | 15 | 3 | 4,1 4,0 6,2 3,2 1,5 1,1 7,4 0,5 |
| 16 | 8×6 | 28 | 16 | 4 | 3,4 3,2 6,0 1,2 1,0 4,1 5,3 6,1 |
| 17 | 9×6 | 73 | 17 | 4 | 1,0 5,2 5,4 8,0 3,4 7,2 2,2 1,4 |
| 18 | 9×6 | 127 | 18 | 5 | 6,3 4,2 2,2 0,1 7,5 2,4 8,0 4,4 |
| 19 | 9×7 | 167 | 19 | 5 | 4,5 4,6 2,1 5,1 7,6 3,2 6,4 0,6 |
| 20 | 9×7 | 30 | 20 | 4 | 8,2 3,1 3,6 1,4 3,5 2,1 7,6 0,6 |

- **Random Labyrinths 21 and later:** the valid-seed check does not change. A saved `random_seed` gives the same layout as before. Only the Item squares change, because of the placement rule of part 1.
- The size table, the Item counts, the Areas and the Sea friend of each Labyrinth number do not change.
- **Saves of today:** the save keeps the Labyrinth number and the Collection. The current fixed Labyrinth gets a new layout and new Item squares. A current random Labyrinth keeps its layout and gets new Item squares. The load then does this with `collected_items`:
  - The load rule "Old Item ID" of build spec 12.3 drops each collected Item ID that has no Item now. That Item square shows an Item again.
  - A collected Item ID that matches a new Item square counts that new Item as collected. The Item does not show.
  - `total_items` does not change on the load. An Item that comes back adds 1 again when the Child collects it.
  - No save becomes broken, because each ID is still a free square: the start and Goal squares do not move.

### Part 2: Sizes and the Goal (views of the Labyrinth)

- The sizes in prototype px (multiply by `s = tile_px / 130`) change:
  - Item: 60 px to 90 px.
  - Boat: 54 × 86 px to 69 × 110 px. The aspect of the boat picture stays the same.
  - Chest: 60 px to 100 px. The chest stays at its place on the Goal island tile.
- The new-Area Item stays at 2× the Item size, so it grows with the Item.
- The Item flight still shrinks the Item to 0.55× of its Labyrinth size.
- The closed chest gets the Item sparkle of build spec 8.2: a white 8-point sparkle at (+18, −18) px from the chest centre, radius 7 px, with `i` equal to the Item count of the Labyrinth. The sparkle stops when the chest opens.
- The palm gets the modulate colour `Color(0.7, 0.85, 0.7)`.
- The HUD sizes, the top band, the Item row and the Collection strip do not change.

### Part 4: The fanfare under the Sea friend sound (Sound node)

- At `sea_friend_appeared`, a tween moves the volume of the Goal player down by 12 dB from its level in 0.2 s.
- At each `goal_reached`, the game kills an old tween, sets the Goal player to its level from the sound-levels table, and then plays the fanfare.
- A reset during the celebration needs no extra step, because the next Goal sets the level again.
- The tween pauses with the game, like the Goal player.
- The sound-levels table, the bus volumes and the music do not change.

### Part 5: Reset and save safety (hold button, settings panel, main scene, save store, settings store)

- The hold time becomes a value of each hold button. The reset button holds 8 s. The quit button holds 3 s, as today.
- The full ring colour becomes a value of each hold button. The reset ring is `#ff7a59`. The quit ring stays `#ffd447`.
- **Copy before a reset:** before the reset writes the new save, the save store copies the current save file to `save.before-reset.json` in the same folder. The copy uses the write rule of today: a temporary file, then a rename.
  - The game makes the copy only when the progress in memory is not fresh. Progress is fresh when the Labyrinth is 1, the Collection is empty, and `total_items` is 0.
  - A reset of fresh progress keeps the older copy. So a second reset after a reset by mistake does not replace the real Collection.
  - A reset of progress that is not fresh replaces the older copy.
  - With no save file, the game makes no copy.
- The Parent restores the progress by hand: quit the game, then rename `save.before-reset.json` to `save.json`.
- **Newer save:** a save with a version above the current version is not broken.
  - The game does not rename it to `save.bak`.
  - The game plays Labyrinth 1 in memory.
  - The save store goes into a no-write state for the session. Each save call returns without a write and logs one warning. The reset makes no copy.
- A version of 0 or less stays broken, as today.
- **Migration chain:** the chain becomes a value that can hold entries. The migration runner takes the chain and the target version as inputs, so a test can run a chain of one migration.
- **Settings file:** it uses the same version rules.
  - A version above the current version gives the default steps in memory. The game does not write the settings file in that session.
  - A version of 0 or less is broken and gives the default steps, as today.
  - An older version goes through its own migration chain. That chain is empty now.

## Testing Decisions

- A good test checks behaviour that the Child or the Parent can see: the squares of the Items, the presses to the Goal, the sizes on screen, the sound calls and levels, and the files on disk. A test does not check private fields, constant values or the text of the code.
- The tests use the seams of today. They add no new seam:
  - **Labyrinth content:** the Labyrinth plan build function for a Labyrinth number and a random seed. Prior art: the Items tests and the generator tests, which pin values from the separate Python port.
  - **Look:** the main scene node tree, with the global sizes of the sprites. Prior art: the main look tests and the HUD layout tests.
  - **Sound:** the main scene signals into the Sound node, with its sound-played signal and the player volumes. Prior art: the sound tests.
  - **Save and reset:** the save store and the settings store on a temporary folder, and the hold buttons through their fake clock. Prior art: the save tests, the settings tests, the hold button tests and the Parent controls tests.
- The Python port gets the new placement rule, the measure and the fixed seed table. The build writes it from the text of this spec, not from the GDScript, so the cross-check stays independent. The tests pin the Item IDs of Labyrinths 1 to 20 and of two random seeds with values from the port.
- Tests to add or change:
  1. **Placement:** for Labyrinths 1 to 20 and 200 random seeds, the number of Items on the main path equals k. No Item is on the start or the Goal. All Item squares are different. Item 1 is the farthest dead end.
  2. **Fixed seeds:** for each Labyrinth 1 to 20, the presses equal T(n), the decisions are from d to d + 2, and the other conditions of part 3 hold. The Item IDs equal the values from the Python port.
  3. **Save across the change:** a save of Labyrinth 7 written before this change, with collected Items, loads after the change. The Labyrinth number, the Collection and `total_items` stay. Each collected ID without an Item now is dropped, and its square shows an Item again. Each collected ID that matches a new Item square hides that Item. No `save.bak` exists.
  4. **Move rule cross-check:** the presses of the measure equal the count of moves that the move rule gives along the main path.
  5. **Sizes:** at 1920 × 1200, the Item, boat and chest sprites have the new sizes for Labyrinths 1 and 20.
  6. **Chest sparkle:** the closed chest shows the sparkle at the cycle times of build spec 8.2. The open chest does not show it.
  7. **Fanfare duck:** after `sea_friend_appeared`, the Goal player reaches its level − 12 dB in 0.2 s. At the next `goal_reached`, it plays at its level.
  8. **Reset hold:** a reset hold of 7.9 s does nothing. A hold of 8 s resets. A quit hold of 3 s still quits.
  9. **Copy before reset:** after a reset, `save.before-reset.json` holds the old progress. Two resets in a row keep the first copy. A reset after new play replaces the copy. With no save file, no copy exists.
  10. **Newer save:** a version 2 save stays in place with the same bytes. No `save.bak` exists. The game is at Labyrinth 1. A collect and a Goal write nothing.
  11. **Migration:** a chain of one test migration from version 1 to version 2 runs and gives the migrated fields.
  12. **Settings:** a version 2 settings file gives the default steps and stays in place with the same bytes.
- Remove the check "`version` 2 counts as broken" of build spec 14.1 test 7. Replace it with test 10.
- After the build, run the full suite, the smoke run, and the screenshot tool. Look at the new screenshots of Labyrinths 3, 8, 13 and 18.

## Out of Scope

- The other review suggestions: faint shapes in the empty Collection slots, gold stars for all Items, fixed screen sizes for the rewards, larger Area decorations, other sound targets for each event, a limiter pass and a limiter on the Master bus, loop points in the music, more sound variety, and keyboard close of the settings.
- A music duck during the celebration.
- A smaller top band.
- A difficulty band for random Labyrinths 21 and later. The review listed it as a later item, and the Parent did not choose it.
- A "follow the channel" move rule. The open question of the review stays open for the Parent.
- A mix of the seed in the PRNG. The fixed seed table replaces this fix, and the pinned PRNG outputs of build spec 4.1 stay.
- A restore button for the copy before a reset. The Parent restores by hand.
- Changes to the bump, the slide curve and the wake.

## Further Notes

- The review measured all numbers in this spec at 1920 × 1200 with headless probes, `ffmpeg ebur128`, and the windowed smoke run. The probes are deleted.
- At the new sizes, an Item is 69 % of a tile and the boat is 85 % of a tile long. The review checked no overlap with the islands. The build must look at the screenshots to confirm that the boat stays inside the channel when it turns.
- The Parent must do the manual check of ticket 30 of the labyrinth-game map after this change, because the layout of each Labyrinth changes.
- Time estimate for an agent: part 1 about 1.5 h, part 2 about 2.5 h, part 3 about 3 h, part 4 about 1 h, part 5 about 3 h.
