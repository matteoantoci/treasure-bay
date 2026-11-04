## Helpers that several test files share. The runner does not run this file.
extends RefCounted

static var _save_dir_count := 0


## A new empty folder for save files in the OS temp folder. Tests never use user://, the folder of
## the real save of the Child.
static func new_save_dir() -> String:
	_save_dir_count += 1
	var dir := OS.get_temp_dir().path_join("labyrinth-test-saves-%d-%d" % [OS.get_process_id(), _save_dir_count])
	remove_save_dir(dir)
	DirAccess.make_dir_recursive_absolute(dir)
	return dir


## Removes a folder of new_save_dir() with all that is in it. It never removes a folder outside the
## OS temp folder.
static func remove_save_dir(dir: String) -> void:
	if not dir.begins_with(OS.get_temp_dir()) or not DirAccess.dir_exists_absolute(dir):
		return
	for name in DirAccess.get_directories_at(dir):
		remove_save_dir(dir.path_join(name))
	for name in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir.path_join(name))
	DirAccess.remove_absolute(dir)


## Builds a Labyrinth from a tile picture of spec 4.5: "." is water, "#" is island.
## The picture has 2W + 1 columns and 2H + 1 rows. Square (x, y) is tile (2x + 1, 2y + 1),
## and a water tile between two squares opens the wall between them.
static func labyrinth_from_tiles(rows: Array) -> Labyrinth:
	var labyrinth := Labyrinth.new((rows[0].length() - 1) / 2, (rows.size() - 1) / 2)
	for y in labyrinth.height:
		for x in labyrinth.width:
			var square := Vector2i(x, y)
			var tile := Labyrinth.square_to_tile(square)
			if x + 1 < labyrinth.width and rows[tile.y][tile.x + 1] == ".":
				labyrinth.open_wall(square, Vector2i.RIGHT)
			if y + 1 < labyrinth.height and rows[tile.y + 1][tile.x] == ".":
				labyrinth.open_wall(square, Vector2i.DOWN)
	return labyrinth


## Draws the tiles of a Labyrinth as a picture in the format of labyrinth_from_tiles().
static func tile_picture(labyrinth: Labyrinth) -> Array:
	var rows := []
	var count := labyrinth.tile_count()
	for y in count.y:
		var row := ""
		for x in count.x:
			row += "." if labyrinth.is_water_tile(Vector2i(x, y)) else "#"
		rows.append(row)
	return rows
