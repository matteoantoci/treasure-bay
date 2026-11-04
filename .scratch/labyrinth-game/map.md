# Labyrinth game for a 5-year-old

Label: wayfinder:map

## Destination

A build-ready spec at `.scratch/labyrinth-game/spec.md`. An agent can build the game from the spec and ask no more questions. The game is a keyboard Labyrinth game for the Parent's 5-year-old Child. It is a Godot 4.7 app in a fullscreen window on the Parent's Mac laptop.

## Notes

- Domain: a small 2D game for one specific Child, the Parent's 5-year-old daughter. Use the terms in `GLOSSARY.md`.
- Plan only. The map stops when the spec is complete. The build is a separate task after the map.
- Fixed rules from the Parent:
  - The Child cannot read, so the game shows no words to the Child. Numbers are allowed, because she knows them well.
  - The Child cannot lose. The game has no timer, no enemies, and no lives.
  - The keyboard is the only input for play. The mouse is allowed for settings, for example the volume buttons. The Child can use the settings too.
  - The game has no recorded voice.
  - The game has no accounts and no ads, and it sends no data over the network.
- The Parent wants some scoring or reward to encourage the Child. It must obey the "cannot lose" rule.
- Skills to consult are in `.claude/skills/`. Start with `router`. Use the `godot-*` skills for the engine, and `godot-gdscript-headless-testing` for tests. Use `puzzle` and `level-design` for Labyrinths, `procedural-gen` for generated levels, `input-systems` for keys, `game-feel` and `game-ui-ux` for movement and screens, `audio-design` for sound, `save-systems` for saved progress, and `prototype-fast` for prototype tickets.

## Decisions so far

