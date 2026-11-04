## The main scene: one Labyrinth on the screen, the boat, the Items, the Item row, and the
## Collection strip (spec 5, 6). The arrow keys sail the boat. The boat collects each Item that it
## stops on. At the Goal, a Sea friend comes to the strip, then the next Labyrinth starts.
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
## Emitted when the Sea friend of the Goal appears next to the Goal island.
signal sea_friend_appeared(sea_friend: String)

## Goal celebration times in seconds from the arrival on the Goal square (spec 6.3).
const SEA_FRIEND_APPEARS_SECONDS := 1.4
const SEA_FRIEND_IN_SLOT_SECONDS := 3.7
const NEXT_LABYRINTH_SECONDS := 4.2
## Next to the Goal island, the Sea friend is 1.3 times 110 px, 30 px above the island centre, in
## px of the prototype tile (spec 8.6, 10).
const SEA_FRIEND_PX := 110.0 * 1.3
const SEA_FRIEND_RISE_PX := 30.0

## The progress of the Child. The save code can replace it, then call show_labyrinth().
var progress := Progress.new()
## The save file (spec 12). Tests set a store with their own folder before the scene enters the tree.
var save_store := SaveStore.new()
var labyrinth: Labyrinth
var boat_square := Vector2i.ZERO

var _busy := false
## True from the arrival on the Goal to the start of the next Labyrinth. Presses are dropped
## (spec 5.4).
var _locked := false
## One early press, kept while the boat is busy (spec 5.4). ZERO means none.
var _kept_direction := Vector2i.ZERO
var _tile_px := 0.0
var _celebration: Tween

@onready var _water: WaterView = $Water
@onready var _area_decoration: AreaDecoration = $AreaDecoration
@onready var _labyrinth_view: LabyrinthView = $LabyrinthView
@onready var _items: ItemsView = $Items
@onready var _boat: BoatView = $Boat
@onready var _item_row: ItemRow = $ItemRow
@onready var _collection_strip: CollectionStrip = $CollectionStrip
@onready var _gear: GearView = $Gear
@onready var _sea_friend: Sprite2D = $SeaFriend


func _ready() -> void:
	randomize()
	progress = save_store.load_progress()
	# The game saves after each Item and at each Goal, before the celebration (spec 12.2).
	item_collected.connect(save_progress.unbind(1))
	goal_reached.connect(save_progress.unbind(1))
	get_viewport().size_changed.connect(_layout)
	show_labyrinth()


## Shows the current Labyrinth of `progress`, with the boat on its start square.
func show_labyrinth() -> void:
	if _celebration != null:
		_celebration.kill()
		_celebration = null
	labyrinth = progress.build_labyrinth()
	boat_square = labyrinth.start_square()
	_boat.rotation = 0.0
	_kept_direction = Vector2i.ZERO
	_locked = false
	_sea_friend.visible = false
	var area := Area.for_labyrinth(progress.labyrinth_number)
	_water.show_area(area)
	_area_decoration.show_labyrinth(labyrinth, area)
	_labyrinth_view.labyrinth = labyrinth
	_items.show_items(labyrinth, progress)
	_item_row.show_items(labyrinth, progress)
	_collection_strip.show_progress(progress)
	_layout()
	labyrinth_started.emit(progress.labyrinth_number)


## Writes the progress to the save file (spec 12.3). The Child gets no message if it fails.
func save_progress() -> void:
	var error := save_store.save(progress)
	if error != OK:
		push_warning("The progress was not saved: %s" % error_string(error))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var direction := _direction_of(event)
	if direction == Vector2i.ZERO:
		return
	get_viewport().set_input_as_handled()
	if _locked:
		return
	if _busy:
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
	_busy = true
	_boat.rotation = move.rotation
	var start := _square_centre(boat_square)
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if move.bump:
		var push := Vector2(direction) * MoveRule.BUMP_TILES * _tile_px
		tween.tween_property(_boat, "position", start + push, MoveRule.BUMP_OUT_SECONDS)
		tween.tween_property(_boat, "position", start, MoveRule.BUMP_BACK_SECONDS)
	else:
		tween.tween_property(_boat, "position", _square_centre(move.target), move.duration)
	await tween.finished
	boat_square = move.target
	_boat.position = _square_centre(boat_square)
	_busy = false
	_arrive()
	move_finished.emit()
	if _kept_direction != Vector2i.ZERO:
		var kept := _kept_direction
		_kept_direction = Vector2i.ZERO
		_move(kept)


