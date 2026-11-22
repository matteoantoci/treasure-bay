## Spec 14.1 test 3: Item placement of spec 4.6 with the main-path Items of play-improvements
## Part 1, the Item counts of spec 4.3, and the Item kinds of spec 7.2.
extends RefCounted

# Spec 4.3: Labyrinth n -> Item count.
const COUNTS := {
	1: 2, 2: 2, 3: 2, 4: 2, 5: 3, 6: 3, 7: 4, 8: 4, 9: 4, 10: 4,
	11: 5, 12: 5, 13: 6, 14: 6, 15: 8, 16: 8, 17: 8, 18: 8, 19: 8, 20: 8,
}
# Spec 7.2: Item kinds of Areas 1 to 4, in list order.
const AREA_KINDS := [
	["spiral_shell", "starfish", "pearl"],
	["coral", "sand_dollar"],
	["gem_stone", "spiral_shell"],
	["glowing_star", "star"],
]
# Item IDs of Labyrinths 1 to 20 in placement order, from tests/spec_port.py, an independent Python
# port of spec 4.1, 4.2, and 4.6 and of the fixed seed table of play-improvements Part 3. The
# candidate squares of each list are in row order (lowest y, then lowest x) before the shuffle.
const PINNED_IDS := {
	1: ["1,1", "0,2"],
	2: ["0,1", "2,1"],
	3: ["1,1", "4,1"],
	4: ["2,1", "3,2"],
	5: ["4,0", "2,1", "1,1"],
	6: ["0,3", "2,1", "4,0"],
	7: ["5,2", "2,2", "0,3", "1,0"],
	8: ["0,3", "3,1", "4,3", "1,1"],
	9: ["0,1", "3,1", "6,0", "5,3"],
	10: ["6,0", "1,3", "0,1", "6,2"],
	11: ["3,2", "3,1", "6,0", "1,0", "2,4"],
	12: ["4,3", "2,1", "6,0", "0,4", "1,2"],
	13: ["0,2", "3,3", "6,0", "4,1", "6,1", "2,3"],
	14: ["1,0", "4,1", "2,4", "7,0", "6,2", "1,3"],
	15: ["4,1", "4,0", "6,2", "3,2", "1,5", "1,1", "7,4", "0,5"],
	16: ["3,4", "3,2", "6,0", "1,2", "1,0", "4,1", "5,3", "6,1"],
	17: ["1,0", "5,2", "5,4", "8,0", "3,4", "7,2", "2,2", "1,4"],
	18: ["6,3", "4,2", "2,2", "0,1", "7,5", "2,4", "8,0", "4,4"],
	19: ["4,5", "4,6", "2,1", "5,1", "7,6", "3,2", "6,4", "0,6"],
	20: ["8,2", "3,1", "3,6", "1,4", "3,5", "2,1", "7,6", "0,6"],
}


func test_item_count_matches_the_table(t) -> bool:
	for n in COUNTS:
		t.assert_eq(LabyrinthPlan.item_count(n), COUNTS[n], "Item count of Labyrinth %d" % n)
		t.assert_eq(LabyrinthPlan.build(n).items.size(), COUNTS[n], "Items in Labyrinth %d" % n)
	return true


func test_item_squares_of_labyrinths_1_to_20_are_pinned(t) -> bool:
	for n in PINNED_IDS:
		t.assert_eq(_ids(LabyrinthPlan.build(n)), PINNED_IDS[n], "Item IDs of Labyrinth %d" % n)
	return true


func test_item_id_is_x_comma_y_of_its_square(t) -> bool:
	var labyrinth := LabyrinthPlan.build(20)
	for item in labyrinth.items:
		t.assert_eq(item.id, "%d,%d" % [item.square.x, item.square.y], "ID of the Item on %s" % item.square)
	t.assert_eq(Item.id_of(Vector2i(8, 1)), "8,1", "ID of square (8, 1)")
	return true


func test_fixed_labyrinths_follow_the_placement_rules(t) -> bool:
	for n in COUNTS:
		_check_items(t, LabyrinthPlan.build(n), n, "Labyrinth %d" % n)
	return true


