## The Kenney island look of spec 7.1: the coast tile of each Kenney cell, the rocks and bushes
## on the wall islands, and the Goal island of 2 tiles (game-flow spec part 5, fix 4). Each
## Labyrinth tile is 3 x 3 Kenney cells (Open gap 1).
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")

## The shape of each Kenney tile, read from the tile pictures in assets/kenney/tiles/:
## A, B, C, D: outer corners with water at north-west, north-east, south-west, south-east.
## n, e, s, w: straight coast with water at north, east, south, west.
## a, b, c, d: inner corners with water only at the north-west, north-east, south-west, south-east
## diagonal. g: grass.
const SHAPES := {
	6: "A", 9: "B", 54: "C", 57: "D",
	7: "n", 8: "n", 25: "e", 41: "e", 55: "s", 56: "s", 22: "w", 38: "w",
	53: "a", 52: "b", 37: "c", 36: "d",
	23: "g", 24: "g", 39: "g", 40: "g",
}
const ROCKS := [49, 50, 51, 65, 66, 67]
const BUSH := 70


func _shape_picture(look: IslandLook, cell_count: Vector2i) -> Array:
	var rows := []
	for y in cell_count.y:
		var row := ""
		for x in cell_count.x:
			var cell := Vector2i(x, y)
			row += SHAPES.get(look.cells[cell], "?") if look.cells.has(cell) else "."
		rows.append(row)
	return rows


func test_two_squares_with_a_wall_between_them(t) -> bool:
	var labyrinth := Fixtures.labyrinth_from_tiles([
		"#####",
		"#.#.#",
		"#####",
	])
	var look := IslandLook.build(labyrinth)
	# The Goal island tile (4, 1) and the tile (5, 1) right of it, outside the Labyrinth, make the
	# Goal island: 2 tiles wide, with a sand coast all around.
	t.assert_eq(_shape_picture(look, Vector2i(18, 9)), [
		"AnnnnnnnnnnnnnB...",
		"wggggggggggggge...",
		"wgdssscgdssscge...",
		"wge...wge...wgbnnB",
		"wge...wge...wgggge",
		"wge...wge...wgdssD",
		"wgbnnnagbnnnage...",
		"wggggggggggggge...",
		"CsssssssssssssD...",
	], "Kenney cells of a 2 x 1 Labyrinth with its Goal island")
	return true


func test_the_goal_island_is_2_tiles_wide_with_no_rock_and_no_bush(t) -> bool:
	for number in range(1, 21):
		var labyrinth := LabyrinthPlan.build(number)
		var look := IslandLook.build(labyrinth)
		var tiles := IslandLook.goal_island_tiles(labyrinth)
		var label := "Labyrinth %d: " % number
		t.assert_eq(tiles.size(), 2, label + "2 tiles")
		t.assert_eq(tiles[0], labyrinth.goal_island_tile(), label + "the Goal island tile")
		t.assert_eq(tiles[1], labyrinth.goal_island_tile() + Vector2i.RIGHT, label + "the tile right of the Goal island tile")
		t.assert_eq(tiles[1].x, labyrinth.tile_count().x, label + "the outer tile is outside the Labyrinth")
		var outer := tiles[1] * IslandLook.CELLS_PER_TILE
		var cells := []
		for cy in IslandLook.CELLS_PER_TILE:
			var row := ""
			for cx in IslandLook.CELLS_PER_TILE:
				row += SHAPES.get(look.cells.get(outer + Vector2i(cx, cy), -1), ".")
			cells.append(row)
		t.assert_eq(cells, ["nnB", "gge", "ssD"], label + "the outer tile has a sand coast at the top, the right and the bottom")
		for tile in tiles:
			t.assert_true(not look.decorations.has(tile), label + "no rock and no bush on the Goal island tile %s" % tile)
	return true


