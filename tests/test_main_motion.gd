## The motion of the main scene (spec 8): the launch fade-in, the Item fly, the Goal celebration
## with the chest, the hops, the confetti, and the Sea friend, the fade between Labyrinths, and the
## first Item of a new Area. The motion values are in test_motion.gd.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
## Game seconds of slack for a time measured in frames.
const TIME_SLACK := 0.2
## Game seconds after the Sea friend appears, when it stands still at its end place.
const FRIEND_STILL_SECONDS := 0.8


## Game seconds since `start_usec`, at the test time scale.
func _seconds_since(start_usec: int) -> float:
	return (Time.get_ticks_usec() - start_usec) / 1e6 * Engine.time_scale


func _show(main: Node, number: int) -> void:
	var progress := Progress.new()
	progress.labyrinth_number = number
	progress.collection = SeaFriends.IDS.slice(0, number - 1)
	main.progress = progress
	main.show_labyrinth()


func test_the_game_fades_in_from_dark_at_launch(t) -> bool:
	var main: Node = load("res://main.tscn").instantiate()
	main.save_store = SaveStore.new(preload("res://tests/fixtures.gd").new_save_dir())
	t.root.add_child(main)
	var fade: FadeView = main.get_node("Fade")
	t.assert_true(fade.dark.color.a > 0.9, "the screen starts dark")
	t.assert_true(fade.dark.color.is_equal_approx(Color("#0a1428", fade.dark.color.a)), "dark colour")
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "the fade-in ends")
	t.assert_true(fade.dark.color.a < 0.001, "the screen is clear")
	t.assert_true(not fade.area_item.visible, "no Area Item at launch")
	await Scene.remove(t, main)
	return true


func test_a_collected_item_flies_to_its_outline_and_fills_it(t) -> bool:
	var main := await Scene.add_main(t)
	var row: ItemRow = main.get_node("ItemRow")
	var effects: EffectsView = main.get_node("Effects")
	await Scene.press(t, main, KEY_DOWN)
	t.assert_true(await Scene.press(t, main, KEY_RIGHT), "the boat stops on the Item")
	var start := Time.get_ticks_usec()
	t.assert_eq(effects.flying_items().size(), 1, "the Item flies")
	t.assert_eq(row.fills[1].modulate.a, 0.0, "its outline is still empty")
	var bounce_scale: Vector2 = row.outlines[1].scale
	while row.fills[1].modulate.a == 0.0 and _seconds_since(start) < 2.0:
		await t.process_frame
	_near(t, _seconds_since(start), Motion.item_fly_arrival(), "the outline starts to fill at the arrival of the Item")
	t.assert_true(row.outlines[1].scale.x > bounce_scale.x, "the outline bounces from a larger size")
	t.assert_eq(effects.flying_items().size(), 0, "the Item is in its outline")
	await Scene.remove(t, main)
	return true


func test_the_goal_celebration_runs_on_the_spec_times(t) -> bool:
	var main := await Scene.add_main(t)
	var view: LabyrinthView = main.get_node("LabyrinthView")
	var boat: BoatView = main.get_node("Boat")
	var friend: SeaFriendView = main.get_node("SeaFriend")
	var times := {}
	var start := [0]
	main.goal_reached.connect(func(_f: String) -> void: start[0] = Time.get_ticks_usec())
	for event in ["sea_friend_appeared", "next_labyrinth_coming", "labyrinth_started", "labyrinth_ready"]:
		main.connect(event, func(_value: Variant) -> void: times[event] = _seconds_since(start[0]))
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	t.assert_eq(view.chest.texture.resource_path, "res://assets/sprites/goal/chest_closed.png", "the chest is closed on the arrival")
	await t.process_frame
	await t.process_frame
	t.assert_eq(view.chest.texture.resource_path, "res://assets/sprites/goal/chest_open.png", "the chest opens at the start of the celebration")
	t.assert_true(boat.hop_scale > 1.0, "the boat hops")
	t.assert_true(not boat.idle, "the boat does not rock during the celebration")
	t.assert_eq(_confetti_count(main), 1, "the confetti falls")
	t.assert_true(await t.wait_for(main.sea_friend_appeared, Scene.NEXT_LABYRINTH_TIMEOUT), "the Sea friend appears")
	t.assert_true(friend.visible, "the Sea friend shows next to the Goal island")
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.NEXT_LABYRINTH_TIMEOUT), "the next Labyrinth is ready")
	_near(t, times.get("sea_friend_appeared", -1.0), 1.4, "the Sea friend appears at 1.4 s")
	_near(t, times.get("next_labyrinth_coming", -1.0), 4.2, "the fade to dark starts at 4.2 s")
	_near(t, times.get("labyrinth_started", -1.0), 4.7, "the next Labyrinth shows at 4.7 s")
	_near(t, times.get("labyrinth_ready", -1.0), 5.2, "the input unlocks at 5.2 s")
	t.assert_eq(view.chest.texture.resource_path, "res://assets/sprites/goal/chest_closed.png", "the next Goal chest is closed")
	t.assert_true(not friend.visible, "the Sea friend is in its slot")
	t.assert_true(boat.idle, "the boat rocks again")
	await Scene.remove(t, main)
	return true


