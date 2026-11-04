## One Labyrinth: W x H squares, each with 4 wall bits (spec 4.2), and the tiles that the game
## draws from them (spec 4.5). The generator opens the walls. The view only reads this data.
class_name Labyrinth
extends RefCounted

const NORTH := 1
const EAST := 2
const SOUTH := 4
const WEST := 8
const ALL_WALLS := NORTH | EAST | SOUTH | WEST

## The 4 directions in the order north, east, south, west.
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

var width: int
var height: int
## Wall bits of each square, at index y * width + x. A set bit is a closed wall.
var _walls: PackedByteArray
## The seed that LabyrinthPlan.build() used. The wall island decoration uses seed_value + 1 (spec 7.1).
var seed_value := 0
## The Items in placement order (spec 4.6). LabyrinthPlan.build() places them.
var items: Array[Item] = []


## Makes a Labyrinth with every wall closed.
func _init(w: int, h: int) -> void:
	width = w
	height = h
	_walls.resize(w * h)
	_walls.fill(ALL_WALLS)


static func wall_bit(direction: Vector2i) -> int:
	match direction:
		Vector2i.UP:
			return NORTH
		Vector2i.RIGHT:
			return EAST
		Vector2i.DOWN:
			return SOUTH
		Vector2i.LEFT:
			return WEST
	push_error("Not a direction: %s" % direction)
	return 0


func contains(square: Vector2i) -> bool:
	return square.x >= 0 and square.y >= 0 and square.x < width and square.y < height


func wall_bits(square: Vector2i) -> int:
	return _walls[square.y * width + square.x]


func has_wall(square: Vector2i, direction: Vector2i) -> bool:
	return wall_bits(square) & wall_bit(direction) != 0


## Opens the wall between a square and its neighbour, on both sides.
func open_wall(square: Vector2i, direction: Vector2i) -> void:
	var neighbour := square + direction
	_walls[square.y * width + square.x] &= ~wall_bit(direction)
	_walls[neighbour.y * width + neighbour.x] &= ~wall_bit(-direction)


func open_side_count(square: Vector2i) -> int:
	var count := 0
	for direction in DIRECTIONS:
		if not has_wall(square, direction):
			count += 1
	return count


func start_square() -> Vector2i:
	return Vector2i.ZERO


func goal_square() -> Vector2i:
	return Vector2i(width - 1, height - 1)


## Breadth-first search distances in moves of one square, at index y * width + x.
## A square that the search cannot reach has -1.
func distances_from(square: Vector2i) -> PackedInt32Array:
	var distances := PackedInt32Array()
	distances.resize(width * height)
	distances.fill(-1)
	distances[square.y * width + square.x] = 0
	var queue: Array[Vector2i] = [square]
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		for direction in DIRECTIONS:
			if has_wall(current, direction):
				continue
			var next := current + direction
			var index := next.y * width + next.x
			if distances[index] == -1:
				distances[index] = distances[current.y * width + current.x] + 1
				queue.append(next)
	return distances


func all_squares_reachable() -> bool:
	return not distances_from(start_square()).has(-1)


## The drawn grid has 2W + 1 by 2H + 1 tiles.
func tile_count() -> Vector2i:
	return Vector2i(2 * width + 1, 2 * height + 1)


static func square_to_tile(square: Vector2i) -> Vector2i:
	return square * 2 + Vector2i.ONE


## A square tile is water. A tile between two neighbour squares is water if their wall is open.
## All other tiles (corners and border) are island.
func is_water_tile(tile: Vector2i) -> bool:
	var count := tile_count()
	if tile.x <= 0 or tile.y <= 0 or tile.x >= count.x - 1 or tile.y >= count.y - 1:
		return false
	var odd_x := tile.x % 2 == 1
	var odd_y := tile.y % 2 == 1
	if odd_x and odd_y:
		return true
	if odd_y:
		return not has_wall(Vector2i(tile.x / 2 - 1, tile.y / 2), Vector2i.RIGHT)
	if odd_x:
		return not has_wall(Vector2i(tile.x / 2, tile.y / 2 - 1), Vector2i.DOWN)
	return false


## The Goal island is the border tile to the right of the Goal square (spec 6.2).
func goal_island_tile() -> Vector2i:
	return Vector2i(2 * width, 2 * height - 1)
