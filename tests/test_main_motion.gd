## The motion of the main scene (spec 8): the launch fade-in, the Item fly, the Goal celebration
## with the chest, the hops, the confetti, and the Sea friend, the fade between Labyrinths, and the
## first Item of a new Area. The motion values are in test_motion.gd.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
## Game seconds of slack for a time measured in frames.
const TIME_SLACK := 0.2


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
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "the boat stops on the Item")
	var start := Time.get_ticks_usec()
	t.assert_eq(effects.flying_items().size(), 1, "the Item flies")
	t.assert_eq(row.fills[1].modulate.a, 0.0, "its outline is still empty")
	var bounce_scale: Vector2 = row.outlines[1].scale
	var flying := effects.flying_items()[0]
	var texture_px := maxf(flying.texture.get_width(), flying.texture.get_height())
	var smallest := INF
	while row.fills[1].modulate.a == 0.0 and _seconds_since(start) < 2.0:
		if is_instance_valid(flying):
			smallest = minf(smallest, texture_px * flying.scale.x)
		await t.process_frame
	_near(t, _seconds_since(start), Motion.item_fly_arrival(), "the outline starts to fill at the arrival of the Item")
	t.assert_true(row.outlines[1].scale.x > bounce_scale.x, "the outline bounces from a larger size")
	t.assert_eq(effects.flying_items().size(), 0, "the Item is in its outline")
	# The Item is 90 px of the 130 px tile on the water, and it shrinks to 0.55 times that size.
	var item_px: float = 90.0 * main.get_node("LabyrinthView").tile_px / 130.0
	t.assert_true(absf(smallest / item_px - 0.55) < 0.02, "the Item shrinks to 0.55 times its size (%.3f)" % (smallest / item_px))
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
	t.assert_true(friend.visible, "the Sea friend shows")
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


## At the reveal the Sea friend flips in at the middle of the Labyrinth area, the space between the
## top band and the strip. Its horizontal scale starts at 0 and its size at 50 %. It grows to 108 %
## and settles at 100 %: 35 % of the visible height (game-flow spec part 6, fix 5). The flip runs
## at the real time scale, so the frames show the peak.
func test_the_sea_friend_flips_in_large_in_the_middle_of_the_labyrinth_area(t) -> bool:
	var main := await Scene.add_main(t)
	var friend: SeaFriendView = main.get_node("SeaFriend")
	var visible: Vector2 = main.get_viewport().get_visible_rect().size
	var full_px := 0.35 * visible.y
	var at_start := []
	main.sea_friend_appeared.connect(func(_f: String) -> void:
		Engine.time_scale = 1.0
		at_start.append(_shown_size(friend) / full_px), CONNECT_ONE_SHOT)
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	t.assert_true(await t.wait_for(main.sea_friend_appeared, Scene.NEXT_LABYRINTH_TIMEOUT), "the Sea friend appears")
	var start := Time.get_ticks_usec()
	var biggest := 0.0
	while _seconds_since(start) < 0.4:
		biggest = maxf(biggest, _shown_size(friend).y / full_px)
		await t.process_frame
	var end := _shown_size(friend) / full_px
	Engine.time_scale = Scene.TIME_SCALE
	# Godot keeps a scale of 0 at a very small value, so the check uses 1 % of the full size.
	t.assert_true(at_start.size() == 1 and at_start[0].x < 0.01, "the flip starts edge-on")
	t.assert_true(at_start.size() == 1 and is_equal_approx(at_start[0].y, 0.5), "the flip starts at 50 % of the full size")
	t.assert_true(biggest > 1.06 and biggest < 1.081, "it grows to 108 %% (%.3f)" % biggest)
	t.assert_true(end.is_equal_approx(Vector2.ONE), "it settles at 35 %% of the visible height (%s)" % end)
	var top := ScreenLayout.top_band_height(visible)
	var bottom := visible.y - ScreenLayout.bottom_strip_height(visible)
	t.assert_true(friend.position.is_equal_approx(Vector2(visible.x / 2.0, (top + bottom) / 2.0)), "in the middle of the Labyrinth area (%s)" % friend.position)
	await Scene.remove(t, main)
	return true


