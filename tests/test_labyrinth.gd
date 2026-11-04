## The Labyrinth data: squares and tiles (spec 4.5), and the reachability check (spec 4.2).
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")


func test_square_is_water_and_closed_wall_is_island(t) -> bool:
	var labyrinth := Labyrinth.new(2, 1)
	t.assert_eq(Fixtures.tile_picture(labyrinth), ["#####", "#.#.#", "#####"], "2 x 1, wall closed")
	return true


func test_open_wall_is_water(t) -> bool:
	var labyrinth := Labyrinth.new(2, 1)
	labyrinth.open_wall(Vector2i(1, 0), Vector2i.LEFT)
	t.assert_eq(Fixtures.tile_picture(labyrinth), ["#####", "#...#", "#####"], "2 x 1, wall open")
	t.assert_true(not labyrinth.has_wall(Vector2i(0, 0), Vector2i.RIGHT), "the neighbour side opens too")
	return true


func test_tiles_of_labyrinth_1(t) -> bool:
	var expected := [
		"#########",
		"#.#.....#",
		"#.#.###.#",
		"#.#.#...#",
		"#.###.###",
		"#.......#",
		"#########",
	]
	t.assert_eq(Fixtures.tile_picture(LabyrinthPlan.build(1)), expected, "tiles of Labyrinth 1")
	return true


func test_tile_grid_is_2w_plus_1_by_2h_plus_1(t) -> bool:
	t.assert_eq(Labyrinth.new(4, 3).tile_count(), Vector2i(9, 7), "tiles of 4 x 3")
	t.assert_eq(Labyrinth.new(10, 7).tile_count(), Vector2i(21, 15), "tiles of 10 x 7")
	t.assert_eq(Labyrinth.square_to_tile(Vector2i(0, 0)), Vector2i(1, 1), "tile of square (0, 0)")
	t.assert_eq(Labyrinth.square_to_tile(Vector2i(3, 2)), Vector2i(7, 5), "tile of square (3, 2)")
	return true


func test_goal_island_is_the_border_tile_right_of_the_goal(t) -> bool:
	t.assert_eq(Labyrinth.new(4, 3).goal_island_tile(), Vector2i(8, 5), "Goal island of 4 x 3")
	t.assert_eq(Labyrinth.new(10, 7).goal_island_tile(), Vector2i(20, 13), "Goal island of 10 x 7")
	return true


func test_open_side_count(t) -> bool:
	var labyrinth = Fixtures.labyrinth_from_tiles([
		"#######",
		"#.....#",
		"###.###",
		"#.....#",
		"#######",
	])
	t.assert_eq(labyrinth.open_side_count(Vector2i(0, 0)), 1, "dead end")
	t.assert_eq(labyrinth.open_side_count(Vector2i(1, 0)), 3, "junction")
	t.assert_eq(labyrinth.open_side_count(Vector2i(1, 1)), 3, "junction below")
	return true


func test_distances_from_start(t) -> bool:
	var labyrinth = Fixtures.labyrinth_from_tiles([
		"#######",
		"#.....#",
		"#####.#",
		"#.....#",
		"#######",
	])
	t.assert_eq(Array(labyrinth.distances_from(Vector2i(0, 0))), [0, 1, 2, 5, 4, 3], "distances, row by row")
	t.assert_true(labyrinth.all_squares_reachable(), "all squares reachable")
	return true


func test_cut_off_square_is_not_reachable(t) -> bool:
	var labyrinth = Fixtures.labyrinth_from_tiles([
		"#######",
		"#...#.#",
		"#######",
	])
	t.assert_eq(Array(labyrinth.distances_from(Vector2i(0, 0))), [0, 1, -1], "distances, -1 is not reachable")
	t.assert_true(not labyrinth.all_squares_reachable(), "not all squares reachable")
	return true
