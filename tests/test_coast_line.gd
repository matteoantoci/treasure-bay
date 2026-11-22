## The coast lines of the foam (spec 8.2, gap-audit default 40, game-flow spec part 5, fix 2): the
## foam follows the whole coast of the water inside the Labyrinth and the outer coast of the border
## islands with the Goal island.
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")

## 2 x 1 squares, one open wall: the water is one row of 3 tiles.
const ROW := [
	"#####",
	"#...#",
	"#####",
]
## 2 x 2 squares in an S: the water has a bend with an inner corner.
const S_SHAPE := [
	"#####",
	"#...#",
	"###.#",
	"#...#",
	"#####",
]


## The loop turned so that it starts at its point with the lowest y, then the lowest x.
func _from_top_left(loop: PackedVector2Array) -> PackedVector2Array:
	var first := 0
	for i in loop.size():
		if loop[i].y < loop[first].y or (loop[i].y == loop[first].y and loop[i].x < loop[first].x):
			first = i
	return loop.slice(first) + loop.slice(0, first)


func test_the_water_outline_of_a_straight_channel(t) -> bool:
	var outlines := CoastLine.water_outlines(Fixtures.labyrinth_from_tiles(ROW))
	t.assert_eq(outlines.size(), 1, "one coast around the water")
	t.assert_eq(_from_top_left(outlines[0]), PackedVector2Array([Vector2(1, 1), Vector2(4, 1), Vector2(4, 2), Vector2(1, 2)]), "the corners of the channel, clockwise on the screen")
	return true


func test_the_water_outline_follows_a_bend(t) -> bool:
	var outlines := CoastLine.water_outlines(Fixtures.labyrinth_from_tiles(S_SHAPE))
	t.assert_eq(outlines.size(), 1, "one coast around the water")
	var expected := PackedVector2Array([
		Vector2(1, 1), Vector2(4, 1), Vector2(4, 4), Vector2(1, 4),
		Vector2(1, 3), Vector2(3, 3), Vector2(3, 2), Vector2(1, 2),
	])
	t.assert_eq(_from_top_left(outlines[0]), expected, "the corners of the S, clockwise on the screen")
	return true


func test_the_water_of_each_labyrinth_has_one_coast(t) -> bool:
	# A perfect Labyrinth has no loops, so its water is one piece with no island inside it. The
	# area inside the outline is the number of water tiles.
	for number in [1, 7, 20]:
		var labyrinth := LabyrinthPlan.build(number)
		var outlines := CoastLine.water_outlines(labyrinth)
		t.assert_eq(outlines.size(), 1, "Labyrinth %d: one coast" % number)
		var water := 0
		for y in labyrinth.tile_count().y:
			for x in labyrinth.tile_count().x:
				if labyrinth.is_water_tile(Vector2i(x, y)):
					water += 1
		var area := 0.0
		var loop: PackedVector2Array = outlines[0]
		for i in loop.size():
			area += loop[i].cross(loop[(i + 1) % loop.size()]) / 2.0
		t.assert_eq(roundi(absf(area)), water, "Labyrinth %d: the outline holds the water tiles" % number)
	return true


func test_the_outer_coast_goes_round_the_goal_island(t) -> bool:
	# The Goal island tile is (4, 1). The tile (5, 1) right of it is island too (fix 4).
	var outline := CoastLine.outer_outline(Fixtures.labyrinth_from_tiles(ROW))
	var expected := PackedVector2Array([
		Vector2(0, 0), Vector2(5, 0), Vector2(5, 1), Vector2(6, 1),
		Vector2(6, 2), Vector2(5, 2), Vector2(5, 3), Vector2(0, 3),
	])
	t.assert_eq(_from_top_left(outline), expected, "the corners of the outer coast, clockwise on the screen")
	return true


func test_the_foam_lies_on_the_water_at_its_distance_from_the_coast(t) -> bool:
	# Tiles of 100 px, foam 4 px from the coast. The inner foam stays 4 px inside the water. The
	# outer foam goes 4 px around the Labyrinth and its Goal island.
	var labyrinth := Fixtures.labyrinth_from_tiles(ROW)
	var loops := CoastLine.foam_loops(CoastLine.water_outlines(labyrinth), CoastLine.outer_outline(labyrinth), 100.0, 30.0, 4.0)
	t.assert_eq(loops.size(), 2, "the inner and the outer foam")
	var bounds: Array[Rect2] = []
	for loop: PackedVector2Array in loops:
		var rect := Rect2(loop[0], Vector2.ZERO)
		for point in loop:
			rect = rect.expand(point)
		bounds.append(rect)
	bounds.sort_custom(func(a: Rect2, b: Rect2) -> bool: return a.get_area() < b.get_area())
	t.assert_true(bounds[0].is_equal_approx(Rect2(104, 104, 292, 92)), "inner foam: %s" % bounds[0])
	t.assert_true(bounds[1].is_equal_approx(Rect2(-4, -4, 608, 308)), "outer foam: %s" % bounds[1])
	return true
