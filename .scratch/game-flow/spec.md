# Treasure Bay: a game with a start and an end, a locked chest, and a UI polish

Status: ready-for-agent

Sources: [ticket 01](issues/01-opening-and-end-screens.md) and [ticket 02](issues/02-ui-polish.md) of this folder, with their prototypes, and the conversation with the Parent on 2026-11-22. Research: `~/Personal/beat-pals/research/game-ui.md` and `~/Personal/pile-pals/research/native-feel/`. The build spec of the game is [labyrinth-game/spec.md](../labyrinth-game/spec.md). The [play-improvements spec](../play-improvements/spec.md) changed it last.

## Problem Statement

The Child is the Parent's 5-year-old daughter. She cannot read, but she knows numbers well. She plays Treasure Bay every day, and the Parent sees five problems:

1. She gets very angry when she sails onto the chest by mistake before she collects all the Items of a Labyrinth. The Labyrinth then ends, and the Items that she did not collect are lost.
2. After Labyrinth 20, each Goal gives back a Sea friend that she already has. She is annoyed by the duplicates.
3. The game never ends. After Labyrinth 20 the Labyrinths are random and endless. She wants to collect all 20 Sea friends in one session, which takes about 30 minutes, and then she gets bored. The Parent cannot find a natural point to stop.
4. The game has no name, no opening screen and no end screen. It starts in the middle of a Labyrinth.
5. The screen does not look finished. Large Labyrinths are small on the screen and the sides are empty. The background moves all the time. The empty Item outlines are almost invisible. The chest is small and sits half on the coast. The Sea friend appears small at the edge of the screen. The crab sprite leans to one side.

## Solution

The game gets the name **Treasure Bay**. It has an opening screen with the logo and one big start button. One Voyage is 20 Labyrinths, from easy to hard, with new random Labyrinths in each Voyage. At the Goal of Labyrinth 20 a party plays with all 20 Sea friends. After the party the Child goes back to the opening screen, and a new Voyage starts with an empty Collection. So she never gets a duplicate, and the end of a Voyage is a natural point to stop.

The chest has a padlock until the Child collects all the Items of the Labyrinth. A visit to the chest too early does nothing bad: the chest shakes, the empty Item slots blink, and she sails away.

The play screen gets a polish: a larger maze with an Item column at its left, a still background, clear Item slots, a larger chest on its own island, a big Sea friend reveal in the middle of the screen, 20 visible Collection slots, a quiet gear, one font and one style, a soft wake, and an idle hint. The crab gets a new sprite.

## User Stories

### Name, opening screen, start

1. As the Child, I want an opening screen with a picture of a chest on an island, so that I know which game this is.
2. As the Child, I want one big green button with a play triangle, so that I know what to press without words.
3. As the Child, I want any arrow key, Space or Enter to press the button, so that I do not need to find one special key.
4. As the Child, I want the button to move down a little and make a sound when I press it, so that I feel that the press worked.
5. As the Child, I want the screen to fade into my current Labyrinth after the press, so that I continue where I stopped.
6. As the Parent, I want the game name "Treasure Bay" on the opening screen, in the window title and on the app, so that the game has a name that we can say.
7. As the Parent, I want the opening screen at each launch, so that the game does not start the play before my daughter is ready.
8. As the Parent, I want the gear on the opening screen too, so that I can quit or change the volume before she plays.
9. As the Parent, I want my daughter's progress to stay after the rename, so that the new name does not lose her save.

### Voyage: 20 Labyrinths with an end

