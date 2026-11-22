## The Party of the game-flow spec part 4: the end screen of a Voyage after the Goal celebration of
## Labyrinth 20. The full path from the Goal of Labyrinth 20 is in test_main_rewards.gd. These tests
## show the Party with show_party(), and check its picture, its timeline, its loop, its input lock,
## and the gear.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const Fixtures := preload("res://tests/fixtures.gd")
## Game seconds of a check that no opening screen comes. Longer than the fade to dark.
const NO_OPENING_SECONDS := 1.0


func _party(main: Node) -> PartyView:
	return main.get_node("Party")


## Waits until the Party time is `seconds` or more. Returns false after 30 game seconds.
func _wait_party_time(t, party: PartyView, seconds: float) -> bool:
	for frame in 100000:
		if party.time >= seconds:
			return true
		await t.process_frame
	return false


## The rectangle of a sprite of the logo, in logo px.
func _sprite_rect(sprite: Sprite2D) -> Rect2:
	var size := sprite.texture.get_size() * sprite.scale
	return Rect2(sprite.position - size / 2.0, size)


func _island_rect(party: PartyView) -> Rect2:
	var cell_px := party.island.scale * LabyrinthView.KENNEY_TILE_PX
	return Rect2(party.island.position, Vector2(party.island.get_used_rect().size) * cell_px)


## Spec part 4: the still water of Area 1, an all-land island with a sand coast and a grass top, the
## chest on it, and the boat below the island with its bow up. The Collection strip does not show,
## and the gear stays above the Party.
func test_the_party_shows_the_water_the_island_the_chest_and_the_boat(t) -> bool:
	var main := await Scene.add_main(t)
	main.show_party()
	await t.process_frame
	var party := _party(main)
	var visible := main.get_viewport().get_visible_rect()
	t.assert_true(main.is_party_shown(), "the Party shows")
	t.assert_true(party.is_visible_in_tree(), "the Party is visible")
	t.assert_true(not main.get_node("CollectionStrip").is_visible_in_tree(), "the Collection strip does not show over the Party")
	t.assert_true(main.get_node("Gear").get_index() > party.get_index(), "the gear draws above the Party")
	t.assert_eq(party.water.color, Area.deep_colour(1), "the water of Area 1")
	t.assert_eq(Rect2(party.water.position, party.water.size), visible, "the water covers the screen")
	var cells := party.island.get_used_cells()
	var size := party.island.get_used_rect().size
	t.assert_eq(cells.size(), size.x * size.y, "the island is all land")
	t.assert_eq(size % IslandLook.CELLS_PER_TILE, Vector2i.ZERO, "the island is whole Labyrinth tiles")
	var corners := {Vector2i(0, 0): 6, Vector2i(size.x - 1, 0): 9, Vector2i(0, size.y - 1): 54, Vector2i(size.x - 1, size.y - 1): 57}
	for cell: Vector2i in corners:
		t.assert_eq(party.island.get_cell_source_id(cell), corners[cell], "the outer corner at %s" % cell)
	var island := _island_rect(party)
	t.assert_true(absf(island.get_center().x) < 0.01, "the island is in the middle")
	t.assert_eq(party.chest.texture, LabyrinthView.CHEST_CLOSED, "the chest is closed at the start")
	t.assert_true(island.has_point(party.chest.position), "the chest is on the island")
	var boat := party.boat
	t.assert_true(absf(boat.rotation - PI) < 0.001, "the bow of the boat points up")
	t.assert_true(absf(boat.position.x) < 0.01, "the boat is in the middle")
	var boat_top := boat.position.y - BoatView.LENGTH_PX * boat.scale.y / 2.0
	t.assert_true(boat_top > island.end.y, "the boat is below the island")
	var screen_bottom := (visible.end.y - party.logo.position.y) / party.logo.scale.y
	t.assert_true(boat.position.y + BoatView.LENGTH_PX * boat.scale.y / 2.0 < screen_bottom, "the boat is on the screen")
	await Scene.remove(t, main)
	return true


