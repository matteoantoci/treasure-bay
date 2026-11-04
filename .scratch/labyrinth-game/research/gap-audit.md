# Gap audit before the spec

Date: 2026-11-03. Ticket: [19 Gaps before the spec](../issues/19-gaps-before-the-spec.md).

`spec.md` does not exist yet. Sources read: `map.md`, tickets 01 to 18, research (`sounds.md` final list, `godot4-facts.md`, `tech-stack.md`, `graphics.md`), `GLOSSARY.md`, the motion and movement prototype code, round-3 listening data, sprite `PROVENANCE.md`, and the skills `godot-audio`, `godot-gdscript-headless-testing`, `save-systems`, `audio-design`. I also looked at the Kenney tiles and the boat sprite.

Main result: ticket 13 replaced the emoji art, but nobody re-decided the Area look. Ticket 08's table is provisional. The Collection is a screen in ticket 04 and a bottom strip in ticket 11. Many other gaps are prototype-code facts that no ticket states.

Not checked: no audio listened to, no Freesound or Pixabay download, no Godot run. I identified the Kenney tiles only by eye, because the repo has no Kenney tile list.

## Open gaps (ranked)

**Must-decide by the Parent**
1. **Items for Areas 2 to 4** (blocks §7 Areas, §13 assets). Only the 3 Area 1 sprites exist (`13:68`). Ticket 08's Items are provisional (`08:42`), and "Tropical fish" clashes with the Fish Sea friend, a clownfish (`PROVENANCE.md:22`; rule `13:21`). Recommend: Area 2 Coral + a non-animal Item (for example sand dollar), Area 3 Gem stone + Spiral shell, Area 4 Glowing star + Star. Generate them with the Grok method on the Parent's xAI quota (`13:69`).
2. **Area colours in the Kenney look** (§7). Ticket 13 says they must change (`13:76`); no ticket gives new values. Recommend: the water colour pairs from `motion-PROTOTYPE/index.html:22`: `#3fb4d8/#7fd8ef`, `#2aa6a0/#76d6c4`, `#1f6fb5/#5aa0dc`, `#14284f/#3a5a92`. Islands are not tinted (`08:33`).
3. **Area decoration** (§7). The emoji decorations in `08:37-40` are obsolete, and nothing replaced them. Recommend: the same ideas, made with the shader and particles: Area 1 waves, Area 2 rising bubbles, Area 3 droplets, Area 4 small stars that twinkle.
4. **Collection: screen or strip** (§6, §10). Ticket 04 says "a screen with pictures only" plus the total Item count (`04:32-34`). Ticket 11 has the Sea friend fly to a strip at the bottom (`11:52,84`). Ticket 18's layout has no strip (`18:12`). No source says how the Child opens a screen with the keys. Recommend: the bottom strip is the Collection, with the total Item count as a number at its left end. No separate screen.
5. **Goal island and wall islands** (§7). Ticket 13 puts "some palms" on the wall islands (`13:65`). In the prototype, only the Goal island has the palm (`motion-PROTOTYPE:131`, `11:79`). Recommend: only the Goal island gets a palm (by eye, `tile_71` or `tile_72`). Wall islands get rocks and bushes.
6. **Who downloads the sound files** (§13). Freesound needs an account for the originals (`sounds.md:89`). It is not known whether Pixabay needs a login (`sounds.md:90`). That is 18 Freesound files and 4 Pixabay files. Recommend: the Parent logs in once in their own Chrome, and the agent downloads through it.
7. **If the manual key test fails** (§11). Ctrl+Cmd+F is not known (`godot4-facts.md:79`). A macOS logout is blocked while the game runs (`godot4-facts.md:91`). Recommend: accept Cmd+Tab, Cmd+H, Cmd+M, and Cmd+Option+Esc as not blockable. If Ctrl+Cmd+F leaves fullscreen, the game sets exclusive fullscreen again (this API is not traced in any source). The Parent quits with the door button before a logout.

**Agent-decidable defaults**

*§3 Platform and project setup*
8. **Window mode.** `display/window/size/mode=4` (exclusive) (`godot4-facts.md:72`, `tech-stack.md:203`). Ticket 01 says only "native fullscreen window" (`01:36`).
9. **Project name**, which sets the save folder `<game name>` (`09:26`). Recommend "Labyrinth".
10. **Repo layout.** The project is at the repo root, because `./play` runs `godot --path .`. Assets go under `res://assets/{kenney,sprites/friends,sprites/items,audio/music,audio/effects,audio/friends}`. `credits.txt` goes at the root.
11. **`./play` and the version check.** The spec must check `godot --version` (`tech-stack.md:242`), but no source says what happens on a mismatch. Recommend: print a warning and continue.

