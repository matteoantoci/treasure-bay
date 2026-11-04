# 30: Parent manual check

**What to build:** The Parent plays the game on the Mac and confirms the parts that only a person can test. Spec sections 11.4, 14.3, 15.

**Blocked by:** 28 (Final check, agent part)

**Status:** ready-for-human

- [ ] The Parent does the manual key test of spec 11.4, and the results are recorded.
- [ ] The Parent completes the manual checklist of spec 14.3.
- [ ] The Parent confirms each criterion that ticket 28 listed as needing a person.

## Comments

**From ticket 28 (agent final check, 2026-11-04).** These criteria of spec 15 need a person. The agent tested all other parts. Do these steps on the Parent's Mac. Record each result in the build report.

NOTE: Do these steps after the Goal fix. The Goal fix changes the shape of each Labyrinth.

1. Criterion 1 (spec 14.3 item 1):
   - Start the game with `./play`.
   - Make sure that the game fills the full screen.
   - Make sure that the Dock and the menu bar do not show.
   - Make sure that the game shows the saved Labyrinth.
   - Make sure that no start screen shows.
2. Criterion 8 (spec 14.3 item 5):
   - Sail the boat to an Item.
   - Make sure that the Item becomes large and that you hear the pop sound.
   - Make sure that the Item moves to its outline at the top.
   - Make sure that the outline fills.
   - Make sure that the boat can get to each Item before it gets to the Goal.
3. Criterion 9 (spec 14.3 items 5 and 6):
   - Sail the boat to the Goal.
   - Make sure that the chest opens.
   - Make sure that the boat jumps 2 times and that confetti falls.
   - Make sure that you hear the fanfare.
   - Make sure that the Sea friend comes with its sound.
   - Make sure that the Sea friend moves to its slot in the strip at the bottom.
   - Make sure that the next Labyrinth starts without an action from you.
   - The agent moved the Sea friend to the right side of the Goal island. Thus the open chest and the boat stay visible. The palm is behind the Sea friend for approximately 2 seconds. Accept or reject this position.
4. Criterion 11 (spec 14.3 items 7 and 8):
   - Look at each Area: Labyrinths 1 to 5, 6 to 10, 11 to 15, and 16 to 20.
   - Make sure that each Area has its colours, Items, decoration, and music.
   - At the start of Labyrinth 6, make sure that the first Item of the Area shows large in the centre.
   - Make sure that this Item then goes away.
   - Make sure that you cannot hear a jump when the music starts again.
   - Make sure that the music changes smoothly when the Area changes.
5. Criterion 12 (spec 14.3 items 3 and 4):
   - Make sure that the water moves.
   - Make sure that the foam moves along the coasts.
   - Make sure that the boat makes a wake with a V shape.
   - Make sure that the boat rocks when it does not move.
   - Make sure that the sprite edges are smooth on light water (Area 1) and on dark water (Area 4).
   - Make sure that the dark outline of each sprite is complete.
6. Criterion 16 (spec 14.3 item 9):
   - Click the gear with the mouse.
   - Make sure that the settings show.
   - Push an arrow key. Make sure that the boat does not move.
   - Push the minus and plus buttons of the music and of the effects.
   - Make sure that the music and the effects change separately.
   - Make sure that step 0 gives no sound.
   - Stop the game with the door button. Start the game again with `./play`.
   - Make sure that the volume steps did not change.
   - Do a reset. Make sure that the volume steps did not change.
7. Criterion 17 (spec 14.3 item 10):
   - Hold the reset button (circular arrow) for less than 3 seconds.
   - Make sure that nothing occurs.
   - Hold the reset button for 3 seconds.
   - Make sure that Labyrinth 1 starts, that the strip is empty, and that the count is 0.
8. Criterion 18 (spec 14.3 items 10 and 11, spec 11.4):
   - Hold the door button for less than 3 seconds.
   - Make sure that nothing occurs.
   - Hold the door button for 3 seconds.
   - Make sure that the game saves and stops.
   - Start the game again with `./play`.
   - Push Cmd+Q. Make sure that the game does not stop.
   - Try to close the window. Make sure that the game does not stop.
9. Criterion 19 (spec 14.3 item 12):
   - Collect one Item.
   - Stop the game with the door button.
   - Start the game with `./play`.
   - Make sure that the same Labyrinth shows.
   - Make sure that the same Items are collected.
   - Make sure that the strip and the count did not change.
10. Criterion 21 (spec 14.3 item 13):
    - Set the Wi-Fi to off.
    - Start the game with `./play`.
    - Make sure that the game starts and that you can play.
11. Criterion 24 (spec 14.3 item 2, spec 11.4):
    - Do the key test of spec 11.4 for each key.
    - In the build report, write the result of each key in a table: blocked, not blocked, or other effect.
    - In the build report, write the result of each item of spec 14.3.
