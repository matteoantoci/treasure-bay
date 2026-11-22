## Game-flow spec part 5, fix 10: the idle hint. When the Child presses no key for 6 s while the
## play is free, the open chest or the nearest uncollected Item hops. Labyrinth 1 starts the boat on
## (0, 0) with its Items on (1, 1) and (0, 2). One press down takes the boat to (0, 2). The Item on
## (1, 1) is first in the Item list and nearer in a straight line, but it needs more presses.
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const Fixtures := preload("res://tests/fixtures.gd")


## The press path of the move rule: the boat stops on each uncollected Item, so (0, 2) is one press
## away from the start and (1, 1) is more presses away.
func test_the_nearest_target_has_the_shortest_press_path(t) -> bool:
	var labyrinth := LabyrinthPlan.build(1)
	var items := {Vector2i(1, 1): false, Vector2i(0, 2): false}
	var targets := {Vector2i(1, 1): true, Vector2i(0, 2): true}
	var path := MoveRule.nearest_target(labyrinth, Vector2i(0, 0), items, targets)
	t.assert_eq(path.target, Vector2i(0, 2), "the Item on (0, 2) is the nearest")
	t.assert_eq(path.first_press, Vector2i.DOWN, "the first press is down")
	t.assert_eq(path.presses, 1, "one press")
	items[Vector2i(0, 2)] = true
	path = MoveRule.nearest_target(labyrinth, Vector2i(0, 2), items, {Vector2i(1, 1): true})
	t.assert_eq(path.target, Vector2i(1, 1), "the Item on (1, 1) from (0, 2)")
	t.assert_true(path.presses > 1, "more than one press to (1, 1)")
	t.assert_eq(MoveRule.nearest_target(labyrinth, Vector2i(1, 1), items, {Vector2i(1, 1): true}), null, "no path when the boat is on the target")
	return true


## A LabyrinthView of Labyrinth 1 with a tile of 121 px, in the tree, so it can make tweens.
static func _labyrinth_view(t) -> LabyrinthView:
	var view := LabyrinthView.new()
	t.root.add_child(view)
	view.labyrinth = LabyrinthPlan.build(1)
	view.tile_px = 121.0
	return view


static func _near(t, actual: float, expected: float, label: String) -> void:
	t.assert_true(absf(actual - expected) < 0.01, "%s: %.4f, expected %.4f" % [label, actual, expected])


## Checks one hop of `sprite` in steps of `tween`: up by 12 % of the 121 px tile at the top, then a
## landing squash of 108 % wide and 92 % tall with its bottom in place, then the rest place at
## 350 ms.
static func _check_hop(t, sprite: Sprite2D, tween: Tween, what: String) -> void:
	var rest := sprite.position
	var rest_scale := sprite.scale
	var height := sprite.texture.get_size().y * rest_scale.y
	tween.pause()
	tween.custom_step(0.1225)
	_near(t, rest.y - sprite.position.y, 0.12 * 121.0, "%s: up by 12 %% of a tile at the top" % what)
	t.assert_eq(sprite.scale, rest_scale, "%s: no squash in the air" % what)
	tween.custom_step(0.175)
	_near(t, sprite.scale.x / rest_scale.x, 1.08, "%s: 108 %% wide in the landing squash" % what)
	_near(t, sprite.scale.y / rest_scale.y, 0.92, "%s: 92 %% tall in the landing squash" % what)
	_near(t, sprite.position.y + sprite.texture.get_size().y * sprite.scale.y / 2.0, rest.y + height / 2.0, "%s: the bottom stays in place in the squash" % what)
	_near(t, sprite.position.x, rest.x, "%s: no move sideways" % what)
	tween.custom_step(0.0525)
	t.assert_true(not tween.is_valid() or not tween.is_running(), "%s: the hop ends at 350 ms" % what)
	t.assert_eq(sprite.position, rest, "%s: back in its place" % what)
	t.assert_eq(sprite.scale, rest_scale, "%s: back to its size" % what)