10. As the Child, I want exactly 20 Labyrinths in one Voyage, so that the game has an end that I can reach.
11. As the Child, I want the Labyrinths to start easy and get harder, so that I learn and do not get stuck.
12. As the Child, I want new Labyrinths in each Voyage, so that the game stays interesting when I play it again.
13. As the Child, I want Labyrinth n to give the same Sea friend as now (crab first, flamingo last), so that I know the order of my friends.
14. As the Child, I want to never get a Sea friend that I already have, so that each Goal feels new.
15. As the Child, I want the 4 Areas in the same order as now, 5 Labyrinths each, so that the trip goes from the lagoon to the sea at night.
16. As the Parent, I want the end of a Voyage to be a natural point to stop, so that I can end the session without a fight.
17. As the Child, I want a new Voyage to start with an empty Collection, so that I can collect all 20 Sea friends again.
18. As the Child, I want my total Item count to stay after a Voyage, so that my big number keeps growing.
19. As the Parent, I want a reset to start a new Voyage with new Labyrinths and to go to the opening screen, so that a reset feels like a new game.
20. As the Parent, I want a save from the current game version to load, so that my daughter does not lose her progress.
21. As the Parent, I want a save that is in Labyrinths 1 to 20 to keep its Labyrinth, its Items and its Collection, so that she continues exactly where she stopped.
22. As the Parent, I want a save that is past Labyrinth 20 to start a new Voyage, so that she does not see duplicates any more.
23. As the Parent, I want the game never to wait at the start of a new Voyage, so that the end of the party and the opening screen stay smooth.

### Padlock on the chest

24. As the Child, I want the chest to show a padlock while Items are still in the Labyrinth, so that I see that the chest is not ready.
25. As the Child, I want nothing bad to happen when I sail to the locked chest, so that I do not lose my Items by mistake.
26. As the Child, I want the locked chest to shake and make a soft locked sound, so that I understand "not yet" without words.
27. As the Child, I want the empty Item slots to blink when I visit the locked chest, so that I see which Items are still missing.
28. As the Child, I want to sail away from the locked chest with one press, so that a wrong visit costs little time.
29. As the Child, I want the padlock to pop off with a sound when I collect the last Item, so that I know that the chest is open now.
30. As the Child, I want the chest to sparkle only when it is open, so that the sparkle means "go to the chest now".
31. As the Child, I want the Goal celebration to start when I reach the open chest, so that the reward comes after all the Items.

### End screen (party)

32. As the Child, I want the Sea friend of Labyrinth 20 to arrive in my Collection first, so that I see my Collection get full.
33. As the Child, I want a party with all 20 Sea friends around the open chest, so that the end of the Voyage feels like a big win.
34. As the Child, I want each Sea friend to pop in with its sound, so that I greet all my friends.
35. As the Child, I want the Sea friends to do a wave, and confetti to fall, so that the party is fun to watch.
36. As the Child, I want a star with the number 20, so that I see that I have all 20 friends.
37. As the Child, I want a key press to end the party and go to the opening screen, so that I decide when the party is over.
38. As the Parent, I want the first seconds of the party to ignore key presses, so that a press from the last move does not skip the party.

### Play screen polish

39. As the Child, I want a large maze, so that I can see the boat, the Items and the chest well.
40. As the Child, I want the boat to keep its size in small Labyrinths, so that it does not look too big.
41. As the Child, I want the Items of the Labyrinth in a column at the left, each in a clear round slot, so that I see what I have and what is still missing.
42. As the Child, I want a collected Item to fill its slot, so that I see my progress.
43. As the Child, I want the water to stay still, so that only the important things move.
44. As the Child, I want a soft foam edge around the islands, so that the coast looks nice and calm.
45. As the Child, I want the islands to keep all their details (sand, grass dots, rocks, bushes), so that the sea still looks like the Kenney sample.
46. As the Child, I want a larger chest on its own small island with a palm, so that I find the Goal at a glance.
47. As the Child, I want the Sea friend to appear large in the middle of the screen, with the maze darker behind it, so that the reward is a big moment.
48. As the Child, I want the Sea friend to flip in, so that it feels like a surprise.
49. As the Child, I want 20 round slots in the Collection strip, so that I see how many friends are still missing.
50. As the Child, I want a shell next to my total count, so that I know what the number counts.
51. As the Child, I want the gear to be small and quiet, so that I do not try to press it.
52. As the Parent, I want the settings panel in the same cream-and-wood style as the logo, with the screen darker behind it, so that it looks like part of the game.
53. As the Child, I want one round font for all numbers and the name, so that the game looks like one thing.
54. As the Child, I want a soft shadow under the boat and the Items, so that they look like they float on the water.
55. As the Child, I want a soft foam wake behind the boat, so that the motion looks smooth.
56. As the Child, I want the chest or the nearest Item to hop when I do not press a key for a while, so that I get a hint where to go.
57. As the Child, I want the hint to stop after a few hops, so that it does not bother me.
58. As the Child, I want circles with space between them, so that the slots look neat.

