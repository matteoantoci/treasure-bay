# 26: Sound

**What to build:** Each Area plays its joyful music with a crossfade loop. The effects and Sea friend sounds play at their events. Spec section 9.

**Blocked by:** 29 (Sounds and credits), 24 (Sea look, Areas, and layout)

**Status:** resolved

- [x] The `Music` and `Effects` buses exist (spec 9.1).
- [x] Each Area plays its track, with the crossfade at the end of the track and at an Area change (spec 9.2).
- [x] Each event of spec 9.7 plays its sound. The move swish varies its pitch.
- [x] 13 Sea friends play their own sound, and 7 play the splash (spec 9.4).

## Comments

**Built (ticket 26 worker, 2026-11-04).**
- `src/sound.gd` (`Sound`, a `Node`): the node `Sound` (last child of `main.tscn`) connects to the signals of its parent in `_ready()`. `Sound.add_buses()` adds the `Music` and `Effects` buses in code with `AudioServer.add_bus()`, `set_bus_name()`, `set_bus_send(idx, "Master")` (spec 9.1); it adds no bus that exists, so many scenes in one run are fine. No `default_bus_layout.tres`.
- Music (spec 9.2): two `AudioStreamPlayer` nodes on `Music` with `PROCESS_MODE_ALWAYS` (the `Sound` node is `ALWAYS` too, so `_process` and the crossfade tween go on in the pause). `play_area(area)` starts the track at its level at launch, crossfades when the Area track differs, and does nothing when it already plays. `_process()` starts the loop crossfade when `length - get_playback_position() <= 1.5` s. The crossfade: the other player plays the track from -40 dB to its `SoundLevels` level in 1.5 s, the old one goes to -40 dB and stops; the tween ignores `Engine.time_scale` (audio runs in real time). A crossfade during a crossfade restarts the copy that fades out. `labyrinth_started(number)` (launch, Parent reset) and `next_labyrinth_coming(number)` (the start of the fade to dark) both call `play_area()`. `_exit_tree()` stops the music.
- Effects (spec 9.3, 9.7): one player each on `Effects` with its `SoundLevels` level: `move_player` (an `AudioStreamRandomizer` with `random_pitch_semitones = 1.0`, `max_polyphony = 4`), `wall_player`, `item_player`, `goal_player`, `sea_friend_player` (stream and level set per Sea friend). Effects players are `PROCESS_MODE_PAUSABLE`. `Sound.sea_friend_sound_path(id)`: the 13 Sea friends of `SEA_FRIENDS_WITH_OWN_SOUND` play `assets/audio/friends/<id>.wav`, the other 7 play `splash.wav` (spec 9.4); returning Sea friends after Labyrinth 20 use the same rule.
- **New signals in `src/main.gd`** (events of spec 9.7 that had none): `move_started` and `bumped`, emitted in `_move()` right after the boat turns; `next_labyrinth_coming(number)` at 4.2 s of the celebration, with the next Labyrinth number. Ticket 25 agreed to emit `next_labyrinth_coming` at the start of its fade to dark (same declaration text).
- **Hook for ticket 27 (settings):** the bus names are `Sound.MUSIC_BUS` / `Sound.EFFECTS_BUS`; set their volumes with `AudioServer.set_bus_volume_db(AudioServer.get_bus_index(...), ...)` (spec 11.2). Call `Sound.add_buses()` first if the settings load before the main scene.
- **Test hook:** `Sound.sound_played(path, bus)` fires at each `play()`, with the file and the bus of the real player. The tests connect a recorder to it before the scene enters the tree.
- Tests: `tests/test_sound.gd` (test 9 of spec 14.1: buses and their send; launch music on `Music`; one swish for a move of several squares with the randomizer, polyphony, and level; a bump plays only the wall sound; swish then pop at an Item; fanfare at the Goal, the crab at 1.4 s, no new music inside Area 1; 13 own sounds and 7 splashes; the Area 1 to 2 crossfade at `next_labyrinth_coming`, both players during it, the old one stopped at -40 dB after it; the track-end crossfade after a `seek()` to 1.7 s before the end; each played file has a level). Test 6 (`tests/test_areas_and_sea_friends.gd`) now also checks the real music player of the scene at saved Labyrinths 1, 6, 11, 16, 21, 26, 36. Levels are compared to 0.01 dB (a player stores `volume_db` as a 32-bit float).
- `tests/scene_helpers.gd`: `Scene.remove()` now waits 0.1 s of real time after the scene is freed. The audio server frees a stopped playback in a later mix step; with no wait, the runner exit printed a leaked `AudioStreamPlaybackMP3`.

**Checked.** Full test run exits 0 with no warnings or leaks (`--verbose`). A windowed run (CoreAudio, a temp save folder, removed after) started at Labyrinth 5: the lagoon track, the wall sound, the swishes, the fanfare, the dolphin 1.42 s after the fanfare, the coral reef crossfade 4.2 s after the Goal, and the loop crossfade after a seek, with no script or audio errors. Not checked: listening by a person (the loudness and the crossfade by ear).
