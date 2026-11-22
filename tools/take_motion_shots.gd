## Takes frames in the middle of the motion of spec 8 in a window (spec 14.2), at 1920 x 1200: the
## wake of a slide, an Item in flight to its outline, the locked chest during its shake and the open
## chest after the padlock pops (game-flow spec Part 2), the Goal celebration (chest, hop, confetti,
## Sea friend), the fade to the next Labyrinth, and the first Item of a new Area. A headless run has
## no pixels. The game draws into a SubViewport of the exact size, so the window size does not
## matter. The arrow keys go in through the SubViewport.
##
## Run from the repository root:
##   godot --path . --windowed --script res://tools/take_motion_shots.gd
## It writes the PNG files to shots/ and quits with code 0, or prints "MOTION SHOTS FAIL ..." and
## quits with code 1. The game saves into a new folder in the OS temp folder, which the tool removes
## at the end: it never reads or changes the real save.
extends SceneTree

const Scene := preload("res://tests/scene_helpers.gd")
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
	# Labyrinth 1: the boat sails the main path to the Goal. The first slide shows the wake, the
	# boat stops on an Item of the path, and the arrival on the Goal finds the chest locked, because
	# the Item on (1, 1) is not on the main path.
	var collected := [false]
	_main.item_collected.connect(func(_item: Item) -> void: collected[0] = true, CONNECT_ONE_SHOT)
	var locked_visit := [false]
	_main.locked_chest_reached.connect(func() -> void: locked_visit[0] = true, CONNECT_ONE_SHOT)
	_press(_key_to_goal())
	await _wait(0.45)
	await _shot("motion-wake.png", "the wake behind the sliding boat")
	if not await _wait_for(_main.move_finished):
		await _end("Labyrinth 1: the first slide did not end")
		return
	var item_shot := false
	while not locked_visit[0]:
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
	# locked_chest_reached fires on the arrival, just before move_finished. The shake has its
	# first offset (-10 px) at 60 ms.
	await _wait(0.045)
	await _shot("motion-locked.png", "0.06 s: the locked chest shakes, and the empty slot pulses")
	await _wait(1.2)
	# The boat collects the last Item. The padlock pops off when the Item arrives in its slot.
	var labyrinth: Labyrinth = _main.labyrinth
	while _main.progress.collected_items.size() < labyrinth.items.size():
		_press(_key_to_next())
		if not await _wait_for(_main.move_finished):
			await _end("Labyrinth 1: a move to the last Item did not end")
			return
	if not await _wait_for(_main.chest_unlocked):
		await _end("Labyrinth 1: the chest did not unlock")
		return
	await _wait(0.35)
	await _shot("motion-unlocked.png", "0.35 s after the unlock: the padlock is gone, the open chest and the sparkles")
	var reached := [false]
	_main.goal_reached.connect(func(_friend: String) -> void: reached[0] = true, CONNECT_ONE_SHOT)
	while not reached[0]:
		_press(_key_to_next())
		if not await _wait_for(_main.move_finished):
			await _end("Labyrinth 1: a move to the open chest did not end")
			return
	# goal_reached fires on the arrival, just before move_finished.
	await _wait(0.2)
	await _shot("motion-goal.png", "0.2 s: the open chest, the hop, the confetti")
	await _wait(1.8)
	await _shot("motion-sea-friend.png", "2.0 s: the Sea friend wiggles next to the Goal island")
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
	while _main.progress.labyrinth_number == 5:
		_press(_key_to_next())
		if not await _wait_for(_main.move_finished):
			await _end("Labyrinth 5: a move did not end")
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


## The arrow key of the first press on the shortest press path to the next uncollected Item, or to
## the open chest when all Items are collected.
func _key_to_next() -> Key:
	var labyrinth: Labyrinth = _main.labyrinth
	return _key_for(Scene.first_press(labyrinth, _main.boat_square, _main.progress.item_states(labyrinth)))


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
