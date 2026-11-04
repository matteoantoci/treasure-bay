## The Sea friend table of spec 4.7, the Sea friends with an own sound (spec 9.4), and the pick of
## the Sea friend that comes back after Labyrinth 20 (spec 6.4).
class_name SeaFriends
extends RefCounted

## Labyrinth n (1 to 20) gives the n-th Sea friend. This is also the slot order of the Collection
## strip (spec 6.5). Each ID is the file name of its sprite.
const IDS: PackedStringArray = [
	"crab", "octopus", "spouting_whale", "whale", "dolphin",
	"fish", "blowfish", "shark", "squid", "lobster",
	"shrimp", "oyster", "seal", "turtle", "jellyfish",
	"otter", "penguin", "duck", "swan", "flamingo",
]
## The 13 Sea friends with an own sound (spec 9.4). The other 7 play the splash.
const WITH_OWN_SOUND: PackedStringArray = [
	"crab", "octopus", "whale", "dolphin", "fish", "squid", "seal",
	"jellyfish", "otter", "penguin", "duck", "swan", "flamingo",
]


## The Sea friend that Labyrinth `number` (1 to 20) gives.
static func for_labyrinth(number: int) -> String:
	return IDS[number - 1]


## The slot of a Sea friend in the Collection strip, from 0.
static func slot_of(id: String) -> int:
	return IDS.find(id)


static func texture_path(id: String) -> String:
	return "res://assets/sprites/friends/%s.png" % id


static func has_own_sound(id: String) -> bool:
	return WITH_OWN_SOUND.has(id)


## Picks the Sea friend that comes back: one of `collection`, never `last`. `random_value` is a
## random non-negative int, for example randi(). Returns "" when no Sea friend can come back.
static func pick_returning(collection: PackedStringArray, last: String, random_value: int) -> String:
	var candidates := PackedStringArray()
	for id in collection:
		if id != last:
			candidates.append(id)
	if candidates.is_empty():
		return ""
	return candidates[random_value % candidates.size()]
