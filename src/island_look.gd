## The Kenney island look of a Labyrinth (spec 7.1): the Kenney tile of each Kenney cell, and the
## rocks and bushes on the wall islands. The outside of the Labyrinth is sea. The Goal island gets
## no rock and no bush: the view puts the palm and the chest on it (spec 6.2).
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
	var count := labyrinth.tile_count()
	for y in count.y:
		for x in count.x:
			var tile := Vector2i(x, y)
			if not _is_island(labyrinth, tile):
				continue
			for cy in CELLS_PER_TILE:
				for cx in CELLS_PER_TILE:
					var side := Vector2i(cx - 1, cy - 1)
					look.cells[tile * CELLS_PER_TILE + Vector2i(cx, cy)] = _cell_tile(labyrinth, tile, side)
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
	for cell: Vector2i in look.cells:
		var r := prng.next()
		var variants: Array = VARIANTS.get(look.cells[cell], [])
		if r % VARIANT_CHANCE == 0 and not variants.is_empty():
			look.cells[cell] = variants[(r / VARIANT_CHANCE) % variants.size()]
	return look


## The Kenney tile of the cell of `tile` on `side`: (-1, -1) is the top-left cell, (0, 0) the
## centre cell. The cell faces the neighbours of `tile` on that side.
static func _cell_tile(labyrinth: Labyrinth, tile: Vector2i, side: Vector2i) -> int:
	var island_beside := side.x == 0 or _is_island(labyrinth, tile + Vector2i(side.x, 0))
	var island_above_or_below := side.y == 0 or _is_island(labyrinth, tile + Vector2i(0, side.y))
	if not island_beside and not island_above_or_below:
		return OUTER_CORNERS[side]
	if not island_above_or_below:
		return COAST[Vector2i(0, side.y)]
	if not island_beside:
		return COAST[Vector2i(side.x, 0)]
	if side.x != 0 and side.y != 0 and not _is_island(labyrinth, tile + side):
		return INNER_CORNERS[side]
	return GRASS


## A tile outside the Labyrinth is sea.
static func _is_island(labyrinth: Labyrinth, tile: Vector2i) -> bool:
	var count := labyrinth.tile_count()
	if tile.x < 0 or tile.y < 0 or tile.x >= count.x or tile.y >= count.y:
		return false
	return not labyrinth.is_water_tile(tile)
