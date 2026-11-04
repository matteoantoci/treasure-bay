## The main scene with the save file (spec 12): it starts at the saved Labyrinth, and it saves after
## each Item and at each Goal. Each scene saves to its own folder in the OS temp folder.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const Fixtures := preload("res://tests/fixtures.gd")
const WarningLog := preload("res://tests/warning_log.gd")


func test_a_restart_continues_at_the_saved_labyrinth(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var saved := Progress.new()
	saved.labyrinth_number = 7
	var items := saved.build_labyrinth().items
	saved.collect_item(items[1].id)
	saved.collection = SeaFriends.IDS.slice(0, 6)
	saved.total_items = 23
	SaveStore.new(dir).save(saved)
	var main := await Scene.add_main(t, dir)
	t.assert_eq(main.progress.labyrinth_number, 7, "Labyrinth 7")
	t.assert_eq(_ids(main.labyrinth), _ids(LabyrinthPlan.build(7)), "the Items of Labyrinth 7")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat is on the start square")
	var filled: Array[bool] = []
	for i in items.size():
		filled.append(i == 1)
	t.assert_eq(main.get_node("ItemRow").filled, filled, "the collected Item fills its outline")
	t.assert_true(not main.get_node("Items").shown_ids().has(items[1].id), "the collected Item is not on the water")
	t.assert_eq(main.get_node("Items").shown_ids().size(), items.size() - 1, "the other Items are on the water")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), SeaFriends.IDS.slice(0, 6), "6 Sea friends in the strip")
	t.assert_eq(main.get_node("CollectionStrip").count_text(), "23", "total count")
	await Scene.remove(t, main)
	return true


func test_a_restart_continues_at_the_saved_random_labyrinth_with_its_seed(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var saved := Progress.new()
	saved.labyrinth_number = 25
	saved.random_seed = 4242
	saved.collection = SeaFriends.IDS
	saved.last_returning_friend = "crab"
	SaveStore.new(dir).save(saved)
	var main := await Scene.add_main(t, dir)
	t.assert_eq(main.progress.labyrinth_number, 25, "Labyrinth 25")
	t.assert_eq(main.progress.random_seed, 4242, "random seed")
	t.assert_eq(main.progress.last_returning_friend, "crab", "last returning Sea friend")
	t.assert_eq(_ids(main.labyrinth), _ids(LabyrinthPlan.build(25, 4242)), "the Labyrinth of seed 4242")
	t.assert_eq(Scene.wall_list(main.labyrinth), Scene.wall_list(LabyrinthPlan.build(25, 4242)), "the walls of seed 4242")
	await Scene.remove(t, main)
	return true


func test_a_broken_file_starts_at_labyrinth_1(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var file := FileAccess.open(dir.path_join("save.json"), FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	var main := await Scene.add_main(t, dir)
	t.assert_eq(main.progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("save.bak")), "{broken", "save.bak holds the broken file")
	await Scene.remove(t, main)
	return true


## A save from before the Goal rule of spec 4.2: Labyrinth 14 with the old Items 3,3, 4,1, and 4,3
## collected. Now 4,3 is Item 1 of 6, and 3,3 and 4,1 hold no Item.
func test_an_old_save_starts_at_its_labyrinth_with_its_count(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var file := FileAccess.open(dir.path_join("save.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"version": 1, "labyrinth": 14, "random_seed": 0, "collected_items": ["3,3", "4,1", "4,3"],
		"collection": SeaFriends.IDS.slice(0, 13), "total_items": 40, "last_returning_friend": "",
	}))
	file.close()
	var main := await Scene.add_main(t, dir)
	t.assert_eq(main.progress.labyrinth_number, 14, "Labyrinth 14")
	t.assert_eq(main.get_node("CollectionStrip").count_text(), "40", "the total count stays")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), SeaFriends.IDS.slice(0, 13), "13 Sea friends in the strip")
	t.assert_eq(main.get_node("ItemRow").filled, [true, false, false, false, false, false] as Array[bool], "only Item 4,3 fills its outline")
	t.assert_eq(main.get_node("Items").shown_ids(), PackedStringArray(["3,1", "6,0", "6,1", "0,4", "6,4"]), "the other 5 Items are on the water")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.bak")), "the old save is not broken")
	await Scene.remove(t, main)
	return true


