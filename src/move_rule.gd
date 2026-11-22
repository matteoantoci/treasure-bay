## The move rule of spec 5.2 and the bump of spec 5.3: where one arrow press takes the boat. The
## timings are in Motion.
class_name MoveRule
extends RefCounted

## One move from a square to its neighbour crosses 2 tiles (spec 4.5).
const TILES_PER_SQUARE := 2


## The result of one press.
class Move:
	## The boat turns at once to this rotation, also before a bump.
	var rotation: float
	## True when the side in `direction` is a wall: the boat bumps and stays.
	var bump: bool
	## The square where the boat stops. For a bump, its own square.
	var target: Vector2i
	var tiles: int
	## Seconds for the whole slide, or for the whole bump.
	var duration: float


## The shortest press path to a target, as nearest_target() gives it.
class PressPath:
	## The target square at the end of the path.
	var target: Vector2i
	## The first press of the path.
	var first_press: Vector2i
	## The count of presses on the path.
	var presses: int


## The bow of boat_white_sail.png points down at rotation 0.
static func rotation_for(direction: Vector2i) -> float:
	return atan2(direction.y, direction.x) - PI / 2


## Plans one press in `direction` from `from`. `items` maps the square of each Item of this
## Labyrinth to true if the Child has collected it. The boat stops on an Item not collected.
static func plan(labyrinth: Labyrinth, from: Vector2i, direction: Vector2i, items: Dictionary = {}) -> Move:
	var move := Move.new()
	move.rotation = rotation_for(direction)
	move.target = from
	if labyrinth.has_wall(from, direction):
		move.bump = true
		move.duration = Motion.BUMP_OUT_SECONDS + Motion.BUMP_BACK_SECONDS
		return move
	var squares := 0
	var square := from
	while true:
		square += direction
		squares += 1
		if stops_at(labyrinth, square, direction, items):
			break
	move.target = square
	move.tiles = squares * TILES_PER_SQUARE
	move.duration = move.tiles * Motion.TILE_SECONDS
	return move


## True when a boat that moves in `direction` and arrives on `square` stops there (spec 5.2 rule 3).
## `items` has the shape of plan(). LabyrinthMeasure counts the presses with it.
static func stops_at(labyrinth: Labyrinth, square: Vector2i, direction: Vector2i, items: Dictionary = {}) -> bool:
	if labyrinth.has_wall(square, direction):
		return true
	if labyrinth.open_side_count(square) >= 3:
		return true
	if items.has(square) and not items[square]:
		return true
	return square == labyrinth.goal_square()


## The shortest press path from `from` to the nearest square of `targets`, a set of squares. Each
## press follows plan() with `items`, so the boat stops on each Item not collected and on the Goal.
## Of two paths with the same press count, the first in the order of Labyrinth.DIRECTIONS wins.
## Returns null when `from` is a target or no target is in reach. The idle hint and the test helpers
## use it.
static func nearest_target(labyrinth: Labyrinth, from: Vector2i, items: Dictionary, targets: Dictionary) -> PressPath:
	if targets.has(from):
		return null
	# Breadth-first search over the stops of the move rule. Each stop keeps the first press and the
	# press count of the first path that reaches it.
	var first := {from: Vector2i.ZERO}
	var presses := {from: 0}
	var queue: Array[Vector2i] = [from]
	var head := 0
	while head < queue.size():
		var square := queue[head]
		head += 1
		for direction in Labyrinth.DIRECTIONS:
			var move := plan(labyrinth, square, direction, items)
			if move.bump or first.has(move.target):
				continue
			first[move.target] = direction if square == from else first[square]
			presses[move.target] = presses[square] + 1
			if targets.has(move.target):
				var path := PressPath.new()
				path.target = move.target
				path.first_press = first[move.target]
				path.presses = presses[move.target]
				return path
			queue.append(move.target)
	return null
