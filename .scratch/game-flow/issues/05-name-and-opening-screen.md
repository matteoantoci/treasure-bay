# 05: Name and opening screen

**What to build:** The game gets the name Treasure Bay, one rounded font, and an opening screen with the chest logo and one big start button. The opening screen shows at each launch and after each Parent reset. Spec: [spec.md](../spec.md), Part 3. Prototype: [screens-PROTOTYPE](../prototypes/screens-PROTOTYPE/index.html), round 2, variant B.

**Blocked by:** 03 (Voyage)

**Status:** ready-for-agent

- [ ] The project name, the window title, and the app of `tools/make_app.sh` (app name and folder name) are "Treasure Bay".
- [ ] A custom user folder keeps the old name "Labyrinth", so the save does not move. A test checks that the user folder name stays "Labyrinth".
- [ ] One rounded font with the SIL Open Font License (for example Fredoka) is in the repo, with its licence file and a line in `credits.txt`. A shared place gives the font to the title, the total count (ticket 08) and the star number of the Party (ticket 07).
- [ ] The opening screen shows, from the top to the bottom: the still water of Area 1, the title in an arc with even letter gaps, the island from the Kenney tiles with the island rules (an all-land block of 4 × 3 tiles), the closed chest with its sparkle, four bobbing Items, the wide green button with the play triangle and its gentle pulse, and the quiet gear. The music of Area 1 plays.
- [ ] One new input action holds Space and Enter. It acts only on the opening screen and on the Party.
- [ ] Any arrow key, Space, Enter or a mouse click on the button starts the game: the button press motion, the Item sound, the fade to dark in 0.8 s, and the fade-in of the current Labyrinth. Input is locked from the press to the end of the fade-in.
- [ ] While the settings panel is open, the button does nothing.
- [ ] Main-scene tests: at launch the opening screen shows and the Labyrinth does not take arrow presses. An arrow press, Space or Enter starts the current Labyrinth. A Parent reset shows the opening screen with a new Voyage. A launch from a version 1 save past Labyrinth 20 shows the opening screen, then Labyrinth 1 with an empty strip.
- [ ] The scene helpers of `tests/` get one helper that goes through the opening screen, so that the existing main-scene tests keep their meaning.
- [ ] The screenshot tool adds a shot of the opening screen.
- [ ] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.