func test_wall_island_decorations_of_labyrinth_1(t) -> bool:
	# From tests/spec_port.py, an independent Python port of the rule: a PRNG with seed 1 + 1 gives
	# one output r for each island tile in row order, except the Goal island. If r % 6 == 0, the
	# tile gets a decoration: pick = (r / 6) % 12 is the bush for 0 to 5, else rock ROCKS[pick - 6].
	var look := IslandLook.build(LabyrinthPlan.build(1))
	t.assert_eq(look.decorations, {
		Vector2i(0, 0): BUSH,
		Vector2i(1, 0): 67,
		Vector2i(2, 2): 49,
		Vector2i(4, 3): 51,
		Vector2i(8, 3): BUSH,
		Vector2i(4, 4): BUSH,
	}, "Labyrinth 1 decorations")
	return true


func test_wall_islands_get_rocks_and_bushes_and_no_palm(t) -> bool:
	var kinds := {}
	for number in range(1, 21):
		var labyrinth := LabyrinthPlan.build(number)
		var look := IslandLook.build(labyrinth)
		for tile: Vector2i in look.decorations:
			var kind: int = look.decorations[tile]
			kinds[kind] = true
			t.assert_true(not labyrinth.is_water_tile(tile), "Labyrinth %d: decoration %s on an island" % [number, tile])
			t.assert_true(tile != labyrinth.goal_island_tile(), "Labyrinth %d: no decoration on the Goal island" % number)
			t.assert_true(kind == BUSH or ROCKS.has(kind), "Labyrinth %d: %d is a rock or the bush" % [number, kind])
	t.assert_true(kinds.has(BUSH), "some wall islands have the bush")
	t.assert_true(ROCKS.any(func(rock: int) -> bool: return kinds.has(rock)), "some wall islands have a rock")
	t.assert_true(not kinds.has(IslandLook.PALM) and not kinds.has(72), "no palm and no small plant on a wall island")
	return true


func test_the_look_keeps_the_labyrinth_data(t) -> bool:
	var labyrinth := LabyrinthPlan.build(7)
	var before := Fixtures.tile_picture(labyrinth)
	var items := labyrinth.items.map(func(item: Item) -> String: return item.id + item.kind)
	IslandLook.build(labyrinth)
	t.assert_eq(Fixtures.tile_picture(labyrinth), before, "walls")
	t.assert_eq(labyrinth.items.map(func(item: Item) -> String: return item.id + item.kind), items, "Items")
	t.assert_eq(Fixtures.tile_picture(LabyrinthPlan.build(7)), before, "a new build gives the same Labyrinth")
	return true


func test_every_cell_has_a_kenney_tile_of_its_shape(t) -> bool:
	# The tile variants (for example 07 and 08) keep the shape of each cell.
	for number in [1, 9, 20]:
		var labyrinth := LabyrinthPlan.build(number)
		var look := IslandLook.build(labyrinth)
		var count := (labyrinth.tile_count() + Vector2i(1, 0)) * IslandLook.CELLS_PER_TILE
		var picture := _shape_picture(look, count)
		t.assert_true(not "".join(picture).contains("?"), "Labyrinth %d: every cell has a known Kenney tile" % number)
		# The outer tile of the Goal island is island too.
		var island_cells := IslandLook.CELLS_PER_TILE * IslandLook.CELLS_PER_TILE
		for y in labyrinth.tile_count().y:
			for x in labyrinth.tile_count().x:
				if not labyrinth.is_water_tile(Vector2i(x, y)):
					island_cells += IslandLook.CELLS_PER_TILE * IslandLook.CELLS_PER_TILE
		t.assert_eq(look.cells.size(), island_cells, "Labyrinth %d: one Kenney tile for each island cell" % number)
		var tiles: Array = look.cells.values()
		t.assert_true(tiles.has(24) or tiles.has(39) or tiles.has(40), "Labyrinth %d: the grass keeps its dots" % number)
		t.assert_true(tiles.has(8) or tiles.has(41) or tiles.has(56) or tiles.has(38), "Labyrinth %d: the sand keeps its bumps" % number)
	return true
