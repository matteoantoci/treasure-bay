## The settings and the Parent controls in the main scene (spec 11, 12.4): the gear opens and closes
## the settings and pauses play, the volume buttons, the reset and quit holds, and the window rules
## of spec 11.1. The holds use HoldButton.advance() as a fake clock, so no test waits for a full hold.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const Fixtures := preload("res://tests/fixtures.gd")
const QUIT_PROBE := "res://tests/quit_probe.gd"
## Godot ends the probe after this count of frames, also when a script error stops the probe before
## its quit, so the test run never hangs. A headless frame lasts about 7 ms (the low processor sleep
## of Godot), so the limit is about 10 s. The probe needs fewer than 50 frames, and 2.3 s when the
## quit hold does not quit.
const PROBE_FRAME_LIMIT := 1500


func test_a_gear_click_opens_and_closes_the_settings_and_pauses_play(t) -> bool:
	var main := await Scene.add_main(t)
	var panel: SettingsPanel = main.get_node("Settings")
	t.assert_true(not panel.is_open(), "the settings are closed at the start")
	t.assert_true(not t.paused, "play runs at the start")
	await _click(t, main.get_node("Gear"))
	t.assert_true(panel.is_open(), "the first click opens the settings")
	t.assert_true(t.paused, "the settings pause play")
	t.assert_eq(panel.process_mode, Node.PROCESS_MODE_ALWAYS, "the settings work in the pause")
	t.assert_eq(Input.mouse_mode, Input.MOUSE_MODE_VISIBLE, "the mouse pointer stays visible")
	var moves := [0]
	main.move_started.connect(func() -> void: moves[0] += 1)
	main.bumped.connect(func() -> void: moves[0] += 1)
	Scene.send_key(KEY_DOWN)
	for frame in 5:
		await t.process_frame
	t.assert_eq(moves[0], 0, "an arrow key does nothing while the settings are open")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat stays on the start square")
	await _click(t, main.get_node("Gear"))
	t.assert_true(not panel.is_open(), "the second click closes the settings")
	t.assert_true(not t.paused, "the second click unpauses play")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "an arrow key moves the boat again")
	t.assert_eq(moves[0], 1, "one move")
	await Scene.remove(t, main)
	return true


func test_the_closed_settings_take_no_clicks(t) -> bool:
	var main := await Scene.add_main(t)
	var panel: SettingsPanel = main.get_node("Settings")
	await _click(t, main.get_node("Gear"))
	var plus_rect := panel.music_plus.get_global_rect()
	await _click(t, main.get_node("Gear"))
	await _click_at(t, plus_rect.get_center())
	t.assert_eq(panel.settings.music_step, 2, "a click where the closed plus button was does nothing")
	t.assert_true(not FileAccess.file_exists(main.save_store.dir.path_join("settings.json")), "no settings.json")
	await Scene.remove(t, main)
	return true


