## The save file of the progress (spec 12.1 and 12.3): save.json in one folder. The game uses
## user://. Tests pass their own folder, so they never touch the real save.
class_name SaveStore
extends RefCounted

## Schema version of save.json.
const VERSION := 1
const SAVE_FILE := "save.json"
const TMP_FILE := "save.json.tmp"
## Holds only a broken file, never a last good copy (spec 12.3).
const BROKEN_FILE := "save.bak"
## MIGRATIONS[i] turns a save of version i + 1 into version i + 2 (spec 12.3). Version 1 is the
## first version, so the chain is empty.
const MIGRATIONS: Array[Callable] = []

## The folder of the save files.
var dir: String


func _init(save_dir: String = "user://") -> void:
	dir = save_dir


func save_path() -> String:
	return dir.path_join(SAVE_FILE)


func tmp_path() -> String:
	return dir.path_join(TMP_FILE)


func broken_path() -> String:
	return dir.path_join(BROKEN_FILE)


## Writes `progress` to save.json.tmp, closes it, then renames it to save.json. A crash leaves the
## old save.json or the new one, never half a file.
func save(progress: Progress) -> Error:
	DirAccess.make_dir_recursive_absolute(dir)
	var file := FileAccess.open(tmp_path(), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var written := file.store_string(JSON.stringify(to_dictionary(progress), "  "))
	file.close()
	if not written:
		return ERR_FILE_CANT_WRITE
	return DirAccess.rename_absolute(tmp_path(), save_path())


## Loads the progress. With no save.json, the game starts at Labyrinth 1. A broken or newer file
## becomes save.bak (it replaces an older save.bak), and the game starts at Labyrinth 1. The Child
## gets no message.
func load_progress() -> Progress:
	if not FileAccess.file_exists(save_path()):
		return Progress.new()
	var json := JSON.new()
	var progress: Progress = null
	if json.parse(FileAccess.get_file_as_string(save_path())) == OK:
		progress = from_dictionary(json.data)
	if progress == null:
		_keep_broken_file()
		return Progress.new()
	return progress


static func to_dictionary(progress: Progress) -> Dictionary:
	return {
		"version": VERSION,
		"labyrinth": progress.labyrinth_number,
		"random_seed": progress.random_seed,
		"collected_items": Array(progress.collected_items),
		"collection": Array(progress.collection),
		"total_items": progress.total_items,
		"last_returning_friend": progress.last_returning_friend,
	}


## The progress of a parsed save.json, or null when the file is broken (spec 12.3): not a
## dictionary, a field absent or of the wrong type, a version above VERSION, a Labyrinth below 1, a
## random Labyrinth with seed 0, an Item ID that is not a square where an Item can be, or a Sea
## friend ID that is not in spec 4.7. An Item ID of a square with no Item now is dropped: a save
## from before the Goal rule of spec 4.2 can have one. JSON reads each number as a float, so the
## numbers become int here.
static func from_dictionary(data: Variant) -> Progress:
	if not data is Dictionary or not _is_whole_number(data.get("version")):
		return null
	var version := int(data["version"])
	if version < 1 or version > VERSION:
		return null
	data = migrate(data, version)
	for field in ["labyrinth", "random_seed", "total_items"]:
		if not _is_whole_number(data.get(field)):
			return null
	for field in ["collected_items", "collection"]:
		if not _is_string_list(data.get(field)):
			return null
	if not data.get("last_returning_friend") is String:
		return null
	var progress := Progress.new()
	progress.labyrinth_number = int(data["labyrinth"])
	progress.random_seed = int(data["random_seed"])
	progress.collected_items = PackedStringArray(data["collected_items"])
	progress.collection = PackedStringArray(data["collection"])
	progress.total_items = int(data["total_items"])
	progress.last_returning_friend = data["last_returning_friend"]
	if progress.labyrinth_number < 1:
		return null
	if LabyrinthPlan.is_random(progress.labyrinth_number) and progress.random_seed == 0:
		return null
	var labyrinth := progress.build_labyrinth()
	var item_ids := PackedStringArray()
	for item in labyrinth.items:
		item_ids.append(item.id)
	var kept := PackedStringArray()
	for id in progress.collected_items:
		if not _is_free_square_id(labyrinth, id):
			return null
		if item_ids.has(id):
			kept.append(id)
	progress.collected_items = kept
	for id in progress.collection:
		if not SeaFriends.IDS.has(id):
			return null
	if progress.last_returning_friend != "" and not SeaFriends.IDS.has(progress.last_returning_friend):
		return null
	return progress


## Runs the chain of MIGRATIONS from `version` up to VERSION.
static func migrate(data: Dictionary, version: int) -> Dictionary:
	while version < VERSION:
		data = MIGRATIONS[version - 1].call(data)
		version += 1
	return data


## True if `id` is the "x,y" ID of a square where an Item can be: inside `labyrinth`, and not the
## start square or the Goal square (spec 4.6 rule 4).
static func _is_free_square_id(labyrinth: Labyrinth, id: String) -> bool:
	var parts := id.split(",")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return false
	var square := Vector2i(parts[0].to_int(), parts[1].to_int())
	if Item.id_of(square) != id or not labyrinth.contains(square):
		return false
	return square != labyrinth.start_square() and square != labyrinth.goal_square()


func _keep_broken_file() -> void:
	if FileAccess.file_exists(broken_path()):
		DirAccess.remove_absolute(broken_path())
	DirAccess.rename_absolute(save_path(), broken_path())


static func _is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	return value is float and is_finite(value) and value == floorf(value)


static func _is_string_list(value: Variant) -> bool:
	if not value is Array:
		return false
	for entry in value:
		if not entry is String:
			return false
	return true
