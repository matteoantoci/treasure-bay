## Spec 14.1 test 3: Item placement of spec 4.6, with the Item counts of spec 4.3 and the Item
## kinds of spec 7.2.
extends RefCounted

const RANDOM_SEED_COUNT := 200
# Spec 4.3: Labyrinth n -> Item count.
const COUNTS := {
	1: 2, 2: 2, 3: 2, 4: 2, 5: 3, 6: 3, 7: 4, 8: 4, 9: 4, 10: 4,
	11: 5, 12: 5, 13: 6, 14: 6, 15: 8, 16: 8, 17: 8, 18: 8, 19: 8, 20: 8,
}
const RANDOM_COUNT := 8
# Spec 7.2: Item kinds of Areas 1 to 4, in list order.
const AREA_KINDS := [
	["spiral_shell", "starfish", "pearl"],
	["coral", "sand_dollar"],
	["gem_stone", "spiral_shell"],
	["glowing_star", "star"],
]
# Item IDs of Labyrinths 1 to 20 in placement order, from tests/spec_port.py, an independent Python
# port of spec 4.1, 4.2, and 4.6. The candidate squares of each list are in row order (lowest y,
# then lowest x) before the shuffle.
const PINNED_IDS := {
	1: ["1,1", "1,2"],
	2: ["0,1", "2,2"],
	3: ["2,1", "4,1"],
	4: ["0,1", "4,1"],
	5: ["4,0", "2,0", "3,2"],
	6: ["3,3", "1,1", "1,2"],
	7: ["2,0", "5,2", "1,2", "3,3"],
	8: ["0,1", "4,1", "2,3", "1,1"],
	9: ["0,3", "1,1", "5,3", "3,2"],
	10: ["5,1", "0,3", "4,2", "3,2"],
	11: ["0,4", "2,1", "4,2", "6,2", "3,4"],
	12: ["5,1", "1,1", "5,4", "3,1", "4,2"],
	13: ["2,4", "6,1", "1,1", "5,2", "7,3", "2,0"],
	14: ["4,3", "6,1", "0,4", "6,4", "1,1", "0,2"],
	15: ["7,1", "5,4", "1,4", "4,1", "2,1", "0,5", "7,0", "1,0"],
	16: ["7,2", "0,3", "4,0", "5,2", "4,5", "2,5", "4,3", "2,0"],
	17: ["7,3", "0,5", "2,2", "5,5", "5,2", "0,1", "6,0", "6,4"],
	18: ["6,3", "4,5", "8,4", "3,1", "5,1", "3,5", "0,4", "4,3"],
	19: ["4,6", "5,1", "3,3", "8,3", "2,5", "1,2", "0,6", "0,1"],
	20: ["4,2", "1,4", "3,3", "8,1", "0,6", "2,5", "6,3", "3,1"],
}
# The same Python port, for random Labyrinths (10 x 7) with these seeds.
const PINNED_RANDOM_IDS := {
	4242: ["0,4", "0,6", "5,5", "9,0", "2,3", "7,3", "5,0", "3,4"],
	123456789: ["6,4", "3,6", "2,3", "1,0", "4,2", "9,5", "6,1", "0,2"],
}


func test_item_count_matches_the_table(t) -> bool:
	for n in COUNTS:
		t.assert_eq(LabyrinthPlan.item_count(n), COUNTS[n], "Item count of Labyrinth %d" % n)
		t.assert_eq(LabyrinthPlan.build(n).items.size(), COUNTS[n], "Items in Labyrinth %d" % n)
	for n in [21, 45]:
		t.assert_eq(LabyrinthPlan.item_count(n), RANDOM_COUNT, "Item count of Labyrinth %d" % n)
		t.assert_eq(LabyrinthPlan.build(n, 4242).items.size(), RANDOM_COUNT, "Items in Labyrinth %d" % n)
	return true


func test_item_squares_of_labyrinths_1_to_20_are_pinned(t) -> bool:
	for n in PINNED_IDS:
		t.assert_eq(_ids(LabyrinthPlan.build(n)), PINNED_IDS[n], "Item IDs of Labyrinth %d" % n)
	return true


func test_item_squares_of_random_labyrinths_are_pinned(t) -> bool:
	for seed_value in PINNED_RANDOM_IDS:
		t.assert_eq(_ids(LabyrinthPlan.build(21, seed_value)), PINNED_RANDOM_IDS[seed_value], "Item IDs of random seed %d" % seed_value)
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


func test_random_labyrinths_follow_the_placement_rules(t) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4104
	for i in RANDOM_SEED_COUNT:
		var number := 21 + i
		var seed_value := rng.randi()
		_check_items(t, LabyrinthPlan.build(number, seed_value), number, "random seed %d" % seed_value)
	return true


func test_seeds_1_to_20_are_valid(t) -> bool:
	for n in COUNTS:
		var size := LabyrinthPlan.size_for(n)
		var labyrinth := LabyrinthGenerator.generate(size.x, size.y, Prng.new(n))
		t.assert_true(ItemPlacement.has_free_dead_end(labyrinth), "seed %d has a dead end that is not the start or the Goal" % n)
		t.assert_eq(LabyrinthPlan.build(n).seed_value, n, "Labyrinth %d uses seed %d" % [n, n])
	return true


func test_random_seed_with_no_free_dead_end_moves_to_seed_plus_1(t) -> bool:
	# At 3 x 2 squares, tests/spec_port.py finds no free dead end for seeds 9, 15, and 16.
	var size := Vector2i(3, 2)
	for seed_value in [9, 15, 16]:
		var labyrinth := LabyrinthGenerator.generate(size.x, size.y, Prng.new(seed_value))
		t.assert_true(not ItemPlacement.has_free_dead_end(labyrinth), "seed %d at 3 x 2 is not valid" % seed_value)
	t.assert_eq(LabyrinthPlan.valid_seed(size, 9), 10, "seed 9 moves to 10")
	t.assert_eq(LabyrinthPlan.valid_seed(size, 15), 17, "seed 15 moves past 16 to 17")
	t.assert_eq(LabyrinthPlan.valid_seed(size, 10), 10, "a valid seed stays")
	t.assert_eq(LabyrinthPlan.build(21, 4242).seed_value, 4242, "a valid random seed stays")
	return true


func test_first_item_is_in_the_farthest_dead_end(t) -> bool:
	# Labyrinth 2 (seed 2, 4 x 3). From tests/spec_port.py: its free dead ends are (0, 1) at
	# distance 9 and (2, 2) at distance 8 from the start, so Item 1 is on (0, 1).
	var labyrinth := LabyrinthPlan.build(2)
	t.assert_eq(ItemPlacement.free_dead_ends(labyrinth), [Vector2i(0, 1), Vector2i(2, 2)] as Array[Vector2i], "free dead ends of Labyrinth 2")
	t.assert_eq(labyrinth.items[0].square, Vector2i(0, 1), "Item 1 of Labyrinth 2")
	return true


## The rules of spec 4.6 and 14.1 test 3 for one Labyrinth.
func _check_items(t, labyrinth: Labyrinth, number: int, label: String) -> void:
	var items: Array = labyrinth.items
	t.assert_eq(items.size(), COUNTS.get(number, RANDOM_COUNT), label + ": Item count")
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


func _ids(labyrinth: Labyrinth) -> Array:
	var ids := []
	for item in labyrinth.items:
		ids.append(item.id)
	return ids