### Art

59. As the Child, I want a crab that stands straight and is wider than tall, so that it looks like the other Sea friends.
60. As the Parent, I want new art to pass the odd-one-out check on a contact sheet, so that the set stays in one style.

## Implementation Decisions

### General

- Use the glossary words: Labyrinth, Goal, Item, Sea friend, Collection, Area, Child, Parent. Add three terms to the glossary:
  - **Voyage**: the 20 Labyrinths from Labyrinth 1 to the Goal of Labyrinth 20. Each Voyage has its own Labyrinths. Avoid: round, run, game, level.
  - **Opening screen**: the screen with the logo and the start button. Avoid: title screen, menu, home.
  - **Party**: the end screen of a Voyage. Avoid: credits, victory screen.
- Each part below is one slice. The slices can be built in this order: part 1, part 2, part 3, part 4, part 5, part 6. Parts 2, 5 and 6 depend only on part 1 for the tests that use the save.
- The build spec of the labyrinth-game folder gets errata for each changed section. The build updates it in the same change, section by section.

### Part 1: Voyage (Labyrinth plan, Progress, save)

- **Remove the random Labyrinths after Labyrinth 20 and the Sea friends that come back.** Remove from the Labyrinth plan the random size, the rule "is random", and the new random seed. Remove from the Sea friend table the pick of a returning Sea friend. Remove from Progress the random seed and the last returning Sea friend. Remove their tests.
- **The difficulty curve becomes one pure module.** Move the conditions of the play-improvements spec Part 3 out of the seed-search tool into a module that the game and the tool share. Its interface:
  - `meets_conditions(number, seed) -> bool`: the same conditions as now (presses T(n), decisions from d to d + 2, turns, Item on the main path, largest side branch, free dead end).
  - `new_voyage(start_value) -> Array of 20 seeds`: for each slot n, it tries seeds from a start seed upward until `meets_conditions` is true. The start seed of each slot comes from the own PRNG with `start_value`. The second slot of each size never takes the seed of the first slot of that size.
  - Each slot has a maximum number of tries. If a slot finds no seed within it, the slot uses its seed from the fixed seed table. The fixed seed table stays for this, for the save migration, and for the tests.
- The seed-search tool keeps printing the fixed table. It gets a second mode that measures the cost: for each slot, the tries from 1000 random start seeds (largest, median), and the count of different valid seeds for the two 4 × 3 slots. The build runs it and puts the results in the build notes.
- The maximum tries must be at least 3 times the largest measured tries. A new Voyage, all 20 slots, must take 250 ms or less on the Parent's Mac. The build measures it and reports it. If it takes longer, the build reports it before it changes the curve.
- **Progress.** Progress holds the Labyrinth number (1 to 20), the 20 seeds of the Voyage, the collected Items, the Collection, and the total Item count. The Labyrinth plan builds Labyrinth n from the seed of slot n.
- At the Goal of Labyrinth n from 1 to 19, Progress adds the Sea friend of Labyrinth n and goes to Labyrinth n + 1, as now.
- At the Goal of Labyrinth 20, Progress adds the flamingo and then starts a new Voyage: Labyrinth 1, new seeds, no collected Items, an empty Collection. The total Item count stays. The game saves this new progress before the celebration starts, as it does now at each Goal. The Party shows all 20 Sea friends, so it needs no saved data.
- **Reset.** A Parent reset starts a new Voyage with new seeds, an empty Collection and a total of 0. The copy before a reset stays as it is. After a reset the game shows the opening screen.
- **Save version 2.** The save holds `version` 2, `labyrinth`, `seeds` (20 positive integers), `collected_items`, `collection`, and `total_items`. A save with a `seeds` list of another length, or with a seed of 0 or less, is broken, like the other broken saves.
- **Migration from version 1 to version 2**, added to the migration chain:
  - `labyrinth` 1 to 20: `seeds` becomes the fixed seed table, so the Labyrinth and its Items stay the same. The other fields stay. `random_seed` and `last_returning_friend` go away.
  - `labyrinth` above 20: a new Voyage. `labyrinth` becomes 1, `seeds` become a new Voyage, `collected_items` and `collection` become empty, and `total_items` stays.
