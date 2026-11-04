## The fixed seeds of Labyrinths 1 to 20 by measured difficulty (play-improvements spec Part 3,
## Testing Decisions test 2). The Item IDs of these Labyrinths are pinned in tests/test_items.gd.
extends RefCounted

# Play-improvements spec Part 3: the presses T(n) of Labyrinth n.
const PRESSES := [3, 5, 5, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]


func test_each_labyrinth_meets_the_conditions_of_its_slot(t) -> bool:
	for n in range(1, 21):
		var labyrinth := LabyrinthPlan.build(n)
		var measure := LabyrinthMeasure.measure(labyrinth)
		var label := "Labyrinth %d" % n
		var d := 1 + (n - 1) / 5
		t.assert_eq(measure.presses, PRESSES[n - 1], label + ": presses")
		t.assert_true(measure.decisions >= d and measure.decisions <= d + 2, label + ": decisions %d from %d to %d" % [measure.decisions, d, d + 2])
		if n >= 2:
			t.assert_true(measure.turns >= 2, label + ": turns %d at least 2" % measure.turns)
		t.assert_true(measure.items_on_path >= 1, label + ": at least 1 Item on the main path")
		var branch_limit := maxi(6, measure.length)
		t.assert_true(measure.largest_side_branch <= branch_limit, label + ": largest side branch %d at most %d" % [measure.largest_side_branch, branch_limit])
		t.assert_true(ItemPlacement.has_free_dead_end(labyrinth), label + ": a free dead end")
	return true


func test_the_two_labyrinths_of_each_size_have_different_seeds(t) -> bool:
	for n in range(1, 21, 2):
		var first := LabyrinthPlan.build(n)
		var second := LabyrinthPlan.build(n + 1)
		t.assert_eq(Vector2i(first.width, first.height), Vector2i(second.width, second.height), "Labyrinths %d and %d have the same size" % [n, n + 1])
		t.assert_true(first.seed_value != second.seed_value, "Labyrinths %d and %d have different seeds" % [n, n + 1])
	return true
