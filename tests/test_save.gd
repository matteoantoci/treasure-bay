## Test 7 of spec 14.1: the save file of spec 12. Each test uses its own folder in the OS temp
## folder, never user://.
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")
const Scene := preload("res://tests/scene_helpers.gd")
const WarningLog := preload("res://tests/warning_log.gd")


func test_a_save_and_a_load_give_the_same_state(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var store := SaveStore.new(dir)
	for progress in [_progress_7(), _progress_voyage()]:
		t.assert_eq(store.save(progress), OK, "save of Labyrinth %d" % progress.labyrinth_number)
		var loaded := SaveStore.new(dir).load_progress()
		t.assert_eq(loaded.labyrinth_number, progress.labyrinth_number, "Labyrinth number")
		t.assert_eq(loaded.seeds, progress.seeds, "seeds of the Voyage of Labyrinth %d" % progress.labyrinth_number)
		t.assert_eq(loaded.collected_items, progress.collected_items, "collected Items of Labyrinth %d" % progress.labyrinth_number)
		t.assert_eq(loaded.collection, progress.collection, "Collection")
		t.assert_eq(loaded.total_items, progress.total_items, "total Items")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.bak")), "a good file makes no save.bak")
	Fixtures.remove_save_dir(dir)
	return true


func test_the_file_has_the_fields_of_spec_12_1(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join("save.json")))
	t.assert_eq(data, {
		"version": 2.0,
		"labyrinth": 7.0,
		"seeds": _floats(LabyrinthPlan.FIXED_SEEDS),
		"collected_items": [_item_ids(7)[0]],
		"collection": ["crab", "octopus", "spouting_whale", "whale", "dolphin", "fish"],
		"total_items": 23.0,
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


## A save of a newer build is not broken (spec 12.3). It stays in place with the same bytes, and
## the game plays Labyrinth 1 in memory. The store writes nothing in this session, and each save
## call logs one warning.
func test_a_newer_save_stays_and_the_store_writes_nothing(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var save_path := dir.path_join("save.json")
	var data := _good_data()
	data["version"] = 3
	# A newer build can change a field, so a field that version 2 calls broken does not count.
	data["labyrinth"] = "seven"
	data["a_new_field"] = true
	var text := JSON.stringify(data)
	_write(save_path, text)
	var store := SaveStore.new(dir)
	var progress := store.load_progress()
	t.assert_eq(SaveStore.to_dictionary(progress), SaveStore.to_dictionary(Progress.new()), "Labyrinth 1 with nothing collected")
	var log := WarningLog.new()
	log.start()
	store.save(_progress_7())
	progress.collect_item("0,2")
	store.save(progress)
	log.stop()
	t.assert_eq(log.warnings().size(), 2, "each save call logs one warning")
	t.assert_eq(FileAccess.get_file_as_string(save_path), text, "save.json has the same bytes")
	t.assert_eq(DirAccess.get_files_at(dir), PackedStringArray(["save.json"]), "no save.bak and no other file")
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
	var progress := _progress_voyage()
	t.assert_true(SaveStore.new(dir).save(progress) != OK, "the rename fails")
	t.assert_eq(JSON.parse_string(FileAccess.get_file_as_string(tmp_path)), JSON.parse_string(JSON.stringify(SaveStore.to_dictionary(progress))), "the .tmp file holds the new state")
	Fixtures.remove_save_dir(dir)
	return true


func test_after_a_reload_a_collected_item_does_not_count_again(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var progress := Progress.new()
	# Labyrinth 1 has its Items on 1,1 and 0,2 (tests/test_items.gd).
	progress.collect_item("0,2")
	SaveStore.new(dir).save(progress)
	var loaded := SaveStore.new(dir).load_progress()
	t.assert_true(not loaded.collect_item("0,2"), "the saved Item does not count again")
	t.assert_eq(loaded.total_items, 1, "total Items")
	t.assert_eq(loaded.item_states(loaded.build_labyrinth()), {Vector2i(1, 1): false, Vector2i(0, 2): true}, "Item 0,2 stays collected")
	t.assert_true(loaded.collect_item("1,1"), "the other Item counts")
	t.assert_eq(loaded.total_items, 2, "total Items after the other Item")
	Fixtures.remove_save_dir(dir)
	return true


## A save from before the Goal rule of spec 4.2 can name a square that has no Item now. The load
## drops that ID and keeps all other fields, also the total count. The file is not broken.
func test_an_old_item_id_with_no_item_now_is_dropped(t) -> bool:
	var dir := Fixtures.new_save_dir()
	# Before the Goal rule, Labyrinth 1 had its Items on 2,1 and 1,2, and Labyrinth 14 on 3,3, 4,1,
	# 1,1, 0,2, 2,2, and 4,3. With the seed table of play-improvements Part 3, 4,1 is an Item, and
	# 2,1, 1,2, 3,3, and 4,3 are not.
	for old in [[1, ["2,1", "1,2"], []], [14, ["3,3", "4,1", "4,3"], ["4,1"]]]:
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
	# The Goal of Labyrinth 20 gives a new Voyage.
	progress.labyrinth_number = 20
	progress.collection = SeaFriends.IDS.slice(0, 19)
	progress.reach_goal(4242)
	store.save(progress)
	loaded = store.load_progress()
	t.assert_eq(loaded.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(loaded.seeds, DifficultyCurve.new_voyage(4242), "the seeds of the new Voyage")
	t.assert_eq(loaded.collection, PackedStringArray(), "an empty Collection")
	t.assert_eq(loaded.total_items, 1, "the same total")
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
	_reset(panel)
	t.assert_true(main.progress.is_fresh(), "a new Voyage: Labyrinth 1, an empty Collection, a total of 0")
	t.assert_eq(SaveStore.to_dictionary(SaveStore.new(dir).load_progress()), SaveStore.to_dictionary(main.progress), "the save holds Labyrinth 1 after the reset")
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("settings.json")), settings_text, "settings.json is the same")
	t.assert_eq([panel.settings.music_step, panel.settings.effects_step], [4, 0], "the volume steps stay")
	t.assert_true(AudioServer.is_bus_mute(AudioServer.get_bus_index(Sound.EFFECTS_BUS)), "the effects stay muted")
	await Scene.remove(t, main)
	return true


## Spec 11.2: before the reset writes the new save, the game keeps the old save file as
## save.before-reset.json. The Parent can restore it by hand.
func test_a_reset_keeps_a_copy_of_the_old_save(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var old_text := FileAccess.get_file_as_string(dir.path_join("save.json"))
	var main := await Scene.add_main(t, dir)
	_reset(main.get_node("Settings"))
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("save.before-reset.json")), old_text, "the copy has the bytes of the old save")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.before-reset.json.tmp")), "the rename leaves no .tmp file")
	t.assert_eq(SaveStore.to_dictionary(SaveStore.new(dir).load_progress()), SaveStore.to_dictionary(main.progress), "save.json holds Labyrinth 1")
	# The Parent restores the copy by hand: rename it to save.json.
	DirAccess.rename_absolute(dir.path_join("save.before-reset.json"), dir.path_join("save.json"))
	t.assert_eq(SaveStore.to_dictionary(SaveStore.new(dir).load_progress()), _good_data(), "the renamed copy loads as the old progress")
	await Scene.remove(t, main)
	return true


## The copy goes to save.before-reset.json.tmp first, then a rename makes it
## save.before-reset.json. A folder in place of the copy makes the rename fail, so the old progress
## stays in the .tmp file.
func test_the_copy_goes_to_the_tmp_file_first(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var old_text := FileAccess.get_file_as_string(dir.path_join("save.json"))
	DirAccess.make_dir_absolute(dir.path_join("save.before-reset.json"))
	DirAccess.make_dir_absolute(dir.path_join("save.before-reset.json").path_join("keep"))
	var main := await Scene.add_main(t, dir)
	_reset(main.get_node("Settings"))
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("save.before-reset.json.tmp")), old_text, "the .tmp file holds the old save")
	await Scene.remove(t, main)
	return true


## A reset of fresh progress (Labyrinth 1, an empty Collection, a total of 0) keeps the older copy.
## So a second reset after a reset by mistake does not replace the real Collection.
func test_two_resets_in_a_row_keep_the_first_copy(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var old_text := FileAccess.get_file_as_string(dir.path_join("save.json"))
	var main := await Scene.add_main(t, dir)
	var panel: SettingsPanel = main.get_node("Settings")
	_reset(panel)
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "the fade-in after the first reset ends")
	_reset(panel)
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("save.before-reset.json")), old_text, "the copy still holds the progress from before the first reset")
	await Scene.remove(t, main)
	return true