- **Fresh progress** stays: Labyrinth 1, an empty Collection, and a total of 0.
- **Areas, sizes, Item counts and Sea friends** stay as they are for Labyrinths 1 to 20.

### Part 2: Padlock on the chest (Goal rules, Labyrinth view, Item column)

- The chest is locked while at least one Item of the Labyrinth is not collected. Each Labyrinth has 2 Items or more, so each Labyrinth starts with a locked chest.
- The move rule does not change. The boat still stops on the Goal square.
- **Arrival at a locked chest:**
  - The chest shakes sideways: offsets 0, −10, 8, −6, 4, −2, 0 px of the 130 px prototype tile, over 360 ms, linear (pile-pals soft shake).
  - A soft "locked" sound plays. The build picks a CC0 sound, for example a short wooden knock or a lock rattle, with the same steps and the same level rules as the other effects. Credits get the new line.
  - Each empty Item slot in the Item column pulses two times: scale 1.0 to 1.15 and back, 300 ms each. The slots do not flash.
  - The input stays free. One press in the open direction of the Goal square takes the boat away.
  - The game does not save on this arrival, because nothing changes.
- **The last Item:** when the Item arrives in its slot, the padlock pops off: it grows to 1.3 times its size and fades out in 300 ms, with 6 sparkles. An "unlock" sound plays. The chest sparkle of the build spec starts only now.
- **Arrival at the open chest** starts the Goal celebration of the build spec, as now.
- **Load with all Items collected:** the chest starts open with its sparkle and no padlock.
- **Padlock art:** a padlock sprite in the style of the Sea friends. It sits on the front of the chest. See part 6 for the art steps.

### Part 3: Name and opening screen

- **Name:** "Treasure Bay". It goes into the project name, the window title, and the app that the app tool builds (the app name and the folder name).
- **Keep the save:** the save folder depends on the project name. Set a custom user folder with the old name "Labyrinth", so that the rename does not move the save. A test checks that the user folder name stays "Labyrinth".
- **Font:** one rounded font with the SIL Open Font License, for example Fredoka. Put its licence file in the repo and its line in the credits. Use it for the title, the total count, and the star number of the Party.
- **The opening screen** is variant B of the second prototype round (ticket 01). From the top to the bottom:
  - The water of Area 1, still.
  - The title "Treasure Bay" in an arc over the island. Draw each letter on the arc with the advance width of the font, so that the gaps are even. Fill `#ffe07a`, outline `#7a4a24`.
  - An island made from the Kenney tiles with the island rules of the game: an all-land block of 4 × 3 Labyrinth tiles, so that it has a sand coast and a grass top.
  - The closed chest in the middle of the island, about 22 % of the screen height, with the chest sparkle. No padlock.
  - Four Items on the island (spiral shell, starfish, pearl, coral) that bob 2 px.
  - A wide button under the island: a pill of about 560 × 160 px at a height of 1200 px, fill `#5ccf6a`, a white border of 8 px, a bottom edge of `#2f8f3c`, and a white play triangle. It pulses gently: scale 1.0 to 1.06 and back in 1.6 s.
  - The quiet gear of part 5.
  - The music of Area 1.
