## The Progress model: Labyrinth number, seed, collected Items, Collection, total count, and the
## last Sea friend that came back (spec 6, the fields of spec 12.1).
extends RefCounted

const GOALS_AFTER_20 := 1000
# Spec 4.7.
const SEA_FRIENDS := [
	"crab", "octopus", "spouting_whale", "whale", "dolphin",
	"fish", "blowfish", "shark", "squid", "lobster",
	"shrimp", "oyster", "seal", "turtle", "jellyfish",
	"otter", "penguin", "duck", "swan", "flamingo",
]


func test_new_progress_starts_at_labyrinth_1_with_nothing_collected(t) -> bool:
	var progress := Progress.new()
	t.assert_eq(progress.labyrinth_number, 1, "Labyrinth number")
	t.assert_eq(progress.random_seed, 0, "random seed")
	t.assert_eq(progress.collected_items, PackedStringArray(), "collected Items")
	t.assert_eq(progress.collection, PackedStringArray(), "Collection")
	t.assert_eq(progress.total_items, 0, "total Items")
	t.assert_eq(progress.last_returning_friend, "", "last returning Sea friend")
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
	# Labyrinth 1 has its Items on 2,1 and 1,2 (tests/test_items.gd).
	progress.collect_item("1,2")
	t.assert_eq(progress.item_states(labyrinth), {Vector2i(2, 1): false, Vector2i(1, 2): true}, "Item states of Labyrinth 1")
	return true


func test_build_labyrinth_makes_the_current_labyrinth(t) -> bool:
	var progress := Progress.new()
	progress.labyrinth_number = 7
	t.assert_eq(_ids(progress.build_labyrinth()), _ids(LabyrinthPlan.build(7)), "Labyrinth 7")
	progress.labyrinth_number = 33
	progress.random_seed = 4242
	t.assert_eq(_ids(progress.build_labyrinth()), _ids(LabyrinthPlan.build(33, 4242)), "random Labyrinth 33 with seed 4242")
	return true


func test_goals_of_labyrinths_1_to_20_fill_the_collection_in_order(t) -> bool:
	var progress := Progress.new()
	for n in range(1, 21):
		progress.collect_item("0,1")
		var friend := progress.reach_goal()
		t.assert_eq(friend, SEA_FRIENDS[n - 1], "Sea friend of Labyrinth %d" % n)
		t.assert_eq(progress.labyrinth_number, n + 1, "Labyrinth after the Goal of %d" % n)
		t.assert_eq(progress.collected_items, PackedStringArray(), "no collected Items in Labyrinth %d" % (n + 1))
		if n < 20:
			t.assert_eq(progress.random_seed, 0, "no random seed for Labyrinth %d" % (n + 1))
	t.assert_eq(progress.collection, PackedStringArray(SEA_FRIENDS), "Collection after Labyrinth 20")
	t.assert_eq(progress.total_items, 20, "one Item from each Labyrinth")
	t.assert_true(progress.random_seed != 0, "Labyrinth 21 has a random seed")
	t.assert_eq(progress.last_returning_friend, "", "no Sea friend came back yet")
	return true


func test_goals_after_labyrinth_20_bring_back_a_different_sea_friend(t) -> bool:
	seed(4104)
	var progress := Progress.new()
	for n in range(1, 21):
		progress.reach_goal()
	var last := ""
	var repeats := 0
	var outside := 0
	var unsaved := 0
	var seeds_zero := 0
	for i in GOALS_AFTER_20:
		var friend := progress.reach_goal()
		if friend == last:
			repeats += 1
		if not SEA_FRIENDS.has(friend):
			outside += 1
		if progress.last_returning_friend != friend:
			unsaved += 1
		if progress.random_seed == 0:
			seeds_zero += 1
		last = friend
	t.assert_eq(repeats, 0, "Goals that repeat the last Sea friend")
	t.assert_eq(outside, 0, "Sea friends from outside the Collection")
	t.assert_eq(unsaved, 0, "Goals where last_returning_friend is not the Sea friend that came back")
	t.assert_eq(seeds_zero, 0, "random Labyrinths without a seed")
	t.assert_eq(progress.labyrinth_number, 21 + GOALS_AFTER_20, "Labyrinth number")
	t.assert_eq(progress.collection.size(), 20, "the strip does not grow")
	return true


func test_returning_sea_friend_rule_holds_after_a_restart(t) -> bool:
	# A restart loads last_returning_friend from the save (spec 6.4).
	var progress := Progress.new()
	progress.labyrinth_number = 30
	progress.random_seed = 99
	progress.collection = PackedStringArray(["crab", "octopus"])
	progress.last_returning_friend = "crab"
	t.assert_eq(progress.reach_goal(), "octopus", "the other Sea friend comes back")
	t.assert_eq(progress.last_returning_friend, "octopus", "last returning Sea friend")
	return true


func _ids(labyrinth: Labyrinth) -> Array:
	var ids := [labyrinth.width, labyrinth.height]
	for item in labyrinth.items:
		ids.append(item.id)
	return ids
