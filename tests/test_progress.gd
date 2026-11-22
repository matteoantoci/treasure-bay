## The Progress model: Labyrinth number, the seeds of the Voyage, collected Items, Collection, and
## total count (spec 6, the fields of spec 12.1, game-flow spec Part 1).
extends RefCounted

## A fixed start value, so the new Voyage of each test is the same at each run.
const START_VALUE := 4242


func test_new_progress_starts_at_labyrinth_1_with_nothing_collected(t) -> bool:
	var progress := Progress.new()
	t.assert_eq(progress.labyrinth_number, 1, "Labyrinth number")
	t.assert_eq(progress.seeds, LabyrinthPlan.FIXED_SEEDS, "the fixed seed table")
	t.assert_eq(progress.collected_items, PackedStringArray(), "collected Items")
	t.assert_eq(progress.collection, PackedStringArray(), "Collection")
	t.assert_eq(progress.total_items, 0, "total Items")
	return true


func test_each_item_counts_only_one_time(t) -> bool:
	var progress := Progress.new()
	t.assert_true(progress.collect_item("2,1"), "a new Item counts")
	t.assert_true(not progress.collect_item("2,1"), "the same Item does not count again")
	t.assert_true(progress.collect_item("1,2"), "a second Item counts")
	t.assert_eq(progress.total_items, 2, "total Items")
	t.assert_eq(progress.collected_items, PackedStringArray(["2,1", "1,2"]), "collected Items")
	t.assert_true(progress.is_collected("1,2"), "Item 1,2 is collected")
	t.assert_true(not progress.is_collected("0,1"), "Item 0,1 is not collected")
	return true


func test_item_states_map_each_item_square_to_collected(t) -> bool:
	var progress := Progress.new()
	var labyrinth := progress.build_labyrinth()
	# Labyrinth 1 has its Items on 1,1 and 0,2 (tests/test_items.gd).
	progress.collect_item("0,2")
	t.assert_eq(progress.item_states(labyrinth), {Vector2i(1, 1): false, Vector2i(0, 2): true}, "Item states of Labyrinth 1")
	return true


func test_build_labyrinth_makes_the_current_labyrinth(t) -> bool:
	var progress := Progress.new()
	progress.labyrinth_number = 7
	t.assert_eq(_ids(progress.build_labyrinth()), _ids(LabyrinthPlan.build(7)), "Labyrinth 7")
	progress.seeds[6] = 4242
	t.assert_eq(_ids(progress.build_labyrinth()), _ids(LabyrinthPlan.build_from_seed(7, 4242)), "Labyrinth 7 from the seed of slot 7")
	return true


func test_goals_of_labyrinths_1_to_19_fill_the_collection_in_order(t) -> bool:
	var progress := Progress.new()
	for n in range(1, 20):
		progress.collect_item("0,1")
		var friend := progress.reach_goal(START_VALUE)
		t.assert_eq(friend, SeaFriends.IDS[n - 1], "Sea friend of Labyrinth %d" % n)
		t.assert_eq(progress.labyrinth_number, n + 1, "Labyrinth after the Goal of %d" % n)
		t.assert_eq(progress.collected_items, PackedStringArray(), "no collected Items in Labyrinth %d" % (n + 1))
	t.assert_eq(progress.collection, SeaFriends.IDS.slice(0, 19), "Collection before Labyrinth 20")
	t.assert_eq(progress.seeds, LabyrinthPlan.FIXED_SEEDS, "the seeds stay in one Voyage")
	t.assert_eq(progress.total_items, 19, "one Item from each Labyrinth")
	return true


## Game-flow spec Part 1: the Goal of Labyrinth 20 gives the flamingo, then a new Voyage: Labyrinth
## 1, new seeds, no collected Items, an empty Collection, and the same total.
func test_the_goal_of_labyrinth_20_gives_the_flamingo_and_a_new_voyage(t) -> bool:
	var progress := Progress.new()
	progress.labyrinth_number = 20
	progress.collection = SeaFriends.IDS.slice(0, 19)
	progress.total_items = 150
	progress.collect_item("0,1")
	t.assert_eq(progress.reach_goal(START_VALUE), "flamingo", "the Sea friend of Labyrinth 20")
	t.assert_eq(progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(progress.seeds, DifficultyCurve.new_voyage(START_VALUE), "the seeds of the new Voyage")
	t.assert_true(progress.seeds != LabyrinthPlan.FIXED_SEEDS, "new seeds")
	t.assert_eq(progress.collected_items, PackedStringArray(), "no collected Items")
	t.assert_eq(progress.collection, PackedStringArray(), "an empty Collection")
	t.assert_eq(progress.total_items, 151, "the same total")
	return true


func test_a_new_voyage_starts_at_labyrinth_1_with_its_total(t) -> bool:
	var progress := Progress.new_voyage(START_VALUE, 12)
	t.assert_eq(progress.labyrinth_number, 1, "Labyrinth 1")
	t.assert_eq(progress.seeds, DifficultyCurve.new_voyage(START_VALUE), "the seeds of the start value")
	t.assert_eq(progress.collection, PackedStringArray(), "an empty Collection")
	t.assert_eq(progress.total_items, 12, "the total")
	t.assert_true(Progress.new_voyage(START_VALUE).is_fresh(), "a new Voyage with a total of 0 is fresh progress")
	return true


func _ids(labyrinth: Labyrinth) -> Array:
	var ids := [labyrinth.width, labyrinth.height]
	for item in labyrinth.items:
		ids.append(item.id)
	return ids
