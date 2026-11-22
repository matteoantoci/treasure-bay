## The opening screen of the game-flow spec part 3: it shows at launch, its logo and its button, and
## the start press that fades into the current Labyrinth.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const Fixtures := preload("res://tests/fixtures.gd")
## Game seconds of a check that no start comes. Longer than the fade to dark of 0.8 s.
const NO_START_SECONDS := 2.0


func _opening(main: Node) -> OpeningScreen:
	return main.get_node("Opening")


## Saves Labyrinth `number` with the Sea friends before it and a total of 23 in a new save folder.
func _save_dir_at(number: int) -> String:
	var dir := Fixtures.new_save_dir()
	var saved := Progress.new()
	saved.labyrinth_number = number
	saved.collection = SeaFriends.IDS.slice(0, number - 1)
	saved.total_items = 23
	SaveStore.new(dir).save(saved)
	return dir


func _click_button(t, main: Node) -> void:
	var button := _opening(main).button
	var centre := button.get_global_transform() * (button.size / 2.0)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = centre
		event.global_position = centre
		t.root.push_input(event, true)
	await t.process_frame


func test_at_launch_the_opening_screen_shows_and_an_arrow_press_starts_the_labyrinth(t) -> bool:
	var main := await Scene.add_main_at_opening(t, _save_dir_at(7))
	var moves := Scene.record_moves(main)
	var started := []
	main.labyrinth_started.connect(func(number: int) -> void: started.append(number))
	t.assert_true(main.is_opening_shown(), "the opening screen shows at launch")
	t.assert_true(_opening(main).is_visible_in_tree(), "the opening screen is visible")
	t.assert_eq(started, [], "no Labyrinth shows yet")
	Scene.send_key(KEY_DOWN)
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "the arrow press starts the Labyrinth")
	await t.create_timer(Scene.NO_MOVE_SECONDS).timeout
	t.assert_eq(started, [7], "the saved Labyrinth 7 shows")
	t.assert_eq(moves, [], "the arrow press on the opening screen does not move the boat")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat is on the start square")
	t.assert_true(not main.is_opening_shown(), "the opening screen is gone")
	t.assert_true(await Scene.press(t, main, Scene.key_for(Scene.next_step(main.labyrinth, main.boat_square))), "the next arrow press sails the boat")
	await Scene.remove(t, main)
	return true


func test_each_arrow_key_space_and_enter_start_the_current_labyrinth(t) -> bool:
	for key in [KEY_SPACE, KEY_ENTER, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
		var main := await Scene.add_main_at_opening(t, _save_dir_at(7))
		Scene.send_key(key)
		t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "%s starts the game" % OS.get_keycode_string(key))
		t.assert_eq(main.progress.labyrinth_number, 7, "the current Labyrinth")
		t.assert_eq(main.get_node("CollectionStrip").shown_friends(), SeaFriends.IDS.slice(0, 6), "the saved Collection")
		await Scene.remove(t, main)
	return true


func test_other_keys_do_not_start_the_game(t) -> bool:
	var main := await Scene.add_main_at_opening(t)
	for key in [KEY_ESCAPE, KEY_TAB, KEY_A, KEY_1, KEY_KP_2]:
		Scene.send_key(key)
	t.assert_true(not await t.wait_for(main.labyrinth_started, NO_START_SECONDS), "no Labyrinth starts")
	t.assert_true(main.is_opening_shown(), "the opening screen stays")
	await Scene.remove(t, main)
	return true


## The press: the button scales to 0.86 and back in 140 ms, the Item sound plays one time, and the
## screen fades to dark. A second press does nothing.
func test_the_start_press_moves_the_button_and_plays_the_item_sound_one_time(t) -> bool:
	var main := await Scene.add_main_at_opening(t)
	Engine.time_scale = 1.0
	var calls := []
	main.get_node("Sound").sound_played.connect(func(path: String, _bus: StringName) -> void: calls.append(path))
	var button := _opening(main).button
	var smallest := [1.0]
	var record := func() -> void: smallest[0] = minf(smallest[0], button.scale.x)
	t.process_frame.connect(record)
	Scene.send_key(KEY_SPACE)
	Scene.send_key(KEY_SPACE)
	Scene.send_key(KEY_ENTER)
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.MOVE_TIMEOUT), "the Labyrinth shows")
	t.process_frame.disconnect(record)
	t.assert_true(absf(smallest[0] - StartButton.PRESS_SCALE) < 0.03, "the button scales to 0.86, got %s" % smallest[0])
	t.assert_eq(button.scale, Vector2.ONE, "the button scales back")
	t.assert_eq(calls, [Sound.ITEM_PATH], "one Item sound for three presses")
	await Scene.remove(t, main)
	return true