func test_the_chest_hops_up_with_a_landing_squash_in_350_ms(t) -> bool:
	var view := _labyrinth_view(t)
	_check_hop(t, view.chest, view.hop_chest(), "chest")
	view.free()
	return true


func test_an_item_hops_up_with_a_landing_squash_in_350_ms(t) -> bool:
	var labyrinth := LabyrinthPlan.build(1)
	var items := ItemsView.new()
	t.root.add_child(items)
	items.show_items(labyrinth, Progress.new())
	items.set_tile_px(121.0)
	var other: Sprite2D = items.sprite_of(labyrinth.items[1].id)
	var other_rest := other.position
	_check_hop(t, items.sprite_of(labyrinth.items[0].id), items.hop_item(labyrinth.items[0].id), "item")
	t.assert_eq(other.position, other_rest, "the other Item does not hop")
	items.free()
	return true


## Game seconds of a check that no hop comes: a little less than the 6 s of the idle hint.
const NO_HOP_SECONDS := 5.5
## Game seconds to wait for a hop that is due within 6 s.
const HOP_TIMEOUT := 7.0


## Records the square of each hint hop of `main`.
static func _record_hops(main: Node) -> Array:
	var hops := []
	main.hint_hopped.connect(func(square: Vector2i) -> void: hops.append(square))
	return hops


## Waits `seconds` of game time. The timer also runs while the settings pause the game.
static func _wait(t, seconds: float) -> void:
	await t.create_timer(seconds).timeout


## Waits for the next hint hop of `main`. When it comes, the hop plays at the normal speed, and the
## result tells if `sprite` goes up by more than 8 % of a tile from its place at the hop start.
## Returns false when no hop comes in time.
static func _wait_for_hop_of(t, main: Node, sprite: Sprite2D) -> bool:
	var start_y := [0.0]
	main.hint_hopped.connect(func(_square: Vector2i) -> void: start_y[0] = sprite.position.y, CONNECT_ONE_SHOT)
	if not await t.wait_for(main.hint_hopped, HOP_TIMEOUT):
		return false
	Engine.time_scale = 1.0
	var highest: float = start_y[0]
	var timer: SceneTreeTimer = t.create_timer(Motion.HINT_HOP_SECONDS)
	while timer.time_left > 0.0:
		highest = minf(highest, sprite.position.y)
		await t.process_frame
	Engine.time_scale = Scene.TIME_SCALE
	var tile_px: float = main.get_node("LabyrinthView").tile_px
	return start_y[0] - highest > 0.08 * tile_px


## After 6 s with no key press, the Item with the shortest press path hops: (0, 2), not (1, 1).
## After the boat collects it, the next hop is on (1, 1).
func test_the_nearest_item_hops_after_6_seconds_with_no_key_press(t) -> bool:
	var main := await Scene.add_main(t)
	var items: ItemsView = main.get_node("Items")
	var hops := _record_hops(main)
	await _wait(t, NO_HOP_SECONDS)
	t.assert_eq(hops, [], "no hop before 6 s")
	t.assert_true(await _wait_for_hop_of(t, main, items.sprite_of("0,2")), "the Item on (0, 2) hops up")
	t.assert_eq(hops, [Vector2i(0, 2)], "the hop target is the Item on (0, 2)")
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "the boat sails down")
	t.assert_eq(main.progress.collected_items, PackedStringArray(["0,2"]), "the boat collects the Item on (0, 2)")
	t.assert_true(await _wait_for_hop_of(t, main, items.sprite_of("1,1")), "the Item on (1, 1) hops up")
	t.assert_eq(hops, [Vector2i(0, 2), Vector2i(1, 1)], "the next hop target is the Item on (1, 1)")
	await Scene.remove(t, main)
	return true


