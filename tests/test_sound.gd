## Spec 14.1 test 9: each event of spec 9.7 calls the right stream on the right bus, and each sound
## file has a level in src/sound_levels.gd. A headless run has no audio output (spec 9.1), so a
## recorder on Sound.sound_played logs each call; the checks also read the real players.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const Fixtures := preload("res://tests/fixtures.gd")
const SoundLevels := preload("res://src/sound_levels.gd")

const MUSIC := "res://assets/audio/music/"
const EFFECTS := "res://assets/audio/effects/"
const FRIENDS := "res://assets/audio/friends/"
# Spec 9.4: the 7 Sea friends with no own sound play the splash.
const SPLASH_FRIENDS := ["spouting_whale", "blowfish", "shark", "lobster", "shrimp", "oyster", "turtle"]
# The crossfade takes 1.5 s of real time (spec 9.2); Engine.time_scale does not change it.
const CROSSFADE_WAIT := 2.0
## Real seconds from the start of a crossfade: the old copy is still the louder copy.
const EARLY_IN_A_CROSSFADE := 0.2


## Adds the main scene at saved Labyrinth `number`, with a recorder connected before the launch, and
## waits for the end of the launch fade-in. Returns [main, calls]; each call is [path, bus].
static func _add_main(t, number: int) -> Array:
	var dir := Fixtures.new_save_dir()
	var saved := Progress.new()
	saved.labyrinth_number = number
	SaveStore.new(dir).save(saved)
	var main: Node = load("res://main.tscn").instantiate()
	main.save_store = SaveStore.new(dir)
	var calls := []
	main.get_node("Sound").sound_played.connect(func(path: String, bus: StringName) -> void: calls.append([path, bus]))
	t.root.add_child(main)
	await t.process_frame
	Engine.time_scale = Scene.TIME_SCALE
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "the launch fade-in ends")
	return [main, calls]


## A player stores its volume as a 32-bit float: compare to 0.01 dB.
static func _assert_db(t, actual: float, expected: float, label: String) -> void:
	t.assert_eq(snappedf(actual, 0.01), snappedf(expected, 0.01), label)


static func _real_seconds(t, seconds: float) -> void:
	await t.create_timer(seconds, true, false, true).timeout


func test_the_music_and_effects_buses_send_to_master(t) -> bool:
	Sound.add_buses()
	var count := AudioServer.bus_count
	Sound.add_buses()
	t.assert_eq(AudioServer.bus_count, count, "a second add_buses() adds no bus")
	for bus_name in [&"Music", &"Effects"]:
		var index := AudioServer.get_bus_index(bus_name)
		t.assert_true(index > 0, "%s bus exists" % bus_name)
		t.assert_eq(AudioServer.get_bus_send(index), &"Master", "%s sends to Master" % bus_name)
	return true


