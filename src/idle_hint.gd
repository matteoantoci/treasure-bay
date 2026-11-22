## The idle hint (game-flow spec part 5, fix 10). When the Child presses no key for
## Motion.HINT_IDLE_SECONDS while the play is free, this node emits hop_due, and the main scene hops
## the hint target: the open chest, or else the uncollected Item with the shortest press path from
## the boat. The hop repeats after each further HINT_IDLE_SECONDS, at most Motion.HINT_HOP_COUNT
## times. A key press starts the count again. While the play is not free, the time does not count,
## and it starts again from 0 when the play is free again.
class_name IdleHint
extends Node

## The value of target_square() when no target is in reach.
const NO_TARGET := Vector2i(-1, -1)

## Emitted when the hint target must hop.
signal hop_due

## Returns true while the play is free: no move, no lock, settings closed. The main scene sets it.
var is_play_free := func() -> bool: return false

## Seconds of free play with no key press since the last hop or key press.
var _idle_seconds := 0.0
## Hops since the last key press.
var _hops := 0


## The square of the hint target: the Goal square while the chest is open, else the uncollected Item
## with the shortest press path from `boat_square`. `items` has the shape of MoveRule.plan().
## Returns NO_TARGET when no target is in reach.
static func target_square(labyrinth: Labyrinth, boat_square: Vector2i, items: Dictionary, chest_open: bool) -> Vector2i:
	if chest_open:
		return labyrinth.goal_square()
	var targets := {}
	for square: Vector2i in items:
		if not items[square]:
			targets[square] = true
	var path := MoveRule.nearest_target(labyrinth, boat_square, items, targets)
	return NO_TARGET if path == null else path.target


## Places `sprite` for `phase` of the hint hop, from 0 to 1: up from its rest place `centre`, then
## the landing squash from its rest scale `rest_scale`, with its bottom in place. The values are in
## Motion. `tile_px` is the tile size of the Labyrinth.
static func place_hop(sprite: Sprite2D, centre: Vector2, rest_scale: Vector2, phase: float, tile_px: float) -> void:
	var squash := Motion.hint_hop_squash(phase)
	sprite.scale = rest_scale * squash
	var height := sprite.texture.get_size().y * rest_scale.y
	sprite.position = centre + Vector2(0.0, (1.0 - squash.y) * height / 2.0 - Motion.hint_hop_lift(phase) * tile_px)


## A key press starts the count again: the time and the hops.
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		_idle_seconds = 0.0
		_hops = 0


## The open settings pause the game. The time starts again from 0 when they close.
func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_idle_seconds = 0.0


func _process(delta: float) -> void:
	if not is_play_free.call():
		_idle_seconds = 0.0
		return
	if _hops >= Motion.HINT_HOP_COUNT:
		return
	_idle_seconds += delta
	if _idle_seconds >= Motion.HINT_IDLE_SECONDS:
		_idle_seconds = 0.0
		_hops += 1
		hop_due.emit()
