## Game-flow spec Part 2: the padlock on the chest. The chest is locked while an Item of the
## Labyrinth is not collected. A visit to the locked chest shakes the chest, plays the locked sound,
## and pulses the empty Item slots, with no Goal. The last Item pops the padlock off, and then a
## visit to the chest starts the Goal celebration. Labyrinth 1 has its Items on (1, 1) and (0, 2);
## the main path collects only the Item on (0, 2) (see test_items.gd).
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
const Fixtures := preload("res://tests/fixtures.gd")
const SoundLevels := preload("res://src/sound_levels.gd")
const EFFECTS := "res://assets/audio/effects/"
const CHEST_CLOSED := "res://assets/sprites/goal/chest_closed.png"
const PADLOCK := "res://assets/sprites/goal/padlock.png"
## Game seconds of a check that nothing of the Goal comes: longer than the start of the Sea friend
## (1.4 s) and of the fade (4.2 s) of the celebration.
const NO_GOAL_SECONDS := 4.5


## A save store that counts its save calls.
class CountingStore extends SaveStore:
	var saves := 0

	func save(progress: Progress) -> Error:
		saves += 1
		return super(progress)


## Counts each emission of `sig` in the returned list.
static func _count(sig: Signal) -> Array:
	var count := [0]
	sig.connect(func(..._args: Array) -> void: count[0] += 1)
	return count


## A LabyrinthView of Labyrinth 1 with a tile of 121 px, in the tree, so it can make tweens.
static func _view(t) -> LabyrinthView:
	var view := LabyrinthView.new()
	t.root.add_child(view)
	view.labyrinth = LabyrinthPlan.build(1)
	view.tile_px = 121.0
	return view


static func _near(t, actual: float, expected: float, label: String) -> void:
	t.assert_true(absf(actual - expected) < 0.001, "%s: %.4f, expected %.4f" % [label, actual, expected])


func test_the_padlock_sits_on_the_front_of_the_locked_chest(t) -> bool:
	var view := _view(t)
	view.locked = true
	var padlock: Sprite2D = view.padlock
	t.assert_eq(padlock.texture.resource_path, PADLOCK, "the padlock sprite")
	t.assert_true(padlock.visible, "the padlock shows on the locked chest")
	t.assert_true(padlock.get_index() > view.chest.get_index(), "the padlock is drawn over the chest")
	var chest_size: Vector2 = view.chest.texture.get_size() * view.chest.scale
	var chest_rect := Rect2(view.chest.position - chest_size / 2.0, chest_size)
	var padlock_size: Vector2 = padlock.texture.get_size() * padlock.scale
	t.assert_true(chest_rect.encloses(Rect2(padlock.position - padlock_size / 2.0, padlock_size)), "the padlock is inside the chest box")
	t.assert_true(padlock.position.y > view.chest.position.y, "the padlock is on the front, below the chest centre")
	t.assert_true(padlock_size.y < chest_size.y / 2.0, "the padlock is smaller than half the chest")
	view.locked = false
	t.assert_true(not padlock.visible, "no padlock on the open chest")
	view.free()
	return true


## The locked chest does not sparkle. The sparkle of the build spec shows only on the open chest.
func test_only_the_open_chest_sparkles(t) -> bool:
	var view := _view(t)
	var sparkle: Polygon2D = view.chest_sparkle
	var shown := func() -> bool:
		for i in 100:
			view.time = i * 0.02
			view._process(0.0)
			if sparkle.visible:
				return true
		return false
	view.locked = true
	t.assert_true(not shown.call(), "no sparkle on the locked chest in 2 s")
	view.locked = false
	t.assert_true(shown.call(), "the open chest sparkles")
	view.free()
	return true


## The chest moves sideways by 0, -10, 8, -6, 4, -2, 0 px of the 130 px tile, linear, in 360 ms.
## The padlock moves with it.
func test_the_locked_chest_shakes_with_the_spec_offsets(t) -> bool:
	var view := _view(t)
	view.locked = true
	var rest: Vector2 = view.chest.position
	var padlock_rest: Vector2 = view.padlock.position
	var s := view.tile_px / 130.0
	var tween := view.shake_chest()
	tween.pause()
	var offsets := [-10.0, 8.0, -6.0, 4.0, -2.0, 0.0]
	for i in offsets.size():
		tween.custom_step(0.03)
		_near(t, view.chest.position.x - rest.x, (offsets[i] + (offsets[i - 1] if i > 0 else 0.0)) / 2.0 * s, "linear half way to offset %d" % i)
		tween.custom_step(0.03)
		_near(t, view.chest.position.x - rest.x, offsets[i] * s, "offset %d at %d ms" % [i, (i + 1) * 60])
		_near(t, view.padlock.position.x - padlock_rest.x, offsets[i] * s, "the padlock moves with the chest at %d ms" % [(i + 1) * 60])
		t.assert_eq(view.chest.position.y, rest.y, "the chest moves only sideways")
	t.assert_eq(view.chest.position, rest, "the chest is back in its place")
	view.free()
	return true