func test_the_volume_buttons_change_each_bus_in_5_steps(t) -> bool:
	var main := await Scene.add_main(t)
	var panel: SettingsPanel = main.get_node("Settings")
	var settings_path: String = main.save_store.dir.path_join("settings.json")
	_check_bus(t, Sound.MUSIC_BUS, 0.25, "music at the start: default step 2")
	_check_bus(t, Sound.EFFECTS_BUS, 0.5625, "effects at the start: default step 3")
	await _click(t, main.get_node("Gear"))
	t.assert_eq([panel.music_bars.step, panel.effects_bars.step], [2, 3], "the bars show the default steps")
	await _click(t, panel.music_plus)
	t.assert_eq(panel.music_bars.step, 3, "music plus: 3 bars")
	_check_bus(t, Sound.MUSIC_BUS, 0.5625, "music step 3")
	t.assert_eq(_file_steps(settings_path), [3, 3], "settings.json after music plus")
	await _click(t, panel.music_plus)
	await _click(t, panel.music_plus)
	t.assert_eq(panel.music_bars.step, 4, "music stops at step 4")
	_check_bus(t, Sound.MUSIC_BUS, 1.0, "music step 4")
	for press in 5:
		await _click(t, panel.music_minus)
	t.assert_eq(panel.music_bars.step, 0, "music stops at step 0")
	_check_bus(t, Sound.MUSIC_BUS, 0.0, "music step 0")
	_check_bus(t, Sound.EFFECTS_BUS, 0.5625, "the music buttons do not change the effects")
	await _click(t, panel.effects_minus)
	t.assert_eq(panel.effects_bars.step, 2, "effects minus: 2 bars")
	_check_bus(t, Sound.EFFECTS_BUS, 0.25, "effects step 2")
	await _click(t, panel.effects_plus)
	await _click(t, panel.effects_plus)
	_check_bus(t, Sound.EFFECTS_BUS, 1.0, "effects step 4")
	t.assert_eq(_file_steps(settings_path), [0, 4], "settings.json holds the last steps")
	var settings_text := FileAccess.get_file_as_string(settings_path)
	await _click(t, main.get_node("Gear"))
	await Scene.remove(t, main)
	# A restart loads the steps from settings.json.
	var dir := Fixtures.new_save_dir()
	_write(dir.path_join("settings.json"), settings_text)
	main = await Scene.add_main(t, dir)
	panel = main.get_node("Settings")
	t.assert_eq([panel.music_bars.step, panel.effects_bars.step], [0, 4], "the bars after a restart")
	_check_bus(t, Sound.MUSIC_BUS, 0.0, "music after a restart")
	_check_bus(t, Sound.EFFECTS_BUS, 1.0, "effects after a restart")
	await Scene.remove(t, main)
	return true