func test_launch_plays_the_music_of_the_area_on_the_music_bus(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var sound: Sound = main.get_node("Sound")
	t.assert_eq(added[1], [[MUSIC + "lagoon.mp3", &"Music"]], "launch: the Area 1 track on Music")
	var player := sound.active_music_player()
	t.assert_true(player.playing, "the music plays")
	t.assert_eq(player.stream.resource_path, MUSIC + "lagoon.mp3", "music stream")
	t.assert_eq(player.bus, &"Music", "music bus")
	_assert_db(t, player.volume_db, SoundLevels.volume_db(MUSIC + "lagoon.mp3"), "music level")
	t.assert_eq(player.stream.loop, false, "the import does not loop the track")
	for music_player in sound.music_players:
		t.assert_eq(music_player.process_mode, Node.PROCESS_MODE_ALWAYS, "music goes on in the pause")
	await Scene.remove(t, main)
	return true


func test_a_move_plays_the_swish_with_a_varied_pitch(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var calls: Array = added[1]
	var sound: Sound = main.get_node("Sound")
	calls.clear()
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "move down is over")
	t.assert_eq(calls, [[EFFECTS + "move.wav", &"Effects"]], "one swish for one move of several squares")
	var player := sound.move_player
	t.assert_true(player.stream is AudioStreamRandomizer, "the swish is in a randomizer")
	t.assert_eq(player.stream.get_stream(0).resource_path, EFFECTS + "move.wav", "swish stream")
	_assert_db(t, player.stream.random_pitch_semitones, 1.0, "pitch varies by 1 semitone")
	t.assert_eq(player.max_polyphony, 4, "4 swishes at one time")
	t.assert_eq(player.bus, &"Effects", "swish bus")
	_assert_db(t, player.volume_db, SoundLevels.volume_db(EFFECTS + "move.wav"), "swish level")
	await Scene.remove(t, main)
	return true


func test_a_bump_plays_the_wall_sound_and_no_swish(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var calls: Array = added[1]
	calls.clear()
	# Labyrinth 1 starts in the top-left corner: up is a wall.
	t.assert_true(await Scene.press(t, main, KEY_UP), "bump is over")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat did not move")
	t.assert_eq(calls, [[EFFECTS + "wall.wav", &"Effects"]], "the wall sound only")
	var player: AudioStreamPlayer = main.get_node("Sound").wall_player
	_assert_db(t, player.volume_db, SoundLevels.volume_db(EFFECTS + "wall.wav"), "wall level")
	await Scene.remove(t, main)
	return true


func test_an_item_plays_the_pop(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var calls: Array = added[1]
	await Scene.press(t, main, KEY_DOWN)
	calls.clear()
	t.assert_true(await Scene.press(t, main, KEY_RIGHT), "move right is over")
	t.assert_eq(main.boat_square, Vector2i(1, 2), "the boat stops on the Item")
	t.assert_eq(calls, [[EFFECTS + "move.wav", &"Effects"], [EFFECTS + "item.wav", &"Effects"]], "swish, then pop")
	var player: AudioStreamPlayer = main.get_node("Sound").item_player
	_assert_db(t, player.volume_db, SoundLevels.volume_db(EFFECTS + "item.wav"), "pop level")
	await Scene.remove(t, main)
	return true


func test_the_goal_plays_the_fanfare_then_the_crab(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var calls: Array = added[1]
	var sound: Sound = main.get_node("Sound")
	var goal_calls := []
	main.goal_reached.connect(func(_friend: String) -> void: goal_calls.append(calls.duplicate()))
	t.assert_true(await Scene.sail_to_goal(t, main), "the boat reaches the Goal")
	t.assert_eq(goal_calls[0].back(), [EFFECTS + "goal.wav", &"Effects"], "fanfare at the Goal arrival")
	t.assert_true(await t.wait_for(main.sea_friend_appeared, Scene.NEXT_LABYRINTH_TIMEOUT), "the crab appears")
	t.assert_eq(calls.back(), [FRIENDS + "crab.wav", &"Effects"], "the crab sound when it appears")
	_assert_db(t, sound.sea_friend_player.volume_db, SoundLevels.volume_db(FRIENDS + "crab.wav"), "crab level")
	# Labyrinth 2 is in Area 1 too: the music does not change.
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 2 starts")
	var music_calls := calls.filter(func(call: Array) -> bool: return call[1] == &"Music")
	t.assert_eq(music_calls, [[MUSIC + "lagoon.mp3", &"Music"]], "no new music in the same Area")
	await Scene.remove(t, main)
	return true


func test_the_sea_friend_ducks_the_fanfare_and_the_next_goal_restores_it(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var calls: Array = added[1]
	var sound: Sound = main.get_node("Sound")
	var level := SoundLevels.volume_db(EFFECTS + "goal.wav")
	main.sea_friend_appeared.emit("crab")
	await t.create_timer(0.1, false).timeout
	t.assert_true(sound.goal_player.volume_db < level - 0.5, "the fanfare goes down")
	t.assert_true(sound.goal_player.volume_db > level - 11.5, "the fanfare is still going down")
	await t.create_timer(0.2, false).timeout
	_assert_db(t, sound.goal_player.volume_db, level - 12.0, "the fanfare is 12 dB down after 0.2 s")
	# A reset during the celebration: the next Goal plays the fanfare at its level.
	calls.clear()
	main.goal_reached.emit("crab")
	_assert_db(t, sound.goal_player.volume_db, level, "the next Goal plays at the fanfare level")
	t.assert_eq(calls, [[EFFECTS + "goal.wav", &"Effects"]], "the next Goal plays the fanfare")
	await Scene.remove(t, main)
	return true


func test_the_fanfare_duck_pauses_with_the_game(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var sound: Sound = main.get_node("Sound")
	var level := SoundLevels.volume_db(EFFECTS + "goal.wav")
	t.paused = true
	main.sea_friend_appeared.emit("crab")
	await t.create_timer(0.4, true).timeout
	_assert_db(t, sound.goal_player.volume_db, level, "no duck while the game pauses")
	t.paused = false
	await t.create_timer(0.4, false).timeout
	_assert_db(t, sound.goal_player.volume_db, level - 12.0, "the duck goes on after the pause")
	await Scene.remove(t, main)
	return true



func test_13_sea_friends_play_their_own_sound_and_7_the_splash(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var calls: Array = added[1]
	var sound: Sound = main.get_node("Sound")
	var own := 0
	for id in SeaFriends.IDS:
		calls.clear()
		main.sea_friend_appeared.emit(id)
		var path := EFFECTS + "splash.wav" if SPLASH_FRIENDS.has(id) else FRIENDS + id + ".wav"
		if not SPLASH_FRIENDS.has(id):
			own += 1
		t.assert_eq(calls, [[path, &"Effects"]], "sound of %s" % id)
		t.assert_eq(sound.sea_friend_player.stream.resource_path, path, "stream of %s" % id)
		_assert_db(t, sound.sea_friend_player.volume_db, SoundLevels.volume_db(path), "level of %s" % id)
		t.assert_true(ResourceLoader.exists(path), "file of %s exists" % id)
	t.assert_eq(own, 13, "Sea friends with an own sound")
	await Scene.remove(t, main)
	return true


func test_an_area_change_crossfades_to_the_new_track_at_the_fade(t) -> bool:
	var added := await _add_main(t, 5)
	var main: Node = added[0]
	var calls: Array = added[1]
	var sound: Sound = main.get_node("Sound")
	var old := sound.active_music_player()
	var at_fade := []
	main.next_labyrinth_coming.connect(func(_number: int) -> void: at_fade.append(calls.duplicate()))
	t.assert_true(await Scene.sail_to_goal(t, main), "the boat reaches the Goal")
	t.assert_true(await t.wait_for(main.next_labyrinth_coming, Scene.NEXT_LABYRINTH_TIMEOUT), "the fade starts")
	t.assert_eq(at_fade[0].back(), [MUSIC + "coral_reef.mp3", &"Music"], "the Area 2 track starts with the fade")
	var new := sound.active_music_player()
	t.assert_true(new != old, "the other player takes the new track")
	t.assert_true(old.playing and new.playing, "both tracks play during the crossfade")
	t.assert_true(new.volume_db < SoundLevels.volume_db(MUSIC + "coral_reef.mp3"), "the new track fades in")
	await _real_seconds(t, CROSSFADE_WAIT)
	t.assert_true(not old.playing, "the old track stopped")
	_assert_db(t, old.volume_db, -40.0, "the old track went down to -40 dB")
	_assert_db(t, new.volume_db, SoundLevels.volume_db(MUSIC + "coral_reef.mp3"), "the new track is at its level")
	t.assert_eq(sound.music_path(), MUSIC + "coral_reef.mp3", "Area 2 music")
	await Scene.remove(t, main)
	return true


## Spec 9.2: the old copy goes down to -40 dB, then stops. A second crossfade during a crossfade (a
## reset or an Area change) fades out the louder copy from its level now. The quieter player takes
## the new track.
func test_a_crossfade_during_a_crossfade_fades_out_the_louder_copy(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var calls: Array = added[1]
	var sound: Sound = main.get_node("Sound")
	var lagoon := sound.active_music_player()
	calls.clear()
	sound.play_area(2)
	var coral := sound.active_music_player()
	await _real_seconds(t, EARLY_IN_A_CROSSFADE)
	var lagoon_db := lagoon.volume_db
	t.assert_true(lagoon_db > coral.volume_db, "early in the crossfade, the old copy is the louder copy")
	sound.play_area(3)
	t.assert_eq(calls, [[MUSIC + "coral_reef.mp3", &"Music"], [MUSIC + "open_sea.mp3", &"Music"]], "two crossfades")
	t.assert_true(lagoon.playing, "the louder copy plays on")
	t.assert_eq(lagoon.stream.resource_path, MUSIC + "lagoon.mp3", "the louder copy keeps its track")
	_assert_db(t, lagoon.volume_db, lagoon_db, "the louder copy keeps its level when its fade-out starts")
	t.assert_eq(sound.active_music_player(), coral, "the quieter player takes the new track")
	t.assert_eq(coral.stream.resource_path, MUSIC + "open_sea.mp3", "the new track")
	_assert_db(t, coral.volume_db, -40.0, "the new track starts at -40 dB")
	await _real_seconds(t, CROSSFADE_WAIT)
	t.assert_true(not lagoon.playing, "the louder copy stopped")
	_assert_db(t, lagoon.volume_db, -40.0, "the louder copy went down to -40 dB")
	_assert_db(t, coral.volume_db, SoundLevels.volume_db(MUSIC + "open_sea.mp3"), "the new track is at its level")
	t.assert_eq(sound.music_path(), MUSIC + "open_sea.mp3", "Area 3 music")
	await Scene.remove(t, main)
	return true


func test_the_track_end_crossfades_to_its_own_start(t) -> bool:
	var added := await _add_main(t, 1)
	var main: Node = added[0]
	var calls: Array = added[1]
	var sound: Sound = main.get_node("Sound")
	var old := sound.active_music_player()
	calls.clear()
	old.seek(old.stream.get_length() - 1.7)
	# wait_for() counts scaled time.
	t.assert_true(await t.wait_for(sound.sound_played, CROSSFADE_WAIT * Scene.TIME_SCALE), "the loop crossfade starts")
	t.assert_eq(calls, [[MUSIC + "lagoon.mp3", &"Music"]], "the same track again")
	var new := sound.active_music_player()
	t.assert_true(new != old, "the other player takes the new copy")
	t.assert_true(new.get_playback_position() < 0.5, "the new copy starts at the beginning")
	t.assert_true(old.stream.get_length() - old.get_playback_position() > 1.0, "the crossfade started at 1.5 s before the end")
	await _real_seconds(t, CROSSFADE_WAIT)
	t.assert_true(not old.playing, "the old copy stopped")
	t.assert_true(new.playing, "the new copy plays")
	_assert_db(t, new.volume_db, SoundLevels.volume_db(MUSIC + "lagoon.mp3"), "the new copy is at its level")
	await Scene.remove(t, main)
	return true


func test_each_sound_that_plays_has_a_level(t) -> bool:
	var paths := [Sound.MOVE_PATH, Sound.WALL_PATH, Sound.ITEM_PATH, Sound.GOAL_PATH, Sound.SPLASH_PATH]
	for area in range(1, Area.COUNT + 1):
		paths.append(Area.music_path(area))
	for id in SeaFriends.IDS:
		paths.append(Sound.sea_friend_sound_path(id))
	for path: String in paths:
		t.assert_true(SoundLevels.LEVELS.has(path), "level for %s" % path)
	return true
