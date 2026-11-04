## The settings file of spec 12.4: settings.json in one folder, with the volume steps. The game uses
## the folder of the save file (user://). Tests pass their own folder, so they never touch the real
## settings. A Parent reset does not change this file.
class_name SettingsStore
extends RefCounted

## Schema version of settings.json.
const VERSION := 1
const SETTINGS_FILE := "settings.json"
const TMP_FILE := "settings.json.tmp"
## The migration chain of settings.json, separate from the chain of save.json (spec 12.4):
## migrations[i] turns a file of version i + 1 into version i + 2. Version 1 is the first version,
## so the chain is empty now.
static var migrations: Array[Callable] = []

## The folder of the settings file.
var dir: String
## True after load_settings() finds a file of a newer build (spec 12.4). The store then writes no
## file for the rest of the session, so the newer file stays correct.
var no_write := false


func _init(settings_dir: String = "user://") -> void:
	dir = settings_dir


func settings_path() -> String:
	return dir.path_join(SETTINGS_FILE)


func tmp_path() -> String:
	return dir.path_join(TMP_FILE)


## Writes the steps to settings.json.tmp, closes it, then renames it to settings.json, like the save
## file (spec 12.3). In the no-write state, the call writes nothing and logs one warning.
func save(settings: VolumeSettings) -> Error:
	if no_write:
		push_warning("The settings were not saved: settings.json is from a newer build.")
		return OK
	return JsonFile.write(to_dictionary(settings), settings_path(), tmp_path())


## Loads the steps. An absent or broken file gives the default steps, and the load writes no file.
## A file with a version above VERSION is from a newer build: it gives the default steps, it stays
## in place, and the store goes into the no-write state.
func load_settings() -> VolumeSettings:
	if not FileAccess.file_exists(settings_path()):
		return VolumeSettings.new()
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(settings_path())) != OK:
		return VolumeSettings.new()
	if JsonFile.version_of(json.data) > VERSION:
		no_write = true
		return VolumeSettings.new()
	var settings := from_dictionary(json.data)
	return settings if settings != null else VolumeSettings.new()


static func to_dictionary(settings: VolumeSettings) -> Dictionary:
	return {
		"version": VERSION,
		"music_step": settings.music_step,
		"effects_step": settings.effects_step,
	}


## The steps of a parsed settings.json, or null when the file is broken: not a dictionary, a version
## of 0 or less, a step absent or not a whole number, or a step outside 0 to 4. A version above
## VERSION also gives null: this build cannot read it. An older version goes through `migrations`
## first. JSON reads each number as a float, so the numbers become int here.
static func from_dictionary(data: Variant) -> VolumeSettings:
	var version := JsonFile.version_of(data)
	if version < 1 or version > VERSION:
		return null
	data = JsonFile.migrate(data, version, migrations, VERSION)
	for field in ["music_step", "effects_step"]:
		if not JsonFile.is_whole_number(data.get(field)):
			return null
		if int(data[field]) < 0 or int(data[field]) > VolumeSettings.MAX_STEP:
			return null
	var settings := VolumeSettings.new()
	settings.music_step = int(data["music_step"])
	settings.effects_step = int(data["effects_step"])
	return settings