## The Sea friend grows next to the Goal island at the far side, away from the chest and the boat,
## so the open chest and the boat stay in view (spec 6.2, 8.5, 8.6, Open gap 3). The check uses the
## box of the opaque pixels of each of the 20 Sea friend pictures at the end of the growth.
func test_the_sea_friend_leaves_the_open_chest_and_the_boat_in_view(t) -> bool:
	var main := await Scene.add_main(t)
	var view: LabyrinthView = main.get_node("LabyrinthView")
	var boat: BoatView = main.get_node("Boat")
	var friend: SeaFriendView = main.get_node("SeaFriend")
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	t.assert_true(await t.wait_for(main.sea_friend_appeared, Scene.NEXT_LABYRINTH_TIMEOUT), "the Sea friend appears")
	# Game seconds: after the growth (0.45 s) and before the flight to the strip (1.6 s).
	await t.create_timer(FRIEND_STILL_SECONDS).timeout
	var s := boat.scale.x
	var tile_px := ScreenLayout.PROTOTYPE_TILE_PX * s
	var island := view.global_position + (Vector2(main.labyrinth.goal_island_tile()) + Vector2(0.5, 0.5)) * tile_px
	t.assert_true(friend.position.is_equal_approx(island + Vector2(60, -30) * s), "the Sea friend is at (+60, -30) px from the Goal island centre")
	var chest_px := maxf(view.chest.texture.get_width(), view.chest.texture.get_height()) * view.chest.global_scale.x
	var chest := _opaque_rect(view.chest.texture, view.chest.global_position, chest_px)
	var boat_local := _opaque_rect(BoatView.TEXTURE, Vector2.ZERO, BoatView.LENGTH_PX * s)
	var boat_rect := Transform2D(boat.global_rotation, boat.global_position) * boat_local
	for id in SeaFriends.IDS:
		var texture: Texture2D = load(SeaFriends.texture_path(id))
		var shape := _opaque_rect(texture, friend.position, Motion.FRIEND_PX * Motion.FRIEND_SCALE * s)
		var on_chest := shape.intersection(chest).get_area() / chest.get_area()
		t.assert_true(on_chest <= 0.2, "%s covers at most a corner of the open chest (%.2f of its box)" % [id, on_chest])
		t.assert_true(not shape.intersects(boat_rect), "%s does not cover the boat" % id)
	await Scene.remove(t, main)
	return true


func test_the_screen_fades_between_labyrinths(t) -> bool:
	var main := await Scene.add_main(t)
	var fade: FadeView = main.get_node("Fade")
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 2 shows")
	t.assert_true(fade.dark.color.a > 0.95, "Labyrinth 2 shows while the screen is dark")
	t.assert_true(not fade.area_item.visible, "Labyrinth 2 is in the same Area: no Area Item")
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.NEXT_LABYRINTH_TIMEOUT), "the fade-in ends")
	t.assert_true(fade.dark.color.a < 0.001, "the screen is clear")
	await Scene.remove(t, main)
	return true


