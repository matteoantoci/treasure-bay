## The progress of the Child: the fields of the save file (spec 12.1) and the rules that change
## them (spec 6). The save code writes and loads these fields.
class_name Progress
extends RefCounted

## The current Labyrinth number, from 1. The save field is "labyrinth".
var labyrinth_number := 1
## The seed of the current random Labyrinth (number above 20), else 0.
var random_seed := 0
## IDs ("x,y") of the Items collected in the current Labyrinth.
var collected_items := PackedStringArray()
## Sea friend IDs in the order the Child got them.
var collection := PackedStringArray()
## The total count of collected Items, over all Labyrinths.
var total_items := 0
## The last Sea friend that came back after Labyrinth 20, or "".
var last_returning_friend := ""


## Makes the current Labyrinth with its Items.
func build_labyrinth() -> Labyrinth:
	return LabyrinthPlan.build(labyrinth_number, random_seed)


## True for the progress of a new game or of a reset: Labyrinth 1, an empty Collection, and a total
## of 0 (spec 11.2).
func is_fresh() -> bool:
	return labyrinth_number == 1 and collection.is_empty() and total_items == 0


func is_collected(item_id: String) -> bool:
	return collected_items.has(item_id)


## Collects an Item of the current Labyrinth. Returns true if it is new: only then it counts.
func collect_item(item_id: String) -> bool:
	if is_collected(item_id):
		return false
	collected_items.append(item_id)
	total_items += 1
	return true


## A dictionary for MoveRule.plan(): the square of each Item of `labyrinth` -> true if the Child
## has collected it.
func item_states(labyrinth: Labyrinth) -> Dictionary:
	var states := {}
	for item in labyrinth.items:
		states[item.square] = is_collected(item.id)
	return states


## The Child reaches the Goal of the current Labyrinth. Labyrinth n (1 to 20) adds its Sea friend
## to the Collection (spec 4.7). After Labyrinth 20, a random Sea friend of the Collection comes
## back, never the last one (spec 6.4). At Labyrinth 21 no Sea friend came back yet, so the last
## one is the last Sea friend of the Collection. Then the progress moves to the next Labyrinth, with
## no collected Items and a new random seed above Labyrinth 20 (spec 12.2). Returns the Sea friend.
func reach_goal() -> String:
	var friend: String
	if LabyrinthPlan.is_random(labyrinth_number):
		var last := last_returning_friend
		if last.is_empty() and not collection.is_empty():
			last = collection[collection.size() - 1]
		friend = SeaFriends.pick_returning(collection, last, randi())
		last_returning_friend = friend
	else:
		friend = SeaFriends.for_labyrinth(labyrinth_number)
		if not collection.has(friend):
			collection.append(friend)
	labyrinth_number += 1
	collected_items = PackedStringArray()
	random_seed = LabyrinthPlan.new_random_seed() if LabyrinthPlan.is_random(labyrinth_number) else 0
	return friend
