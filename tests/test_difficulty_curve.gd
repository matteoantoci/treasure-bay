## The difficulty curve of a Voyage (game-flow spec Part 1, Testing Decisions seam 2): the seeds of
## a new Voyage meet the conditions of their slots.
extends RefCounted

## Fixed start values, so each run tests the same Voyages.
const START_VALUE := 4242
const OTHER_START_VALUE := 777

## The layouts of the built Labyrinths, by slot and seed. The tests of this file share them, so each
## Labyrinth builds one time.
var _layouts := {}


func test_each_seed_of_a_new_voyage_meets_the_conditions_of_its_slot(t) -> bool:
	var seeds := DifficultyCurve.new_voyage(START_VALUE)
	t.assert_eq(seeds.size(), 20, "20 seeds")
	for n in range(1, 21):
		t.assert_true(seeds[n - 1] > 0, "the seed of slot %d is positive" % n)
		t.assert_true(DifficultyCurve.meets_conditions(n, seeds[n - 1]), "the seed of slot %d meets its conditions" % n)
	t.assert_true(seeds != LabyrinthPlan.FIXED_SEEDS, "the Voyage has new seeds")
	return true


func test_the_same_start_value_gives_the_same_voyage(t) -> bool:
	t.assert_eq(DifficultyCurve.new_voyage(START_VALUE), DifficultyCurve.new_voyage(START_VALUE), "the same seeds")
	return true


func test_two_start_values_give_different_voyages(t) -> bool:
	t.assert_true(DifficultyCurve.new_voyage(START_VALUE) != DifficultyCurve.new_voyage(OTHER_START_VALUE), "different seeds")
	return true


## Ticket 01: the first Labyrinths do not repeat. The two slots of a size have the same size and
## Item count, so they must not have the same layout.
func test_the_second_slot_of_a_size_never_gets_the_layout_of_the_first(t) -> bool:
	var same := []
	for start_value in range(1, 301):
		var seeds := DifficultyCurve.new_voyage(start_value)
		for n in range(1, 21, 2):
			if _layout(n, seeds[n - 1]) == _layout(n + 1, seeds[n]):
				same.append("start value %d: slots %d and %d" % [start_value, n, n + 1])
	t.assert_eq(same, [], "Voyages with the same layout in the two slots of a size")
	return true


## The seed pool (Parent decision of 2026-11-22): 1 to 100 seeds for each slot, and each one meets
## the conditions of its slot. The second slot of a size has at least 2 seeds, so it can take
## another layout than the first slot.
func test_each_seed_of_the_pool_meets_the_conditions_of_its_slot(t) -> bool:
	t.assert_eq(SeedPool.SEEDS.size(), 20, "a pool row for each slot")
	for n in range(1, 21):
		var row: Array = SeedPool.SEEDS[n - 1]
		var failed := []
		for seed_value in row:
			if seed_value <= 0 or not DifficultyCurve.meets_conditions(n, seed_value):
				failed.append(seed_value)
		t.assert_true(row.size() >= (2 if n % 2 == 0 else 1) and row.size() <= 100, "slot %d: %d seeds" % [n, row.size()])
		t.assert_eq(failed, [], "slot %d: seeds that do not meet the conditions" % n)
	return true


func test_no_two_seeds_of_a_pool_row_have_the_same_layout(t) -> bool:
	for n in range(1, 21):
		var row: Array = SeedPool.SEEDS[n - 1]
		var different := {}
		for seed_value in row:
			different[_layout(n, seed_value)] = true
		t.assert_eq(different.size(), row.size(), "slot %d: different layouts" % n)
	return true


## new_voyage() compares the layout numbers of the pool. In the two slots of a size, the same
## number must be the same layout, and different numbers different layouts.
func test_the_layout_numbers_of_the_pool_match_the_layouts(t) -> bool:
	t.assert_eq(SeedPool.LAYOUTS.size(), 20, "a layout row for each slot")
	for first in range(1, 21, 2):
		var key_of := {}
		var number_of := {}
		var wrong := []
		for n in [first, first + 1]:
			var row: Array = SeedPool.SEEDS[n - 1]
			var layouts: Array = SeedPool.LAYOUTS[n - 1]
			t.assert_eq(layouts.size(), row.size(), "slot %d: a layout number for each seed" % n)
			for i in mini(row.size(), layouts.size()):
				var key := _layout(n, row[i])
				if key_of.get(layouts[i], key) != key or number_of.get(key, layouts[i]) != layouts[i]:
					wrong.append("slot %d, seed %d" % [n, row[i]])
				key_of[layouts[i]] = key
				number_of[key] = layouts[i]
		t.assert_eq(wrong, [], "slots %d and %d: seeds with a wrong layout number" % [first, first + 1])
	return true


func test_the_fixed_seed_table_meets_the_conditions(t) -> bool:
	for n in range(1, 21):
		t.assert_true(DifficultyCurve.meets_conditions(n, LabyrinthPlan.FIXED_SEEDS[n - 1]), "the fixed seed of slot %d" % n)
	return true


## The layout of Labyrinth `number` with `seed_value` (DifficultyCurve.layout_key()).
func _layout(number: int, seed_value: int) -> String:
	var at := Vector2i(number, seed_value)
	if not _layouts.has(at):
		_layouts[at] = DifficultyCurve.layout_key(LabyrinthPlan.build_from_seed(number, seed_value))
	return _layouts[at]