func test_a_new_area_shows_its_first_item_big_in_the_centre(t) -> bool:
	var main := await Scene.add_main(t)
	var fade: FadeView = main.get_node("Fade")
	var items: ItemsView = main.get_node("Items")
	_show(main, 5)
	# The times start when Labyrinth 6 shows, with the fade-in.
	var start := [0]
	var ready_at := [-1.0]
	main.labyrinth_started.connect(func(_n: int) -> void: start[0] = Time.get_ticks_usec(), CONNECT_ONE_SHOT)
	main.labyrinth_ready.connect(func(_n: int) -> void: ready_at[0] = _seconds_since(start[0]), CONNECT_ONE_SHOT)
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed Labyrinth 5 to the Goal")
	t.assert_true(await t.wait_for(main.labyrinth_started, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 6 shows")
	t.assert_true(fade.area_item.visible, "the Area Item shows")
	t.assert_eq(fade.area_item.texture.resource_path, "res://assets/sprites/items/coral.png", "the first Item kind of Area 2")
	t.assert_eq(fade.area_item.position, main.get_viewport().get_visible_rect().get_center(), "in the centre of the screen")
	# The Area Item starts with the fade-in: it grows in 400 ms, stays for 600 ms, and fades out in
	# 400 ms. The input unlocks at the end of the fade-in, at 500 ms, before the Item fades out.
	var biggest := 0.0
	var fade_out_at := -1.0
	var texture_px := maxf(fade.area_item.texture.get_width(), fade.area_item.texture.get_height())
	while fade.area_item.visible and _seconds_since(start[0]) < 3.0:
		biggest = maxf(biggest, texture_px * fade.area_item.scale.x)
		if fade_out_at < 0.0 and fade.area_item.modulate.a < 1.0:
			fade_out_at = _seconds_since(start[0])
		await t.process_frame
	var item_px: float = items.item_px()
	t.assert_true(biggest > 1.99 * item_px and biggest < 2.4 * item_px, "it grows to 2 times the Item size (with the back overshoot)")
	# The first frame after the new Labyrinth can be long, so the times are measured between the
	# steps: the unlock at 500 ms, the fade-out at 1 s, the end at 1.4 s.
	var gone_at := _seconds_since(start[0])
	t.assert_true(ready_at[0] >= 0.0 and ready_at[0] < fade_out_at, "the input unlocks before the Area Item fades out")
	_near(t, fade_out_at - ready_at[0], Motion.AREA_ITEM_GROW_SECONDS + Motion.AREA_ITEM_STAY_SECONDS - Motion.FADE_SECONDS, "the fade-out starts 500 ms after the unlock")
	_near(t, gone_at - fade_out_at, Motion.AREA_ITEM_FADE_SECONDS, "it fades out in 400 ms")
	await Scene.remove(t, main)
	return true


func test_the_boat_rocks_only_when_it_does_not_move_and_leaves_a_wake(t) -> bool:
	var main := await Scene.add_main(t)
	var boat: BoatView = main.get_node("Boat")
	var wake: WakeView = main.get_node("Wake")
	t.assert_true(boat.idle, "the boat rocks on the start square")
	Scene.send_key(KEY_DOWN)
	t.assert_true(not boat.idle, "no rock while the boat moves")
	var finished := [false]
	main.move_finished.connect(func() -> void: finished[0] = true, CONNECT_ONE_SHOT)
	var timer: SceneTreeTimer = t.create_timer(Scene.MOVE_TIMEOUT)
	while wake.rings.is_empty() and not finished[0] and timer.time_left > 0.0:
		await t.process_frame
	t.assert_true(wake.rings.size() > 0, "the moving boat leaves wake rings")
	if not finished[0]:
		t.assert_true(await t.wait_for(main.move_finished, Scene.MOVE_TIMEOUT), "the move is over")
	t.assert_true(boat.idle, "the boat rocks again")
	await Scene.remove(t, main)
	return true


func test_a_new_labyrinth_stops_a_running_move(t) -> bool:
	var main := await Scene.add_main(t)
	Scene.send_key(KEY_DOWN)
	main.show_labyrinth()
	t.assert_true(not await t.wait_for(main.move_finished, Scene.NO_MOVE_SECONDS), "the old move never ends")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat is on the start square")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "the boat is free for a new move")
	t.assert_eq(main.boat_square, Vector2i(0, 2), "the new move runs")
	await Scene.remove(t, main)
	return true


## The box on the screen of the opaque pixels of `texture`, drawn centred on `centre` with its
## longer side `px` long and no rotation.
func _opaque_rect(texture: Texture2D, centre: Vector2, px: float) -> Rect2:
	var size := texture.get_size()
	var k := px / maxf(size.x, size.y)
	var used := Rect2(texture.get_image().get_used_rect())
	return Rect2(centre + (used.position - size / 2.0) * k, used.size * k)


func _confetti_count(main: Node) -> int:
	var count := 0
	for child in main.get_node("Effects").get_children():
		if child is Burst and child.amount == Motion.CONFETTI_COUNT:
			count += 1
	return count


func _near(t, actual: float, expected: float, label: String) -> void:
	t.assert_true(absf(actual - expected) < TIME_SLACK, "%s: expected %s, got %s" % [label, expected, actual])