## A reset after new play replaces the older copy: one collected Item is not fresh progress.
func test_a_reset_after_new_play_replaces_the_copy(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var main := await Scene.add_main(t, dir)
	var panel: SettingsPanel = main.get_node("Settings")
	_reset(panel)
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "the fade-in after the first reset ends")
	# Labyrinth 1 of the new Voyage: the boat sails the main path to its first Item.
	t.assert_true(await _sail_to_an_item(t, main), "the Child collects an Item")
	var new_text := FileAccess.get_file_as_string(dir.path_join("save.json"))
	t.assert_eq(SaveStore.new(dir).load_progress().total_items, 1, "the save holds the new Item")
	_reset(panel)
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("save.before-reset.json")), new_text, "the copy holds the new play")
	await Scene.remove(t, main)
	return true


## With no save file, the reset makes no copy.
func test_a_reset_with_no_save_file_makes_no_copy(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var main := await Scene.add_main(t, dir)
	# Progress that is not fresh, with no save file yet.
	main.progress.collect_item("0,2")
	_reset(main.get_node("Settings"))
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.before-reset.json")), "no copy")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.before-reset.json.tmp")), "no .tmp copy")
	t.assert_true(FileAccess.file_exists(dir.path_join("save.json")), "the reset writes the save")
	await Scene.remove(t, main)
	return true


