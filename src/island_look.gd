## The Kenney island look of a Labyrinth (spec 7.1): the Kenney tile of each Kenney cell, and the
## rocks and bushes on the wall islands. The outside of the Labyrinth is sea, but the tile right of
## the Goal island tile is island too: the Goal island is 2 tiles wide, with a sand coast all
## around (game-flow spec part 5, fix 4). The 2 Goal island tiles get no rock and no bush: the
## view puts the palm and the chest on them (spec 6.2).
##
## Each Labyrinth tile is drawn as 3 x 3 Kenney cells (Open gap 1). The Kenney coast tiles need an
## island at least 2 tiles thick, and a wall island is only 1 Labyrinth tile thick. With 3 x 3
## cells, each island has a sand coast around a grass top, like the Kenney sample.
##
## A second PRNG with seed `labyrinth.seed_value + 1` picks the decorations, then the tile variants,
## so the Labyrinth data stays the same (spec 7.1).
class_name IslandLook
extends RefCounted

## Kenney cells on each side of a Labyrinth tile.
const CELLS_PER_TILE := 3
## Kenney tile numbers of assets/kenney/tiles/tile_NN.png, picked by eye (spec 7.1).
const GRASS := 23
const PALM := 71
const BUSH := 70
const ROCKS: Array[int] = [49, 50, 51, 65, 66, 67]
## One island tile in DECORATION_CHANCE gets a decoration: half of them the bush, half a rock.
const DECORATION_CHANCE := 6
## One Kenney cell in VARIANT_CHANCE gets a variant of its tile with the same shape: a coast with a
## grass bump, or grass with dots.
const VARIANT_CHANCE := 3
const VARIANTS := {
	7: [8],
	25: [41],
	55: [56],
	22: [38],
	GRASS: [39, 40, 24],
}
## Straight coast, by the side of the water.
const COAST := {
	Vector2i.UP: 7,
	Vector2i.RIGHT: 25,
	Vector2i.DOWN: 55,
	Vector2i.LEFT: 22,
}
## Outer corners, by the corner of the water.
const OUTER_CORNERS := {
	Vector2i(-1, -1): 6,
	Vector2i(1, -1): 9,
	Vector2i(-1, 1): 54,
	Vector2i(1, 1): 57,
}
## Inner corners, with water only at this diagonal.
const INNER_CORNERS := {
	Vector2i(-1, -1): 53,
	Vector2i(1, -1): 52,
	Vector2i(-1, 1): 37,
	Vector2i(1, 1): 36,
}

## Kenney cell -> Kenney tile number. Cell (0, 0) is the top-left cell of Labyrinth tile (0, 0).
## Water cells are absent.
var cells := {}
## Labyrinth tile -> Kenney tile number of its rock or bush, drawn on the centre cell.
var decorations := {}


static func build(labyrinth: Labyrinth) -> IslandLook:
	var look := IslandLook.new()
	var is_island := func(tile: Vector2i) -> bool: return _is_island(labyrinth, tile)
	var tiles: Array[Vector2i] = []
	var count := labyrinth.tile_count()
	for y in count.y:
		for x in count.x:
			tiles.append(Vector2i(x, y))
	# The outer Goal island tile comes last, so the tile variants of the Labyrinth tiles keep their
	# PRNG outputs.
	tiles.append(goal_island_tiles(labyrinth)[1])
	for tile in tiles:
		if is_island.call(tile):
			look._add_tile(is_island, tile)
	var prng := Prng.new(labyrinth.seed_value + 1)
	for y in count.y:
		for x in count.x:
			var tile := Vector2i(x, y)
			if not _is_island(labyrinth, tile) or tile == labyrinth.goal_island_tile():
				continue
			var r := prng.next()
			if r % DECORATION_CHANCE == 0:
				var pick := (r / DECORATION_CHANCE) % (2 * ROCKS.size())
				look.decorations[tile] = BUSH if pick < ROCKS.size() else ROCKS[pick - ROCKS.size()]
	look._pick_variants(prng)
	return look


## An island of `tiles` Labyrinth tiles, all land, from tile (0, 0), in the sea: a sand coast around
## a grass top, with the cell rules of build(). It has no rock and no bush. A PRNG with seed
## `seed_value` picks the tile variants. The opening screen and the Party show it (game-flow spec
## parts 3 and 4).
static func block(tiles: Vector2i, seed_value: int) -> IslandLook:
	var look := IslandLook.new()
	var is_island := func(tile: Vector2i) -> bool: return Rect2i(Vector2i.ZERO, tiles).has_point(tile)
	for y in tiles.y:
		for x in tiles.x:
			look._add_tile(is_island, Vector2i(x, y))
	look._pick_variants(Prng.new(seed_value))
	return look


## The Goal island: the Goal island tile on the right border, and the tile right of it, outside the
## Labyrinth.
static func goal_island_tiles(labyrinth: Labyrinth) -> Array[Vector2i]:
	var tile := labyrinth.goal_island_tile()
	return [tile, tile + Vector2i.RIGHT]


## Adds the 3 x 3 Kenney cells of the island tile `tile`. `is_island` tells if a tile is island.
func _add_tile(is_island: Callable, tile: Vector2i) -> void:
	for cy in CELLS_PER_TILE:
		for cx in CELLS_PER_TILE:
			var side := Vector2i(cx - 1, cy - 1)
			cells[tile * CELLS_PER_TILE + Vector2i(cx, cy)] = _cell_tile(is_island, tile, side)


## One Kenney cell in VARIANT_CHANCE gets a variant of its tile, in the order of `cells`.
func _pick_variants(prng: Prng) -> void:
	for cell: Vector2i in cells:
		var r := prng.next()
		var variants: Array = VARIANTS.get(cells[cell], [])
		if r % VARIANT_CHANCE == 0 and not variants.is_empty():
			cells[cell] = variants[(r / VARIANT_CHANCE) % variants.size()]


## The Kenney tile of the cell of `tile` on `side`: (-1, -1) is the top-left cell, (0, 0) the
## centre cell. The cell faces the neighbours of `tile` on that side.
static func _cell_tile(is_island: Callable, tile: Vector2i, side: Vector2i) -> int:
	var island_beside: bool = side.x == 0 or is_island.call(tile + Vector2i(side.x, 0))
	var island_above_or_below: bool = side.y == 0 or is_island.call(tile + Vector2i(0, side.y))
	if not island_beside and not island_above_or_below:
		return OUTER_CORNERS[side]
	if not island_above_or_below:
		return COAST[Vector2i(0, side.y)]
	if not island_beside:
		return COAST[Vector2i(side.x, 0)]
	if side.x != 0 and side.y != 0 and not is_island.call(tile + side):
		return INNER_CORNERS[side]
	return GRASS


## A tile outside the Labyrinth is sea, except the outer Goal island tile.
static func _is_island(labyrinth: Labyrinth, tile: Vector2i) -> bool:
	if tile == goal_island_tiles(labyrinth)[1]:
		return true
	var count := labyrinth.tile_count()
	if tile.x < 0 or tile.y < 0 or tile.x >= count.x or tile.y >= count.y:
		return false
	return not labyrinth.is_water_tile(tile)