## With all Items collected, the open chest is the hop target.
func test_the_open_chest_hops_when_all_items_are_collected(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var progress := Progress.new()
	for item in progress.build_labyrinth().items:
		progress.collect_item(item.id)
	SaveStore.new(dir).save(progress)
	var main := await Scene.add_main(t, dir)
	var hops := _record_hops(main)
	t.assert_true(await _wait_for_hop_of(t, main, main.get_node("LabyrinthView").chest), "the chest hops up")
	t.assert_eq(hops, [Vector2i(3, 2)], "the hop target is the chest on the Goal square")
	await Scene.remove(t, main)
	return true


## The hop repeats after each further 6 s, at most 3 times.
func test_the_hop_repeats_every_6_seconds_at_most_3_times(t) -> bool:
	var main := await Scene.add_main(t)
	var hops := _record_hops(main)
	for i in 3:
		await _wait(t, NO_HOP_SECONDS)
		t.assert_eq(hops.size(), i, "no hop %d before 6 s after the last" % (i + 1))
		t.assert_true(await t.wait_for(main.hint_hopped, HOP_TIMEOUT - NO_HOP_SECONDS), "hop %d comes 6 s after the last" % (i + 1))
	await _wait(t, HOP_TIMEOUT)
	t.assert_eq(hops, [Vector2i(0, 2), Vector2i(0, 2), Vector2i(0, 2)], "3 hops, then no more")
	await Scene.remove(t, main)
	return true


## A key press starts the count again: the next hop comes 6 s after the press, and 3 more hops can
## come. The press is up at the top edge, so the boat bumps and stays on the start square.
func test_a_key_press_starts_the_count_again(t) -> bool:
	var main := await Scene.add_main(t)
	var hops := _record_hops(main)
	t.assert_true(await t.wait_for(main.hint_hopped, HOP_TIMEOUT), "the first hop comes")
	await _wait(t, 3.0)
	t.assert_true(await Scene.press(t, main, KEY_UP), "the boat bumps")
	await _wait(t, NO_HOP_SECONDS)
	t.assert_eq(hops.size(), 1, "no hop 6 s after the first hop: the count starts again at the press")
	for i in 3:
		t.assert_true(await t.wait_for(main.hint_hopped, HOP_TIMEOUT), "hop %d after the press comes" % (i + 1))
	await _wait(t, HOP_TIMEOUT)
	t.assert_eq(hops.size(), 4, "1 hop before the press and 3 hops after it")
	await Scene.remove(t, main)
	return true


## No hop on the opening screen. The count starts when the Child can sail.
func test_no_hop_on_the_opening_screen(t) -> bool:
	var main := await Scene.add_main_at_opening(t)
	var hops := _record_hops(main)
	await _wait(t, HOP_TIMEOUT)
	t.assert_eq(hops, [], "no hop on the opening screen")
	t.assert_true(await Scene.start_from_opening(t, main), "the start press fades in Labyrinth 1")
	await _wait(t, NO_HOP_SECONDS)
	t.assert_eq(hops, [], "no hop before 6 s of play")
	t.assert_true(await t.wait_for(main.hint_hopped, HOP_TIMEOUT - NO_HOP_SECONDS), "the hop comes after 6 s of play")
	await Scene.remove(t, main)
	return true


## No hop while the settings are open. The count starts again when they close.
func test_no_hop_while_the_settings_are_open(t) -> bool:
	var main := await Scene.add_main(t)
	var panel: SettingsPanel = main.get_node("Settings")
	var hops := _record_hops(main)
	await _wait(t, 3.0)
	panel.open()
	await _wait(t, HOP_TIMEOUT)
	t.assert_eq(hops, [], "no hop while the settings are open")
	panel.close()
	await _wait(t, NO_HOP_SECONDS)
	t.assert_eq(hops, [], "no hop before 6 s after the settings close")
	t.assert_true(await t.wait_for(main.hint_hopped, HOP_TIMEOUT - NO_HOP_SECONDS), "the hop comes 6 s after the settings close")
	await Scene.remove(t, main)
	return true