func test_a_click_on_the_button_starts_the_game(t) -> bool:
	var main := await Scene.add_main_at_opening(t)
	await _click_button(t, main)
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "the click starts the game")
	t.assert_true(not main.is_opening_shown(), "the opening screen is gone")
	await Scene.remove(t, main)
	return true


## Spec 11.2 and game-flow spec part 3: the gear works on the opening screen. While the settings are
## open, the keys and a click on the button do nothing.
func test_while_the_settings_are_open_the_button_does_nothing(t) -> bool:
	var main := await Scene.add_main_at_opening(t)
	var panel: SettingsPanel = main.get_node("Settings")
	var gear: Control = main.get_node("Gear")
	t.assert_true(gear.get_index() > _opening(main).get_index(), "the gear draws above the opening screen")
	await t.process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = gear.get_global_rect().get_center()
		event.global_position = event.position
		t.root.push_input(event, true)
	await t.process_frame
	t.assert_true(panel.is_open(), "a click on the gear opens the settings")
	for key in [KEY_SPACE, KEY_ENTER, KEY_DOWN]:
		Scene.send_key(key)
	await _click_button(t, main)
	t.assert_true(not await t.wait_for(main.labyrinth_started, NO_START_SECONDS), "no Labyrinth starts")
	t.assert_true(not _opening(main).button.is_pressed(), "the button does not move")
	panel.close()
	await _click_button(t, main)
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "after the close, a click starts the game")
	await Scene.remove(t, main)
	return true


## Variant B of the second prototype round: the title, the island of 4 x 3 tiles with a sand coast
## and a grass top, the closed chest with its sparkle, four Items, and the green button.
func test_the_opening_screen_shows_the_chest_logo_and_the_button(t) -> bool:
	var main := await Scene.add_main_at_opening(t)
	var opening := _opening(main)
	var visible := main.get_viewport().get_visible_rect()
	var u := visible.size.y / OpeningScreen.REFERENCE_HEIGHT
	t.assert_eq(opening.water.color, Area.deep_colour(1), "the water of Area 1")
	t.assert_eq(Rect2(opening.water.position, opening.water.size), visible, "the water covers the screen")
	t.assert_eq(opening.title.text, "Treasure Bay", "the title")
	t.assert_eq(opening.title.font, GameFont.bold(), "the title uses the game font")
	# The island: 4 x 3 tiles of 3 x 3 Kenney cells, all land, with the corners and coasts of the
	# island rules.
	var cells := opening.island.get_used_cells()
	t.assert_eq(cells.size(), 12 * 9, "4 x 3 tiles of 3 x 3 cells")
	var corners := {Vector2i(0, 0): 6, Vector2i(11, 0): 9, Vector2i(0, 8): 54, Vector2i(11, 8): 57}
	for cell: Vector2i in corners:
		t.assert_eq(opening.island.get_cell_source_id(cell), corners[cell], "the outer corner at %s" % cell)
	var grass := [IslandLook.GRASS] + IslandLook.VARIANTS[IslandLook.GRASS]
	var coast := 0
	var top := 0
	for cell in cells:
		var id := opening.island.get_cell_source_id(cell)
		var inside := cell.x > 0 and cell.y > 0 and cell.x < 11 and cell.y < 8
		if inside and grass.has(id):
			top += 1
		elif not inside:
			coast += 1
	t.assert_eq(top, 10 * 7, "a grass top inside the coast")
	t.assert_eq(coast, 12 * 9 - 10 * 7, "a sand coast all around")
	# The chest: closed, 22 % of the visible height, on the island, with its sparkle.
	var chest := opening.chest
	t.assert_eq(chest.texture, LabyrinthView.CHEST_CLOSED, "the closed chest")
	var chest_height := chest.texture.get_height() * chest.scale.y * opening.logo.scale.y
	t.assert_true(absf(chest_height - 0.22 * visible.size.y) < 1.0, "the chest is 22 % of the screen height")
	var island_rect := Rect2(opening.island.position, Vector2(4, 3) * OpeningScreen.ISLAND_TILE_PX)
	t.assert_true(island_rect.has_point(chest.position), "the chest is on the island")
	var sparkled := false
	for frame in 300:
		sparkled = sparkled or opening.chest_sparkle.visible
		await t.process_frame
	t.assert_true(sparkled, "the chest sparkles")
	# Four Items on the island.
	var kinds := []
	for sprite in opening.items:
		kinds.append(sprite.texture.resource_path.get_file().get_basename())
		t.assert_true(island_rect.has_point(sprite.position), "the Item is on the island")
	t.assert_eq(kinds, ["spiral_shell", "starfish", "pearl", "coral"], "the four Items")
	# The button under the island: about 560 x 160 px at 1200 px.
	var button := opening.button
	t.assert_eq(button.size, Vector2(560, 160), "the button size at 1200 px")
	var button_top := opening.logo.position.y + button.position.y * u
	t.assert_true(button_top > opening.logo.position.y + island_rect.end.y * u, "the button is under the island")
	t.assert_true(button_top + button.size.y * u < visible.end.y, "the button is on the screen")
	t.assert_true(opening.logo.position.x == visible.get_center().x, "the logo is in the centre")
	await Scene.remove(t, main)
	return true