## A settings file of a newer build (spec 12.4): the game uses the default steps, and a volume
## button changes the bus but does not write settings.json in this session.
func test_a_newer_settings_file_stays_after_a_volume_click(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var settings_path := dir.path_join("settings.json")
	var text := "{\"version\": 2, \"music_step\": 4, \"effects_step\": 0}"
	_write(settings_path, text)
	var main := await Scene.add_main(t, dir)
	var panel: SettingsPanel = main.get_node("Settings")
	_check_bus(t, Sound.MUSIC_BUS, 0.25, "music at the default step 2")
	await _click(t, main.get_node("Gear"))
	await _click(t, panel.music_plus)
	_check_bus(t, Sound.MUSIC_BUS, 0.5625, "music plus sets step 3")
	t.assert_eq(FileAccess.get_file_as_string(settings_path), text, "settings.json has the same bytes")
	await _click(t, main.get_node("Gear"))
	await Scene.remove(t, main)
	return true


func test_an_8_second_hold_on_reset_starts_labyrinth_1(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var main := await Scene.add_main(t, dir)
	var panel: SettingsPanel = main.get_node("Settings")
	var started := []
	main.labyrinth_started.connect(func(number: int) -> void: started.append(number))
	await _click(t, main.get_node("Gear"))
	# A shorter hold does nothing.
	_mouse(t, panel.reset_button, true)
	panel.reset_button.advance(7.9)
	t.assert_true(panel.reset_button.ring > 0.98, "the ring is nearly full after 7.9 s")
	_mouse(t, panel.reset_button, false)
	t.assert_eq(panel.reset_button.ring, 0.0, "the release empties the ring")
	t.assert_eq(main.progress.labyrinth_number, 7, "a hold of 7.9 s does not reset")
	t.assert_true(panel.is_open() and t.paused, "a shorter hold keeps the settings open")
	t.assert_eq(SaveStore.new(dir).load_progress().labyrinth_number, 7, "a shorter hold writes no save")
	# A hold of 8 s resets.
	_mouse(t, panel.reset_button, true)
	panel.reset_button.advance(8.0)
	t.assert_true(not panel.is_open(), "the reset closes the settings")
	t.assert_true(not t.paused, "the reset unpauses play")
	t.assert_eq(SaveStore.to_dictionary(main.progress), SaveStore.to_dictionary(Progress.new()), "Labyrinth 1, empty Collection, total 0")
	t.assert_eq(SaveStore.to_dictionary(SaveStore.new(dir).load_progress()), SaveStore.to_dictionary(Progress.new()), "the save holds the reset")
	t.assert_eq(started, [1], "Labyrinth 1 starts")
	t.assert_eq([main.labyrinth.width, main.labyrinth.height], [4, 3], "the 4 x 3 Labyrinth 1")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat is on the start square")
	t.assert_eq(main.get_node("CollectionStrip").shown_friends(), PackedStringArray(), "an empty Collection strip")
	t.assert_eq(main.get_node("CollectionStrip").count_text(), "0", "total count 0")
	t.assert_eq(main.get_node("Fade").dark.color.a, 1.0, "the screen is dark at the reset")
	t.assert_true(await t.wait_for(main.labyrinth_ready, 5.0), "the screen fades in from dark")
	t.assert_eq(main.get_node("Fade").dark.color.a, 0.0, "the screen is clear after the fade-in")
	_mouse(t, panel.reset_button, false)
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "the Child can sail Labyrinth 1")
	await Scene.remove(t, main)
	return true

## Spec 11.2: the reset ring fills in orange and the quit ring in yellow, so the Parent sees which
## hold runs.
func test_the_reset_ring_is_orange_and_the_quit_ring_is_yellow(t) -> bool:
	var main := await Scene.add_main(t)
	var panel: SettingsPanel = main.get_node("Settings")
	t.assert_eq(panel.reset_button.ring_full_colour, Color("#ff7a59"), "the full reset ring is #ff7a59")
	t.assert_eq(panel.quit_button.ring_full_colour, Color("#ffd447"), "the full quit ring is #ffd447")
	await Scene.remove(t, main)
	return true



## The Parent can open the settings while the boat slides. The reset stops the slide of the old
## Labyrinth: the boat stays on the start square of Labyrinth 1, and it sails again.
func test_a_reset_during_a_slide_starts_labyrinth_1_on_its_start_square(t) -> bool:
	var dir := Fixtures.new_save_dir()
	SaveStore.new(dir).save(_progress_7())
	var main := await Scene.add_main(t, dir)
	var panel: SettingsPanel = main.get_node("Settings")
	var moves := [0]
	main.move_started.connect(func() -> void: moves[0] += 1)
	Scene.send_key(Scene.key_for(Scene.next_step(main.labyrinth, main.boat_square)))
	t.assert_eq(moves[0], 1, "the boat slides")
	panel.open()
	panel.reset_button.button_down.emit()
	panel.reset_button.advance(panel.reset_button.hold_seconds)
	panel.reset_button.button_up.emit()
	await t.create_timer(1.0).timeout
	t.assert_eq(main.progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the old slide does not move the boat")
	t.assert_eq(main.progress.total_items, 0, "the old slide collects nothing")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "the boat sails in Labyrinth 1")
	t.assert_eq(main.boat_square.x, 0, "down from the start square")
	t.assert_true(main.boat_square.y > 0, "the boat moved down")
	await Scene.remove(t, main)
	return true


## Spec 11.2: the settings stay usable in the pause, so the frames fill the ring of a held button.
func test_the_frames_fill_the_ring_while_play_is_paused(t) -> bool:
	var main := await Scene.add_main(t)
	var panel: SettingsPanel = main.get_node("Settings")
	await _click(t, main.get_node("Gear"))
	panel.reset_button.hold_seconds = 0.2
	_mouse(t, panel.reset_button, true)
	t.assert_true(await t.wait_for(panel.reset_button.held, 3.0), "the hold ends in the pause")
	t.assert_true(not t.paused, "the reset unpauses play")
	_mouse(t, panel.reset_button, false)
	await Scene.remove(t, main)
	return true


## Cmd+Q and the window close button both send a close request to the main window (godot4-facts
## §3). A quit would stop the test run, so a second Godot process runs tests/quit_probe.gd: it sends
## the close request, holds the quit button for 2.75 s, then for 3 s.
func test_window_close_does_nothing_and_a_quit_hold_saves_and_quits(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var output := []
	var arguments := ["--headless", "--quit-after", str(PROBE_FRAME_LIMIT), "--path", ProjectSettings.globalize_path("res://"), "--script", QUIT_PROBE, "--", dir]
	var exit_code := OS.execute(OS.get_executable_path(), arguments, output, true)
	var text := "\n".join(output)
	t.assert_eq(exit_code, 0, "the probe quits with code 0")
	t.assert_true(text.contains("RUNNING AFTER CLOSE REQUEST"), "a close request does not quit")
	t.assert_true(text.contains("RUNNING AFTER SHORT HOLD"), "a quit hold of 2.75 s does not quit")
	t.assert_true(not text.contains("DID NOT QUIT"), "a quit hold of 3 s quits")
	var saved := SaveStore.new(dir).load_progress()
	t.assert_eq(saved.collected_items, PackedStringArray(["1,2"]), "the quit writes the save first")
	t.assert_eq(saved.total_items, 1, "the saved total")
	Fixtures.remove_save_dir(dir)
	return true


func test_the_game_goes_back_to_exclusive_fullscreen(t) -> bool:
	var display := FakeDisplay.new(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	var guard := FullscreenGuard.new()
	guard.display = display
	t.root.add_child(guard)
	t.root.size_changed.emit()
	t.assert_eq(display.set_modes, [], "nothing changes while the game is in exclusive fullscreen")
	for mode in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.WINDOW_MODE_MAXIMIZED]:
		display.mode = mode
		display.set_modes.clear()
		t.root.size_changed.emit()
		t.assert_eq(display.set_modes, [DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN], "mode %d goes back to exclusive fullscreen" % mode)
	guard.queue_free()
	await t.process_frame
	return true


## A run with --windowed (the screenshot tool) starts in a window and stays in it.
func test_a_windowed_run_stays_in_its_window(t) -> bool:
	var display := FakeDisplay.new(DisplayServer.WINDOW_MODE_WINDOWED)
	var guard := FullscreenGuard.new()
	guard.display = display
	t.root.add_child(guard)
	t.root.size_changed.emit()
	t.assert_eq(display.set_modes, [], "a windowed start stays windowed")
	guard.queue_free()
	await t.process_frame
	return true


## A display server with only the window mode.
class FakeDisplay:
	var mode: int
	var set_modes := []

	func _init(start_mode: int) -> void:
		mode = start_mode

	func window_get_mode(_window_id := 0) -> int:
		return mode

	func window_set_mode(new_mode: int, _window_id := 0) -> void:
		set_modes.append(new_mode)
		mode = new_mode


## Labyrinth 7 with one Item collected and 6 Sea friends.
static func _progress_7() -> Progress:
	var progress := Progress.new()
	progress.labyrinth_number = 7
	progress.collect_item(progress.build_labyrinth().items[0].id)
	progress.collection = SeaFriends.IDS.slice(0, 6)
	progress.total_items = 23
	return progress


## A left click in the centre of `control`, like the Parent with the mouse.
static func _click(t, control: Control) -> void:
	await t.process_frame
	await _click_at(t, control.get_global_rect().get_center())


static func _click_at(t, at: Vector2) -> void:
	for pressed in [true, false]:
		_mouse_event(t, at, pressed)
	await t.process_frame


## Presses or releases the left mouse button on `control`.
static func _mouse(t, control: Control, pressed: bool) -> void:
	_mouse_event(t, control.get_global_rect().get_center(), pressed)


static func _mouse_event(t, at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = at
	event.global_position = at
	t.root.push_input(event, true)


## Bus volume `linear` (value * value of spec 11.2); 0 means a muted bus.
static func _check_bus(t, bus: StringName, linear: float, label: String) -> void:
	var index := AudioServer.get_bus_index(bus)
	t.assert_eq(AudioServer.is_bus_mute(index), linear == 0.0, "%s: mute" % label)
	if linear > 0.0:
		t.assert_true(is_equal_approx(AudioServer.get_bus_volume_linear(index), linear), "%s: volume %f, got %f" % [label, linear, AudioServer.get_bus_volume_linear(index)])


## [music_step, effects_step] of a settings.json.
static func _file_steps(path: String) -> Array:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	return [int(data["music_step"]), int(data["effects_step"])]


static func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
