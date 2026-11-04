## The move rule of spec 5.2 and the bump of spec 5.3: where one arrow press takes the boat. The
## timings are in Motion.
class_name MoveRule
extends RefCounted

## One move from a square to its neighbour crosses 2 tiles (spec 4.5).
const TILES_PER_SQUARE := 2


## The result of one press.
class Move:
	var direction: Vector2i
	## The boat turns at once to this rotation, also before a bump.
	var rotation: float
	## True when the side in `direction` is a wall: the boat bumps and stays.
	var bump: bool
	## The square where the boat stops. For a bump, its own square.
	var target: Vector2i
	var tiles: int
	## Seconds for the whole slide, or for the whole bump.
	var duration: float


## The bow of boat_white_sail.png points down at rotation 0.
static func rotation_for(direction: Vector2i) -> float:
	return atan2(direction.y, direction.x) - PI / 2


## Plans one press in `direction` from `from`. `items` maps the square of each Item of this
## Labyrinth to true if the Child has collected it. The boat stops on an Item not collected.
static func plan(labyrinth: Labyrinth, from: Vector2i, direction: Vector2i, items: Dictionary = {}) -> Move:
	var move := Move.new()
	move.direction = direction
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
		if _stops_at(labyrinth, square, direction, items):
			break
	move.target = square
	move.tiles = squares * TILES_PER_SQUARE
	move.duration = move.tiles * Motion.TILE_SECONDS
	return move


static func _stops_at(labyrinth: Labyrinth, square: Vector2i, direction: Vector2i, items: Dictionary) -> bool:
	if labyrinth.has_wall(square, direction):
		return true
	if labyrinth.open_side_count(square) >= 3:
		return true
	if items.has(square) and not items[square]:
		return true
	return square == labyrinth.goal_square()
