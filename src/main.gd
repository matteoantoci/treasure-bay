## The main scene: one Labyrinth on the screen, the boat, the Items, the Item row, and the
## Collection strip (spec 5, 6). The arrow keys sail the boat. The boat collects each Item that it
## stops on. The chest of the Goal is locked until the last Item. At the open chest, a Sea friend
## comes to the strip, then the next Labyrinth fades in. The motion values of spec 8 are in Motion.
extends Node2D

## Emitted when a Labyrinth shows, with the boat on its start square.
signal labyrinth_started(number: int)
## Emitted when the boat is free again after a slide or a bump.
signal move_finished
## Emitted when the boat collects a new Item. The progress already counts it.
signal item_collected(item: Item)
## Emitted when the boat arrives on the Goal square, before the celebration. The progress already
## holds the Sea friend and the next Labyrinth (spec 12.2).
signal goal_reached(sea_friend: String)
## Emitted when the Sea friend of the Goal flips in at the reveal (game-flow spec part 6, fix 5).
signal sea_friend_appeared(sea_friend: String)
## Emitted at 4.2 s of the Goal celebration, when the fade to the next Labyrinth starts (spec 8.8).
signal next_labyrinth_coming(number: int)
## Emitted when the Child can sail the shown Labyrinth: at once after show_labyrinth(), or at the end
## of the fade-in (spec 5.4, 8.8).
signal labyrinth_ready(number: int)
## Emitted when the boat starts a slide (spec 9.7).
signal move_started
## Emitted when the boat bumps at a wall (spec 5.3, 9.7).
signal bumped
## Emitted when the boat arrives on the Goal square while the chest is locked: an Item of the
## Labyrinth is not collected. Nothing of the Goal happens (game-flow spec Part 2).
signal locked_chest_reached
## Emitted when the last Item of the Labyrinth arrives in its slot and the padlock pops off.
signal chest_unlocked

## The progress of the Child. _ready() loads it from the save file. Tests and tools can replace it,
## then call show_labyrinth().
var progress := Progress.new()
## The save file (spec 12). Tests set a store with their own folder before the scene enters the tree.
var save_store := SaveStore.new()
var labyrinth: Labyrinth
var boat_square := Vector2i.ZERO

## True from the arrival on the Goal to the end of the fade-in of the next Labyrinth, and during the
## fade-in at launch and after a reset. Presses are dropped (spec 5.4, 8.8). Only _unlock() clears it.
var _locked := false
## One early press, kept while the boat is busy (spec 5.4). ZERO means none.
var _kept_direction := Vector2i.ZERO
var _tile_px := 0.0
var _celebration: Tween
## The slide or the bump of the boat while it runs. The boat is busy while this is not null.
var _move_tween: Tween
## The collected Items that fly to their slots now. The padlock pops off only when none flies.
var _items_in_flight := 0

@onready var _water: WaterView = $Water
@onready var _area_decoration: AreaDecoration = $AreaDecoration
@onready var _foam: FoamView = $Foam
@onready var _wake: WakeView = $Wake
@onready var _labyrinth_view: LabyrinthView = $LabyrinthView
@onready var _items: ItemsView = $Items
@onready var _boat: BoatView = $Boat
@onready var _item_row: ItemRow = $ItemRow
@onready var _collection_strip: CollectionStrip = $CollectionStrip
@onready var _gear: GearView = $Gear
@onready var _sea_friend: SeaFriendView = $SeaFriend
@onready var _reveal: RevealView = $Reveal
@onready var _effects: EffectsView = $Effects
@onready var _fade: FadeView = $Fade
@onready var _settings: SettingsPanel = $Settings


func _ready() -> void:
	# Cmd+Q and window close do nothing. The quit button is the only quit path (spec 11.1).
	get_tree().set_auto_accept_quit(false)
	randomize()
	progress = save_store.load_progress()
	# The game saves after each Item and at each Goal, before the celebration (spec 12.2).
	item_collected.connect(save_progress.unbind(1))
	goal_reached.connect(save_progress.unbind(1))
	get_viewport().size_changed.connect(_layout)
	_wake.boat = _boat
	_settings.reset_requested.connect(_reset_progress)
	start_with_fade()


## Shows the current Labyrinth of `progress` at once, with the boat on its start square, and the
## Child can sail it. A Goal celebration or a fade stops. Tests and tools use it; the game starts
## each Labyrinth with a fade-in.
func show_labyrinth() -> void:
	_stop_celebration()
	_fade.stop()
	_show_current_labyrinth()
	_unlock()


