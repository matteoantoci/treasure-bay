## Helpers for the tests of the main scene. The runner does not run this file.
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")

## Tweens and timers run faster, so the tests take less time. Engine.time_scale also speeds up the
## Goal celebration.
const TIME_SCALE := 8.0
const MOVE_TIMEOUT := 10.0
## The next Labyrinth shows 4.7 s after the arrival on the Goal, and its fade-in ends at 5.2 s
## (spec 6.3, 8.8).
const NEXT_LABYRINTH_TIMEOUT := 10.0
## The audio server frees a stopped playback in a later mix step.
const AUDIO_FREE_SECONDS := 0.1
## Game seconds of a check that no move comes. Longer than the longest move: a slide on a 10 x 7
## Labyrinth crosses at most 9 squares, 18 tiles, in 3.24 s (spec 5.2). The timer of the check runs
## at the test time scale, like the moves.
const NO_MOVE_SECONDS := 3.5
## The start value of each new Voyage of the main scene in the tests, so the Labyrinths of a new
## Voyage are the same in each run.
const VOYAGE_START_VALUE := 2026


## Adds the main scene, goes through the opening screen, and waits for the end of the fade-in of the
## current Labyrinth, so the Child can sail. It loads and saves in `save_dir`, never in user://. With
## no `save_dir`, it uses a new folder in the OS temp folder with a save of the fixed Labyrinth 1
## (fixed_labyrinth_1_dir()), so the tests can name the squares of that Labyrinth. A test of a launch
## with no save passes an empty folder of Fixtures.new_save_dir().
static func add_main(t, save_dir: String = "") -> Node:
	var main := await add_main_at_opening(t, save_dir)
	t.assert_true(await start_from_opening(t, main), "the fade-in after the start press ends")
	return main


## Adds the main scene with the opening screen on it, and sets the test time scale. It loads and
## saves like add_main(). Each new Voyage of the scene uses VOYAGE_START_VALUE.
static func add_main_at_opening(t, save_dir: String = "") -> Node:
	var main: Node = load("res://main.tscn").instantiate()
	main.save_store = SaveStore.new(save_dir if not save_dir.is_empty() else fixed_labyrinth_1_dir())
	main.voyage_start_value = func() -> int: return VOYAGE_START_VALUE
	t.root.add_child(main)
	await t.process_frame
	Engine.time_scale = TIME_SCALE
	return main


## A new folder in the OS temp folder with a save of Labyrinth 1 of the fixed seed table, with no
## collected Items: the Labyrinth of tests/test_items.gd, with its Items on (1, 1) and (0, 2).
static func fixed_labyrinth_1_dir() -> String:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(Progress.new())
	return dir


## Goes through the opening screen (game-flow spec part 3): presses Space, and waits for the end of
## the fade-in of the current Labyrinth. Returns true when the fade-in ends in time.
static func start_from_opening(t, main: Node) -> bool:
	t.assert_true(main.is_opening_shown(), "the opening screen shows")
	send_key(KEY_SPACE)
	return await t.wait_for(main.labyrinth_ready, MOVE_TIMEOUT)


## Removes the main scene and its save folder, and ends a pause of the settings. Then it waits a
## short real time, so the audio server frees the stopped music playbacks before the runner exits.
static func remove(t, main: Node) -> void:
	Engine.time_scale = 1.0
	t.paused = false
	var save_dir: String = main.save_store.dir
	main.queue_free()
	await t.process_frame
	Fixtures.remove_save_dir(save_dir)
	await t.create_timer(AUDIO_FREE_SECONDS, true, false, true).timeout


## Presses and releases a key.
static func send_key(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		Input.parse_input_event(event)
	Input.flush_buffered_events()


## Records the start of each move of `main`: "move_started" for a slide, "bumped" for a bump. Both
## fire when the move starts, so the list shows a move before it ends.
static func record_moves(main: Node) -> Array:
	var moves := []
	main.move_started.connect(func() -> void: moves.append("move_started"))
	main.bumped.connect(func() -> void: moves.append("bumped"))
	return moves


## Presses and releases an arrow key. Returns true when the boat is free again in time.
static func press(t, main: Node, key: Key) -> bool:
	send_key(key)
	return await t.wait_for(main.move_finished, MOVE_TIMEOUT)


## Collects all Items of the shown Labyrinth, then sails to the open chest. The presses follow
## the shortest press path of the move rule to the next uncollected Item, then to the Goal. A visit
## to the locked chest on the way does no harm (game-flow spec Part 2). Returns true when the boat
## arrives at the open chest and the Goal celebration starts. Returns false if a move is not over in
## time or the boat needs too many presses.
static func sail_to_goal(t, main: Node) -> bool:
	var reached := [false]
	var on_goal := func(_friend: String) -> void: reached[0] = true
	main.goal_reached.connect(on_goal, CONNECT_ONE_SHOT)
	var labyrinth: Labyrinth = main.labyrinth
	for presses in 100:
		if reached[0]:
			break
		var direction := first_press(labyrinth, main.boat_square, main.progress.item_states(labyrinth))
		if direction == Vector2i.ZERO or not await press(t, main, key_for(direction)):
			break
	if main.goal_reached.is_connected(on_goal):
		main.goal_reached.disconnect(on_goal)
	return reached[0]


## Presses the arrow keys along the main path until the boat is on the Goal square. The boat
## collects only the Items on the main path, so the chest can still be locked. Returns false if a
## move is not over in time or the boat needs too many presses.
static func sail_main_path_to_goal(t, main: Node) -> bool:
	var labyrinth: Labyrinth = main.labyrinth
	for presses in 100:
		if main.boat_square == labyrinth.goal_square():
			return true
		if not await press(t, main, key_for(next_step(labyrinth, main.boat_square))):
			return false
	return false


## The first press on the shortest press path from `from` to the next target: an uncollected Item,
## or the Goal when all Items are collected. `items` has the shape of MoveRule.plan(). Each press
## follows the move rule, so the boat stops on each uncollected Item and on the Goal. Returns ZERO
## when the boat is on a target or no target is in reach.
static func first_press(labyrinth: Labyrinth, from: Vector2i, items: Dictionary) -> Vector2i:
	var targets := {}
	for square: Vector2i in items:
		if not items[square]:
			targets[square] = true
	if targets.is_empty():
		targets[labyrinth.goal_square()] = true
	var path := MoveRule.nearest_target(labyrinth, from, items, targets)
	return Vector2i.ZERO if path == null else path.first_press


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