## The padlock grows to 1.3 times its size and fades out in 300 ms, then it is gone.
func test_the_padlock_pops_off(t) -> bool:
	var view := _view(t)
	view.locked = true
	var size: Vector2 = view.padlock.scale
	var tween := view.pop_padlock()
	tween.pause()
	t.assert_true(not view.locked, "the chest is open from the start of the pop")
	tween.custom_step(0.15)
	t.assert_true(view.padlock.visible, "the padlock shows during the pop")
	t.assert_true(view.padlock.scale.x > size.x and view.padlock.scale.x < 1.3 * size.x, "the padlock grows")
	t.assert_true(view.padlock.modulate.a > 0.0 and view.padlock.modulate.a < 1.0, "the padlock fades")
	tween.custom_step(0.15)
	_near(t, view.padlock.scale.x / size.x, 1.3, "1.3 times its size after 300 ms")
	_near(t, view.padlock.modulate.a, 0.0, "faded out after 300 ms")
	tween.custom_step(0.01)
	t.assert_true(not view.padlock.visible, "the padlock is gone")
	view.free()
	return true


## Each empty slot pulses two times: scale 1.0 to 1.15 and back, 300 ms each. A filled slot does not
## pulse. The slots do not flash.
func test_the_empty_item_slots_pulse_two_times(t) -> bool:
	var labyrinth := LabyrinthPlan.build(1)
	var progress := Progress.new()
	progress.collect_item(labyrinth.items[1].id)
	var row := ItemRow.new()
	t.root.add_child(row)
	row.show_items(labyrinth, progress)
	row.layout(Vector2(1920, 1200))
	var empty_size: Vector2 = row.outlines[0].scale
	var filled_size: Vector2 = row.outlines[1].scale
	var tweens := row.pulse_empty()
	t.assert_eq(tweens.size(), 1, "one pulse: only slot 1 is empty")
	for tween: Tween in tweens:
		tween.pause()
	var expected := [1.15, 1.0, 1.15, 1.0]
	for i in expected.size():
		for tween: Tween in tweens:
			tween.custom_step(0.3)
		_near(t, row.outlines[0].scale.x / empty_size.x, expected[i], "empty slot at %d ms" % [(i + 1) * 300])
		_near(t, row.fills[0].scale.x / empty_size.x, expected[i], "the fill of the empty slot at %d ms" % [(i + 1) * 300])
		t.assert_eq(row.outlines[1].scale, filled_size, "the filled slot does not pulse")
		t.assert_eq(row.outlines[0].modulate.a, 1.0, "the empty slot does not flash")
	row.free()
	return true


## The boat on the Goal square with an Item still uncollected: the chest shakes, the empty slot
## pulses, the locked sound plays, and nothing of the Goal comes. The input stays free.
func test_a_visit_to_the_locked_chest_does_nothing_bad(t) -> bool:
	var main := await Scene.add_main(t)
	var store := CountingStore.new(main.save_store.dir)
	main.save_store = store
	var view: LabyrinthView = main.get_node("LabyrinthView")
	var row: ItemRow = main.get_node("ItemRow")
	var calls := []
	main.get_node("Sound").sound_played.connect(func(path: String, bus: StringName) -> void: calls.append([path, bus]))
	var goals := _count(main.goal_reached)
	var friends := _count(main.sea_friend_appeared)
	var starts := _count(main.labyrinth_started)
	var visits := _count(main.locked_chest_reached)
	var rest: Vector2 = view.chest.position
	var empty_size: Vector2 = row.outlines[0].scale
	t.assert_true(view.locked and view.padlock.visible, "Labyrinth 1 starts with the padlock on the chest")
	t.assert_true(await Scene.sail_main_path_to_goal(t, main), "sailed the main path to the Goal")
	t.assert_eq(main.boat_square, main.labyrinth.goal_square(), "the boat stops on the Goal square")
	t.assert_eq(main.progress.collected_items, PackedStringArray(["0,2"]), "the Item on (1, 1) is still in the water")
	t.assert_eq(visits[0], 1, "one visit to the locked chest")
	t.assert_eq(calls.back(), [EFFECTS + "locked.wav", &"Effects"], "the locked sound plays at the arrival")
	_near(t, main.get_node("Sound").locked_player.volume_db, SoundLevels.volume_db(EFFECTS + "locked.wav"), "the locked sound plays at its level")
	var saves := store.saves
	await t.process_frame
	t.assert_true(view.chest.position.x < rest.x, "the chest shakes to the left first")
	var largest := 0.0
	var timer: SceneTreeTimer = t.create_timer(0.7)
	while timer.time_left > 0.0:
		largest = maxf(largest, row.outlines[0].scale.x / empty_size.x)
		await t.process_frame
	t.assert_true(largest > 1.1 and largest <= 1.15 + 0.001, "the empty slot pulses to 1.15 times its size (%.3f)" % largest)
	t.assert_eq(view.chest.position, rest, "the chest is back in its place")
	t.assert_true(view.locked and view.padlock.visible, "the chest stays locked")
	t.assert_eq(view.chest.texture.resource_path, CHEST_CLOSED, "the chest stays closed")
	await t.create_timer(NO_GOAL_SECONDS).timeout
	t.assert_eq([goals[0], friends[0], starts[0]], [0, 0, 0], "no Goal celebration, no new Sea friend, and no next Labyrinth")
	t.assert_eq(main.progress.labyrinth_number, 1, "the progress stays in Labyrinth 1")
	t.assert_eq(main.progress.collection, PackedStringArray(), "the Collection stays empty")
	t.assert_eq(main.progress.total_items, 1, "the total stays 1")
	t.assert_eq(store.saves, saves, "the game does not save at the locked chest")
	t.assert_true(await Scene.press(t, main, KEY_LEFT), "one press in the open direction moves the boat")
	t.assert_true(main.boat_square != main.labyrinth.goal_square(), "the boat sails away from the Goal")
	await Scene.remove(t, main)
	return true


