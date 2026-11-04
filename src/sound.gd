## The sound of the game (spec 9): the `Music` and `Effects` buses, the music of each Area with its
## crossfade loop, and the sounds of the events of spec 9.7. A child of the main scene: it connects
## to the signals of its parent in _ready().
class_name Sound
extends Node

## Emitted each time a sound starts, with the file that plays and the bus of its player. A headless
## run has no audio output, so the tests connect a recorder here and check the sound calls (spec 9.1,
## 14.1 test 9).
signal sound_played(path: String, bus: StringName)

const SoundLevels := preload("res://src/sound_levels.gd")

const MUSIC_BUS := &"Music"
const EFFECTS_BUS := &"Effects"
## The crossfade of spec 9.2: 1.5 s, from or to -40 dB. It starts when 1.5 s of the track remain.
const CROSSFADE_SECONDS := 1.5
const SILENT_DB := -40.0

const MOVE_PATH := "res://assets/audio/effects/move.wav"
const WALL_PATH := "res://assets/audio/effects/wall.wav"
const ITEM_PATH := "res://assets/audio/effects/item.wav"
const GOAL_PATH := "res://assets/audio/effects/goal.wav"
const SPLASH_PATH := "res://assets/audio/effects/splash.wav"
## The move swish varies its pitch, and up to 4 swishes can sound at one time (spec 9.3).
const MOVE_PITCH_SEMITONES := 1.0
const MOVE_POLYPHONY := 4
## The 13 Sea friends with an own sound (spec 9.4). The other 7 play the splash.
const SEA_FRIENDS_WITH_OWN_SOUND: PackedStringArray = [
	"crab", "octopus", "whale", "dolphin", "fish", "squid", "seal",
	"jellyfish", "otter", "penguin", "duck", "swan", "flamingo",
]

## The two music players of the crossfade. `_active` is the one with the current track.
var music_players: Array[AudioStreamPlayer] = []
var move_player: AudioStreamPlayer
var wall_player: AudioStreamPlayer
var item_player: AudioStreamPlayer
var goal_player: AudioStreamPlayer
var sea_friend_player: AudioStreamPlayer

var _active := 0
var _crossfade: Tween


## Adds the `Music` and `Effects` buses, each sending to `Master`, if they do not exist yet (spec 9.1).
static func add_buses() -> void:
	for bus_name: StringName in [MUSIC_BUS, EFFECTS_BUS]:
		if AudioServer.get_bus_index(bus_name) != -1:
			continue
		var index := AudioServer.bus_count
		AudioServer.add_bus(index)
		AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, &"Master")


## The sound file of a Sea friend: its own sound, or the splash (spec 9.4).
static func sea_friend_sound_path(sea_friend: String) -> String:
	if SEA_FRIENDS_WITH_OWN_SOUND.has(sea_friend):
		return "res://assets/audio/friends/%s.wav" % sea_friend
	return SPLASH_PATH


func _ready() -> void:
	# The music and its crossfade go on while the settings pause the game (spec 9.2).
	process_mode = PROCESS_MODE_ALWAYS
	add_buses()
	for i in 2:
		music_players.append(_add_player(MUSIC_BUS, PROCESS_MODE_ALWAYS))
	var swish := AudioStreamRandomizer.new()
	swish.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM
	swish.add_stream(0, load(MOVE_PATH))
	swish.random_pitch_semitones = MOVE_PITCH_SEMITONES
	move_player = _add_player(EFFECTS_BUS, PROCESS_MODE_PAUSABLE, swish, MOVE_PATH)
	move_player.max_polyphony = MOVE_POLYPHONY
	wall_player = _add_player(EFFECTS_BUS, PROCESS_MODE_PAUSABLE, load(WALL_PATH), WALL_PATH)
	item_player = _add_player(EFFECTS_BUS, PROCESS_MODE_PAUSABLE, load(ITEM_PATH), ITEM_PATH)
	goal_player = _add_player(EFFECTS_BUS, PROCESS_MODE_PAUSABLE, load(GOAL_PATH), GOAL_PATH)
	sea_friend_player = _add_player(EFFECTS_BUS, PROCESS_MODE_PAUSABLE)
	var main := get_parent()
	main.labyrinth_started.connect(_on_labyrinth_started)
	main.next_labyrinth_coming.connect(_on_labyrinth_started)
	main.move_started.connect(_play.bind(move_player, MOVE_PATH))
	main.bumped.connect(_play.bind(wall_player, WALL_PATH))
	main.item_collected.connect(_play.bind(item_player, ITEM_PATH).unbind(1))
	main.goal_reached.connect(_play.bind(goal_player, GOAL_PATH).unbind(1))
	main.sea_friend_appeared.connect(play_sea_friend)