- **Start:** the opening screen shows at each launch and after each Parent reset. Any arrow key, Space or Enter presses the button. Add one input action for Space and Enter. It acts only on the opening screen and on the Party. The arrow keys keep their actions.
- On the press: the button scales to 0.86 and back in 140 ms, the Item sound plays, the screen fades to dark in 0.8 s, and the current Labyrinth fades in as the build spec does now at launch. Input is locked from the press until the end of the fade-in.
- A mouse click on the button also starts the game. The settings rules stay: while the settings panel is open, the button does nothing.

### Part 4: End screen (Party)

- **The Party** is variant B of the first prototype round (ticket 01). It follows the Goal celebration of Labyrinth 20: the flamingo arrives in its slot as usual, and then the screen fades to the Party.
- **Picture:** the water of Area 1, an island in the middle made with the island rules (like the opening screen), and the open chest on it. The boat sits below the island, with its bow up.
- **Timeline (from the start of the Party):**
  - 0 to 2.4 s: the 20 Sea friends pop in one by one, every 120 ms, on an ellipse around the island, in Labyrinth order, with the gap at the bottom for the boat. Each one plays its own sound or the splash.
  - 0.4 s: the chest opens with the Goal sound, confetti bursts over it, and 8 Items fly out of the chest onto the island.
  - 3.0 s: the star of the Items folder appears over the chest, with the number 20 in the rounded font.
  - From 3.0 s: the Sea friends do a wave: each one hops up to 40 px of the 760 px HUD scale, with a phase delay along the ring. The wave loops.
  - From 2.0 s: a small confetti burst every 1.5 s at a random place. Each burst follows the confetti rules of the build spec.
- The Party loops until a key press. This is the Parent's choice: a loop. The 5 s version with a still Collection (beat-pals rule C18) is not built.
- **Input:** locked for the first 3.0 s. After that, any arrow key, Space or Enter fades to the opening screen. The new Voyage of part 1 is already saved.
- **Launch during a Party:** the save already holds the new Voyage, so the next launch shows the opening screen and Labyrinth 1. The Party does not play again.
- The settings gear works on the Party.

### Part 5: Play screen polish (screen layout, water, foam, HUD, settings)

- **Layout (fix 1).** The top band goes away. All HUD values use the HUD scale h = visible height / 760.
  - The Item column is 100 h wide, at the left. The margin is 12 h.
  - The Labyrinth area is the space right of the Item column and above the Collection strip, less the margin on each side. The Labyrinth is centred in it.
  - The tile size is the largest that fits, with a cap of 121 px at a height of 1200 px (121 × visible height / 1200). The cap is the Area 1 tile of the game now. So small Labyrinths keep their size, and large Labyrinths grow: Labyrinth 18 goes from about 65 px to about 80 px.
  - The Labyrinth width counts one tile more for the Goal island of fix 4.
  - The boat stays 85 % of a tile long, and an Item stays 69 % of a tile (play-improvements spec). Ticket 08 of that spec checked that the boat stays in the channel when it turns.
- **Item slots (fix 3).** Each Item has a slot in the Item column: a disc with fill white at 22 % and an outline of 3 px in white at 85 %. The contrast of the outline against the water must be 3:1 or more in all 4 Areas (beat-pals rule C7).
  - The disc diameter is min(120 px, (free height − (count − 1) × 16 px) / count), at 1200 px. So the gap between two slots is at least 16 px. With 8 Items the disc is about 117 px.
  - The slots are centred as a group in the free height.
  - An empty slot shows the Item sprite grey and light at 35 %, as now. A collected Item fills its slot, with the bounce of the build spec.
- **Water (fix 2).** Remove the light patterns of the water. The wave lines stay but do not move. Nothing in the background moves (beat-pals rules C14 and C15).
- **Foam (fix 2).** Replace the moving dashed foam with a still soft edge along each coast: a white line of 6 px at 35 % with soft edges, under the islands. Use the coast lines that the game already computes.
- **Goal island (fix 4).** The tile right of the Goal island tile, outside the Labyrinth, becomes island too. So the Goal island is 2 tiles wide and gets a sand coast all around. No rock and no bush on these 2 tiles.
  - The chest sits on the seam of the 2 tiles, 115 % of a tile wide, fully on land.
  - The palm sits on the outer tile, up and to the right of the chest, inside the coast.
  - The padlock of part 2 is on the chest.