- [Choose the tech stack](issues/01-choose-tech-stack.md): Godot 4.7 with GDScript, in a native fullscreen window. The Parent installs it once with `brew install --cask godot`, then `./play` starts the game. The game code generates Labyrinths with a seeded recursive backtracker.
- [Polished sea look](issues/13-polished-sea-look.md) (replaces [Source the graphics](issues/07-source-the-graphics.md)): a top-down Kenney Pirate Pack world. The islands are the walls and the water channels are the paths. The water moves, foam moves on the coasts, and the boat leaves a wake. The 20 Sea friends and the Items are Kenney-style sprites that Grok generated, in `prototypes/art-PROTOTYPE/sprites/`.
- [Pick the theme: sea or space](issues/02-pick-the-theme.md): sea. A sailboat finds an island and collects Items. [Polished sea look](issues/13-polished-sea-look.md) sets the look.
- [Arrow-key movement](issues/03-arrow-key-movement.md): one press moves the boat to the next junction, dead end, or Goal. At a wall, the boat does a small bump. Medium speed, about 180 ms for each square.
- [Encouragement without losing](issues/04-encouragement-without-losing.md): Items on the path fill a row of outlines. At the Goal, a celebration plays and a new Sea friend joins the Collection.
- [Levels and difficulty](issues/05-levels-and-difficulty.md): 20 fixed Labyrinths in 4 Areas, from 4 × 3 to 10 × 7 squares, then random ones. The game starts the next Labyrinth by itself. 2 to 8 Items in each Labyrinth.
- [Sound](issues/06-sound.md): calm music for each Area, 5 soft effects, an own sound for each Sea friend where a good one exists, and volume buttons on the screen that the mouse can click.
- [Source the sounds](issues/10-source-the-sounds.md): a short list of 4 Pixabay music tracks with CC0 backups, 5 CC0 effects, and an own CC0 sound for 15 Sea friends. The other 5 use the splash. [Listen to the sounds](issues/12-listen-to-the-sounds.md) changed the list.
- [Saved progress](issues/09-saved-progress.md): the game saves to `user://save.json` after each Item and at each Goal. The file holds a `version`, the current Labyrinth and its seed, and the collected Item IDs, so one Item never counts two times. A missing or broken file starts quietly at Labyrinth 1. A broken file is kept as `save.bak`. The Parent resets with a hold-for-3-seconds button in the settings.
- [Visual change between Labyrinths](issues/08-visual-change-between-labyrinths.md): 4 sea Areas, each with its own colours, Items, and decoration: lagoon, coral reef, open sea, and sea at night. The look changes every 5 Labyrinths. The boat and the island stay the same. The exact colours and Items change with [Polished sea look](issues/13-polished-sea-look.md).
- [Motion and animation](issues/11-motion-and-animation.md): all 7 motions of the prototype at the medium amount: idle rock and bob, water and foam, wake, Item fly, Goal hop and confetti, Sea friend arrival, and a fade between Labyrinths. A new Area starts with its first Item big in the middle, which then fades out. The timings are in the ticket.
- [Clean sprite edges](issues/14-clean-sprite-edges.md): the sprites stay as they are. The rough edges came from the scaling. The spec requires mipmaps on the sprite textures (**Mipmaps > Generate**), the filter `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`, and the window stretch mode `canvas_items`.
- [Reward after Labyrinth 20](issues/15-reward-after-labyrinth-20.md): at the Goal, a random Sea friend from the Collection comes back with the arrival motion, never the same one two times in a row. Random Labyrinths change the Area every 5 Labyrinths, in the order of Labyrinths 1 to 20.
- [Parent controls](issues/16-parent-controls.md): `./play` opens at the saved Labyrinth with no start screen. A gear picture opens the settings: volume, reset, and a quit button (door picture) that the Parent holds for 3 seconds. The game calls `get_tree().set_auto_accept_quit(false)`, so the quit button is the only quit path. No skip. The spec requires a manual test of each key in the list below.
- [Session limit](issues/17-session-limit.md): no limit in the game. The Parent controls the time.
- [Screen layout](issues/18-screen-layout.md): the Labyrinth plus a margin fills the screen height, in the middle. The square size follows the Labyrinth size. The Item row is at the top in the middle, and a small gear is in the top-right corner. Base resolution 1920 × 1200 (16:10, the Mac laptop shape), stretch mode `canvas_items`, stretch aspect `expand`.
- [Listen to the sounds](issues/12-listen-to-the-sounds.md): the Parent listened in 3 rounds. All 4 music tracks are joyful AndriiComposer tracks. 13 Sea friends have an own sound and 7 use the splash. The final list is at the end of [research/sounds.md](research/sounds.md).
- [Gaps before the spec](issues/19-gaps-before-the-spec.md): Areas 2 to 4 Items, colours, and decoration; the Collection is a bottom strip; the Goal island has a palm and a treasure chest that opens; sounds use the Freesound previews, so no login; the keys that no app can block are accepted. 34 small defaults are in [research/gap-audit.md](research/gap-audit.md).
- [Build spec](spec.md): the build-ready spec, written on 2026-11-04 from all decisions above. It overrides older text in the tickets and research files.
- [Build](issues/28-final-check.md): tickets 20 to 29 are built on the branch `labyrinth-game` (2026-11-04). The fixes after the build: the Goal is always a dead end, so the boat can reach each Item; the WAV import does not trim; old saves keep their progress. Ticket 30 (the Parent manual check) is open.

## Facts for the build

- Keys that can end play (facts for the spec; all from a source trace, none tested; see [research/godot4-facts.md](research/godot4-facts.md)):
  - Esc: Godot does not leave fullscreen on Esc.
  - Cmd+Q and window close: blocked only if the game calls `get_tree().set_auto_accept_quit(false)`. Then the game needs a Parent quit key, and the game also blocks a macOS logout until it quits.
  - Ctrl+Cmd+F: not known if it leaves fullscreen.
  - Cmd+Tab, Cmd+H, Cmd+M, Cmd+Option+Esc: Godot cannot block them.
  - Reset of progress: decided in [Saved progress](issues/09-saved-progress.md). It is a button in the settings with a circular-arrow picture, and the Parent holds it for 3 seconds. Do not decide it again.
  - The spec must require a manual test of each key before it states any key as blocked.

## Out of scope

- Mouse, trackpad, and touch input for play: the Parent chose the keyboard for play. The mouse is allowed only for settings.
- A recorded voice: the Parent ruled it out.
- Multiplayer, online accounts, and a public release.
- A web or browser version: the Parent chose a Godot laptop app.