## A save of a newer build puts the save store in the no-write state (spec 12.3). Then the reset makes
## no copy and writes no save: the newer save stays with the same bytes.
func test_in_the_no_write_state_a_reset_makes_no_copy_and_writes_no_save(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var data := _good_data()
	data["version"] = 3
	var newer_text := JSON.stringify(data)
	_write(dir.path_join("save.json"), newer_text)
	var main := await Scene.add_main(t, dir)
	# Labyrinth 1: down stops on the Item 0,2, so the progress is not fresh.
	await Scene.press(t, main, KEY_DOWN)
	t.assert_eq(main.progress.total_items, 1, "the Child collects an Item")
	_reset(main.get_node("Settings"))
	t.assert_eq(main.progress.total_items, 0, "the reset goes on in memory")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.before-reset.json")), "no copy")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.before-reset.json.tmp")), "no .tmp copy")
	t.assert_eq(FileAccess.get_file_as_string(dir.path_join("save.json")), newer_text, "save.json has the same bytes")
	await Scene.remove(t, main)
	return true


## A later save schema adds its first migration to the chain (spec 12.3). A chain of one test
## migration turns a version 1 save into version 2.
func test_a_chain_of_one_migration_turns_version_1_into_version_2(t) -> bool:
	var to_version_2 := func(data: Dictionary) -> Dictionary:
		var migrated := data.duplicate()
		migrated["version"] = 2
		migrated["labyrinth_number"] = migrated["labyrinth"]
		migrated.erase("labyrinth")
		migrated["music_seen"] = false
		return migrated
	var chain: Array[Callable] = [to_version_2]
	var version_1 := {"version": 1, "labyrinth": 7, "total_items": 23}
	t.assert_eq(JsonFile.migrate(version_1, 1, chain, 2), {"version": 2, "labyrinth_number": 7, "total_items": 23, "music_seen": false}, "the migrated fields")
	return true


## The Item IDs of Labyrinth `number`.
func _item_ids(number: int, seeds: Array[int] = LabyrinthPlan.FIXED_SEEDS) -> PackedStringArray:
	var ids := PackedStringArray()
	for item in LabyrinthPlan.build(number, seeds).items:
		ids.append(item.id)
	return ids


func _progress_7() -> Progress:
	var progress := Progress.new()
	progress.labyrinth_number = 7
	progress.collected_items = PackedStringArray([_item_ids(7)[0]])
	progress.collection = SeaFriends.IDS.slice(0, 6)
	progress.total_items = 23
	return progress


## Labyrinth 18 of a new Voyage, with a fixed start value.
func _progress_voyage() -> Progress:
	var progress := Progress.new_voyage(4242, 123)
	progress.labyrinth_number = 18
	progress.collected_items = _item_ids(18, progress.seeds).slice(0, 2)
	progress.collection = SeaFriends.IDS.slice(0, 17)
	return progress