- **Collection strip (fix 6).** The strip keeps its height. It shows 20 slots: a disc with fill white at 14 % and an outline of 2 px in white at 45 %. Each Sea friend shows in its slot as now.
  - The gap between two slots is at least 12 px, and the first and the last slot are at least 24 px from the screen edges.
  - The total Item count sits at the left in the rounded font, with an outline, and a spiral shell icon on its left.
- **Gear (fix 7).** 48 px, 40 % opacity, its centre 40 px from the top and the right edges. It must not overlap the Labyrinth.
- **Settings panel (fix 7).** The screen behind the panel gets darker: black at 50 %. The panel fill is `#fff3d6`, with a border of 10 px in `#7a4a24` and a corner radius of 40 px. The buttons are `#e9c98f` with a bottom edge of `#b58a4a`, and the icons are `#5a3416`. The volume bars and the hold rings work as now. The reset ring stays `#ff7a59`, and the hold times stay.
- **One style (fix 8).** One font (part 3). One outline width for HUD discs (fix 3, fix 6). Light from the top left. The boat and each Item on the water get a static shadow: an ellipse 80 % of the sprite wide and 22 % high, black at 20 %, 28 % of the sprite below its centre and a little to the right. The shadow of the boat moves with the boat. No shadow in the Item column or in the strip.
- **Wake (fix 9).** Replace the ellipse rings with soft white dots behind the stern: radius from 9 % of a tile, smaller and fainter with age, start opacity 42 %, life 0.6 s, a new dot every 40 ms while the boat moves. The dots stay under the islands, as the rings do now.
- **Idle hint (fix 10).** If the Child presses no key for 6 s while the play is free (no move, no lock, settings closed), the target hops one time: up by 12 % of a tile, with a small squash, in 350 ms. The target is the open chest, or else the uncollected Item with the shortest path from the boat. The hop repeats after each further 6 s, at most 3 times. A key press starts the count again. The 6 s value is a starting point. The Parent can ask to tune it.

### Part 6: Sea friend reveal and art

- **Reveal (fix 5).** At 1.4 s of the Goal celebration:
  - The screen gets darker: black at 55 % in 250 ms. The Collection strip stays above the dark layer, so the slot stays visible.
  - A soft light disc appears in the middle of the Labyrinth area.
  - The Sea friend flips in at the middle of the Labyrinth area. The flip has two halves of 140 ms: the horizontal scale goes from 0 to full with an ease-out. At the same time it grows from 50 % to 108 % and settles at 100 %. Its full size is 35 % of the visible height.
  - Its sound plays, as now.
  - The wiggle stays, with a smaller angle of 0.08 rad.
  - At 3.0 s it flies to its slot, as now. The dark layer fades out during the flight.
  - The other times of the celebration stay.
- **Crab.** Generate the crab again with the xAI image pipeline of the labyrinth-game art prototype, with its style prompt: front view, symmetric, both claws at the same height, wider than tall. Normalize it like the other Sea friends (trim, pad, 512 px on the long side).
- **Padlock.** Generate the padlock with the same pipeline and style: a small golden padlock, front view.
- **Check.** Put both on a contact sheet next to the existing set, for the odd-one-out check (pile-pals rule 15). The Parent approves both before they replace or join the assets.
- The app icon uses the crab, so the new crab also becomes the new app icon.

## Testing Decisions

### What makes a good test here

- A test checks what the Child or the Parent can see or do: the screen that shows, the slot that fills, the Sea friend that joins the strip, the save that loads. It does not check private fields or the order of internal calls.
- The tests are deterministic. A random Voyage uses a fixed `start_value` in the tests.
- The tests run in the existing headless runner. The screenshots need a window and are for the Parent check, not for the test suite.

