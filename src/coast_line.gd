## The coast lines of a Labyrinth for the foam (spec 8.2, gap-audit default 40, game-flow spec part
## 5, fix 2): the foam follows the whole coast of the water inside the Labyrinth, and the outer
## coast of the border islands with the Goal island.
class_name CoastLine
extends RefCounted


## The coasts of the water inside the Labyrinth, as closed loops of tile corners (in tiles, the
## tile (0, 0) from (0, 0) to (1, 1)). Each loop goes clockwise on the screen with the water on its
## right, has no point twice, and has only its corners.
static func water_outlines(labyrinth: Labyrinth) -> Array[PackedVector2Array]:
	# One directed side for each side of a water tile that faces an island: the tile corners in
	# clockwise order on the screen.
	var next_corner := {}
	var count := labyrinth.tile_count()
	for y in count.y:
		for x in count.x:
			var tile := Vector2i(x, y)
			if not labyrinth.is_water_tile(tile):
				continue
			var corners: Array[Vector2i] = [tile, tile + Vector2i(1, 0), tile + Vector2i(1, 1), tile + Vector2i(0, 1)]
			var sides: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
			for k in 4:
				if not _is_water(labyrinth, tile + sides[k]):
					next_corner[corners[k]] = corners[(k + 1) % 4]
	# In a Labyrinth, two water tiles that touch only at a corner also touch a third water tile,
	# so each corner starts one side and the sides join into loops.
	var outlines: Array[PackedVector2Array] = []
	while not next_corner.is_empty():
		var start: Vector2i = next_corner.keys()[0]
		var loop := PackedVector2Array()
		var corner := start
		while true:
			loop.append(Vector2(corner))
			var next: Vector2i = next_corner[corner]
			next_corner.erase(corner)
			corner = next
			if corner == start:
				break
		outlines.append(_corners_only(loop))
	return outlines


## The outer coast of the border islands, as a closed loop of tile corners in tiles, clockwise on
## the screen: the Labyrinth rectangle with the outer tile of the Goal island (IslandLook).
static func outer_outline(labyrinth: Labyrinth) -> PackedVector2Array:
	var size := Vector2(labyrinth.tile_count())
	var goal := Vector2(IslandLook.goal_island_tiles(labyrinth)[1])
	return PackedVector2Array([
		Vector2.ZERO, Vector2(size.x, 0), goal, goal + Vector2(1, 0),
		goal + Vector2(1, 1), goal + Vector2(0, 1), size, Vector2(0, size.y),
	])


## The foam lines in px from the tile (0, 0) corner, `distance_px` from the coast on the water.
## `outlines` are the water_outlines() and `outer` the outer_outline() of a Labyrinth. The island
## corners that face the water are round with a radius of `corner_px`, as the Kenney corner tiles;
## the foam goes round them at its distance.
static func foam_loops(outlines: Array[PackedVector2Array], outer: PackedVector2Array, tile_px: float, corner_px: float, distance_px: float) -> Array[PackedVector2Array]:
	var loops: Array[PackedVector2Array] = []
	var to_px := Transform2D.IDENTITY.scaled(Vector2.ONE * tile_px)
	# Inside: grow the water over the round island corners, then shrink it back past the coast.
	for outline in outlines:
		for grown in Geometry2D.offset_polygon(to_px * outline, corner_px, Geometry2D.JOIN_ROUND):
			loops.append_array(Geometry2D.offset_polygon(grown, -(corner_px + distance_px), Geometry2D.JOIN_ROUND))
	# Outside: round the corners of the islands, then grow them past the coast.
	for shrunk in Geometry2D.offset_polygon(to_px * outer, -corner_px, Geometry2D.JOIN_ROUND):
		loops.append_array(Geometry2D.offset_polygon(shrunk, corner_px + distance_px, Geometry2D.JOIN_ROUND))
	return loops


## Tiles outside the Labyrinth are sea, but the border islands keep it away from the inner water.
static func _is_water(labyrinth: Labyrinth, tile: Vector2i) -> bool:
	var count := labyrinth.tile_count()
	if tile.x < 0 or tile.y < 0 or tile.x >= count.x or tile.y >= count.y:
		return false
	return labyrinth.is_water_tile(tile)


## The loop without the points in the middle of a straight side.
static func _corners_only(loop: PackedVector2Array) -> PackedVector2Array:
	var corners := PackedVector2Array()
	for i in loop.size():
		var before := loop[i - 1]
		var after := loop[(i + 1) % loop.size()]
		if not is_zero_approx((loop[i] - before).cross(after - loop[i])):
			corners.append(loop[i])
	return corners
