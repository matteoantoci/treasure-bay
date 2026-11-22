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
	for start_value in [START_VALUE, OTHER_START_VALUE, 1, 2, 3]:
		var seeds := DifficultyCurve.new_voyage(start_value)
		for n in range(1, 21, 2):
			t.assert_true(seeds[n - 1] != seeds[n], "start value %d: slots %d and %d" % [start_value, n, n + 1])
	# The start seed of slot 2 is a seed that meets its conditions: the slot still skips the seed of
	# slot 1.
	t.assert_true(DifficultyCurve.meets_conditions(2, LabyrinthPlan.FIXED_SEEDS[1]), "the fixed seed of slot 2 meets the conditions of slot 2")
	t.assert_true(DifficultyCurve.find_seed(2, LabyrinthPlan.FIXED_SEEDS[1], 1000, LabyrinthPlan.FIXED_SEEDS[1]) > LabyrinthPlan.FIXED_SEEDS[1], "slot 2 does not take the taken seed")
	return true


func test_a_slot_with_no_seed_within_its_tries_uses_the_fixed_seed(t) -> bool:
	t.assert_eq(DifficultyCurve.new_voyage(START_VALUE, 0), LabyrinthPlan.FIXED_SEEDS, "no tries: the fixed seed table")
	# With 1 try, each slot takes its start seed or its fixed seed. Both meet the conditions.
	var seeds := DifficultyCurve.new_voyage(START_VALUE, 1)
	for n in range(1, 21):
		t.assert_true(DifficultyCurve.meets_conditions(n, seeds[n - 1]), "the seed of slot %d meets its conditions" % n)
	t.assert_eq(seeds, LabyrinthPlan.FIXED_SEEDS, "start value %d: no start seed meets its conditions" % START_VALUE)
	return true


func test_the_fixed_seed_table_meets_the_conditions(t) -> bool:
	for n in range(1, 21):
		t.assert_true(DifficultyCurve.meets_conditions(n, LabyrinthPlan.FIXED_SEEDS[n - 1]), "the fixed seed of slot %d" % n)
	return true