### Seams

1. **The main scene with key presses.** This is the highest seam and the main one. The existing helpers add the main scene to the tree, press keys, and wait for moves. Prior art: the main-scene tests for rewards, save, look, and motion. New tests at this seam:
   - At launch the opening screen shows and the Labyrinth does not take arrow presses. An arrow press, Space, or Enter starts the current Labyrinth.
   - The boat on the Goal square with an Item still uncollected: no Goal celebration, no new Sea friend, the progress does not change, and the empty slots pulse. After the last Item, a visit to the chest starts the celebration.
   - The Goal of Labyrinth 20: the flamingo joins the strip, the Party shows, presses in the first 3 s do nothing, a press after that shows the opening screen, and the next start shows Labyrinth 1 with an empty strip and the same total count.
   - A Parent reset shows the opening screen with a new Voyage.
   - A launch from a version 1 save past Labyrinth 20 shows the opening screen, then Labyrinth 1 with an empty strip.
2. **Pure modules.** Prior art: the tests for the fixed seeds, the progress, the save, and the screen layout.
   - The difficulty curve: each seed of `new_voyage` meets the conditions of its slot. Two calls with the same `start_value` give the same seeds. Two different values give different Voyages. The second slot of a size never repeats the first. A slot with no seed in its tries uses the fixed seed.
   - Progress: the Goal of Labyrinth 20 gives a new Voyage with an empty Collection and the same total. A reset gives fresh progress.
   - The save: version 2 writes and loads. A version 1 save in Labyrinths 1 to 20 keeps its Labyrinth, its Items and its Collection. A version 1 save past Labyrinth 20 becomes a new Voyage. A `seeds` list of the wrong length is broken.
   - The screen layout: the tile cap, the Item column, the slot gaps (16 px in the column with 8 Items, 12 px in the strip, 24 px from the edges), and the gear outside the Labyrinth, at 1920 × 1200 and at 1512 × 982.
   - The project settings: the user folder name stays "Labyrinth".
3. **The Python port** keeps pinning the fixed seed table and the Item IDs of Labyrinths 1 to 20. It is still the source for the migration and the fallback seeds.

### Tests to delete

- The tests of the random Labyrinths after Labyrinth 20 and of the Sea friends that come back. They test removed behaviour.

### Screenshots for the Parent

- The screenshot tools add: the opening screen, the Party at about 4 s, a locked chest during its shake, the open chest after the padlock pops, and the reveal at about 1.8 s. The play shots of all 4 Areas and the settings shot are taken again.
- The build looks at each shot and reports: the slot gaps, the chest fully on land, the boat inside the channel, and the contrast of the slot outlines.

## Out of Scope

- A time limit or a session limit in the game (ticket 17 of the labyrinth-game map stays).
- New Sea friends, golden Sea friends, or a counter of duplicates.
- The 5 s Party with a still Collection.
- A reduced-motion setting.
- Touch input or mouse play in the Labyrinth.
- New Areas or a new Area order.
- A logo image from xAI. The logo is the Kenney island, the chest sprite, and the title in the font.
- A restore button for the copy before a reset.
- Changes to the move rule, the bump, the slide curve, the sound levels, or the Item placement rules.

## Further Notes

- The Child's save is past Labyrinth 20 now, so after this change she starts a new Voyage at Labyrinth 1 with an empty Collection. Her total Item count stays. The Parent accepted this on 2026-11-22.
- The opening screen, the padlock, the Party, and the layout come from the prototypes of tickets 01 and 02. The real-game layout shots of ticket 02 show fixes 1, 2, 3, 6 and 7 with the real art.
- The Parent must do the manual check of ticket 30 of the labyrinth-game map after this change, because the layout and the flow change.
- Time estimate for an agent: part 1 about 4 h, part 2 about 2 h, part 3 about 3 h, part 4 about 2.5 h, part 5 about 5 h, part 6 about 2 h, plus the Parent check of the art.
