## The write, the number check, the version rules and the migration runner that save.json and
## settings.json share (spec 12.3, 12.4).
class_name JsonFile
extends RefCounted


## Writes `data` as JSON to `tmp_path`, closes it, then renames it to `path`. A crash leaves the old
## file or the new one, never half a file (spec 12.3). The folder of `path` is made first.
static func write(data: Dictionary, path: String, tmp_path: String) -> Error:
	return write_text(JSON.stringify(data, "  "), path, tmp_path)


## Writes `text` to `tmp_path`, closes it, then renames it to `path`, with the rule of write().
static func write_text(text: String, path: String, tmp_path: String) -> Error:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var written := file.store_string(text)
	file.close()
	if not written:
		return ERR_FILE_CANT_WRITE
	return DirAccess.rename_absolute(tmp_path, path)


## True for an int, or for a finite float with no fraction. JSON reads each number as a float.
static func is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	return value is float and is_finite(value) and value == floorf(value)


## The "version" of a parsed file, or 0 when the file is not a dictionary or its version is absent
## or not a whole number. A version of 0 or less is not a real version: the file is broken.
static func version_of(data: Variant) -> int:
	if not data is Dictionary or not is_whole_number(data.get("version")):
		return 0
	return int(data["version"])


## Runs `chain` on `data`, version by version, from `version` up to `target`. chain[i] turns a file
## of version i + 1 into version i + 2. Each entry takes the dictionary and returns the new one.
static func migrate(data: Dictionary, version: int, chain: Array[Callable], target: int) -> Dictionary:
	while version < target:
		data = chain[version - 1].call(data)
		version += 1
	return data
