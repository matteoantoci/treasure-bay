## The settings file of spec 12.4: settings.json in one folder, with the volume steps. The game uses
## the folder of the save file (user://). Tests pass their own folder, so they never touch the real
## settings. A Parent reset does not change this file.
class_name SettingsStore
extends RefCounted

## Schema version of settings.json.
const VERSION := 1
const SETTINGS_FILE := "settings.json"
const TMP_FILE := "settings.json.tmp"

## The folder of the settings file.
var dir: String


func _init(settings_dir: String = "user://") -> void:
	dir = settings_dir


func settings_path() -> String:
	return dir.path_join(SETTINGS_FILE)


func tmp_path() -> String:
	return dir.path_join(TMP_FILE)


## Writes the steps to settings.json.tmp, closes it, then renames it to settings.json, like the save
## file (spec 12.3).
func save(settings: VolumeSettings) -> Error:
	DirAccess.make_dir_recursive_absolute(dir)
	var file := FileAccess.open(tmp_path(), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var written := file.store_string(JSON.stringify(to_dictionary(settings), "  "))
	file.close()
	if not written:
		return ERR_FILE_CANT_WRITE
	return DirAccess.rename_absolute(tmp_path(), settings_path())


## Loads the steps. An absent or broken file gives the default steps, and the load writes no file.
func load_settings() -> VolumeSettings:
	if not FileAccess.file_exists(settings_path()):
		return VolumeSettings.new()
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(settings_path())) != OK:
		return VolumeSettings.new()
	var settings := from_dictionary(json.data)
	return settings if settings != null else VolumeSettings.new()


static func to_dictionary(settings: VolumeSettings) -> Dictionary:
	return {
		"version": VERSION,
		"music_step": settings.music_step,
		"effects_step": settings.effects_step,
	}


## The steps of a parsed settings.json, or null when the file is broken: not a dictionary, a field
## absent or not a whole number, a version other than 1, or a step outside 0 to 4. JSON reads each
## number as a float, so the numbers become int here.
static func from_dictionary(data: Variant) -> VolumeSettings:
	if not data is Dictionary:
		return null
	for field in ["version", "music_step", "effects_step"]:
		if not _is_whole_number(data.get(field)):
			return null
	if int(data["version"]) != VERSION:
		return null
	var settings := VolumeSettings.new()
	for field in ["music_step", "effects_step"]:
		if int(data[field]) < 0 or int(data[field]) > VolumeSettings.MAX_STEP:
			return null
	settings.music_step = int(data["music_step"])
	settings.effects_step = int(data["effects_step"])
	return settings


static func _is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	return value is float and is_finite(value) and value == floorf(value)
