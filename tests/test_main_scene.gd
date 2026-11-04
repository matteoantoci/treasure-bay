## The main scene: the arrow keys sail the boat by the move rule, and the Goal starts the next
## Labyrinth (ticket 20). The keys go in through Input.parse_input_event (spec 14.1 test 5).
## The move rule durations are in test_move_rule.gd.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")


func test_starts_labyrinth_1_with_the_boat_on_the_start(t) -> bool:
	var main := await Scene.add_main(t)
	t.assert_eq(main.progress.labyrinth_number, 1, "Labyrinth number")
	t.assert_eq(Scene.wall_list(main.labyrinth), Scene.wall_list(LabyrinthPlan.build(1)), "Labyrinth 1 walls")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "boat on the start square")
	t.assert_eq(main.texture_filter, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "texture filter of spec 3.5")
	await Scene.remove(t, main)
	return true


func test_arrow_keys_sail_labyrinth_1_to_the_goal(t) -> bool:
	var main := await Scene.add_main(t)
	# Labyrinth 1 (see test_generator.gd): the start has only its south side open. Its Items are on
	# (2, 1) and (1, 2) (see test_items.gd).
	t.assert_true(await Scene.press(t, main, KEY_RIGHT), "bump is over")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "a bump keeps the boat on its square")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "move down is over")
	t.assert_eq(main.boat_square, Vector2i(0, 2), "one press slides down to the bend")
	t.assert_true(await Scene.press(t, main, KEY_RIGHT), "move right is over")
	t.assert_eq(main.boat_square, Vector2i(1, 2), "the boat stops on the Item")
	t.assert_true(await Scene.press(t, main, KEY_RIGHT), "move right is over")
	t.assert_eq(main.boat_square, Vector2i(3, 2), "the next press slides on to the Goal")
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "the next Labyrinth starts")
	t.assert_eq(main.progress.labyrinth_number, 2, "the Goal starts Labyrinth 2")
	t.assert_eq(Scene.wall_list(main.labyrinth), Scene.wall_list(LabyrinthPlan.build(2)), "Labyrinth 2 walls")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "boat on the start square of Labyrinth 2")
	await Scene.remove(t, main)
	return true


func test_sailing_each_goal_starts_the_next_labyrinth(t) -> bool:
	var main := await Scene.add_main(t)
	for number in [1, 2, 3]:
		t.assert_eq(main.progress.labyrinth_number, number, "Labyrinth %d started" % number)
		var presses := 0
		while main.boat_square != main.labyrinth.goal_square() and presses < 50:
			var direction := Scene.next_step(main.labyrinth, main.boat_square)
			var before: Vector2i = main.boat_square
			var expected := MoveRule.plan(main.labyrinth, before, direction, main.progress.item_states(main.labyrinth)).target
			t.assert_true(await Scene.press(t, main, Scene.key_for(direction)), "move is over")
			t.assert_eq(main.boat_square, expected, "the boat stops where the move rule says")
			presses += 1
		t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth %d starts" % (number + 1))
	t.assert_eq(main.progress.labyrinth_number, 4, "Labyrinth 4 after 3 Goals")
	t.assert_eq(main.labyrinth.width, LabyrinthPlan.size_for(4).x, "Labyrinth 4 width")
	await Scene.remove(t, main)
	return true
