## Smoke run in a window (ticket 28): the main scene sails Labyrinths 1 to 3 through their Goals
## with arrow key events through Input.parse_input_event(), with the real audio driver and the
## Master bus muted. In each Labyrinth the boat collects all Items first, so the chest is open
## (game-flow spec Part 2). It also bumps into a wall one time. The game saves into a new folder in
## the OS temp folder, which the tool removes at the end: it never reads or changes the real save
## or the real settings.
##
## Run from the repository root:
##   godot --path . --windowed --script res://tools/smoke_run.gd
## It prints "SMOKE OK ..." and exits with code 0, or prints "SMOKE FAIL ..." and exits with code 1.
## Script errors show in the output as "SCRIPT ERROR".
extends SceneTree

const Scene := preload("res://tests/scene_helpers.gd")
const GOALS := 3
## Real seconds. One Labyrinth of this run takes less than 10 s, its celebration 5.2 s.
const TIMEOUT_SECONDS := 30.0

var _main: Node
var _save_dir := OS.get_temp_dir().path_join("labyrinth-smoke-run-%d" % OS.get_process_id())


func _initialize() -> void:
	await process_frame
	_remove_save_dir()
	DirAccess.make_dir_recursive_absolute(_save_dir)
	_main = load("res://main.tscn").instantiate()
	_main.save_store = SaveStore.new(_save_dir)
	root.add_child(_main)
	current_scene = _main
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), true)
	if not await _wait_for(_main.labyrinth_ready):
		_end("the launch fade-in did not end")
		return
	# The start square (0, 0) of every Labyrinth has the border to the left, so this press is a
	# bump whatever the Labyrinth shape. The bump signal fires at the press.
	var bumps := [0]
	_main.bumped.connect(func() -> void: bumps[0] += 1)
	_press(KEY_LEFT)
	if not await _wait_for(_main.move_finished) or bumps[0] != 1 or _main.boat_square != Vector2i.ZERO:
		_end("no bump at the wall")
		return
	for goal in GOALS:
		var number: int = _main.progress.labyrinth_number
		if not await _sail_to_goal():
			_end("Labyrinth %d: the boat did not reach the Goal" % number)
			return
		if not await _wait_for(_main.labyrinth_ready):
			_end("Labyrinth %d: the next Labyrinth did not start" % number)
			return
		print("Goal of Labyrinth %d: Labyrinth %d is ready, Collection %s, total Items %d" % [number,
			_main.progress.labyrinth_number, _main.progress.collection, _main.progress.total_items])
	var saved := SaveStore.new(_save_dir).load_progress()
	if saved.labyrinth_number != 1 + GOALS:
		_end("the save holds Labyrinth %d" % saved.labyrinth_number)
		return
	_end("")


## Presses the arrow keys along the shortest press path to each uncollected Item, then to the open
## chest, until the Goal celebration starts.
func _sail_to_goal() -> bool:
	var labyrinth: Labyrinth = _main.labyrinth
	var number: int = _main.progress.labyrinth_number
	for presses in 100:
		# The progress moves to the next Labyrinth at the arrival on the open chest.
		if _main.progress.labyrinth_number != number:
			return true
		var direction := Scene.first_press(labyrinth, _main.boat_square, _main.progress.item_states(labyrinth))
		if direction == Vector2i.ZERO:
			return false
		_press(_key_for(direction))
		if not await _wait_for(_main.move_finished):
			return false
	return false


func _press(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		Input.parse_input_event(event)
	Input.flush_buffered_events()


func _key_for(direction: Vector2i) -> Key:
	match direction:
		Vector2i.UP:
			return KEY_UP
		Vector2i.DOWN:
			return KEY_DOWN
		Vector2i.LEFT:
			return KEY_LEFT
	return KEY_RIGHT


## Waits until `sig` fires or the timeout passes. Returns true if the signal fired.
func _wait_for(sig: Signal) -> bool:
	var fired := [false]
	var on_signal := func(..._args: Array) -> void: fired[0] = true
	sig.connect(on_signal, CONNECT_ONE_SHOT)
	var timer := create_timer(TIMEOUT_SECONDS)
	while not fired[0] and timer.time_left > 0.0:
		await process_frame
	if sig.is_connected(on_signal):
		sig.disconnect(on_signal)
	return fired[0]


func _end(failure: String) -> void:
	_main.queue_free()
	await process_frame
	# The audio server frees a stopped playback in a later mix step.
	await create_timer(0.1, true, false, true).timeout
	_remove_save_dir()
	if failure.is_empty():
		print("SMOKE OK: %d Goals, no failure" % GOALS)
		quit(0)
	else:
		print("SMOKE FAIL: " + failure)
		quit(1)


func _remove_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(_save_dir):
		return
	for file_name in DirAccess.get_files_at(_save_dir):
		DirAccess.remove_absolute(_save_dir.path_join(file_name))
	DirAccess.remove_absolute(_save_dir)
