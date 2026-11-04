## Helpers for the tests of the main scene. The runner does not run this file.
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")

## Tweens and timers run faster, so the tests take less time. Engine.time_scale also speeds up the
## Goal celebration.
const TIME_SCALE := 8.0
const MOVE_TIMEOUT := 10.0
## The Goal celebration takes 4.2 s before the next Labyrinth (spec 6.3).
const NEXT_LABYRINTH_TIMEOUT := 10.0


## Adds the main scene. It loads and saves in `save_dir`, or in a new empty folder in the OS temp
## folder, never in user://.
static func add_main(t, save_dir: String = "") -> Node:
	var main: Node = load("res://main.tscn").instantiate()
	main.save_store = SaveStore.new(save_dir if not save_dir.is_empty() else Fixtures.new_save_dir())
	t.root.add_child(main)
	await t.process_frame
	Engine.time_scale = TIME_SCALE
	return main


## Removes the main scene and its save folder.
static func remove(t, main: Node) -> void:
	Engine.time_scale = 1.0
	var save_dir: String = main.save_store.dir
	main.queue_free()
	await t.process_frame
	Fixtures.remove_save_dir(save_dir)


## Presses and releases an arrow key.
static func send_key(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		Input.parse_input_event(event)
	Input.flush_buffered_events()


## Presses and releases an arrow key. Returns true when the boat is free again in time.
static func press(t, main: Node, key: Key) -> bool:
	send_key(key)
	return await t.wait_for(main.move_finished, MOVE_TIMEOUT)


## Presses the arrow keys along the path to the Goal until the boat is on the Goal square.
## Returns false if a move is not over in time or the boat needs too many presses.
static func sail_to_goal(t, main: Node) -> bool:
	var labyrinth: Labyrinth = main.labyrinth
	for presses in 100:
		if main.boat_square == labyrinth.goal_square():
			return true
		if not await press(t, main, key_for(next_step(labyrinth, main.boat_square))):
			return false
	return false


## The direction of the first step on the path from `from` to the Goal.
static func next_step(labyrinth: Labyrinth, from: Vector2i) -> Vector2i:
	var distances := labyrinth.distances_from(labyrinth.goal_square())
	var here := distances[from.y * labyrinth.width + from.x]
	for direction in Labyrinth.DIRECTIONS:
		var next := from + direction
		if not labyrinth.has_wall(from, direction) and distances[next.y * labyrinth.width + next.x] == here - 1:
			return direction
	return Vector2i.ZERO


static func key_for(direction: Vector2i) -> Key:
	match direction:
		Vector2i.UP:
			return KEY_UP
		Vector2i.DOWN:
			return KEY_DOWN
		Vector2i.LEFT:
			return KEY_LEFT
	return KEY_RIGHT


static func wall_list(labyrinth: Labyrinth) -> Array:
	var bits := []
	for y in labyrinth.height:
		for x in labyrinth.width:
			bits.append(labyrinth.wall_bits(Vector2i(x, y)))
	return bits