func test_the_scene_saves_after_each_item(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var main := await Scene.add_main(t, dir)
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.json")), "no save before an Item")
	var saved := []
	main.item_collected.connect(func(_item: Item) -> void: saved.append(SaveStore.new(dir).load_progress().collected_items))
	# Labyrinth 1: down stops on the Item 0,2 (tests/test_main_rewards.gd).
	await Scene.press(t, main, KEY_DOWN)
	t.assert_eq(saved, [PackedStringArray(["0,2"])], "the save holds the Item when item_collected fires")
	var loaded := SaveStore.new(dir).load_progress()
	t.assert_eq(loaded.labyrinth_number, 1, "saved Labyrinth")
	t.assert_eq(loaded.total_items, 1, "saved total Items")
	await Scene.remove(t, main)
	return true


func test_the_scene_saves_at_the_goal_before_the_celebration(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var main := await Scene.add_main(t, dir)
	var saved := []
	main.goal_reached.connect(func(_friend: String) -> void: saved.append(SaveStore.to_dictionary(SaveStore.new(dir).load_progress())))
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	t.assert_eq(saved.size(), 1, "one Goal")
	t.assert_eq(saved[0]["labyrinth"], 2, "the save holds Labyrinth 2 when the celebration starts")
	t.assert_eq(saved[0]["collection"], ["crab"], "the save holds the crab")
	t.assert_eq(saved[0]["collected_items"], [], "no collected Items in Labyrinth 2")
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 2 starts")
	await Scene.remove(t, main)
	return true


## Test 10 of the play improvements: a save of a newer build stays in place with the same bytes, and
## no save.bak exists. The game plays Labyrinth 1 in memory. A collect and a Goal write nothing,
## and each save call logs one warning (spec 12.3).
func test_a_newer_save_plays_labyrinth_1_and_writes_nothing(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var save_path := dir.path_join("save.json")
	var text := JSON.stringify({"version": 2, "labyrinth": 9, "a_new_field": [1, 2]})
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
	var main := await Scene.add_main(t, dir)
	t.assert_eq(main.progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(_ids(main.labyrinth), _ids(LabyrinthPlan.build(1)), "the Items of Labyrinth 1")
	var save_calls := [0]
	main.item_collected.connect(func(_item: Item) -> void: save_calls[0] += 1)
	main.goal_reached.connect(func(_friend: String) -> void: save_calls[0] += 1)
	var log := WarningLog.new()
	log.start()
	# Labyrinth 1: down stops on the Item 0,2 (tests/test_main_rewards.gd).
	await Scene.press(t, main, KEY_DOWN)
	t.assert_eq(main.progress.collected_items, PackedStringArray(["0,2"]), "the Item is collected in memory")
	t.assert_eq(FileAccess.get_file_as_string(save_path), text, "the collect writes nothing")
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	log.stop()
	t.assert_eq(main.progress.labyrinth_number, 2, "Labyrinth 2 in memory")
	t.assert_eq(FileAccess.get_file_as_string(save_path), text, "the Goal writes nothing")
	t.assert_eq(DirAccess.get_files_at(dir), PackedStringArray(["save.json"]), "no save.bak and no other file")
	t.assert_true(save_calls[0] >= 2, "a collect and a Goal")
	t.assert_eq(log.warnings().size(), save_calls[0], "each save call logs one warning")
	await Scene.remove(t, main)
	return true


func _ids(labyrinth: Labyrinth) -> Array:
	var ids := [labyrinth.width, labyrinth.height]
	for item in labyrinth.items:
		ids.append(item.id)
	return ids