## Spec part 4, 0 to 2.4 s: the 20 Sea friends pop in one by one, every 120 ms, on an ellipse
## around the island, in Labyrinth order, with the gap at the bottom for the boat. Each one plays its
## own sound or the splash.
func test_the_sea_friends_pop_in_every_120_ms_on_a_ring_with_their_sounds(t) -> bool:
	var main := await Scene.add_main(t)
	Engine.time_scale = 1.0
	var party := _party(main)
	var popped := []
	var times := []
	main.party_friend_popped.connect(func(friend: String) -> void:
		popped.append(friend)
		times.append(party.time))
	var sounds := []
	main.get_node("Sound").sound_played.connect(func(path: String, _bus: StringName) -> void: sounds.append(path))
	main.show_party()
	t.assert_true(await _wait_party_time(t, party, 2.6), "the Party runs to 2.6 s")
	t.assert_eq(popped, Array(SeaFriends.IDS), "the 20 Sea friends in Labyrinth order")
	for k in times.size():
		t.assert_true(times[k] >= 0.12 * k and times[k] < 0.12 * k + 0.05, "Sea friend %d pops in at %.2f s, got %.3f" % [k + 1, 0.12 * k, times[k]])
	var friend_sounds := sounds.filter(func(path: String) -> bool: return path != Sound.GOAL_PATH)
	var expected := []
	for id in SeaFriends.IDS:
		expected.append(Sound.sea_friend_sound_path(id))
	t.assert_eq(friend_sounds, expected, "each Sea friend plays its own sound or the splash")
	var island := _island_rect(party)
	var boat := party.boat
	var boat_half := BoatView.LENGTH_PX * boat.scale.x / 2.0
	for k in party.friends.size():
		var friend := party.friends[k]
		var rect := _sprite_rect(friend)
		t.assert_true(friend.visible and friend.scale.x > 0.0, "Sea friend %d shows" % [k + 1])
		t.assert_eq(friend.texture.resource_path, SeaFriends.texture_path(SeaFriends.IDS[k]), "Sea friend %d" % [k + 1])
		t.assert_true(not rect.intersects(island), "Sea friend %d is around the island, not on it" % [k + 1])
		# The ellipse around the island centre: the friend is on it.
		var offset := (friend.position - island.get_center()) / PartyView.RING_RADII
		t.assert_true(absf(offset.length() - 1.0) < 0.01, "Sea friend %d is on the ellipse" % [k + 1])
		if rect.end.y > boat.position.y - boat_half:
			t.assert_true(absf(friend.position.x) - rect.size.x / 2.0 > boat_half, "Sea friend %d leaves the gap for the boat" % [k + 1])
	# The ring goes around in Labyrinth order: each Sea friend is a little further round than the one
	# before it, and the first and the last are at the two sides of the gap at the bottom.
	var first := party.friends[0].position - island.get_center()
	var last := party.friends[19].position - island.get_center()
	t.assert_true(first.x < 0.0 and last.x > 0.0 and first.y > 0.0 and last.y > 0.0, "the gap is at the bottom, between the first and the last Sea friend")
	for k in range(1, 20):
		var a := (party.friends[k - 1].position - island.get_center()) / PartyView.RING_RADII
		var b := (party.friends[k].position - island.get_center()) / PartyView.RING_RADII
		t.assert_true(a.angle_to(b) > 0.0, "Sea friend %d is after Sea friend %d on the ring" % [k + 1, k])
	await Scene.remove(t, main)
	return true


## Spec part 4, 0.4 s: the chest opens with the Goal sound, confetti bursts over it, and 8 Items fly
## out of the chest onto the island.
func test_at_0_4_s_the_chest_opens_with_the_goal_sound_confetti_and_8_items(t) -> bool:
	var main := await Scene.add_main(t)
	Engine.time_scale = 1.0
	var party := _party(main)
	var opened := []
	main.party_chest_opened.connect(func() -> void: opened.append(party.time))
	var sounds := []
	main.get_node("Sound").sound_played.connect(func(path: String, _bus: StringName) -> void:
		if path == Sound.GOAL_PATH:
			sounds.append(party.time))
	var bursts := []
	party.effects.child_entered_tree.connect(func(node: Node) -> void: bursts.append([party.time, node]))
	main.show_party()
	t.assert_true(await _wait_party_time(t, party, 0.35), "the Party runs to 0.35 s")
	t.assert_eq(party.chest.texture, LabyrinthView.CHEST_CLOSED, "the chest is closed before 0.4 s")
	t.assert_true(party.items.all(func(item: Sprite2D) -> bool: return not item.visible), "no Item shows before 0.4 s")
	t.assert_true(await _wait_party_time(t, party, 0.45), "the Party runs to 0.45 s")
	t.assert_eq(opened.size(), 1, "the chest opens one time")
	t.assert_true(opened[0] >= 0.4 and opened[0] < 0.45, "the chest opens at 0.4 s, got %s" % opened)
	t.assert_eq(party.chest.texture, LabyrinthView.CHEST_OPEN, "the open chest")
	t.assert_eq(sounds.size(), 1, "the Goal sound plays one time")
	t.assert_eq(bursts.size(), 1, "one burst")
	var burst: Burst = bursts[0][1]
	t.assert_eq(burst.amount, Motion.CONFETTI_COUNT, "the confetti of the build spec")
	t.assert_eq(burst.texture, Burst.confetti_texture(), "confetti pieces")
	var chest := _sprite_rect(party.chest)
	t.assert_true(absf(burst.position.x - chest.get_center().x) < 0.01 and burst.position.y < chest.get_center().y, "the confetti bursts over the chest")
	t.assert_true(await _wait_party_time(t, party, 1.3), "the Party runs to 1.3 s")
	var island := _island_rect(party)
	var kinds := []
	for item in party.items:
		kinds.append(item.texture.resource_path.get_file().get_basename())
		t.assert_true(item.visible, "the Item shows")
		t.assert_true(island.has_point(item.position), "the Item is on the island")
		t.assert_true(not chest.has_point(item.position), "the Item flew out of the chest")
	t.assert_eq(kinds.size(), 8, "8 Items")
	t.assert_eq(kinds, ["spiral_shell", "coral", "gem_stone", "glowing_star", "pearl", "starfish", "sand_dollar", "star"], "the Item kinds of the prototype")
	await Scene.remove(t, main)
	return true


