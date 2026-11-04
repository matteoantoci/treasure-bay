## The main scene: one Labyrinth on the screen, the boat, and the arrow keys (spec 5).
## At the Goal, the next Labyrinth starts.
extends Node2D

## Emitted when a Labyrinth shows, with the boat on its start square.
signal labyrinth_started(number: int)
## Emitted when the boat is free again after a slide or a bump.
signal move_finished

## The deep water colour of Area 1 (spec 7.2).
const WATER_COLOUR := Color("#3fb4d8")

## The current Labyrinth number, from 1.
var labyrinth_number := 0
## The seed of the current random Labyrinth (number above 20), else 0.
var random_seed := 0
var labyrinth: Labyrinth
var boat_square := Vector2i.ZERO

var _busy := false
## One early press, kept while the boat is busy (spec 5.4). ZERO means none.
var _kept_direction := Vector2i.ZERO
var _tile_px := 0.0

@onready var _water: ColorRect = $Water
@onready var _labyrinth_view: LabyrinthView = $LabyrinthView
@onready var _boat: BoatView = $Boat


func _ready() -> void:
	randomize()
	_water.color = WATER_COLOUR
	get_viewport().size_changed.connect(_layout)
	start_labyrinth(1)


func start_labyrinth(number: int) -> void:
	labyrinth_number = number
	random_seed = LabyrinthPlan.new_random_seed() if LabyrinthPlan.is_random(number) else 0
	labyrinth = LabyrinthPlan.build(number, random_seed)
	boat_square = labyrinth.start_square()
	_boat.rotation = 0.0
	_kept_direction = Vector2i.ZERO
	_labyrinth_view.labyrinth = labyrinth
	_layout()
	labyrinth_started.emit(number)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var direction := _direction_of(event)
	if direction == Vector2i.ZERO:
		return
	get_viewport().set_input_as_handled()
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
	var move := MoveRule.plan(labyrinth, boat_square, direction)
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
	if boat_square == labyrinth.goal_square():
		# The press kept during the last slide is dropped: the Goal locks the input (spec 5.4).
		start_labyrinth(labyrinth_number + 1)
	move_finished.emit()
	if _kept_direction != Vector2i.ZERO:
		var kept := _kept_direction
		_kept_direction = Vector2i.ZERO
		_move(kept)


func _layout() -> void:
	var visible := get_viewport().get_visible_rect()
	_water.position = visible.position
	_water.size = visible.size
	if labyrinth == null:
		return
	var rect := ScreenLayout.labyrinth_rect(visible.size, labyrinth.tile_count())
	_tile_px = rect.size.x / labyrinth.tile_count().x
	_labyrinth_view.position = rect.position
	_labyrinth_view.tile_px = _tile_px
	_boat.set_tile_px(_tile_px)
	_boat.position = _square_centre(boat_square)


func _square_centre(square: Vector2i) -> Vector2:
	var tile := Labyrinth.square_to_tile(square)
	return _labyrinth_view.position + (Vector2(tile) + Vector2(0.5, 0.5)) * _tile_px
