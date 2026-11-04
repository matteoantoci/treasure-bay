## The wake of spec 8.2: while the boat moves, about 36 rings each second start 30 px behind the
## boat centre on the move line, a little to the left and to the right in turn, so they make a V.
## Each ring is a white ellipse line, turned to the boat direction, that grows and fades out. This
## node is above the water and under the islands, in the coordinates of the boat.
class_name WakeView
extends Node2D


class Ring:
	var centre: Vector2
	var rotation: float
	var age := 0.0


## The boat that the rings follow.
var boat: Node2D
## While true, new rings start behind the boat.
var active := false
## The rings on the water, oldest first.
var rings: Array[Ring] = []
var _direction := Vector2.DOWN
var _tile_px := 0.0
## Rings due: one more ring starts each time this reaches 1.
var _due := 0.0
## The side of the next ring: 1 or -1.
var _side := 1.0


func set_tile_px(tile_px: float) -> void:
	_tile_px = tile_px


## New rings start behind the boat while it moves in `direction`.
func start(direction: Vector2i) -> void:
	_direction = Vector2(direction)
	active = true


func stop() -> void:
	active = false
	_due = 0.0


## Removes all rings at once, for a new Labyrinth.
func clear() -> void:
	stop()
	rings.clear()
	queue_redraw()


func _process(delta: float) -> void:
	for ring in rings:
		ring.age += delta
	while not rings.is_empty() and rings[0].age >= Motion.WAKE_LIFE:
		rings.pop_front()
	if active and boat != null:
		_due += delta * Motion.WAKE_RINGS_PER_SECOND
		while _due >= 1.0:
			_due -= 1.0
			_add_ring()
	queue_redraw()


func _add_ring() -> void:
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	var ring := Ring.new()
	var side := _direction.orthogonal() * Motion.WAKE_SIDE_PX * _side
	ring.centre = boat.position + (side - _direction * Motion.WAKE_BEHIND_PX) * s
	ring.rotation = MoveRule.rotation_for(Vector2i(_direction))
	rings.append(ring)
	_side = -_side


func _draw() -> void:
	var s := ScreenLayout.labyrinth_scale(_tile_px)
	for ring in rings:
		var radii := Motion.wake_ring_radii(ring.age) * s
		var points := PackedVector2Array()
		for k in 25:
			var angle := TAU * k / 24.0
			points.append(ring.centre + Vector2(cos(angle) * radii.x, sin(angle) * radii.y).rotated(ring.rotation))
		draw_polyline(points, Color(1, 1, 1, Motion.wake_ring_alpha(ring.age)), Motion.WAKE_WIDTH_PX * s, true)
