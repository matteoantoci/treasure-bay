## Test 7 of spec 14.1: the save file of spec 12. Each test uses its own folder in the OS temp
## folder, never user://.
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")
const Scene := preload("res://tests/scene_helpers.gd")


func test_a_save_and_a_load_give_the_same_state(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var store := SaveStore.new(dir)
	for progress in [_progress_7(), _progress_25()]:
		t.assert_eq(store.save(progress), OK, "save of Labyrinth %d" % progress.labyrinth_number)
		var loaded := SaveStore.new(dir).load_progress()
		t.assert_eq(loaded.labyrinth_number, progress.labyrinth_number, "Labyrinth number")
		t.assert_eq(loaded.random_seed, progress.random_seed, "random seed of Labyrinth %d" % progress.labyrinth_number)
		t.assert_eq(loaded.collected_items, progress.collected_items, "collected Items of Labyrinth %d" % progress.labyrinth_number)
		t.assert_eq(loaded.collection, progress.collection, "Collection")
		t.assert_eq(loaded.total_items, progress.total_items, "total Items")
		t.assert_eq(loaded.last_returning_friend, progress.last_returning_friend, "last returning Sea friend")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.bak")), "a good file makes no save.bak")
	Fixtures.remove_save_dir(dir)
	return true


func test_the_file_has_the_fields_of_spec_12_1(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join("save.json")))
	t.assert_eq(data, {
		"version": 1.0,
		"labyrinth": 7.0,
		"random_seed": 0.0,
		"collected_items": [_item_ids(7)[0]],
		"collection": ["crab", "octopus", "spouting_whale", "whale", "dolphin", "fish"],
		"total_items": 23.0,
		"last_returning_friend": "",
	}, "save.json")
	Fixtures.remove_save_dir(dir)
	return true