*§4 Labyrinths*
12. **Grid shape.** The movement prototype uses thin walls between squares (`movement-PROTOTYPE:38-53`). The motion prototype treats each square as island or water (`motion-PROTOTYPE:36-38`). No source maps the Kenney tiles to walls. Recommend: generate a W × H thin-wall Labyrinth, then draw a (2W+1) × (2H+1) tile grid. Squares and opened walls are water. All other tiles are island, made from the 31 tiles in `style-target/assets/kenney/tiles`.
13. **Start and Goal squares.** Start top-left (0,0). The Goal is bottom-right (W-1,H-1), as in both prototypes (`movement-PROTOTYPE:65,123`). The boat stops on the Goal square. The Goal island is on the border tile next to it, like the "dock" in `motion-PROTOTYPE:42`.
14. **PRNG.** xorshift32 with `& 0xFFFFFFFF` (`tech-stack.md:225`). Replace seed 0, because xorshift32 stays at 0. A test pins the first outputs.
15. **The 20 fixed seed values.** No source gives them. Use the constants 1 to 20, pinned by a test.
16. **Seed for random Labyrinths after 20.** Take it from Godot `randi()` after `randomize()`, and save it. Generate only with our own PRNG.
17. **Size steps.** "+1 column or row every 2 Labyrinths" gives only 9 steps in 20 Labyrinths, so Labyrinth 20 is not 10 × 7 (`05:28` against `05:27`). Table:
    - 1-2: 4×3; 3-4: 5×3; 5-6: 5×4; 7-8: 6×4; 9-10: 7×4
    - 11-12: 7×5; 13-14: 8×5; 15-16: 8×6; 17-18: 9×6; 19-20: 9×7
    - Random Labyrinths: 10×7.
18. **Item count rounding.** `clamp(floor(W*H/6), 2, 8)`.
19. **Item placement** (`05:31` says only "at least one in a dead end"). Never on the start or the Goal. One Item per square. The first Item goes in the dead end farthest from the start. The PRNG places the rest, with dead ends first. Item kinds cycle in the Area's list order.
20. **Which Sea friend belongs to which Labyrinth.** Use the list order in `05:35`. Then the low-contrast whale lands in light Area 1 and the near-white swan in dark Area 4 (`13:70`).

*§5 Movement and input*
21. **Stop at a bend.** The ticket text names only junction, dead end, and Goal (`03:30`). Both prototypes also stop where the boat cannot go straight on (`movement-PROTOTYPE:138`, `motion-PROTOTYPE:58`). Follow the prototypes.
22. **Turning.** The boat turns at once, also before a bump (`motion-PROTOTYPE:56`). At rotation 0 the bow points down (seen in `boat_white_sail.png`).
23. **Key presses during a lock.** Drop presses from the Goal to the end of the fade-in. No lock while an Item flies (`motion-PROTOTYPE:60-64`).
24. **Key map.** Only 4 arrow actions. No game code is bound to `ui_cancel` (Esc).

*§8 Motion*
25. **New Area: when input unlocks.** The new-Area Item runs 1.4 s, but the fade-in is 500 ms (`11:71` against `11:85`). The prototype waits 900 ms before the fade-in (`motion-PROTOTYPE:93`). The Item starts with the fade-in. Input unlocks when the fade-in ends.
26. **Launch and reset.** A 500 ms fade-in from dark, with no Area sign.
27. **Pixel values.** The ticket 11 values are for a 130 px square (`11:73`). Scale Labyrinth values by square size ÷ 130. Scale the HUD by 1200 ÷ 760.

*§10 Screen layout and HUD*
28. **Margins and gear.** From the prototype proportions at 1200 px height: a top band of about 237 px and a bottom strip of about 110 px. The Labyrinth fits between them. Gear 64 px.
29. **Collection strip with 20 friends.** The prototype spacing overflows: 60 + 19 × 48 = 972 px on a 960 px canvas (`motion-PROTOTYPE:86`). Spacing = strip width ÷ 20.

*§6 Items, Goal, Collection*
30. **Returning Sea friend after Labyrinth 20.** It flies to its own slot. The strip does not grow. Save `last_returning_friend`, so the "never two times in a row" rule survives a restart.

*§12 Saved progress*
31. **Save details.**
    - `version` 1. Item IDs are `"x,y"` strings. Collection entries are sprite file names.
    - The boat position is not saved, so the boat restarts at the start square.
    - At the Goal, save before the celebration, with the friend added and the index moved on.
    - A newer `version` counts as broken. An old `save.bak` is overwritten.

