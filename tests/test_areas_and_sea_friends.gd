## Spec 14.1 test 6: the Area of each Labyrinth (spec 4.3, 4.4, 7.2), its music track (spec 9.2),
## the Sea friend of Labyrinths 1 to 20 (spec 4.7), and the Sea friend that comes back after
## Labyrinth 20 (spec 6.4).
extends RefCounted

const DRAWS := 1000

# Spec 4.3 and 4.4: Labyrinths 1 to 5 are Area 1, 6 to 10 Area 2, 11 to 15 Area 3, 16 to 20 Area 4,
# then 21 to 25 Area 1 again, and so on.
const AREA_RANGES := [
	[1, 5, 1], [6, 10, 2], [11, 15, 3], [16, 20, 4],
	[21, 25, 1], [26, 30, 2], [31, 35, 3], [36, 40, 4], [41, 45, 1],
]
# Spec 9.2.
const MUSIC := {
	1: "res://assets/audio/music/lagoon.mp3",
	2: "res://assets/audio/music/coral_reef.mp3",
	3: "res://assets/audio/music/open_sea.mp3",
	4: "res://assets/audio/music/sea_at_night.mp3",
}
# Spec 7.2, in list order.
const ITEM_KINDS := {
	1: ["spiral_shell", "starfish", "pearl"],
	2: ["coral", "sand_dollar"],
	3: ["gem_stone", "spiral_shell"],
	4: ["glowing_star", "star"],
}
# Spec 4.7: Labyrinth n gives the n-th Sea friend.
const SEA_FRIENDS := [
	"crab", "octopus", "spouting_whale", "whale", "dolphin",
	"fish", "blowfish", "shark", "squid", "lobster",
	"shrimp", "oyster", "seal", "turtle", "jellyfish",
	"otter", "penguin", "duck", "swan", "flamingo",
]


func test_area_of_labyrinths_1_to_45(t) -> bool:
	for area_range in AREA_RANGES:
		for n in range(area_range[0], area_range[1] + 1):
			t.assert_eq(Area.for_labyrinth(n), area_range[2], "Area of Labyrinth %d" % n)
	return true


func test_music_track_matches_the_area(t) -> bool:
	for area in MUSIC:
		t.assert_eq(Area.music_path(area), MUSIC[area], "music of Area %d" % area)
	t.assert_eq(Area.music_path(Area.for_labyrinth(26)), MUSIC[2], "music of Labyrinth 26")
	return true


func test_item_kinds_of_each_area(t) -> bool:
	for area in ITEM_KINDS:
		t.assert_eq(Area.item_kinds(area), PackedStringArray(ITEM_KINDS[area]), "Item kinds of Area %d" % area)
	return true


func test_sea_friend_of_labyrinths_1_to_20(t) -> bool:
	for n in range(1, 21):
		t.assert_eq(SeaFriends.for_labyrinth(n), SEA_FRIENDS[n - 1], "Sea friend of Labyrinth %d" % n)
	t.assert_eq(SeaFriends.IDS, PackedStringArray(SEA_FRIENDS), "the 20 Sea friends in strip order")
	return true


func test_each_sea_friend_has_a_sprite(t) -> bool:
	for id in SEA_FRIENDS:
		t.assert_true(SeaFriends.texture_path(id) == "res://assets/sprites/friends/%s.png" % id, "sprite path of %s" % id)
		t.assert_true(ResourceLoader.exists(SeaFriends.texture_path(id)), "sprite of %s exists" % id)
	return true


func test_returning_sea_friend_never_repeats_and_is_in_the_collection(t) -> bool:
	seed(20261104)
	var collection := PackedStringArray(SEA_FRIENDS)
	var last := ""
	var repeats := 0
	var outside := 0
	var seen := {}
	for i in DRAWS:
		var friend := SeaFriends.pick_returning(collection, last, randi())
		if friend == last:
			repeats += 1
		if not collection.has(friend):
			outside += 1
		seen[friend] = true
		last = friend
	t.assert_eq(repeats, 0, "draws that repeat the last Sea friend")
	t.assert_eq(outside, 0, "draws outside the Collection")
	t.assert_eq(seen.size(), SEA_FRIENDS.size(), "every Sea friend of the Collection comes back sometimes")
	return true


func test_returning_sea_friend_comes_only_from_the_collection(t) -> bool:
	var collection := PackedStringArray(["seal", "duck", "crab"])
	for value in range(0, 12):
		var friend := SeaFriends.pick_returning(collection, "duck", value)
		t.assert_true(friend in ["seal", "crab"], "draw %d gives a Sea friend of the Collection, not the last one" % value)
	return true


func test_no_sea_friend_comes_back_when_none_can(t) -> bool:
	t.assert_eq(SeaFriends.pick_returning(PackedStringArray(), "", 5), "", "empty Collection")
	t.assert_eq(SeaFriends.pick_returning(PackedStringArray(["crab"]), "crab", 5), "", "only the last one")
	return true
