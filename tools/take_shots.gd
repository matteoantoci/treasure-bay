## Takes the screenshots of spec 14.2 in a window: one Labyrinth of each Area at 1920 x 1200 (a
## 16:10 screen), Area 1 at 1920 x 1247 (the 1512 x 982 screen of spec 10), and the open settings
## panel with the reset button held for 1.5 s (spec 11.2). Each Labyrinth has its first Item
## collected and the Sea friends of the Labyrinths before it. A headless run has no pixels. The game
## draws into a SubViewport of the exact size, so the window size does not matter.
##
## Run from the repository root:
##   godot --path . --windowed --script res://tools/take_shots.gd
## It writes the PNG files to shots/ and quits. To take only some shots, put their file names after
## `--`, for example `... --script res://tools/take_shots.gd -- settings.png`.
extends SceneTree

## [file name, Labyrinth number, visible size, settings open with the reset ring half full] of each
## screenshot.
const SHOTS := [
	["area1.png", 3, Vector2i(1920, 1200), false],
	["area2.png", 8, Vector2i(1920, 1200), false],
	["area3.png", 13, Vector2i(1920, 1200), false],
	["area4.png", 18, Vector2i(1920, 1200), false],
	["area1-1920x1247.png", 3, Vector2i(1920, 1247), false],
	["settings.png", 3, Vector2i(1920, 1200), true],
]
const SHOTS_DIR := "res://shots/"


func _initialize() -> void:
	await process_frame
	var only := OS.get_cmdline_user_args()
	for shot: Array in SHOTS:
		if not only.is_empty() and not only.has(shot[0]):
			continue
		var viewport := SubViewport.new()
		viewport.size = shot[2]
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var main: Node = load("res://main.tscn").instantiate()
		# A save folder with no save file and no settings file: the tool never reads or changes the
		# real save or the real settings.
		main.save_store = SaveStore.new(OS.get_temp_dir().path_join("labyrinth-shots-no-save"))
		viewport.add_child(main)
		main.progress = _progress(shot[1])
		main.show_labyrinth()
		if shot[3]:
			var panel: SettingsPanel = main.get_node("Settings")
			panel.open()
			panel.reset_button.button_down.emit()
			panel.reset_button.advance(HoldButton.HOLD_SECONDS / 2.0)
		for frame in 5:
			await process_frame
		await RenderingServer.frame_post_draw
		var image := viewport.get_texture().get_image()
		var path := ProjectSettings.globalize_path(SHOTS_DIR + shot[0])
		image.save_png(path)
		print("%s: Labyrinth %d, %d x %d px" % [path, shot[1], image.get_width(), image.get_height()])
		paused = false
		viewport.queue_free()
	# The audio server frees a stopped playback in a later mix step.
	await create_timer(0.1, true, false, true).timeout
	quit()


## Labyrinth `number` with its first Item collected, and the Sea friends of the Labyrinths before it.
func _progress(number: int) -> Progress:
	var progress := Progress.new()
	progress.labyrinth_number = number
	progress.collection = SeaFriends.IDS.slice(0, number - 1)
	progress.total_items = 3 * (number - 1)
	progress.collect_item(progress.build_labyrinth().items[0].id)
	return progress