## Collects the Item on the boat square, and starts the celebration on the Goal square (spec 5.2).
func _arrive() -> void:
	for i in labyrinth.items.size():
		var item := labyrinth.items[i]
		if item.square == boat_square and progress.collect_item(item.id):
			_items.remove_item(item.id)
			_item_row.fill(i)
			_collection_strip.set_count(progress.total_items)
			item_collected.emit(item)
	if boat_square == labyrinth.goal_square():
		_reach_goal()


## Locks the input, moves the progress on, and plays the celebration of spec 6.3: the Sea friend
## appears at 1.4 s, is in its slot at 3.7 s, and the next Labyrinth starts at 4.2 s.
func _reach_goal() -> void:
	_locked = true
	_kept_direction = Vector2i.ZERO
	var friend := progress.reach_goal()
	goal_reached.emit(friend)
	_celebration = create_tween()
	_celebration.tween_interval(SEA_FRIEND_APPEARS_SECONDS)
	_celebration.tween_callback(_show_sea_friend.bind(friend))
	_celebration.tween_interval(SEA_FRIEND_IN_SLOT_SECONDS - SEA_FRIEND_APPEARS_SECONDS)
	_celebration.tween_callback(_put_sea_friend_in_slot.bind(friend))
	_celebration.tween_interval(NEXT_LABYRINTH_SECONDS - SEA_FRIEND_IN_SLOT_SECONDS)
	_celebration.tween_callback(show_labyrinth)


func _show_sea_friend(friend: String) -> void:
	if friend.is_empty():
		return
	_sea_friend.texture = load(SeaFriends.texture_path(friend))
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	var centre := _tile_centre(labyrinth.goal_island_tile()) + Vector2(0, -SEA_FRIEND_RISE_PX * s)
	var rect := ScreenLayout.sprite_rect(centre, _sea_friend.texture.get_size(), SEA_FRIEND_PX * s)
	_sea_friend.position = rect.get_center()
	_sea_friend.scale = rect.size / _sea_friend.texture.get_size()
	_sea_friend.visible = true
	sea_friend_appeared.emit(friend)


func _put_sea_friend_in_slot(friend: String) -> void:
	_sea_friend.visible = false
	if not friend.is_empty():
		_collection_strip.show_friend(friend)


func _layout() -> void:
	var visible := get_viewport().get_visible_rect()
	_item_row.layout(visible.size)
	_collection_strip.layout(visible.size)
	_gear.layout(visible.size)
	if labyrinth == null:
		return
	var rect := ScreenLayout.labyrinth_rect(visible.size, labyrinth.tile_count())
	_tile_px = rect.size.x / labyrinth.tile_count().x
	_water.layout(visible, rect, _tile_px)
	_area_decoration.position = rect.position
	_area_decoration.set_tile_px(_tile_px)
	_labyrinth_view.position = rect.position
	_labyrinth_view.tile_px = _tile_px
	_items.position = rect.position
	_items.set_tile_px(_tile_px)
	_boat.set_tile_px(_tile_px)
	_boat.position = _square_centre(boat_square)


func _square_centre(square: Vector2i) -> Vector2:
	return _tile_centre(Labyrinth.square_to_tile(square))


func _tile_centre(tile: Vector2i) -> Vector2:
	return _labyrinth_view.position + (Vector2(tile) + Vector2(0.5, 0.5)) * _tile_px