*§11 Settings and Parent controls*
32. **Volume buttons.** − and + for each bus, 5 steps from 0 to 1, with `set_bus_volume_linear(v²)` (`sounds.md:106`). Step 0 is mute. Music starts at 0.5 and effects at 0.75. Volumes go in `user://settings.json`, so a progress reset keeps them.
33. **Settings panel.**
    - Play pauses while the panel is open. A click on the gear closes it.
    - A ring fills during the 3 s hold. A release before 3 s cancels.
    - Quit saves, then calls `get_tree().quit()`.
    - The mouse pointer stays visible.
34. **Manual key list.** `map.md:44-48` leaves out Cmd+W, Cmd+Option+H, Globe+F, Cmd+Space, Mission Control, Ctrl+Cmd+Q, and Cmd+Shift+3/4/5 (`godot4-facts.md:101-108`). Test them all.

*§9 Sound*
35. **Loudness targets.** −18 LUFS and true peak ≤ −1 dBTP for effects and Sea friend sounds (`audio-design SKILL.md:38-41`). Music 6 dB lower. The 6 dB is the agent's own value.
36. **Music crossfade length and start.** 1.5 s, the skill default (`godot-audio SKILL.md:74`). Start it 1.5 s before the end, after a cut of each track's own fade-out. The Area change uses the same crossfade.
37. **Fanfare fade.** Cut it into the file with ffmpeg: `afade=t=out:st=3.2:d=0.5`.
38. **When the Sea friend sound plays.** When the friend appears (1.4 s). Its own sound replaces the splash. The new-Area Item plays no pop.
39. **Clip times against the originals** (`12:37`). No method is given. Line the preview up with the original file by cross-correlation, then cut.

*§7 Areas and look*
40. **Water details.** Neither ticket gives values for the light patterns (`13:56`). Foam follows whole coastlines, not a ring around each one-square island. The V-shaped wake (`13:58`) is made from the rings in `11:81`.

*§13 Asset acquisition*
41. **`credits.txt`.** No source gives its location or art credits. Put it at the repo root, with the Kenney line (`sounds.md:156`) and the xAI terms note (`PROVENANCE.md:43`).

## Conflicts (the later source wins)
1. **Fanfare.** `11:87` "Use the 3.8 s fanfare alternative" against `12:61` "Effects: the 5 first picks." The first pick is Success Fanfare Trumpets, 4.4 s (`sounds.md:49`). **12 wins:** keep Trumpets, and fade it out from 3.2 s to 3.7 s by the rule in `11:87`.
2. **Celebration length.** `04:33` "about 3 seconds" against `11:87` "runs from 0 to 3.7 s", with the fade at 4.2 s (`11:85`). **11 wins.**
3. **Sea friend sounds.** `10:39` and `map.md:31` "15 Sea friends… Shark, Lobster, Shrimp, Oyster, and Turtle use the splash" against `12:62-63`: 13 own sounds and 7 splashes. **12 wins.**
4. **Music.** `06:24` "calm music loop" and `10:37` (Under the Sea, Midnight Reef Sleep, CC0 fallbacks) against `12:36,60`: "must be joyful", Fairy Land and Cloud of Dreams, fallbacks rejected. **12 wins.**
5. **Draft `credits.txt`.** `sounds.md:126-129,141-153` lists the old music, Suction Cup, Thar'she blows, Diving with whales, Inflating Balloon, and Cartoon Wobble. It does not list claretcanelon, Smoochy Squeak, or megmcduffee. The Final list is `sounds.md:182-185`. **The Final list wins.**
6. **Where the volume buttons are.** `06:27` "buttons on the screen" against `16:14` "The settings hold the volume buttons". **16 wins.**
7. **Area Items and colours.** `08:35-40` (emoji Items and colours) against `13:68,76` (Area 1: spiral shell, starfish, pearl; the colours must change). **13 wins for Area 1.** Areas 2 to 4 stay open (gaps 1 to 3).
8. **Goal and boat art.** `08:33` "sailboat… desert island" (emoji) against `13:20` "No emoji remain" and `13:66` `boat_white_sail.png`. **13 wins.**
9. **Collection.** `04:32,34` "a screen with pictures only" against `11:52,84` "flies to the Collection strip at the bottom". **11 wins on the motion.** Whether the screen still exists is gap 4.
10. **Wake and water.** `13:56,58` "light patterns… V-shaped wake and small ripples" against `11:49,80-81` (rings, waves). Ticket 11 says it decides "their amounts" (`11:32`). **Both apply:** 13 gives the shape, and 11 gives the amounts.
11. **Palms.** `13:65` "some palms" on the wall islands against the palm on the Goal only (`11:79`, `motion-PROTOTYPE:131`). **11 wins for now.** Gap 5 asks the Parent.
12. **Bump.** `movement-PROTOTYPE:110-111` (14 px of a 110 px square, 90 ms out, 120 ms back) against `motion-PROTOTYPE:62` (0.12 square, 70 ms out, 110 ms back). **Ticket 11's prototype wins.** Neither prototype has the "shake" from `03:31`.
13. **Move tween.** `movement-PROTOTYPE:118-119` (one 180 ms ease-out tween for each square) against `motion-PROTOTYPE:61` (one tween of 180 ms × n squares). **Ticket 11's prototype wins.**
14. **Reaching the Goal.** `movement-PROTOTYPE:123` (the boat enters the Goal square) and `GLOSSARY.md:12` ("The square… the Child must reach") against `motion-PROTOTYPE:42,64` (the boat stops at a dock square next to the Goal island). **Combined in gap 13:** the Goal is a square, and the island is drawn next to it.
15. **New-Area sign.** The prototype shows the Area number (`motion-PROTOTYPE:92,118`) against the Answer in `11:71` (the first Item, big). **The Answer wins.**
16. **Area-start timing.** `11:71` "plays while the screen fades in" (1.4 s) against `11:85` (500 ms fade-in, input locked until it ends) and `motion-PROTOTYPE:93` (900 ms delay). **The ticket text wins** (gap 25).
17. **`save.bak`.** `09:29` "A broken file: rename it to save.bak" against `save-systems SKILL.md:86-91` (keep the last good save as `.bak` and load it as a fallback). **The ticket wins.**
18. **Random Labyrinth size.** `05:27` "at the largest size" against `05:28`: the step rule does not reach 10 × 7 in 20 Labyrinths. **The "later wins" rule does not resolve it.** See gap 17.
19. **Tile size.** `graphics.md:70` "64×64 tiles" against the repo tiles, which are all 128 × 128. The repo files are the fact.

