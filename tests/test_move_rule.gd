## Spec 14.1 test 4: the move rule of spec 5.2 and the bump of spec 5.3.
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")

# Two corridors joined on the right side: bends at (2, 0) and (2, 1), dead ends at (0, 0) and (0, 1).
const U_TURN := [
	"#######",
	"#.....#",
	"#####.#",
	"#.....#",
	"#######",
]
# (1, 0) and (1, 1) are junctions.
const JUNCTION := [
	"#######",
	"#.....#",
	"###.###",
	"#.....#",
	"#######",
]
# One straight corridor of 4 squares.
const CORRIDOR := [
	"#########",
	"#.......#",
	"#########",
]
# An S-shaped channel. The Goal (2, 1) is its last square.
const S_CHANNEL := [
	"#######",
	"#.....#",
	"#.#####",
	"#.....#",
	"#######",
]


func test_stops_at_a_bend(t) -> bool:
	var move := MoveRule.plan(Fixtures.labyrinth_from_tiles(U_TURN), Vector2i(0, 0), Vector2i.RIGHT)
	t.assert_eq(move.bump, false, "no bump")
	t.assert_eq(move.target, Vector2i(2, 0), "stops at the bend")
	t.assert_eq(move.tiles, 4, "crosses 4 tiles")
	return true


func test_stops_at_a_dead_end(t) -> bool:
	var move := MoveRule.plan(Fixtures.labyrinth_from_tiles(U_TURN), Vector2i(2, 1), Vector2i.LEFT)
	t.assert_eq(move.target, Vector2i(0, 1), "stops at the dead end")
	t.assert_eq(move.tiles, 4, "crosses 4 tiles")
	return true


func test_stops_at_a_junction(t) -> bool:
	var labyrinth = Fixtures.labyrinth_from_tiles(JUNCTION)
	var move := MoveRule.plan(labyrinth, Vector2i(0, 0), Vector2i.RIGHT)
	t.assert_eq(move.target, Vector2i(1, 0), "stops at the junction")
	t.assert_eq(move.tiles, 2, "crosses 2 tiles")
	move = MoveRule.plan(labyrinth, Vector2i(1, 0), Vector2i.RIGHT)
	t.assert_eq(move.target, Vector2i(2, 0), "leaves the junction to the dead end")
	return true


func test_stops_at_an_item_not_collected(t) -> bool:
	var labyrinth = Fixtures.labyrinth_from_tiles(CORRIDOR)
	var move := MoveRule.plan(labyrinth, Vector2i(0, 0), Vector2i.RIGHT, {Vector2i(2, 0): false})
	t.assert_eq(move.target, Vector2i(2, 0), "stops on the Item")
	t.assert_eq(move.tiles, 4, "crosses 4 tiles")
	return true


func test_passes_a_collected_item(t) -> bool:
	var labyrinth = Fixtures.labyrinth_from_tiles(CORRIDOR)
	var move := MoveRule.plan(labyrinth, Vector2i(0, 0), Vector2i.RIGHT, {Vector2i(2, 0): true})
	t.assert_eq(move.target, Vector2i(3, 0), "passes the collected Item to the dead end")
	t.assert_eq(move.tiles, 6, "crosses 6 tiles")
	return true


func test_stops_at_the_goal(t) -> bool:
	var labyrinth = Fixtures.labyrinth_from_tiles(S_CHANNEL)
	var move := MoveRule.plan(labyrinth, Vector2i(0, 1), Vector2i.RIGHT)
	t.assert_eq(move.target, labyrinth.goal_square(), "stops on the Goal")
	t.assert_eq(move.tiles, 4, "crosses 4 tiles")
	return true


func test_move_toward_a_wall_is_a_bump(t) -> bool:
	var move := MoveRule.plan(Fixtures.labyrinth_from_tiles(U_TURN), Vector2i(1, 0), Vector2i.DOWN)
	t.assert_eq(move.bump, true, "bump")
	t.assert_eq(move.target, Vector2i(1, 0), "stays on its square")
	t.assert_eq(move.tiles, 0, "crosses no tile")
	t.assert_true(is_equal_approx(move.duration, 0.07 + 0.11), "bump takes 70 ms, then 110 ms")
	return true


func test_duration_is_180_ms_per_tile(t) -> bool:
	var labyrinth = Fixtures.labyrinth_from_tiles(CORRIDOR)
	var long_move := MoveRule.plan(labyrinth, Vector2i(0, 0), Vector2i.RIGHT)
	t.assert_true(is_equal_approx(long_move.duration, 6 * 0.18), "6 tiles take 1.08 s")
	var short_move := MoveRule.plan(Fixtures.labyrinth_from_tiles(JUNCTION), Vector2i(0, 0), Vector2i.RIGHT)
	t.assert_true(is_equal_approx(short_move.duration, 2 * 0.18), "2 tiles take 0.36 s")
	return true


func test_boat_faces_the_pressed_direction(t) -> bool:
	# The bow of boat_white_sail.png points down at rotation 0 (spec 5.2).
	var labyrinth = Fixtures.labyrinth_from_tiles(U_TURN)
	t.assert_true(is_equal_approx(MoveRule.plan(labyrinth, Vector2i(2, 0), Vector2i.DOWN).rotation, 0.0), "down")
	t.assert_true(is_equal_approx(MoveRule.plan(labyrinth, Vector2i(0, 0), Vector2i.RIGHT).rotation, -PI / 2), "right")
	t.assert_true(is_equal_approx(MoveRule.plan(labyrinth, Vector2i(2, 1), Vector2i.UP).rotation, -PI), "up")
	t.assert_true(is_equal_approx(MoveRule.plan(labyrinth, Vector2i(2, 0), Vector2i.LEFT).rotation, PI / 2), "left")
	# The boat also turns before a bump.
	t.assert_true(is_equal_approx(MoveRule.plan(labyrinth, Vector2i(0, 0), Vector2i.UP).rotation, -PI), "up, bump")
	return true