func test_no_file_gives_labyrinth_1(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var progress := SaveStore.new(dir).load_progress()
	t.assert_eq(SaveStore.to_dictionary(progress), SaveStore.to_dictionary(Progress.new()), "a new progress")
	t.assert_eq(progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(DirAccess.get_files_at(dir), PackedStringArray(), "the load writes no file")
	Fixtures.remove_save_dir(dir)
	return true


func test_each_broken_file_becomes_save_bak_and_gives_labyrinth_1(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var save_path := dir.path_join("save.json")
	var bak_path := dir.path_join("save.bak")
	# The good file loads, so each broken case below fails by its one change.
	_write(save_path, JSON.stringify(_good_data()))
	t.assert_eq(SaveStore.new(dir).load_progress().labyrinth_number, 7, "the good file loads")
	for case_name in _broken_files():
		var text: String = _broken_files()[case_name]
		_write(save_path, text)
		_write(bak_path, "an older save.bak")
		var progress := SaveStore.new(dir).load_progress()
		t.assert_eq(SaveStore.to_dictionary(progress), SaveStore.to_dictionary(Progress.new()), "%s: Labyrinth 1 with nothing collected" % case_name)
		t.assert_true(not FileAccess.file_exists(save_path), "%s: save.json is gone" % case_name)
		t.assert_eq(FileAccess.get_file_as_string(bak_path), text, "%s: save.bak holds the broken file" % case_name)
	Fixtures.remove_save_dir(dir)
	return true


func test_version_2_counts_as_broken(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var data := _good_data()
	data["version"] = 2
	var text := JSON.stringify(data)
	_write(dir.path_join("save.json"), text)
	t.assert_eq(SaveStore.new(dir).load_progress().labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("save.bak")), text, "the version 2 file is save.bak")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.json")), "save.json is gone")
	Fixtures.remove_save_dir(dir)
	return true


func test_the_write_goes_to_the_tmp_file_first(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var tmp_path := dir.path_join("save.json.tmp")
	t.assert_eq(SaveStore.new(dir).save(_progress_7()), OK, "save")
	t.assert_true(FileAccess.file_exists(dir.path_join("save.json")), "save.json exists")
	t.assert_true(not FileAccess.file_exists(tmp_path), "the rename leaves no .tmp file")
	# A folder in place of save.json makes the rename fail. The new state is then in the .tmp file:
	# the write went there first.
	Fixtures.remove_save_dir(dir)
	dir = Fixtures.new_save_dir()
	tmp_path = dir.path_join("save.json.tmp")
	DirAccess.make_dir_absolute(dir.path_join("save.json"))
	DirAccess.make_dir_absolute(dir.path_join("save.json").path_join("keep"))
	var progress := _progress_25()
	t.assert_true(SaveStore.new(dir).save(progress) != OK, "the rename fails")
	t.assert_eq(JSON.parse_string(FileAccess.get_file_as_string(tmp_path)), JSON.parse_string(JSON.stringify(SaveStore.to_dictionary(progress))), "the .tmp file holds the new state")
	Fixtures.remove_save_dir(dir)
	return true


func test_after_a_reload_a_collected_item_does_not_count_again(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var progress := Progress.new()
	# Labyrinth 1 has its Items on 1,1 and 1,2 (tests/test_items.gd).
	progress.collect_item("1,2")
	SaveStore.new(dir).save(progress)
	var loaded := SaveStore.new(dir).load_progress()
	t.assert_true(not loaded.collect_item("1,2"), "the saved Item does not count again")
	t.assert_eq(loaded.total_items, 1, "total Items")
	t.assert_eq(loaded.item_states(loaded.build_labyrinth()), {Vector2i(1, 1): false, Vector2i(1, 2): true}, "Item 1,2 stays collected")
	t.assert_true(loaded.collect_item("1,1"), "the other Item counts")
	t.assert_eq(loaded.total_items, 2, "total Items after the other Item")
	Fixtures.remove_save_dir(dir)
	return true


## A save from before the Goal rule of spec 4.2 can name a square that has no Item now. The load
## drops that ID and keeps all other fields, also the total count. The file is not broken.
func test_an_old_item_id_with_no_item_now_is_dropped(t) -> bool:
	var dir := Fixtures.new_save_dir()
	# Before the Goal rule, Labyrinth 1 had its Items on 2,1 and 1,2, and Labyrinth 14 on 3,3, 4,1,
	# 1,1, 0,2, 2,2, and 4,3. Now 1,2 and 1,1 are still Items, and 2,1, 3,3, and 4,1 are not.
	for old in [[1, ["2,1", "1,2"], ["1,2"]], [14, ["3,3", "4,1", "1,1"], ["1,1"]]]:
		var data := _good_data()
		data.merge({"labyrinth": old[0], "collected_items": old[1]}, true)
		_write(dir.path_join("save.json"), JSON.stringify(data))
		var progress := SaveStore.new(dir).load_progress()
		var label := "old save of Labyrinth %d" % old[0]
		t.assert_eq(progress.labyrinth_number, old[0], label + ": Labyrinth")
		t.assert_eq(progress.collected_items, PackedStringArray(old[2]), label + ": only the IDs of Items stay")
		t.assert_eq(progress.collection, PackedStringArray(data["collection"]), label + ": Collection")
		t.assert_eq(progress.total_items, 23, label + ": the total count stays")
		t.assert_true(FileAccess.file_exists(dir.path_join("save.json")), label + ": save.json stays")
		t.assert_true(not FileAccess.file_exists(dir.path_join("save.bak")), label + ": no save.bak")
	Fixtures.remove_save_dir(dir)
	return true


func test_a_goal_save_holds_the_new_sea_friend_and_the_next_labyrinth(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var store := SaveStore.new(dir)
	var progress := Progress.new()
	progress.labyrinth_number = 3
	progress.collection = PackedStringArray(["crab", "octopus"])
	progress.collect_item(_item_ids(3)[0])
	progress.reach_goal()
	store.save(progress)
	var loaded := store.load_progress()
	t.assert_eq(loaded.labyrinth_number, 4, "Labyrinth 3 + 1")
	t.assert_eq(loaded.collection, PackedStringArray(["crab", "octopus", "spouting_whale"]), "the new Sea friend is in the Collection")
	t.assert_eq(loaded.collected_items, PackedStringArray(), "no collected Items in Labyrinth 4")
	t.assert_eq(loaded.random_seed, 0, "no random seed for Labyrinth 4")
	# The Goal of Labyrinth 20 gives a random seed for Labyrinth 21.
	progress.labyrinth_number = 20
	progress.collection = SeaFriends.IDS.slice(0, 19)
	progress.reach_goal()
	store.save(progress)
	loaded = store.load_progress()
	t.assert_eq(loaded.labyrinth_number, 21, "Labyrinth 21")
	t.assert_eq(loaded.collection, SeaFriends.IDS, "all 20 Sea friends")
	t.assert_true(loaded.random_seed != 0, "Labyrinth 21 has its random seed")
	t.assert_eq(loaded.random_seed, progress.random_seed, "the saved random seed")
	# After Labyrinth 20, the save holds the Sea friend that came back.
	var friend := progress.reach_goal()
	store.save(progress)
	loaded = store.load_progress()
	t.assert_eq(loaded.labyrinth_number, 22, "Labyrinth 22")
	t.assert_eq(loaded.last_returning_friend, friend, "the Sea friend that came back")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.bak")), "each Goal save loads as a good file")
	Fixtures.remove_save_dir(dir)
	return true


## A Parent reset writes a save of Labyrinth 1 and does not change settings.json (spec 12.4).
func test_a_reset_keeps_settings_json(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var settings_text := "{\"version\": 1, \"music_step\": 4, \"effects_step\": 0}"
	_write(dir.path_join("settings.json"), settings_text)
	var main := await Scene.add_main(t, dir)
	var panel: SettingsPanel = main.get_node("Settings")
	panel.open()
	panel.reset_button.button_down.emit()
	panel.reset_button.advance(HoldButton.HOLD_SECONDS)
	panel.reset_button.button_up.emit()
	t.assert_eq(SaveStore.to_dictionary(SaveStore.new(dir).load_progress()), SaveStore.to_dictionary(Progress.new()), "the save holds Labyrinth 1 after the reset")
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("settings.json")), settings_text, "settings.json is the same")
	t.assert_eq([panel.settings.music_step, panel.settings.effects_step], [4, 0], "the volume steps stay")
	t.assert_true(AudioServer.is_bus_mute(AudioServer.get_bus_index(Sound.EFFECTS_BUS)), "the effects stay muted")
	await Scene.remove(t, main)
	return true


## The Item IDs of Labyrinth `number`.
func _item_ids(number: int, random_seed: int = 0) -> PackedStringArray:
	var ids := PackedStringArray()
	for item in LabyrinthPlan.build(number, random_seed).items:
		ids.append(item.id)
	return ids


func _progress_7() -> Progress:
	var progress := Progress.new()
	progress.labyrinth_number = 7
	progress.collected_items = PackedStringArray([_item_ids(7)[0]])
	progress.collection = SeaFriends.IDS.slice(0, 6)
	progress.total_items = 23
	return progress


func _progress_25() -> Progress:
	var progress := Progress.new()
	progress.labyrinth_number = 25
	progress.random_seed = 4242
	progress.collected_items = _item_ids(25, 4242).slice(0, 2)
	progress.collection = SeaFriends.IDS
	progress.total_items = 123
	progress.last_returning_friend = "crab"
	return progress


## The file of _progress_7() as a dictionary.
func _good_data() -> Dictionary:
	return SaveStore.to_dictionary(_progress_7())


## Each case of spec 12.3: case name -> the text of save.json.
func _broken_files() -> Dictionary:
	var files := {
		"no JSON": "{\"version\": 1, \"labyrinth\": ",
		"not a dictionary": "[1, 7]",
	}
	for field in _good_data():
		var data := _good_data()
		data.erase(field)
		files["no field %s" % field] = JSON.stringify(data)
	var wrong_types := {
		"version": "1",
		"labyrinth": "7",
		"random_seed": null,
		"collected_items": _item_ids(7)[0],
		"collection": "crab",
		"total_items": 2.5,
		"last_returning_friend": 0,
	}
	for field in wrong_types:
		var data := _good_data()
		data[field] = wrong_types[field]
		files["wrong type of %s" % field] = JSON.stringify(data)
	var cases := {
		"labyrinth 7.5": {"labyrinth": 7.5},
		"an Item ID that is a number": {"collected_items": [3]},
		"a Sea friend ID that is a number": {"collection": [1]},
		"version 2": {"version": 2},
		"version 0": {"version": 0},
		"labyrinth 0": {"labyrinth": 0},
		"labyrinth 21 with random seed 0": {"labyrinth": 21, "random_seed": 0, "collected_items": []},
		"an Item ID outside the Labyrinth": {"collected_items": ["9,9"]},
		"the start square as an Item ID": {"collected_items": ["0,0"]},
		"the Goal square as an Item ID": {"collected_items": ["5,3"]},
		"an Item ID that is not x,y": {"collected_items": ["shell"]},
		"an Item ID with a sign": {"collected_items": ["+1,2"]},
		"a Sea friend ID not in spec 4.7": {"collection": ["crab", "unicorn"]},
		"a last returning Sea friend not in spec 4.7": {"last_returning_friend": "unicorn"},
	}
	for case_name in cases:
		var data := _good_data()
		data.merge(cases[case_name], true)
		files[case_name] = JSON.stringify(data)
	return files


func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
