## The progress of the Child: the fields of the save file (spec 12.1) and the rules that change
## them (spec 6). The save code writes and loads these fields.
class_name Progress
extends RefCounted

## The current Labyrinth number, from 1 to 20. The save field is "labyrinth".
var labyrinth_number := 1
## The 20 seeds of the Voyage: Labyrinth n uses seeds[n - 1]. A new Progress has the fixed seed
## table. new_voyage() gives new seeds.
var seeds: Array[int] = LabyrinthPlan.FIXED_SEEDS.duplicate()
## IDs ("x,y") of the Items collected in the current Labyrinth.
var collected_items := PackedStringArray()
## Sea friend IDs in the order the Child got them.
var collection := PackedStringArray()
## The total count of collected Items, over all Labyrinths.
var total_items := 0


## The progress at the start of a new Voyage: Labyrinth 1, the new seeds of `start_value`, no
## collected Items, an empty Collection, and a total of `total`.
static func new_voyage(start_value: int, total: int = 0) -> Progress:
	var progress := Progress.new()
	progress.total_items = total
	progress._start_voyage(start_value)
	return progress


## Makes the current Labyrinth with its Items.
func build_labyrinth() -> Labyrinth:
	return LabyrinthPlan.build(labyrinth_number, seeds)


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


## The Child reaches the Goal of the current Labyrinth. Labyrinth n adds its Sea friend to the
## Collection (spec 4.7). After Labyrinth 1 to 19, the progress moves to the next Labyrinth with no
## collected Items. After Labyrinth 20, a new Voyage starts with the seeds of `start_value` and the
## same total (game-flow spec Part 1). Returns the Sea friend.
func reach_goal(start_value: int) -> String:
	var friend := SeaFriends.for_labyrinth(labyrinth_number)
	if not collection.has(friend):
		collection.append(friend)
	collected_items = PackedStringArray()
	if labyrinth_number < LabyrinthPlan.FIXED_COUNT:
		labyrinth_number += 1
	else:
		_start_voyage(start_value)
	return friend


## Starts a new Voyage from `start_value`: Labyrinth 1, new seeds, no collected Items, and an empty
## Collection. The total stays. new_voyage() and reach_goal() share it.
func _start_voyage(start_value: int) -> void:
	labyrinth_number = 1
	seeds = DifficultyCurve.new_voyage(start_value)
	collected_items = PackedStringArray()
	collection = PackedStringArray()