## The last Item pops the padlock off when it arrives in its slot, with 6 sparkles and the unlock
## sound. After that, a visit to the chest starts the Goal celebration.
func test_the_last_item_unlocks_the_chest_and_the_goal_follows(t) -> bool:
	var main := await Scene.add_main(t)
	var view: LabyrinthView = main.get_node("LabyrinthView")
	var effects: EffectsView = main.get_node("Effects")
	var calls := []
	main.get_node("Sound").sound_played.connect(func(path: String, bus: StringName) -> void: calls.append([path, bus]))
	var at_unlock := []
	main.chest_unlocked.connect(func() -> void:
		var bursts := effects.get_children().filter(func(node: Node) -> bool: return node is Burst and node.amount == 6)
		at_unlock.append([main.progress.total_items, view.locked, bursts.size(), calls.back()]))
	var at_last_item := []
	main.item_collected.connect(func(_item: Item) -> void:
		if main.progress.total_items == 2:
			at_last_item.append([view.locked, view.padlock.visible]))
	var labyrinth: Labyrinth = main.labyrinth
	while main.progress.total_items < 2:
		var direction := Scene.first_press(labyrinth, main.boat_square, main.progress.item_states(labyrinth))
		t.assert_true(await Scene.press(t, main, Scene.key_for(direction)), "the move is over")
	t.assert_eq(at_last_item, [[true, true]], "the padlock stays on while the last Item flies")
	t.assert_true(await t.wait_for(main.chest_unlocked, Scene.MOVE_TIMEOUT), "the chest unlocks")
	t.assert_eq(at_unlock.size(), 1, "one unlock")
	if at_unlock.size() == 1:
		t.assert_eq(at_unlock[0][1], false, "the chest is open")
		t.assert_eq(at_unlock[0][2], 1, "6 sparkles burst at the unlock")
		t.assert_eq(at_unlock[0][3], [EFFECTS + "unlock.wav", &"Effects"], "the unlock sound plays")
	_near(t, main.get_node("Sound").unlock_player.volume_db, SoundLevels.volume_db(EFFECTS + "unlock.wav"), "the unlock sound plays at its level")
	var reached := []
	main.goal_reached.connect(func(friend: String) -> void: reached.append(friend))
	t.assert_true(await Scene.sail_to_goal(t, main), "a visit to the open chest starts the Goal celebration")
	t.assert_eq(reached, ["crab"], "the crab comes")
	t.assert_true(not view.padlock.visible, "no padlock in the celebration")
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.NEXT_LABYRINTH_TIMEOUT), "Labyrinth 2 starts")
	t.assert_true(view.locked and view.padlock.visible, "Labyrinth 2 starts with the padlock on the chest")
	await Scene.remove(t, main)
	return true


## A load with all Items collected shows the open chest with no padlock.
func test_a_load_with_all_items_collected_shows_the_open_chest(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var progress := Progress.new()
	for item in progress.build_labyrinth().items:
		progress.collect_item(item.id)
	SaveStore.new(dir).save(progress)
	var main := await Scene.add_main(t, dir)
	var view: LabyrinthView = main.get_node("LabyrinthView")
	t.assert_eq(main.progress.collected_items.size(), 2, "the save holds both Items")
	t.assert_true(not view.locked and not view.padlock.visible, "no padlock")
	var shown := false
	for i in 100:
		view.time = i * 0.02
		view._process(0.0)
		shown = shown or view.chest_sparkle.visible
	t.assert_true(shown, "the open chest sparkles")
	t.assert_true(await Scene.sail_to_goal(t, main), "a visit to the chest starts the Goal celebration")
	await Scene.remove(t, main)
	return true
