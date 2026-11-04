## Spec 14.1 test 2: the generator of spec 4.2 with the sizes and seeds of spec 4.3.
extends RefCounted

# Spec 4.3: Labyrinth n -> W x H squares.
const SIZES := {
	1: Vector2i(4, 3), 2: Vector2i(4, 3),
	3: Vector2i(5, 3), 4: Vector2i(5, 3),
	5: Vector2i(5, 4), 6: Vector2i(5, 4),
	7: Vector2i(6, 4), 8: Vector2i(6, 4),
	9: Vector2i(7, 4), 10: Vector2i(7, 4),
	11: Vector2i(7, 5), 12: Vector2i(7, 5),
	13: Vector2i(8, 5), 14: Vector2i(8, 5),
	15: Vector2i(8, 6), 16: Vector2i(8, 6),
	17: Vector2i(9, 6), 18: Vector2i(9, 6),
	19: Vector2i(9, 7), 20: Vector2i(9, 7),
}
const RANDOM_SIZE := Vector2i(10, 7)
const RANDOM_SEED_COUNT := 200

# Labyrinth 1 (seed 1, 4 x 3), wall bits of each square row by row: north 1, east 2, south 4,
# west 8. From an independent Python run of spec 4.1 and 4.2. As tiles (spec 4.5):
#   #########
#   #.#.....#
#   #.#.###.#
#   #.#...#.#
#   #.#####.#
#   #.......#
#   #########
const LABYRINTH_1_WALLS := [11, 9, 5, 3, 10, 12, 7, 10, 12, 5, 5, 6]


func test_sizes_match_the_table(t) -> bool:
	for n in SIZES:
		t.assert_eq(LabyrinthPlan.size_for(n), SIZES[n], "size of Labyrinth %d" % n)
	for n in [21, 22, 45, 1000]:
		t.assert_eq(LabyrinthPlan.size_for(n), RANDOM_SIZE, "size of Labyrinth %d" % n)
	return true


func test_labyrinth_1_wall_data_is_pinned(t) -> bool:
	t.assert_eq(_wall_list(LabyrinthPlan.build(1)), LABYRINTH_1_WALLS, "wall bits of Labyrinth 1")
	return true


func test_same_seed_gives_same_labyrinth(t) -> bool:
	for n in [1, 7, 20]:
		t.assert_eq(_wall_list(LabyrinthPlan.build(n)), _wall_list(LabyrinthPlan.build(n)), "Labyrinth %d two times" % n)
	t.assert_eq(_wall_list(LabyrinthPlan.build(21, 4242)), _wall_list(LabyrinthPlan.build(37, 4242)), "random seed 4242 two times")
	return true


func test_seed_sets_the_labyrinth(t) -> bool:
	var differ := _wall_list(LabyrinthPlan.build(21, 1)) != _wall_list(LabyrinthPlan.build(21, 2))
	t.assert_true(differ, "random seeds 1 and 2 give different Labyrinths")
	return true


func test_fixed_labyrinths_are_perfect(t) -> bool:
	for n in SIZES:
		_check_perfect(t, LabyrinthPlan.build(n), SIZES[n], "Labyrinth %d" % n)
	return true


func test_random_labyrinths_are_perfect(t) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261104
	for i in RANDOM_SEED_COUNT:
		var seed_value := rng.randi()
		_check_perfect(t, LabyrinthPlan.build(21, seed_value), RANDOM_SIZE, "random seed %d" % seed_value)
	return true


func test_start_is_top_left_and_goal_is_bottom_right(t) -> bool:
	var labyrinth := LabyrinthPlan.build(19)
	t.assert_eq(labyrinth.start_square(), Vector2i(0, 0), "start square")
	t.assert_eq(labyrinth.goal_square(), Vector2i(8, 6), "goal square of a 9 x 7 Labyrinth")
	return true


## Size, W x H - 1 open walls, every square reachable, and wall bits that agree.
func _check_perfect(t, labyrinth: Labyrinth, size: Vector2i, label: String) -> void:
	t.assert_eq(Vector2i(labyrinth.width, labyrinth.height), size, label + ": size")
	var open := 0
	var agree := true
	for y in labyrinth.height:
		for x in labyrinth.width:
			var square := Vector2i(x, y)
			for direction in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
				var neighbour: Vector2i = square + direction
				var inside := neighbour.x >= 0 and neighbour.y >= 0 and neighbour.x < labyrinth.width and neighbour.y < labyrinth.height
				if not inside:
					agree = agree and labyrinth.has_wall(square, direction)
					continue
				agree = agree and labyrinth.has_wall(square, direction) == labyrinth.has_wall(neighbour, -direction)
				if direction in [Vector2i.RIGHT, Vector2i.DOWN] and not labyrinth.has_wall(square, direction):
					open += 1
	t.assert_eq(open, size.x * size.y - 1, label + ": open walls")
	t.assert_true(agree, label + ": wall bits of neighbours agree, border is closed")
	t.assert_true(labyrinth.all_squares_reachable(), label + ": every square reachable")


func _wall_list(labyrinth: Labyrinth) -> Array:
	var bits := []
	for y in labyrinth.height:
		for x in labyrinth.width:
			bits.append(labyrinth.wall_bits(Vector2i(x, y)))
	return bits
