## The Labyrinth measure of play-improvements spec Part 3, and its move rule cross-check (Testing
## Decisions test 4).
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")

const RANDOM_SEED_COUNT := 200
# An L-shaped main path (0, 0) to (2, 1). The squares (1, 0) and (2, 0) are a side branch.
const BEND := [
	"#######",
	"#.....#",
	"#.#####",
	"#.....#",
	"#######",
]
# The main path (0, 0), (1, 0), (1, 1), (2, 1) goes through 2 junctions.
const TWO_JUNCTIONS := [
	"#######",
	"#.....#",
	"###.###",
	"#.....#",
	"#######",
]
# Main paths of Labyrinths 1 and 2, from tests/spec_port.py.
const PINNED_PATHS := {
	1: ["0,0", "0,1", "0,2", "1,2", "2,2", "3,2"],
	2: ["0,0", "1,0", "2,0", "2,1", "1,1", "1,2", "2,2", "3,2"],
}
# Measure values of Labyrinths 1 to 20 with their Items, from tests/spec_port.py, an independent
# Python port of the spec text: [length, presses, decisions, turns, largest side branch, Items on
# the path].
const PINNED_MEASURES := {
	1: [5, 3, 1, 1, 6, 1],
	2: [7, 5, 2, 4, 2, 1],
	3: [10, 5, 1, 4, 4, 1],
	4: [10, 5, 1, 4, 4, 1],
	5: [7, 5, 2, 2, 6, 1],
	6: [7, 6, 2, 4, 7, 1],
	7: [8, 7, 2, 4, 8, 2],
	8: [12, 8, 2, 6, 8, 1],
	9: [13, 9, 2, 7, 12, 1],
	10: [13, 10, 2, 8, 11, 1],
	11: [20, 11, 3, 10, 8, 1],
	12: [18, 12, 4, 10, 8, 1],
	13: [19, 13, 3, 11, 17, 2],
	14: [21, 14, 4, 12, 11, 2],
	15: [24, 15, 3, 11, 18, 2],
	16: [22, 16, 4, 13, 13, 2],
	17: [29, 17, 4, 15, 14, 2],
	18: [31, 18, 5, 15, 12, 2],
	19: [32, 19, 5, 16, 24, 2],
	20: [32, 20, 4, 16, 25, 3],
}


func test_measure_of_labyrinths_1_to_20_is_pinned(t) -> bool:
	for n in PINNED_MEASURES:
		t.assert_eq(_values(LabyrinthMeasure.measure(LabyrinthPlan.build(n))), PINNED_MEASURES[n], "measure of Labyrinth %d" % n)
	return true


func test_main_path_goes_from_the_start_to_the_goal(t) -> bool:
	for n in PINNED_PATHS:
		var path := LabyrinthMeasure.main_path(LabyrinthPlan.build(n))
		t.assert_eq(_ids(path), PINNED_PATHS[n], "main path of Labyrinth %d" % n)
		t.assert_eq(LabyrinthMeasure.measure(LabyrinthPlan.build(n))["path"], path, "measured path of Labyrinth %d" % n)
	return true


func test_labyrinth_without_items(t) -> bool:
	var measure := LabyrinthMeasure.measure(Fixtures.labyrinth_from_tiles(BEND))
	t.assert_eq(measure["path"], [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)] as Array[Vector2i], "path")
	t.assert_eq(_values(measure), [3, 2, 0, 1, 2, 0], "length, presses, decisions, turns, side branch, Items on the path")
	return true


func test_item_on_the_main_path_is_a_stop(t) -> bool:
	var labyrinth := Fixtures.labyrinth_from_tiles(BEND)
	labyrinth.items = [Item.new(Vector2i(1, 1), "pearl"), Item.new(Vector2i(2, 0), "coral")] as Array[Item]
	var measure := LabyrinthMeasure.measure(labyrinth)
	t.assert_eq(measure["presses"], 3, "presses with an Item on (1, 1)")
	t.assert_eq(measure["items_on_path"], 1, "Items on the path")
	return true


func test_junctions_on_the_main_path_are_decisions(t) -> bool:
	var measure := LabyrinthMeasure.measure(Fixtures.labyrinth_from_tiles(TWO_JUNCTIONS))
	t.assert_eq(_values(measure), [3, 3, 2, 2, 1, 0], "length, presses, decisions, turns, side branch, Items on the path")
	return true


func test_presses_equal_the_moves_of_the_move_rule_along_the_main_path(t) -> bool:
	for n in PINNED_MEASURES:
		_check_presses(t, LabyrinthPlan.build(n), "Labyrinth %d" % n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 505
	for i in RANDOM_SEED_COUNT:
		var seed_value := rng.randi()
		_check_presses(t, LabyrinthPlan.build(21 + i, seed_value), "random seed %d" % seed_value)
	return true


## Sails the boat with the move rule from the start to the Goal. Each press goes toward the next
## main-path square, and the boat collects the Item where it stops.
func _check_presses(t, labyrinth: Labyrinth, label: String) -> void:
	var measure := LabyrinthMeasure.measure(labyrinth)
	var path: Array[Vector2i] = measure["path"]
	var collected := {}
	for item in labyrinth.items:
		collected[item.square] = false
	var square := path[0]
	var moves := 0
	var on_path := true
	while on_path and square != path[-1] and moves <= path.size():
		var next := path[path.find(square) + 1]
		var move := MoveRule.plan(labyrinth, square, next - square, collected)
		square = move.target
		on_path = not move.bump and path.has(square)
		if collected.has(square):
			collected[square] = true
		moves += 1
	t.assert_true(on_path, label + ": each move stops on the main path")
	t.assert_eq(square, labyrinth.goal_square(), label + ": the moves reach the Goal")
	t.assert_eq(measure["presses"], moves, label + ": presses")


func _values(measure: Dictionary) -> Array:
	return [
		measure["length"], measure["presses"], measure["decisions"], measure["turns"],
		measure["largest_side_branch"], measure["items_on_path"],
	]


func _ids(squares: Array[Vector2i]) -> Array:
	var ids := []
	for square in squares:
		ids.append(Item.id_of(square))
	return ids