## Spec part 4: at 3.0 s the star of the Items folder shows over the chest with the number 20 in the
## rounded font. From 3.0 s the Sea friends do a wave: each one hops up to 40 px of the 760 px HUD
## scale, with a phase delay along the ring. From 2.0 s a small confetti burst comes every 1.5 s.
func test_at_3_s_the_star_with_20_shows_and_the_wave_starts(t) -> bool:
	var main := await Scene.add_main(t)
	var party := _party(main)
	var bursts := []
	party.effects.child_entered_tree.connect(func(node: Node) -> void: bursts.append([party.time, (node as Burst).amount]))
	main.show_party()
	t.assert_true(await _wait_party_time(t, party, 2.9), "the Party runs to 2.9 s")
	t.assert_true(not party.star.visible, "no star before 3.0 s")
	var u := party.logo.scale.y
	for k in party.friends.size():
		var lift: float = PartyView.friend_place(k).y - party.friends[k].position.y
		t.assert_true(absf(lift) < 0.001, "Sea friend %d does not hop before 3.0 s" % [k + 1])
	t.assert_true(await _wait_party_time(t, party, 3.3), "the Party runs to 3.3 s")
	t.assert_true(party.star.visible, "the star shows")
	t.assert_eq(party.star.texture.resource_path, Area.item_texture_path("star"), "the star of the Items folder")
	t.assert_true(party.star.position.y < party.chest.position.y and absf(party.star.position.x - party.chest.position.x) < 0.01, "the star is over the chest")
	t.assert_true(party.star_number.is_visible_in_tree(), "the number shows")
	t.assert_eq(party.star_number.text, "20", "the number 20")
	t.assert_eq(party.star_number.get_theme_font("font"), GameFont.bold(), "the rounded font")
	# The wave: record the largest hop of each Sea friend, in screen px, for 2 s.
	var h := main.get_viewport().get_visible_rect().size.y / 760.0
	var highest := []
	highest.resize(20)
	highest.fill(0.0)
	var mixed := false
	while party.time < 5.3:
		var lifts := []
		for k in 20:
			var lift: float = (PartyView.friend_place(k).y - party.friends[k].position.y) * u
			lifts.append(lift)
			highest[k] = maxf(highest[k], lift)
		mixed = mixed or lifts.max() - lifts.min() > 10.0
		await t.process_frame
	for k in 20:
		t.assert_true(absf(highest[k] - 40.0 * h) < 3.0, "Sea friend %d hops up to 40 px of the HUD scale, got %.1f" % [k + 1, highest[k]])
	t.assert_true(mixed, "the hops have a phase delay along the ring")
	var expected := [0.4, 2.0, 3.5, 5.0]
	t.assert_eq(bursts.size(), expected.size(), "the bursts at 0.4 s, then every 1.5 s from 2.0 s")
	for i in mini(bursts.size(), expected.size()):
		t.assert_true(bursts[i][0] >= expected[i] and bursts[i][0] < expected[i] + 0.2, "a burst at %.1f s, got %.2f" % [expected[i], bursts[i][0]])
		t.assert_eq(bursts[i][1], Motion.CONFETTI_COUNT, "a confetti burst of the build spec")
	await Scene.remove(t, main)
	return true


