## Run by tests/test_parent_controls.gd in its own Godot process, because a quit ends the process:
##   godot --headless --path . --script res://tests/quit_probe.gd -- <save folder>
## It starts the main scene with its save and settings in <save folder>, collects one Item with no
## save, sends a window close request (the path of Cmd+Q and of the window close button), holds the
## quit button for 2.75 s, then for 3 s. It prints a line after each step that does not quit. The
## test reads the lines and the save file.
extends SceneTree

const FRAMES_AFTER_A_STEP := 10
## The quit comes 0.1 s after the hold (SettingsPanel.AUDIO_STOP_SECONDS). The probe waits longer.
const QUIT_WAIT_SECONDS := 2.0


func _initialize() -> void:
	await process_frame
	var main: Node = load("res://main.tscn").instantiate()
	main.save_store = SaveStore.new(OS.get_cmdline_user_args()[0])
	root.add_child(main)
	await process_frame
	# Labyrinth 1 has an Item on 1,2. The save gets it only from the quit.
	main.progress.collect_item("1,2")
	root.close_requested.emit()
	await _frames()
	print("RUNNING AFTER CLOSE REQUEST")
	var panel: SettingsPanel = main.get_node("Settings")
	panel.open()
	panel.quit_button.button_down.emit()
	panel.quit_button.advance(2.75)
	panel.quit_button.button_up.emit()
	await _frames()
	print("RUNNING AFTER SHORT HOLD")
	panel.quit_button.button_down.emit()
	panel.quit_button.advance(3.0)
	await create_timer(QUIT_WAIT_SECONDS, true, false, true).timeout
	print("DID NOT QUIT")
	quit(3)


func _frames() -> void:
	for frame in FRAMES_AFTER_A_STEP:
		await process_frame