## Shows the current Labyrinth of `progress`, and the screen fades in from dark in 500 ms with no
## Area Item: at launch and after a Parent reset (spec 8.8). The input is locked until the end of the
## fade-in (spec 5.4).
func start_with_fade() -> void:
	_stop_celebration()
	_locked = true
	_fade.set_dark()
	_show_current_labyrinth()
	_boat.idle = true
	_fade.fade_in().finished.connect(_unlock)


## Writes the progress to the save file (spec 12.3). The Child gets no message if it fails.
func save_progress() -> void:
	var error := save_store.save(progress)
	if error != OK:
		push_warning("The progress was not saved: %s" % error_string(error))


## The Parent reset (spec 11.2). The game keeps a copy of the old save. A new Voyage starts: new
## seeds, Labyrinth 1, an empty Collection, and a total of 0 (game-flow spec Part 1). The game writes
## the save (spec 12.2), and the screen fades in from dark (spec 8.8). If the copy fails, the reset
## still goes on, because the Parent held the button for the whole hold time.
func _reset_progress() -> void:
	var error := save_store.copy_before_reset(progress)
	if error != OK:
		push_warning("The copy before the reset was not made: %s" % error_string(error))
	progress = Progress.new_voyage(randi())
	save_progress()
	start_with_fade()


## The settings pause play, and the input is locked while they are open. The game does not keep a
## press while the input is locked, so the kept press goes (spec 5.4, 11.2).
func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_kept_direction = Vector2i.ZERO


func _show_current_labyrinth() -> void:
	# A move of the old Labyrinth stops and never ends.
	if _move_tween != null:
		_move_tween.kill()
		_move_tween = null
	labyrinth = progress.build_labyrinth()
	boat_square = labyrinth.start_square()
	_boat.rotation = 0.0
	_kept_direction = Vector2i.ZERO
	_sea_friend.stop()
	_reveal.stop()
	_effects.clear()
	_wake.clear()
	var area := Area.for_labyrinth(progress.labyrinth_number)
	_water.show_area(area)
	_area_decoration.show_labyrinth(labyrinth, area)
	_foam.show_labyrinth(labyrinth)
	_labyrinth_view.labyrinth = labyrinth
	_labyrinth_view.locked = not _all_items_collected()
	_items_in_flight = 0
	_items.show_items(labyrinth, progress)
	_item_row.show_items(labyrinth, progress)
	_collection_strip.show_progress(progress)
	_layout()
	labyrinth_started.emit(progress.labyrinth_number)


func _stop_celebration() -> void:
	if _celebration != null:
		_celebration.kill()
		_celebration = null


## The input unlocks, the boat rocks, and the Child can sail the shown Labyrinth.
func _unlock() -> void:
	_locked = false
	_boat.idle = true
	labyrinth_ready.emit(progress.labyrinth_number)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var direction := _direction_of(event)
	if direction == Vector2i.ZERO:
		return
	get_viewport().set_input_as_handled()
	if _locked:
		return
	if _move_tween != null:
		_kept_direction = direction
	else:
		_move(direction)


func _direction_of(event: InputEvent) -> Vector2i:
	if event.is_action_pressed("move_up"):
		return Vector2i.UP
	if event.is_action_pressed("move_down"):
		return Vector2i.DOWN
	if event.is_action_pressed("move_left"):
		return Vector2i.LEFT
	if event.is_action_pressed("move_right"):
		return Vector2i.RIGHT
	return Vector2i.ZERO


func _move(direction: Vector2i) -> void:
	var move := MoveRule.plan(labyrinth, boat_square, direction, progress.item_states(labyrinth))
	_boat.idle = false
	_wake.start(direction)
	_boat.rotation = move.rotation
	if move.bump:
		bumped.emit()
	else:
		move_started.emit()
	var start := _square_centre(boat_square)
	var tween := create_tween()
	_move_tween = tween
	if move.bump:
		var push := Vector2(direction) * Motion.BUMP_TILES * _tile_px
		Motion.shape(tween.tween_property(_boat, "position", start + push, Motion.BUMP_OUT_SECONDS), Motion.BUMP_CURVE)
		Motion.shape(tween.tween_property(_boat, "position", start, Motion.BUMP_BACK_SECONDS), Motion.BUMP_CURVE)
	else:
		Motion.shape(tween.tween_property(_boat, "position", _square_centre(move.target), move.duration), Motion.SLIDE_CURVE)
	# A new Labyrinth kills the tween. A killed tween does not emit `finished`, and nothing waits on it.
	tween.finished.connect(_end_move.bind(move.target))