## Spec part 4: the Party loops until a key press. The input is locked for the first 3.0 s. After
## that an arrow key, Space or Enter fades to the opening screen.
func test_the_party_loops_and_a_press_after_3_s_goes_to_the_opening_screen(t) -> bool:
	for key in [KEY_SPACE, KEY_ENTER, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
		var main := await Scene.add_main(t)
		var party := _party(main)
		var shown := []
		main.opening_shown.connect(func() -> void: shown.append(party.time))
		main.show_party()
		await t.process_frame
		for press in [KEY_SPACE, KEY_ENTER, KEY_DOWN]:
			Scene.send_key(press)
		t.assert_true(await _wait_party_time(t, party, 2.8), "the Party runs to 2.8 s")
		Scene.send_key(key)
		t.assert_true(await _wait_party_time(t, party, 3.0), "the Party runs to 3.0 s")
		t.assert_eq(shown, [], "the presses of the first 3 s do nothing")
		# Other keys do nothing after 3 s.
		for other in [KEY_ESCAPE, KEY_TAB, KEY_A]:
			Scene.send_key(other)
		t.assert_true(await _wait_party_time(t, party, 12.0), "the Party loops past 12 s")
		t.assert_eq(shown, [], "other keys do nothing")
		t.assert_true(main.is_party_shown(), "the Party loops")
		var lifts := []
		for k in 20:
			lifts.append(PartyView.friend_place(k).y - party.friends[k].position.y)
		t.assert_true(lifts.max() > 0.0, "the wave goes on")
		Scene.send_key(key)
		t.assert_true(await t.wait_for(main.opening_shown, Scene.MOVE_TIMEOUT), "%s goes to the opening screen" % OS.get_keycode_string(key))
		t.assert_true(main.is_opening_shown(), "the opening screen shows")
		t.assert_true(not main.is_party_shown(), "the Party is gone")
		await Scene.remove(t, main)
	return true


## Spec 11.2 and part 4: the gear works on the Party. While the settings are open, the Party stops
## and the keys do nothing. After the close, a press goes to the opening screen.
func test_the_gear_works_on_the_party(t) -> bool:
	var main := await Scene.add_main(t)
	var party := _party(main)
	var panel: SettingsPanel = main.get_node("Settings")
	var gear: Control = main.get_node("Gear")
	main.show_party()
	t.assert_true(await _wait_party_time(t, party, 3.2), "the Party runs to 3.2 s")
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = gear.get_global_rect().get_center()
		event.global_position = event.position
		t.root.push_input(event, true)
	await t.process_frame
	t.assert_true(panel.is_open(), "a click on the gear opens the settings")
	var time := party.time
	for key in [KEY_SPACE, KEY_ENTER, KEY_DOWN]:
		Scene.send_key(key)
	t.assert_true(not await t.wait_for(main.opening_shown, NO_OPENING_SECONDS), "no opening screen while the settings are open")
	t.assert_eq(party.time, time, "the Party stops while the settings are open")
	panel.close()
	Scene.send_key(KEY_SPACE)
	t.assert_true(await t.wait_for(main.opening_shown, Scene.MOVE_TIMEOUT), "after the close, a press goes to the opening screen")
	await Scene.remove(t, main)
	return true


## Spec part 4: the only text of the Party is the number 20 of the star.
func test_the_only_text_of_the_party_is_the_number_20(t) -> bool:
	var main := await Scene.add_main(t)
	var party := _party(main)
	main.show_party()
	t.assert_true(await _wait_party_time(t, party, 3.5), "the Party runs to 3.5 s")
	var texts := []
	var nodes: Array[Node] = [party]
	while not nodes.is_empty():
		var node: Node = nodes.pop_back()
		nodes.append_array(node.get_children(true))
		var text: Variant = node.get("text")
		if text is String and not text.is_empty() and node.is_visible_in_tree():
			texts.append(text)
	t.assert_eq(texts, ["20"], "the only text is the number 20")
	await Scene.remove(t, main)
	return true


## Spec part 4: the save holds the new Voyage at the Goal of Labyrinth 20. A launch during the Party
## shows the opening screen and Labyrinth 1. The Party does not play again.
func test_a_launch_after_a_party_shows_the_opening_screen_and_labyrinth_1(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var saved := Progress.new()
	saved.labyrinth_number = 20
	saved.collection = SeaFriends.IDS.slice(0, 19)
	saved.total_items = 150
	SaveStore.new(dir).save(saved)
	var main := await Scene.add_main(t, dir)
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed Labyrinth 20 to the Goal")
	t.assert_true(await t.wait_for(main.party_started, Scene.NEXT_LABYRINTH_TIMEOUT), "the Party starts")
	var total: int = main.progress.total_items
	# The launch: a new main scene with the same save, as after a quit during the Party.
	Engine.time_scale = 1.0
	main.queue_free()
	await t.process_frame
	var again := await Scene.add_main_at_opening(t, dir)
	var parties := []
	again.party_started.connect(func() -> void: parties.append(true))
	t.assert_true(again.is_opening_shown(), "the opening screen shows")
	t.assert_true(not again.is_party_shown(), "the Party does not show")
	t.assert_true(await Scene.start_from_opening(t, again), "the start press starts the game")
	t.assert_eq(again.progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(again.get_node("CollectionStrip").shown_friends(), PackedStringArray(), "an empty strip")
	t.assert_eq(again.get_node("CollectionStrip").count_text(), str(total), "the same total count")
	t.assert_eq(parties, [], "the Party does not play again")
	await Scene.remove(t, again)
	Fixtures.remove_save_dir(dir)
	return true
