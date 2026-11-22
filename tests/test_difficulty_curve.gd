## The difficulty curve of a Voyage (game-flow spec Part 1, Testing Decisions seam 2): the seeds of
## a new Voyage meet the conditions of their slots.
extends RefCounted

## Fixed start values, so each run tests the same Voyages.
const START_VALUE := 4242
const OTHER_START_VALUE := 777


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


func test_the_second_slot_of_a_size_never_takes_the_seed_of_the_first(t) -> bool:
	for start_value in range(1, 301):
		var seeds := DifficultyCurve.new_voyage(start_value)
		for n in range(1, 21, 2):
			t.assert_true(seeds[n - 1] != seeds[n], "start value %d: slots %d and %d" % [start_value, n, n + 1])
	return true


## The seed pool (Parent decision of 2026-11-22): 100 different seeds for each slot, and each one
## meets the conditions of its slot.
func test_each_seed_of_the_pool_meets_the_conditions_of_its_slot(t) -> bool:
	t.assert_eq(SeedPool.SEEDS.size(), 20, "a pool row for each slot")
	for n in range(1, 21):
		var row: Array = SeedPool.SEEDS[n - 1]
		var different := {}
		var failed := []
		for seed_value in row:
			different[seed_value] = true
			if seed_value <= 0 or not DifficultyCurve.meets_conditions(n, seed_value):
				failed.append(seed_value)
		t.assert_eq(row.size(), 100, "slot %d: 100 seeds" % n)
		t.assert_eq(different.size(), 100, "slot %d: 100 different seeds" % n)
		t.assert_eq(failed, [], "slot %d: seeds that do not meet the conditions" % n)
	return true


func test_the_fixed_seed_table_meets_the_conditions(t) -> bool:
	for n in range(1, 21):
		t.assert_true(DifficultyCurve.meets_conditions(n, LabyrinthPlan.FIXED_SEEDS[n - 1]), "the fixed seed of slot %d" % n)
	return true