## The music of Area 1 plays, and the Items bob 2 px while the water stays still.
func test_the_items_bob_2_px(t) -> bool:
	var main := await Scene.add_main_at_opening(t)
	var opening := _opening(main)
	var lowest := []
	var highest := []
	for sprite in opening.items:
		lowest.append(sprite.position.y)
		highest.append(sprite.position.y)
	for frame in 120:
		await t.process_frame
		for i in opening.items.size():
			lowest[i] = minf(lowest[i], opening.items[i].position.y)
			highest[i] = maxf(highest[i], opening.items[i].position.y)
	for i in opening.items.size():
		var travel: float = highest[i] - lowest[i]
		t.assert_true(travel > 3.0 and travel <= 4.0 + 1e-3, "Item %d bobs 2 px up and down, travel %s" % [i, travel])
	t.assert_eq(main.get_node("Sound").music_path(), Area.music_path(1), "the music of Area 1")
	await Scene.remove(t, main)
	return true


## The letters sit on one arc, each one advance width of the font after the other, so the gaps are
## even. The arc is centred over the island.
func test_the_title_letters_have_even_gaps_on_the_arc(t) -> bool:
	var title := OpeningScreen.ArcTitle.new()
	title.text = "Treasure Bay"
	var angles := title.letter_angles()
	var advances := title.letter_advances()
	t.assert_eq(angles.size(), 12, "one angle for each letter")
	for i in angles.size() - 1:
		var along := (angles[i + 1] - angles[i]) * OpeningScreen.TITLE_RADIUS
		t.assert_true(absf(along - (advances[i] + advances[i + 1]) / 2.0) < 0.01, "letters %d and %d are one half advance each apart" % [i, i + 1])
	var last := angles.size() - 1
	var text_start := angles[0] * OpeningScreen.TITLE_RADIUS - advances[0] / 2.0
	var text_end := angles[last] * OpeningScreen.TITLE_RADIUS + advances[last] / 2.0
	t.assert_true(absf(text_start + text_end) < 0.01, "the text is centred on the arc")
	t.assert_true(advances[0] > 0.0, "the font gives advance widths")
	title.free()
	return true


func test_the_button_pulses_from_1_to_1_06_in_1_6_s(t) -> bool:
	t.assert_true(is_equal_approx(StartButton.pulse_scale(0.0), 1.0), "1.0 at the start")
	t.assert_true(is_equal_approx(StartButton.pulse_scale(0.8), 1.06), "1.06 at the half")
	t.assert_true(is_equal_approx(StartButton.pulse_scale(1.6), 1.0), "1.0 after 1.6 s")
	for step in 16:
		var s := StartButton.pulse_scale(step * 0.1)
		t.assert_true(s >= 1.0 and s <= 1.06 + 1e-6, "between 1.0 and 1.06")
	return true


## Game-flow spec part 3: one rounded font with the SIL Open Font License, its licence file, and its
## line in the credits. GameFont is the one place that gives it to the game.
func test_the_font_has_its_licence_file_and_its_credit(t) -> bool:
	t.assert_eq(GameFont.FILE.resource_path, "res://assets/fonts/fredoka/Fredoka-Variable.ttf", "the font file")
	t.assert_true(GameFont.FILE.get_font_name().begins_with("Fredoka"), "the font is Fredoka")
	t.assert_true(GameFont.bold() == GameFont.bold(), "one shared font")
	var licence := FileAccess.get_file_as_string("res://assets/fonts/fredoka/OFL.txt")
	t.assert_true(licence.contains("SIL Open Font License, Version 1.1"), "the licence file")
	var credits := FileAccess.get_file_as_string("res://credits.txt")
	t.assert_true(credits.contains("\"Fredoka\"") and credits.contains("assets/fonts/fredoka/OFL.txt"), "the credits line")
	return true
