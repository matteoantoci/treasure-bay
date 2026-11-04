## Takes the screenshots of spec 14.2 in a window: one Labyrinth of each Area at 1920 x 1200 (a
## 16:10 screen), and Area 1 at 1920 x 1247 (the 1512 x 982 screen of spec 10). Each Labyrinth has
## its first Item collected and the Sea friends of the Labyrinths before it. A headless run has no
## pixels. The game draws into a SubViewport of the exact size, so the window size does not matter.
##
## Run from the repository root:
##   godot --path . --windowed --script res://tools/take_shots.gd
## It writes the PNG files to shots/ and quits.
extends SceneTree

## [file name, Labyrinth number, visible size] of each screenshot.
const SHOTS := [
	["area1.png", 3, Vector2i(1920, 1200)],
	["area2.png", 8, Vector2i(1920, 1200)],
	["area3.png", 13, Vector2i(1920, 1200)],
	["area4.png", 18, Vector2i(1920, 1200)],
	["area1-1920x1247.png", 3, Vector2i(1920, 1247)],
]
const SHOTS_DIR := "res://shots/"


func _initialize() -> void:
	await process_frame
	for shot: Array in SHOTS:
		var viewport := SubViewport.new()
		viewport.size = shot[2]
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var main: Node = load("res://main.tscn").instantiate()
		# A save folder with no save file: the tool never reads or changes the real save.
		main.save_store = SaveStore.new(OS.get_temp_dir().path_join("labyrinth-shots-no-save"))
		viewport.add_child(main)
		main.progress = _progress(shot[1])
		main.show_labyrinth()
		for frame in 5:
			await process_frame
		await RenderingServer.frame_post_draw
		var image := viewport.get_texture().get_image()
		var path := ProjectSettings.globalize_path(SHOTS_DIR + shot[0])
		image.save_png(path)
		print("%s: Labyrinth %d, %d x %d px" % [path, shot[1], image.get_width(), image.get_height()])
		viewport.queue_free()
	quit()


## Labyrinth `number` with its first Item collected, and the Sea friends of the Labyrinths before it.
func _progress(number: int) -> Progress:
	var progress := Progress.new()
	progress.labyrinth_number = number
	progress.collection = SeaFriends.IDS.slice(0, number - 1)
	progress.total_items = 3 * (number - 1)
	progress.collect_item(progress.build_labyrinth().items[0].id)
	return progress
