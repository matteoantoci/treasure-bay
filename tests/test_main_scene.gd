## The main scene: the arrow keys sail the boat by the move rule, and the Goal starts the next
## Labyrinth (ticket 20). The keys go in through Input.parse_input_event (spec 14.1 test 5).
extends RefCounted

## Tweens run faster, so the test takes less time. The move rule durations are in test_move_rule.gd.
const TIME_SCALE := 8.0
const MOVE_TIMEOUT := 10.0


func test_starts_labyrinth_1_with_the_boat_on_the_start(t) -> bool:
	var main := await _add_main(t)
	t.assert_eq(main.labyrinth_number, 1, "Labyrinth number")
	t.assert_eq(_wall_list(main.labyrinth), _wall_list(LabyrinthPlan.build(1)), "Labyrinth 1 walls")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "boat on the start square")
	t.assert_eq(main.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "texture filter of spec 3.5")
	await _remove(t, main)
	return true


func test_arrow_keys_sail_labyrinth_1_to_the_goal(t) -> bool:
	var main := await _add_main(t)
	Engine.time_scale = TIME_SCALE
	# Labyrinth 1 (see test_generator.gd): the start has only its south side open.
	t.assert_true(await _press(t, main, KEY_RIGHT), "bump is over")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "a bump keeps the boat on its square")
	t.assert_true(await _press(t, main, KEY_DOWN), "move down is over")
	t.assert_eq(main.boat_square, Vector2i(0, 2), "one press slides down to the bend")
	t.assert_true(await _press(t, main, KEY_RIGHT), "move right is over")
	t.assert_eq(main.labyrinth_number, 2, "the Goal starts Labyrinth 2")
	t.assert_eq(_wall_list(main.labyrinth), _wall_list(LabyrinthPlan.build(2)), "Labyrinth 2 walls")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "boat on the start square of Labyrinth 2")
	Engine.time_scale = 1.0
	await _remove(t, main)
	return true


func test_sailing_each_goal_starts_the_next_labyrinth(t) -> bool:
	var main := await _add_main(t)
	Engine.time_scale = TIME_SCALE
	for number in [1, 2, 3]:
		t.assert_eq(main.labyrinth_number, number, "Labyrinth %d started" % number)
		var presses := 0
		while main.labyrinth_number == number and presses < 50:
			var direction := _next_step(main.labyrinth, main.boat_square)
			var before: Vector2i = main.boat_square
			t.assert_true(await _press(t, main, _key_for(direction)), "move is over")
			if main.labyrinth_number == number:
				var expected := MoveRule.plan(main.labyrinth, before, direction).target
				t.assert_eq(main.boat_square, expected, "the boat stops where the move rule says")
			presses += 1
	t.assert_eq(main.labyrinth_number, 4, "Labyrinth 4 after 3 Goals")
	t.assert_eq(main.labyrinth.width, LabyrinthPlan.size_for(4).x, "Labyrinth 4 width")
	Engine.time_scale = 1.0
	await _remove(t, main)
	return true


func _add_main(t) -> Node:
	var main: Node = load("res://main.tscn").instantiate()
	t.root.add_child(main)
	await t.process_frame
	return main


func _remove(t, main: Node) -> void:
	main.queue_free()
	await t.process_frame


## Presses and releases an arrow key. Returns true when the boat is free again in time.
func _press(t, main: Node, key: Key) -> bool:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		Input.parse_input_event(event)
	Input.flush_buffered_events()
	return await t.wait_for(main.move_finished, MOVE_TIMEOUT)


## The direction of the first step on the path from `from` to the Goal.
func _next_step(labyrinth: Labyrinth, from: Vector2i) -> Vector2i:
	var distances := labyrinth.distances_from(labyrinth.goal_square())
	var here := distances[from.y * labyrinth.width + from.x]
	for direction in Labyrinth.DIRECTIONS:
		var next := from + direction
		if not labyrinth.has_wall(from, direction) and distances[next.y * labyrinth.width + next.x] == here - 1:
			return direction
	return Vector2i.ZERO


func _key_for(direction: Vector2i) -> Key:
	match direction:
		Vector2i.UP:
			return KEY_UP
		Vector2i.DOWN:
			return KEY_DOWN
		Vector2i.LEFT:
			return KEY_LEFT
	return KEY_RIGHT


func _wall_list(labyrinth: Labyrinth) -> Array:
	var bits := []
	for y in labyrinth.height:
		for x in labyrinth.width:
			bits.append(labyrinth.wall_bits(Vector2i(x, y)))
	return bits
