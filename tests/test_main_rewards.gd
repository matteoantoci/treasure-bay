## The main scene with Items, the Item row, and the Collection strip (spec 6): Items fill their
## outlines and count one time, the Sea friend of each Goal joins the strip, and after
## Labyrinth 20 a Sea friend comes back.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const LOCK_CHECK_SECONDS := 0.1


func test_labyrinth_1_shows_its_items_and_empty_outlines(t) -> bool:
	var main := await Scene.add_main(t)
	t.assert_eq(main.get_node("Items").shown_ids(), PackedStringArray(["2,1", "1,2"]), "Items on the water")
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
	await Scene.press(t, main, KEY_DOWN)
	t.assert_true(await Scene.press(t, main, KEY_RIGHT), "move right is over")
	t.assert_eq(main.boat_square, Vector2i(1, 2), "the boat stops on the Item")
	t.assert_eq(collected, ["1,2"], "item_collected fired for Item 1,2")
	t.assert_eq(main.progress.total_items, 1, "total Items")
	t.assert_eq(main.get_node("ItemRow").filled, [false, true] as Array[bool], "Item 2 fills outline 2")
	t.assert_eq(main.get_node("Items").shown_ids(), PackedStringArray(["2,1"]), "Item 1,2 left the water")
	t.assert_eq(main.get_node("CollectionStrip").count_text(), "1", "total count")
	# Back over the collected Item: the boat does not stop on it, and it does not count again.
	t.assert_true(await Scene.press(t, main, KEY_LEFT), "move left is over")
	t.assert_eq(main.boat_square, Vector2i(0, 2), "back at the bend")
	t.assert_true(await Scene.press(t, main, KEY_RIGHT), "move right is over")
	t.assert_eq(main.boat_square, Vector2i(3, 2), "the boat passes the collected Item")
	t.assert_eq(collected, ["1,2"], "no second item_collected")
	t.assert_eq(main.progress.total_items, 1, "the Item counts one time")
	t.assert_eq(main.get_node("ItemRow").filled, [false, true] as Array[bool], "the row does not change")
	await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT)
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
	Scene.send_key(KEY_LEFT)
	t.assert_true(not await t.wait_for(main.move_finished, LOCK_CHECK_SECONDS), "no move during the celebration")
	t.assert_eq(main.boat_square, main.labyrinth.goal_square(), "the boat stays on the Goal")
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 2 starts")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), PackedStringArray(["crab"]), "the crab is in its slot")
	t.assert_eq(main.get_node("ItemRow").filled, [false, false] as Array[bool], "Labyrinth 2 starts with empty outlines")
	t.assert_eq(main.get_node("Items").shown_ids(), PackedStringArray(["0,2", "2,1"]), "Items of Labyrinth 2")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat is on the start square")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "the input is free again")
	await Scene.remove(t, main)
	return true


func test_goal_of_labyrinth_20_completes_the_strip_and_starts_a_random_labyrinth(t) -> bool:
	var main := await Scene.add_main(t)
	var progress := Progress.new()
	progress.labyrinth_number = 20
	progress.collection = SeaFriends.IDS.slice(0, 19)
	main.progress = progress
	main.show_labyrinth()
	t.assert_eq(main.get_node("CollectionStrip").shown_friends().size(), 19, "19 Sea friends in the strip")
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed Labyrinth 20 to the Goal")
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 21 starts")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), SeaFriends.IDS, "all 20 Sea friends in the strip")
	t.assert_eq(main.progress.labyrinth_number, 21, "Labyrinth 21")
	t.assert_true(main.progress.random_seed != 0, "Labyrinth 21 has a random seed")
	t.assert_eq(Vector2i(main.labyrinth.width, main.labyrinth.height), Vector2i(10, 7), "Labyrinth 21 is 10 x 7")
	t.assert_eq(main.labyrinth.items.size(), 8, "Labyrinth 21 has 8 Items")
	await Scene.remove(t, main)
	return true


func test_after_labyrinth_20_a_different_sea_friend_comes_back(t) -> bool:
	var main := await Scene.add_main(t)
	var progress := Progress.new()
	progress.labyrinth_number = 25
	progress.random_seed = 4242
	progress.collection = SeaFriends.IDS
	progress.last_returning_friend = "crab"
	main.progress = progress
	main.show_labyrinth()
	var reached := []
	main.goal_reached.connect(func(friend: String) -> void: reached.append(friend))
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed Labyrinth 25 to the Goal")
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 26 starts")
	t.assert_eq(reached.size(), 1, "one Goal")
	t.assert_true(SeaFriends.IDS.has(reached[0]) and reached[0] != "crab", "a Sea friend of the Collection comes back, not the crab")
	t.assert_eq(main.progress.last_returning_friend, reached[0], "last returning Sea friend")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), SeaFriends.IDS, "the strip does not grow")
	t.assert_eq(main.progress.labyrinth_number, 26, "Labyrinth 26")
	t.assert_eq(main.get_node("ItemRow").kinds, PackedStringArray(["coral", "sand_dollar", "coral", "sand_dollar", "coral", "sand_dollar", "coral", "sand_dollar"]), "Labyrinth 26 has the Items of Area 2")
	await Scene.remove(t, main)
	return true