## The move ends with the boat on `target`, and the boat is free again. The kept press runs.
func _end_move(target: Vector2i) -> void:
	_move_tween = null
	_wake.stop()
	boat_square = target
	_boat.position = _square_centre(boat_square)
	_boat.idle = true
	_arrive()
	move_finished.emit()
	if _kept_direction != Vector2i.ZERO:
		var kept := _kept_direction
		_kept_direction = Vector2i.ZERO
		_move(kept)


## Collects the Item on the boat square. On the Goal square, the open chest starts the celebration,
## and the locked chest only shakes (spec 5.2, game-flow spec Part 2).
func _arrive() -> void:
	for i in labyrinth.items.size():
		var item := labyrinth.items[i]
		if item.square == boat_square and progress.collect_item(item.id):
			_collect(i)
			item_collected.emit(item)
	if boat_square == labyrinth.goal_square():
		if _all_items_collected():
			_reach_goal()
		else:
			_visit_locked_chest()


func _all_items_collected() -> bool:
	return labyrinth.items.all(func(item: Item) -> bool: return progress.is_collected(item.id))


## The locked chest shakes and the empty slots pulse. The input stays free, the progress does not
## change, and the game does not save (game-flow spec Part 2).
func _visit_locked_chest() -> void:
	_labyrinth_view.shake_chest()
	_item_row.pulse_empty()
	locked_chest_reached.emit()


## The last Item is in its slot: the padlock pops off with 6 sparkles, and the open chest starts to
## sparkle (game-flow spec Part 2).
func _unlock_chest() -> void:
	var centre := _labyrinth_view.position + _labyrinth_view.padlock.position
	_labyrinth_view.pop_padlock()
	var sparkles := Burst.stars(Motion.PADLOCK_SPARKLE_COUNT, Motion.SPARKLE_COLOURS, Motion.PADLOCK_SPARKLE_SPEED_PX, Motion.PADLOCK_SPARKLE_LIFE)
	_effects.burst(sparkles, centre, _labyrinth_scale())
	chest_unlocked.emit()


## The Item splashes, pops, and flies to its outline, which fills when it arrives (spec 8.4). The
## total count goes up at once.
func _collect(index: int) -> void:
	var item := labyrinth.items[index]
	var sprite := _items.sprite_of(item.id)
	var from := _items.position + sprite.position
	_effects.burst(Burst.stars(Motion.SPLASH_COUNT, Motion.SPLASH_COLOURS, Motion.SPLASH_SPEED_PX, Motion.SPLASH_LIFE), from, _labyrinth_scale())
	_effects.fly_item(sprite.texture, from, _items.item_px(), _item_row.outline_centre(index), _show_item_in_outline.bind(index))
	_items.remove_item(item.id)
	_item_row.collect(index)
	_collection_strip.set_count(progress.total_items)
	_items_in_flight += 1


func _show_item_in_outline(index: int) -> void:
	_item_row.show_fill(index)
	var sparkles := Burst.stars(Motion.OUTLINE_SPARKLE_COUNT, Motion.SPARKLE_COLOURS, Motion.OUTLINE_SPARKLE_SPEED_PX, Motion.OUTLINE_SPARKLE_LIFE)
	_effects.burst(sparkles, _item_row.outline_centre(index), _hud_scale())
	_items_in_flight -= 1
	if _items_in_flight == 0 and _labyrinth_view.locked and _all_items_collected():
		_unlock_chest()


## Locks the input, moves the progress on, and plays the Goal celebration of spec 6.3 and 8.5 to
## 8.8: the steps and their times are in Motion.goal_steps().
func _reach_goal() -> void:
	_locked = true
	_kept_direction = Vector2i.ZERO
	_boat.idle = false
	var friend := progress.reach_goal()
	goal_reached.emit(friend)
	_celebration = create_tween().set_parallel()
	for step: Array in Motion.goal_steps():
		_celebration.tween_callback(_run_goal_step.bind(step[1], friend)).set_delay(step[0])