func _floats(values: Array[int]) -> Array:
	var floats := []
	for value in values:
		floats.append(float(value))
	return floats


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
		"seeds": 17,
		"collected_items": _item_ids(7)[0],
		"collection": "crab",
		"total_items": 2.5,
	}
	for field in wrong_types:
		var data := _good_data()
		data[field] = wrong_types[field]
		files["wrong type of %s" % field] = JSON.stringify(data)
	var cases := {
		"labyrinth 7.5": {"labyrinth": 7.5},
		"an Item ID that is a number": {"collected_items": [3]},
		"a Sea friend ID that is a number": {"collection": [1]},
		"version 0": {"version": 0},
		"version -1": {"version": -1},
		"labyrinth 0": {"labyrinth": 0},
		"labyrinth 21": {"labyrinth": 21, "collected_items": []},
		"19 seeds": {"seeds": LabyrinthPlan.FIXED_SEEDS.slice(0, 19)},
		"21 seeds": {"seeds": LabyrinthPlan.FIXED_SEEDS + [5]},
		"a seed of 0": {"seeds": [0] + LabyrinthPlan.FIXED_SEEDS.slice(1)},
		"a seed of -3": {"seeds": [-3] + LabyrinthPlan.FIXED_SEEDS.slice(1)},
		"a seed that is not a number": {"seeds": ["1"] + LabyrinthPlan.FIXED_SEEDS.slice(1)},
		"a seed of 1.5": {"seeds": [1.5] + LabyrinthPlan.FIXED_SEEDS.slice(1)},
		"an Item ID outside the Labyrinth": {"collected_items": ["9,9"]},
		"the start square as an Item ID": {"collected_items": ["0,0"]},
		"the Goal square as an Item ID": {"collected_items": ["5,3"]},
		"an Item ID that is not x,y": {"collected_items": ["shell"]},
		"an Item ID with a sign": {"collected_items": ["+1,2"]},
		"a Sea friend ID not in spec 4.7": {"collection": ["crab", "unicorn"]},
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


## Sails `main` along the main path until the boat collects an Item. Each Labyrinth has an Item on
## its main path (section 4.6 rule 3). Returns false if no Item comes.
func _sail_to_an_item(t, main: Node) -> bool:
	var total: int = main.progress.total_items
	while main.progress.total_items == total and main.boat_square != main.labyrinth.goal_square():
		if not await Scene.press(t, main, Scene.key_for(Scene.next_step(main.labyrinth, main.boat_square))):
			return false
	return main.progress.total_items > total


## Holds the reset button for its whole hold time, through the fake clock of HoldButton.
func _reset(panel: SettingsPanel) -> void:
	panel.open()
	panel.reset_button.button_down.emit()
	panel.reset_button.advance(panel.reset_button.hold_seconds)
	panel.reset_button.button_up.emit()


## Game-flow spec Part 1, migration 1 to 2: a version 1 save in Labyrinths 1 to 20 keeps its
## Labyrinth, its Items and its Collection, with the fixed seed table.
func test_a_version_1_save_in_labyrinths_1_to_20_keeps_its_labyrinth(t) -> bool:
	var dir := Fixtures.new_save_dir()
	for number in [1, 14, 20]:
		var items := _item_ids(number).slice(0, 2)
		_write(dir.path_join("save.json"), JSON.stringify({
			"version": 1, "labyrinth": number, "random_seed": 0, "collected_items": items,
			"collection": SeaFriends.IDS.slice(0, number - 1), "total_items": 40, "last_returning_friend": "",
		}))
		var progress := SaveStore.new(dir).load_progress()
		var label := "version 1 save of Labyrinth %d" % number
		t.assert_eq(progress.labyrinth_number, number, label + ": Labyrinth")
		t.assert_eq(progress.seeds, LabyrinthPlan.FIXED_SEEDS, label + ": the fixed seed table")
		t.assert_eq(progress.collected_items, items, label + ": collected Items")
		t.assert_eq(progress.collection, SeaFriends.IDS.slice(0, number - 1), label + ": Collection")
		t.assert_eq(progress.total_items, 40, label + ": total")
		t.assert_true(not FileAccess.file_exists(dir.path_join("save.bak")), label + ": not broken")
	Fixtures.remove_save_dir(dir)
	return true


## Game-flow spec Part 1, migration 1 to 2: a version 1 save past Labyrinth 20 becomes a new Voyage
## with the same total.
func test_a_version_1_save_past_labyrinth_20_becomes_a_new_voyage(t) -> bool:
	var dir := Fixtures.new_save_dir()
	_write(dir.path_join("save.json"), JSON.stringify({
		"version": 1, "labyrinth": 34, "random_seed": 4242, "collected_items": ["1,1"],
		"collection": SeaFriends.IDS, "total_items": 260, "last_returning_friend": "crab",
	}))
	var progress := SaveStore.new(dir).load_progress()
	t.assert_eq(progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(progress.seeds.size(), 20, "20 seeds")
	for n in range(1, 21):
		t.assert_true(DifficultyCurve.meets_conditions(n, progress.seeds[n - 1]), "the seed of slot %d meets its conditions" % n)
	t.assert_eq(progress.collected_items, PackedStringArray(), "no collected Items")
	t.assert_eq(progress.collection, PackedStringArray(), "an empty Collection")
	t.assert_eq(progress.total_items, 260, "the same total")
	t.assert_true(not FileAccess.file_exists(dir.path_join("save.bak")), "not broken")
	Fixtures.remove_save_dir(dir)
	return true