## The Labyrinths of a new Voyage (game-flow spec Part 1) follow the placement rules too.
func test_the_labyrinths_of_a_new_voyage_follow_the_placement_rules(t) -> bool:
	var seeds := DifficultyCurve.new_voyage(4242)
	for n in COUNTS:
		_check_items(t, LabyrinthPlan.build(n, seeds), n, "Labyrinth %d of the Voyage of 4242" % n)
	return true


## A new Voyage takes its seeds from the seed pool (src/seed_pool.gd), so each Labyrinth of the pool
## follows the placement rules.
func test_the_labyrinths_of_the_seed_pool_follow_the_placement_rules(t) -> bool:
	for n in COUNTS:
		for seed_value in SeedPool.SEEDS[n - 1]:
			_check_items(t, LabyrinthPlan.build_from_seed(n, seed_value), n, "Labyrinth %d of pool seed %d" % [n, seed_value])
	return true


func test_first_item_is_in_the_farthest_dead_end(t) -> bool:
	# Labyrinth 2 (4 x 3). From tests/spec_port.py: its free dead ends are (3, 0) at distance 5 and
	# (0, 1) at distance 7 from the start, so Item 1 is on (0, 1).
	var labyrinth := LabyrinthPlan.build(2)
	t.assert_eq(ItemPlacement.free_dead_ends(labyrinth), [Vector2i(3, 0), Vector2i(0, 1)] as Array[Vector2i], "free dead ends of Labyrinth 2")
	t.assert_eq(labyrinth.items[0].square, Vector2i(0, 1), "Item 1 of Labyrinth 2")
	return true


## The rules of spec 4.6, play-improvements Part 1, and spec 14.1 test 3 for one Labyrinth.
func _check_items(t, labyrinth: Labyrinth, number: int, label: String) -> void:
	var items: Array = labyrinth.items
	t.assert_eq(items.size(), COUNTS[number], label + ": Item count")
	var in_dead_end := false
	var squares := {}
	var kinds_follow := true
	var kinds: Array = AREA_KINDS[((number - 1) / 5) % 4]
	for i in items.size():
		var square: Vector2i = items[i].square
		squares[square] = true
		in_dead_end = in_dead_end or labyrinth.open_side_count(square) == 1
		t.assert_true(square != Vector2i(0, 0), label + ": no Item on the start square")
		t.assert_true(square != Vector2i(labyrinth.width - 1, labyrinth.height - 1), label + ": no Item on the Goal square")
		t.assert_true(labyrinth.contains(square), label + ": Item inside the Labyrinth")
		kinds_follow = kinds_follow and items[i].kind == kinds[i % kinds.size()]
	t.assert_true(in_dead_end, label + ": at least one Item in a dead end")
	t.assert_eq(squares.size(), items.size(), label + ": all Item squares differ")
	t.assert_true(kinds_follow, label + ": Item kinds follow the Area list")
	var distances := labyrinth.distances_from(Vector2i.ZERO)
	var first: Vector2i = items[0].square
	for dead_end in ItemPlacement.free_dead_ends(labyrinth):
		t.assert_true(distances[dead_end.y * labyrinth.width + dead_end.x] <= distances[first.y * labyrinth.width + first.x], label + ": Item 1 is in the farthest dead end")
	var path := labyrinth.main_path()
	var length := path.size() - 1
	var on_path_count := mini(maxi(1, items.size() / 3), length - 1)
	var on_path := 0
	for square in squares:
		if path.has(square):
			on_path += 1
	t.assert_true(on_path >= on_path_count, label + ": at least %d Items on the main path (%d)" % [on_path_count, on_path])
	# Items 2 to k + 1 are on P[j * L div (k + 1)], from the start to the Goal.
	for j in range(1, on_path_count + 1):
		t.assert_eq(items[j].square, path[j * length / (on_path_count + 1)], label + ": on-path Item %d is on its main-path square" % j)


func _ids(labyrinth: Labyrinth) -> Array:
	var ids := []
	for item in labyrinth.items:
		ids.append(item.id)
	return ids