## At the reveal the screen gets darker, black at 55 %, with a soft light disc in the middle of the
## Labyrinth area. The Labyrinth is under the dark layer. The Collection strip and the Sea friend
## are above it, so the slot stays clear. The dark layer fades out while the Sea friend flies, and
## then the slot shows the Sea friend (game-flow spec part 6, fix 5).
func test_the_screen_gets_darker_behind_the_sea_friend_until_it_flies_to_its_slot(t) -> bool:
	var main := await Scene.add_main(t)
	var reveal: RevealView = main.get_node("Reveal")
	var strip: CollectionStrip = main.get_node("CollectionStrip")
	var friend: SeaFriendView = main.get_node("SeaFriend")
	var visible: Vector2 = main.get_viewport().get_visible_rect().size
	var new_friend := [""]
	main.goal_reached.connect(func(id: String) -> void: new_friend[0] = id, CONNECT_ONE_SHOT)
	t.assert_eq(reveal.dark_colour().a, 0.0, "no dark layer while the Child sails")
	t.assert_true(await Scene.sail_to_goal(t, main), "sailed to the Goal")
	t.assert_true(await t.wait_for(main.sea_friend_appeared, Scene.NEXT_LABYRINTH_TIMEOUT), "the Sea friend appears")
	# Game seconds: after the 250 ms of the dark layer, before the flight at 3.0 s.
	await t.create_timer(0.5).timeout
	t.assert_true(reveal.dark_colour().is_equal_approx(Color(0, 0, 0, 0.55)), "the screen is black at 55 %% (%s)" % reveal.dark_colour())
	t.assert_true(reveal.dark_rect.encloses(Rect2(Vector2.ZERO, visible)), "the dark layer covers the screen")
	t.assert_true(reveal.light_colour().a > 0.5, "the light disc shows")
	var top := ScreenLayout.top_band_height(visible)
	var bottom := visible.y - ScreenLayout.bottom_strip_height(visible)
	t.assert_true(reveal.light_centre.is_equal_approx(Vector2(visible.x / 2.0, (top + bottom) / 2.0)), "the light disc is in the middle of the Labyrinth area")
	for under in ["LabyrinthView", "Boat", "Items", "ItemRow"]:
		t.assert_true(main.get_node(under).get_index() < reveal.get_index(), "%s is under the dark layer" % under)
	t.assert_true(strip.get_index() > reveal.get_index(), "the Collection strip is above the dark layer")
	t.assert_true(friend.get_index() > reveal.get_index(), "the Sea friend is above the dark layer")
	var faded_in_flight := false
	var timer: SceneTreeTimer = t.create_timer(Scene.NEXT_LABYRINTH_TIMEOUT)
	while friend.visible and timer.time_left > 0.0:
		var alpha := reveal.dark_colour().a
		faded_in_flight = faded_in_flight or (alpha > 0.05 and alpha < 0.5)
		await t.process_frame
	t.assert_true(faded_in_flight, "the dark layer fades out during the flight")
	t.assert_eq(reveal.dark_colour().a, 0.0, "the screen is clear when the Sea friend is in its slot")
	t.assert_true(strip.shown_friends().has(new_friend[0]), "the slot of %s shows it" % new_friend[0])
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
	# The Item is 90 px of the 130 px tile of Labyrinth 6.
	var item_px: float = 90.0 * main.get_node("LabyrinthView").tile_px / 130.0
	t.assert_true(biggest > 1.99 * item_px and biggest < 2.4 * item_px, "it grows to 2 times the Item size of 90 px (with the back overshoot)")
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
	while wake.dots.is_empty() and not finished[0] and timer.time_left > 0.0:
		await t.process_frame
	t.assert_true(wake.dots.size() > 0, "the moving boat leaves wake dots")
	t.assert_true(wake.get_index() < main.get_node("LabyrinthView").get_index(), "the wake dots stay under the islands")
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


## Nothing waits for the end of a move that a new Labyrinth stopped, so the stopped move tween is
## freed. A function that waits on its `finished` signal would hold it until the scene is freed.
func test_a_stopped_move_leaves_nothing_waiting(t) -> bool:
	var main := await Scene.add_main(t)
	var refs := _refs_to_new_tweens(t, func() -> void: Scene.send_key(KEY_DOWN))
	t.assert_eq(refs.size(), 1, "the move runs one tween")
	main.show_labyrinth()
	for frame in 3:
		await t.process_frame
	t.assert_true(refs.all(func(ref: WeakRef) -> bool: return ref.get_ref() == null), "the stopped move tween is freed")
	await Scene.remove(t, main)
	return true


## Weak references to the tweens that `action` starts.
func _refs_to_new_tweens(t, action: Callable) -> Array:
	var before: Array = t.get_processed_tweens()
	action.call()
	var refs := []
	for tween: Tween in t.get_processed_tweens():
		if not before.has(tween):
			refs.append(weakref(tween))
	return refs


## The size on the screen of the Sea friend: the long side of its picture, times its scale on each
## axis.
func _shown_size(friend: SeaFriendView) -> Vector2:
	return maxf(friend.texture.get_width(), friend.texture.get_height()) * friend.scale


func _confetti_count(main: Node) -> int:
	var count := 0
	for child in main.get_node("Effects").get_children():
		if child is Burst and child.amount == Motion.CONFETTI_COUNT:
			count += 1
	return count


func _near(t, actual: float, expected: float, label: String) -> void:
	t.assert_true(absf(actual - expected) < TIME_SLACK, "%s: expected %s, got %s" % [label, expected, actual])