## Stale text
- `map.md`:
  - `25`: "the Items are … sprites in `prototypes/art-PROTOTYPE/sprites/`". Only the Area 1 Items exist.
  - `28`: "a new Sea friend joins" is not true after Labyrinth 20 (ticket 15).
  - `30`: "calm music".
  - `31`: "CC0 backups… 15 Sea friends… other 5".
  - `33`: "The exact colours and Items change with 13", but no ticket changed them.
  - `42-51`: the key facts and the decided reset are still under "Not yet specified". The key list does not include Cmd+W and other keys.
- Ticket 02: `19` (emoji context), `23-24` ("items are shells and fish", "blue walls on a light floor").
- Ticket 03: `22-26` (context: emoji, flip the sailboat), `30` ("item rule is still open in 04").
- Ticket 04: `24` (Fluent reward images), `33` ("about 3 seconds"), `34` ("stays in the map fog item Saved progress").
- Ticket 05: `21` ("cell at or below about 128 px, so the 256 px emoji stay sharp"), `35` ("each Fluent Emoji 3D PNG link returns HTTP 200").
- Ticket 06: `24` ("calm"), `27` ("buttons on the screen").
- Ticket 08: `23` (Fluent context), `33` ("desert island"), `35-42` (provisional table), `43` (emoji links HTTP 200), `45` ("Random Labyrinths after Labyrinth 20 are not decided here").
- Ticket 10: `37-40` (old music, the 15/5 split, "Nobody listened to the files yet").
- Ticket 11: `12` ("emoji images"), `30` ("Fade it out at 3 s, or use the 3.8 s alternative"), `87` (3.8 s alternative).
- `research/sounds.md`:
  - `9-11` (Recommendation: 15 own sounds).
  - `14` and `175` ("Areas are not decided yet / placeholders").
  - `52` and `176` (fade the fanfare at 3 s).
  - `111-154` (draft `credits.txt`).
  - `168-170` ("I did not listen to any file", trim times not found).
- `research/graphics.md`: `5-21` (Fluent recommendation), `136` (flip the sailboat), `138` (128-point limit).
- `research/tech-stack.md:1-176`: the first TypeScript answer. The Revision section marks it as replaced, but nothing inside it is flagged.
- `GLOSSARY.md`: `16` ("for example a shell or a fish": a fish is now a Sea friend), `24` ("the screen that shows them", which depends on gap 4).
