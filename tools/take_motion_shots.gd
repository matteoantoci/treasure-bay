## Takes frames in the middle of the motion of spec 8 in a window (spec 14.2), at 1920 x 1200: the
## wake of a slide, an Item in flight to its outline, the Goal celebration (chest, hop, confetti,
## Sea friend), the fade to the next Labyrinth, and the first Item of a new Area. A headless run has
## no pixels. The game draws into a SubViewport of the exact size, so the window size does not
## matter. The arrow keys go in through the SubViewport.
##
## Run from the repository root:
##   godot --path . --windowed --script res://tools/take_motion_shots.gd
## It writes the PNG files to shots/ and quits. The game saves into a new folder in the OS temp
## folder, which the tool removes at the end: it never reads or changes the real save.
extends SceneTree

const SIZE := Vector2i(1920, 1200)
const SHOTS_DIR := "res://shots/"

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
	await _main.labyrinth_ready
	# Labyrinth 1: down slides to the bend, right stops on the Item, right again reaches the Goal.
	_press(KEY_DOWN)
	await _wait(0.45)
	await _shot("motion-wake.png", "the wake behind the sliding boat")
	await _main.move_finished
	_press(KEY_RIGHT)
	await _main.move_finished
	await _wait(0.33)
	await _shot("motion-item-fly.png", "the Item in flight to its outline")
	await _wait(0.4)
	_press(KEY_RIGHT)
	await _main.goal_reached
	await _wait(0.2)
	await _shot("motion-goal.png", "0.2 s: the open chest, the hop, the confetti")
	await _wait(1.8)
	await _shot("motion-sea-friend.png", "2.0 s: the Sea friend wiggles next to the Goal island")
	await _wait(1.35)
	await _shot("motion-sea-friend-fly.png", "3.35 s: the Sea friend flies to its slot")
	await _wait(1.1)
	await _shot("motion-fade.png", "4.45 s: the fade to dark")
	await _main.labyrinth_ready
	# Labyrinth 5 to 6: a new Area starts with its first Item big in the centre.
	var progress := Progress.new()
	progress.labyrinth_number = 5
	progress.collection = SeaFriends.IDS.slice(0, 4)
	_main.progress = progress
	_main.show_labyrinth()
	await _sail_to_goal()
	await _main.labyrinth_started
	await _wait(0.45)
	await _shot("motion-new-area.png", "0.45 s into the fade-in of Labyrinth 6: the first Item of Area 2")
	_main.queue_free()
	await process_frame
	_remove_save_dir()
	quit()


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


## Presses the arrow keys along the path to the Goal until the boat arrives on the Goal square.
func _sail_to_goal() -> void:
	var labyrinth: Labyrinth = _main.labyrinth
	var distances := labyrinth.distances_from(labyrinth.goal_square())
	while _main.boat_square != labyrinth.goal_square():
		var from: Vector2i = _main.boat_square
		for direction in Labyrinth.DIRECTIONS:
			var next := from + direction
			if not labyrinth.has_wall(from, direction) and distances[next.y * labyrinth.width + next.x] == distances[from.y * labyrinth.width + from.x] - 1:
				_press(_key_for(direction))
				break
		await _main.move_finished


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