## Stops the music, so the audio server holds no playback of a freed scene.
func _exit_tree() -> void:
	if _crossfade != null:
		_crossfade.kill()
	for player in music_players:
		player.stop()


## Starts the crossfade back to the start of the track when 1.5 s of it remain (spec 9.2).
func _process(_delta: float) -> void:
	var player := music_players[_active]
	if player.playing and player.stream.get_length() - player.get_playback_position() <= CROSSFADE_SECONDS:
		_crossfade_to(player.stream.resource_path)


## The music file that plays now, or "" when no music plays.
func music_path() -> String:
	var player := music_players[_active]
	return player.stream.resource_path if player.playing else ""


## The music player with the current track.
func active_music_player() -> AudioStreamPlayer:
	return music_players[_active]


## Plays the track of `area`. At launch the track starts at its level. Later the current track
## crossfades to it. Nothing changes when the track already plays.
func play_area(area: int) -> void:
	var path := Area.music_path(area)
	if music_path() == path:
		return
	if music_path().is_empty():
		_start(music_players[_active], path, SoundLevels.volume_db(path))
	else:
		_crossfade_to(path)


## Plays the sound of a Sea friend when it appears (spec 9.4).
func play_sea_friend(sea_friend: String) -> void:
	var path := sea_friend_sound_path(sea_friend)
	sea_friend_player.stream = load(path)
	sea_friend_player.volume_db = SoundLevels.volume_db(path)
	_play(sea_friend_player, path)


func _on_labyrinth_started(number: int) -> void:
	play_area(Area.for_labyrinth(number))


## The new copy goes from -40 dB to its level, the old copy goes to -40 dB and stops (spec 9.2).
## During a crossfade both players play. A new crossfade then fades out the louder copy from its
## level now, and the quieter player takes the new track.
func _crossfade_to(path: String) -> void:
	if _crossfade != null:
		_crossfade.kill()
	var old_index := _active
	var other := music_players[1 - _active]
	if other.playing and other.volume_db > music_players[_active].volume_db:
		old_index = 1 - _active
	var old := music_players[old_index]
	_active = 1 - old_index
	var new := music_players[_active]
	_start(new, path, SILENT_DB)
	_crossfade = create_tween().set_parallel().set_ignore_time_scale()
	_crossfade.tween_property(new, "volume_db", SoundLevels.volume_db(path), CROSSFADE_SECONDS)
	_crossfade.tween_property(old, "volume_db", SILENT_DB, CROSSFADE_SECONDS)
	_crossfade.chain().tween_callback(old.stop)


func _start(player: AudioStreamPlayer, path: String, volume_db: float) -> void:
	player.stream = load(path)
	player.volume_db = volume_db
	_play(player, path)


func _play(player: AudioStreamPlayer, path: String) -> void:
	player.play()
	sound_played.emit(path, player.bus)


func _add_player(bus: StringName, mode: ProcessMode, stream: AudioStream = null, path := "") -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus
	player.process_mode = mode
	player.stream = stream
	if not path.is_empty():
		player.volume_db = SoundLevels.volume_db(path)
	add_child(player)
	return player
