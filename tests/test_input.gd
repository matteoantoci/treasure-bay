## Test 5 of spec 14.1, the input rules of spec 5.4: the key events go in through
## Input.parse_input_event(). An echo does nothing. While the boat is busy, the game keeps only the
## last press. While the input is locked, the game drops each press and does not keep it.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
## Long enough for a move of Labyrinth 1 (at most 4 tiles, 0.72 s) at the test time scale.
const NO_MOVE_SECONDS := 0.25


## Records the boat square at each move_finished.
func _record_moves(main: Node) -> Array:
	var squares := []
	main.move_finished.connect(func() -> void: squares.append(main.boat_square))
	return squares


func test_an_echo_does_nothing(t) -> bool:
	var main := await Scene.add_main(t)
	var event := InputEventKey.new()
	event.physical_keycode = KEY_DOWN
	event.keycode = KEY_DOWN
	event.pressed = true
	event.echo = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	t.assert_true(not await t.wait_for(main.move_finished, NO_MOVE_SECONDS), "no move")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat stays on the start square")
	await Scene.remove(t, main)
	return true


func test_while_the_boat_is_busy_only_the_last_press_is_kept(t) -> bool:
	var main := await Scene.add_main(t)
	var squares := _record_moves(main)
	# Labyrinth 1: down slides from (0, 0) to the bend (0, 2). From there, left is a bump and right
	# stops on the Item (1, 2).
	Scene.send_key(KEY_DOWN)
	Scene.send_key(KEY_LEFT)
	Scene.send_key(KEY_RIGHT)
	t.assert_true(await t.wait_for(main.move_finished, Scene.MOVE_TIMEOUT), "the slide down is over")
	t.assert_true(await t.wait_for(main.move_finished, Scene.MOVE_TIMEOUT), "the kept press runs")
	t.assert_true(not await t.wait_for(main.move_finished, NO_MOVE_SECONDS), "no third move")
	t.assert_eq(squares, [Vector2i(0, 2), Vector2i(1, 2)], "the slide down, then only the last press (right)")
	await Scene.remove(t, main)
	return true


func test_a_flying_item_does_not_make_the_boat_busy(t) -> bool:
	var main := await Scene.add_main(t)
	await Scene.press(t, main, KEY_DOWN)
	t.assert_true(await Scene.press(t, main, KEY_RIGHT), "the boat stops on the Item")
	t.assert_eq(main.progress.total_items, 1, "the Item is collected and flies to its outline")
	# A press while the Item flies runs at once: the boat turns to the left at the press.
	Scene.send_key(KEY_LEFT)
	t.assert_true(is_equal_approx(main.get_node("Boat").rotation, MoveRule.rotation_for(Vector2i.LEFT)), "the boat turns at the press")
	t.assert_true(await t.wait_for(main.move_finished, Scene.MOVE_TIMEOUT), "the move is over")
	t.assert_eq(main.boat_square, Vector2i(0, 2), "the boat sails back to the bend")
	await Scene.remove(t, main)
	return true


func test_presses_are_dropped_from_the_goal_to_the_end_of_the_fade_in(t) -> bool:
	var main := await Scene.add_main(t)
	var squares := _record_moves(main)
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	squares.clear()
	# During the celebration.
	Scene.send_key(KEY_LEFT)
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 2 shows")
	# During the fade-in of Labyrinth 2.
	Scene.send_key(KEY_DOWN)
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.NEXT_LABYRINTH_TIMEOUT), "the fade-in ends")
	t.assert_true(not await t.wait_for(main.move_finished, NO_MOVE_SECONDS), "no dropped press runs later")
	t.assert_eq(squares, [], "no move from the Goal to the end of the fade-in")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat waits on the start square of Labyrinth 2")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "after the fade-in, a press moves the boat")
	await Scene.remove(t, main)
	return true
