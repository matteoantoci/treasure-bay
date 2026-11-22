## The main scene with Items, the Item row, and the Collection strip (spec 6): Items fill their
## outlines and count one time, the Sea friend of each Goal joins the strip, and the Goal of
## Labyrinth 20 starts a new Voyage (game-flow spec Part 1).
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const Fixtures := preload("res://tests/fixtures.gd")


func test_labyrinth_1_shows_its_items_and_empty_outlines(t) -> bool:
	var main := await Scene.add_main(t)
	t.assert_eq(main.get_node("Items").shown_ids(), PackedStringArray(["1,1", "0,2"]), "Items on the water")
	t.assert_eq(main.get_node("ItemRow").kinds, PackedStringArray(["spiral_shell", "starfish"]), "outline kinds")
	t.assert_eq(main.get_node("ItemRow").filled, [false, false] as Array[bool], "no outline is filled")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), PackedStringArray(), "empty strip")
	t.assert_eq(main.get_node("CollectionStrip").count_text(), "0", "total count")
	await Scene.remove(t, main)
	return true


func test_an_item_fills_its_outline_and_counts_one_time(t) -> bool:
	var main := await Scene.add_main(t)
	var collected := []
	main.item_collected.connect(func(item: Item) -> void: collected.append(item.id))
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "move down is over")
	t.assert_eq(main.boat_square, Vector2i(0, 2), "the boat stops on the Item")
	t.assert_eq(collected, ["0,2"], "item_collected fired for Item 0,2")
	t.assert_eq(main.progress.total_items, 1, "total Items")
	t.assert_eq(main.get_node("ItemRow").filled, [false, true] as Array[bool], "Item 2 fills outline 2")
	t.assert_eq(main.get_node("Items").shown_ids(), PackedStringArray(["1,1"]), "Item 0,2 left the water")
	t.assert_eq(main.get_node("CollectionStrip").count_text(), "1", "total count")
	# Back to the square of the collected Item: it does not count again.
	t.assert_true(await Scene.press(t, main, KEY_UP), "move up is over")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "back on the start square")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "move down is over")
	t.assert_eq(main.boat_square, Vector2i(0, 2), "back at the bend")
	t.assert_eq(collected, ["0,2"], "no second item_collected")
	t.assert_eq(main.progress.total_items, 1, "the Item counts one time")
	t.assert_eq(main.get_node("ItemRow").filled, [false, true] as Array[bool], "the row does not change")
	await Scene.remove(t, main)
	return true


func test_goal_of_labyrinth_1_brings_the_crab_to_the_strip(t) -> bool:
	var main := await Scene.add_main(t)
	var reached := []
	main.goal_reached.connect(func(friend: String) -> void: reached.append([friend, main.progress.labyrinth_number]))
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	t.assert_eq(reached, [["crab", 2]], "goal_reached gives the crab, after the progress moved to Labyrinth 2")
	t.assert_eq(main.progress.collection, PackedStringArray(["crab"]), "Collection")
	# The input is locked during the celebration: a press does not move the boat.
	var moves := Scene.record_moves(main)
	Scene.send_key(KEY_LEFT)
	await t.create_timer(Scene.NO_MOVE_SECONDS).timeout
	t.assert_eq(moves, [], "no move and no bump during the celebration")
	t.assert_eq(main.boat_square, main.labyrinth.goal_square(), "the boat stays on the Goal")
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 2 starts, and its fade-in ends")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), PackedStringArray(["crab"]), "the crab is in its slot")
	t.assert_eq(main.get_node("ItemRow").filled, [false, false] as Array[bool], "Labyrinth 2 starts with empty outlines")
	t.assert_eq(main.get_node("Items").shown_ids(), PackedStringArray(["0,1", "2,1"]), "Items of Labyrinth 2")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat is on the start square")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "the input is free again")
	await Scene.remove(t, main)
	return true


func test_goal_of_labyrinth_20_adds_the_flamingo_and_starts_a_new_voyage(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var main := await Scene.add_main(t, dir)
	var progress := Progress.new()
	progress.labyrinth_number = 20
	progress.collection = SeaFriends.IDS.slice(0, 19)
	progress.total_items = 150
	main.progress = progress
	main.show_labyrinth()
	t.assert_eq(main.get_node("CollectionStrip").shown_friends().size(), 19, "19 Sea friends in the strip")
	var friends := []
	main.sea_friend_appeared.connect(func(friend: String) -> void: friends.append(friend))
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed Labyrinth 20 to the Goal")
	var saved := SaveStore.new(dir).load_progress()
	t.assert_eq(saved.labyrinth_number, 1, "the save at the Goal holds Labyrinth 1 of the new Voyage")
	t.assert_eq(saved.collection, PackedStringArray(), "the save holds an empty Collection")
	var total: int = main.progress.total_items
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "the next Labyrinth starts")
	t.assert_eq(friends, ["flamingo"], "the flamingo appears")
	t.assert_eq(main.progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_true(main.progress.seeds != LabyrinthPlan.FIXED_SEEDS, "the new Voyage has new seeds")
	t.assert_eq(main.labyrinth.seed_value, main.progress.seeds[0], "Labyrinth 1 uses the seed of slot 1")
	t.assert_eq(Vector2i(main.labyrinth.width, main.labyrinth.height), Vector2i(4, 3), "Labyrinth 1 is 4 x 3")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), PackedStringArray(), "an empty strip")
	t.assert_eq(main.get_node("CollectionStrip").count_text(), str(total), "the same total count")
	t.assert_true(total >= 150, "the total count stays")
	await Scene.remove(t, main)
	Fixtures.remove_save_dir(dir)
	return true