func _run_goal_step(step: Motion.GoalStep, friend: String) -> void:
	var s := _labyrinth_scale()
	var island := _tile_centre(labyrinth.goal_island_tile())
	match step:
		Motion.GoalStep.OPEN_CHEST:
			_labyrinth_view.open_chest()
		Motion.GoalStep.HOP:
			_boat.hop()
		Motion.GoalStep.CONFETTI:
			_effects.burst(Burst.confetti(), island + Vector2(0, -Motion.CONFETTI_RISE_PX * s), s)
		Motion.GoalStep.FRIEND_APPEARS:
			# The reveal: the screen gets darker, and the Sea friend flips in large in the middle of
			# the Labyrinth area (game-flow spec part 6, fix 5).
			if not friend.is_empty():
				_reveal.show_reveal()
				var full_px := Motion.FRIEND_HEIGHT_SHARE * _visible_size().y
				_sea_friend.appear(load(SeaFriends.texture_path(friend)), _reveal.light_centre, full_px)
				sea_friend_appeared.emit(friend)
		Motion.GoalStep.FRIEND_WIGGLES:
			_sea_friend.wiggle()
		Motion.GoalStep.FRIEND_FLIES:
			if not friend.is_empty():
				_sea_friend.fly_to(_slot_centre(friend), ScreenLayout.collection_icon_px(_visible_size()))
				_reveal.fade_out(Motion.FRIEND_FLY_SECONDS, Motion.FRIEND_FLY_CURVE)
		Motion.GoalStep.FRIEND_IN_SLOT:
			_sea_friend.stop()
			_reveal.stop()
			if not friend.is_empty():
				_collection_strip.show_friend(friend)
				var sparkles := Burst.stars(Motion.SLOT_SPARKLE_COUNT, Motion.SPARKLE_COLOURS, Motion.SLOT_SPARKLE_SPEED_PX, Motion.SLOT_SPARKLE_LIFE)
				_effects.burst(sparkles, _slot_centre(friend), _hud_scale())
		Motion.GoalStep.FADE_OUT:
			next_labyrinth_coming.emit(progress.labyrinth_number)
			_fade.fade_out()
		Motion.GoalStep.NEXT_LABYRINTH:
			# The boat stays still until the input unlocks.
			_show_current_labyrinth()
			_fade.fade_in()
			if Motion.starts_new_area(progress.labyrinth_number):
				_fade.show_area_item(Area.item_kinds(Area.for_labyrinth(progress.labyrinth_number))[0], _items.item_px())
		Motion.GoalStep.UNLOCK:
			_celebration = null
			_unlock()


func _layout() -> void:
	var visible := get_viewport().get_visible_rect()
	_item_row.layout(visible.size)
	_collection_strip.layout(visible.size)
	_reveal.layout(visible, ScreenLayout.labyrinth_area(visible.size))
	_gear.layout(visible.size)
	_fade.layout(visible)
	if labyrinth == null:
		return
	var rect := ScreenLayout.labyrinth_rect(visible.size, labyrinth.tile_count())
	_tile_px = rect.size.x / labyrinth.tile_count().x
	_water.layout(visible, rect, _tile_px)
	_area_decoration.position = rect.position
	_area_decoration.set_tile_px(_tile_px)
	_foam.position = rect.position
	_foam.set_tile_px(_tile_px)
	_wake.set_tile_px(_tile_px)
	_labyrinth_view.position = rect.position
	_labyrinth_view.tile_px = _tile_px
	_items.position = rect.position
	_items.set_tile_px(_tile_px)
	_boat.set_tile_px(_tile_px)
	_boat.position = _square_centre(boat_square)


func _visible_size() -> Vector2:
	return get_viewport().get_visible_rect().size


func _labyrinth_scale() -> float:
	return ScreenLayout.labyrinth_scale(_tile_px)


func _hud_scale() -> float:
	return ScreenLayout.hud_scale(_visible_size())


func _slot_centre(friend: String) -> Vector2:
	return ScreenLayout.collection_slot_centres(_visible_size())[SeaFriends.slot_of(friend)]


func _square_centre(square: Vector2i) -> Vector2:
	return _tile_centre(Labyrinth.square_to_tile(square))


func _tile_centre(tile: Vector2i) -> Vector2:
	return _labyrinth_view.position + (Vector2(tile) + Vector2(0.5, 0.5)) * _tile_px
