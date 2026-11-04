## The write and the number check that save.json and settings.json share (spec 12.3, 12.4).
class_name JsonFile
extends RefCounted


## Writes `data` as JSON to `tmp_path`, closes it, then renames it to `path`. A crash leaves the old
## file or the new one, never half a file (spec 12.3). The folder of `path` is made first.
static func write(data: Dictionary, path: String, tmp_path: String) -> Error:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var written := file.store_string(JSON.stringify(data, "  "))
	file.close()
	if not written:
		return ERR_FILE_CANT_WRITE
	return DirAccess.rename_absolute(tmp_path, path)


## True for an int, or for a finite float with no fraction. JSON reads each number as a float.
static func is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	return value is float and is_finite(value) and value == floorf(value)
