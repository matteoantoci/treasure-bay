## Takes frames in the middle of the motion of spec 8 in a window (spec 14.2), at 1920 x 1200: the
## wake of a slide, an Item in flight to its outline, the Goal celebration (chest, hop, confetti,
## the Sea friend reveal), the fade to the next Labyrinth, and the first Item of a new Area. A
## headless run has no pixels. The game draws into a SubViewport of the exact size, so the window
## size does not matter. The arrow keys go in through the SubViewport.
##
## Run from the repository root:
##   godot --path . --windowed --script res://tools/take_motion_shots.gd
## It writes the PNG files to shots/ and quits with code 0, or prints "MOTION SHOTS FAIL ..." and
## quits with code 1. The game saves into a new folder in the OS temp folder, which the tool removes
## at the end: it never reads or changes the real save.
extends SceneTree

const SIZE := Vector2i(1920, 1200)
const SHOTS_DIR := "res://shots/"
## Real seconds. A move takes less than 2 s, and the Goal celebration 5.2 s.
const TIMEOUT_SECONDS := 30.0

var _viewport := SubViewport.new()
var _main: Node
var _save_dir := OS.get_temp_dir().path_join("labyrinth-motion-shots-%d" % OS.get_process_id())


func _initialize() -> void:
	await process_frame
	_remove_save_dir()
	DirAccess.make_dir_recursive_absolute(_save_dir)
	_viewport.size = SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_viewport)
	_main = load("res://main.tscn").instantiate()
	_main.save_store = SaveStore.new(_save_dir)
	_viewport.add_child(_main)
	if not await _wait_for(_main.labyrinth_ready):
		await _end("the launch fade-in did not end")
		return
	# Labyrinth 1: the boat sails the path to the Goal. The first slide shows the wake, the boat
	# stops on an Item of the path, and the arrival on the Goal starts the celebration.
	var collected := [false]
	_main.item_collected.connect(func(_item: Item) -> void: collected[0] = true, CONNECT_ONE_SHOT)
	var reached := [false]
	_main.goal_reached.connect(func(_friend: String) -> void: reached[0] = true, CONNECT_ONE_SHOT)
	_press(_key_to_goal())
	await _wait(0.45)
	await _shot("motion-wake.png", "the wake behind the sliding boat")
	if not await _wait_for(_main.move_finished):
		await _end("Labyrinth 1: the first slide did not end")
		return
	var item_shot := false
	while not reached[0]:
		if collected[0] and not item_shot:
			item_shot = true
			await _wait(0.33)
			await _shot("motion-item-fly.png", "the Item in flight to its outline")
			await _wait(0.4)
		_press(_key_to_goal())
		if not await _wait_for(_main.move_finished):
			await _end("Labyrinth 1: a move to the Goal did not end")
			return
	if not item_shot:
		await _end("Labyrinth 1: the boat stopped on no Item before the Goal")
		return
	# goal_reached fires on the arrival, just before move_finished.
	await _wait(0.2)
	await _shot("motion-goal.png", "0.2 s: the open chest, the hop, the confetti")
	await _wait(1.6)
	await _shot("motion-reveal.png", "1.8 s: the reveal, the Sea friend large on the darker screen")
	await _wait(0.2)
	await _shot("motion-sea-friend.png", "2.0 s: the Sea friend wiggles at the reveal")
	await _wait(1.35)
	await _shot("motion-sea-friend-fly.png", "3.35 s: the Sea friend flies to its slot")
	await _wait(1.1)
	await _shot("motion-fade.png", "4.45 s: the fade to dark")
	if not await _wait_for(_main.labyrinth_ready):
		await _end("Labyrinth 2 did not start")
		return
	# Labyrinth 5 to 6: a new Area starts with its first Item big in the centre.
	var progress := Progress.new()
	progress.labyrinth_number = 5
	progress.collection = SeaFriends.IDS.slice(0, 4)
	_main.progress = progress
	_main.show_labyrinth()
	while _main.boat_square != _main.labyrinth.goal_square():
		_press(_key_to_goal())
		if not await _wait_for(_main.move_finished):
			await _end("Labyrinth 5: a move to the Goal did not end")
			return
	if not await _wait_for(_main.labyrinth_started):
		await _end("Labyrinth 6 did not start")
		return
	await _wait(0.45)
	await _shot("motion-new-area.png", "0.45 s into the fade-in of Labyrinth 6: the first Item of Area 2")
	await _end("")


func _press(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		_viewport.push_input(event)


func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func _shot(file_name: String, what: String) -> void:
	await RenderingServer.frame_post_draw
	var image := _viewport.get_texture().get_image()
	var path := ProjectSettings.globalize_path(SHOTS_DIR + file_name)
	image.save_png(path)
	print("%s: %s" % [path, what])


## The arrow key of the first step on the path from the boat square to the Goal.
func _key_to_goal() -> Key:
	var labyrinth: Labyrinth = _main.labyrinth
	var distances := labyrinth.distances_from(labyrinth.goal_square())
	var from: Vector2i = _main.boat_square
	for direction in Labyrinth.DIRECTIONS:
		var next := from + direction
		if not labyrinth.has_wall(from, direction) and distances[next.y * labyrinth.width + next.x] == distances[from.y * labyrinth.width + from.x] - 1:
			return _key_for(direction)
	return KEY_NONE


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
		quit(0)
	else:
		print("MOTION SHOTS FAIL: " + failure)
		quit(1)


func _key_for(direction: Vector2i) -> Key:
	match direction:
		Vector2i.UP:
			return KEY_UP
		Vector2i.DOWN:
			return KEY_DOWN
		Vector2i.LEFT:
			return KEY_LEFT
	return KEY_RIGHT


func _remove_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(_save_dir):
		return
	for file_name in DirAccess.get_files_at(_save_dir):
		DirAccess.remove_absolute(_save_dir.path_join(file_name))
	DirAccess.remove_absolute(_save_dir)
