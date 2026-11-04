## Seed search of play-improvements spec Part 3: selects the seed of each fixed Labyrinth 1 to 20 by
## measured difficulty, so that each Labyrinth is a little harder than the one before. For Labyrinth
## n, it takes the first seed from 1 upward whose Labyrinth, with its Items, meets all conditions of
## meets_conditions(). The two Labyrinths of one size are Labyrinths 2i - 1 and 2i (spec 4.3), and
## Labyrinth 2i does not take the seed of Labyrinth 2i - 1.
##
## To tune the difficulty curve, change PRESSES or meets_conditions(), run the tool, and copy the
## printed table into LabyrinthPlan.FIXED_SEEDS (src/labyrinth_plan.gd). Then update
## tests/spec_port.py and the pins of the tests that it gives.
##
## Run from the repository root:
##   godot --headless --path . --script res://tools/seed_search.gd
## It prints one table row for each Labyrinth, then the seed table, and exits with code 0. If no seed
## up to MAX_SEED meets the conditions, it prints "SEED SEARCH FAIL ..." and exits with code 1.
extends SceneTree

## T(n): the arrow presses along the main path of Labyrinth n.
const PRESSES: Array[int] = [3, 5, 5, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
const MAX_SEED := 1000000


func _initialize() -> void:
	var seeds: Array[int] = []
	print("| n | size | seed | presses | decisions | Item IDs in placement order |")
	print("|---|---|---|---|---|---|")
	for number in range(1, LabyrinthPlan.FIXED_COUNT + 1):
		var taken: int = seeds[-1] if number % 2 == 0 else 0
		var seed_value := 1
		while seed_value <= MAX_SEED and (seed_value == taken or not meets_conditions(number, seed_value)):
			seed_value += 1
		if seed_value > MAX_SEED:
			print("SEED SEARCH FAIL: no seed up to %d for Labyrinth %d" % [MAX_SEED, number])
			quit(1)
			return
		seeds.append(seed_value)
		var labyrinth := LabyrinthPlan.build_from_seed(number, seed_value)
		var measure := LabyrinthMeasure.measure(labyrinth)
		var ids := PackedStringArray()
		for item in labyrinth.items:
			ids.append(item.id)
		print("| %d | %d×%d | %d | %d | %d | %s |" % [
			number, labyrinth.width, labyrinth.height, seed_value, measure.presses,
			measure.decisions, " ".join(ids),
		])
	print("FIXED_SEEDS = %s" % [seeds])
	quit(0)


## The conditions of play-improvements spec Part 3 for Labyrinth `number` with `seed_value`, with
## d = 1 + (number - 1) div 5.
func meets_conditions(number: int, seed_value: int) -> bool:
	var size := LabyrinthPlan.size_for(number)
	if not ItemPlacement.has_free_dead_end(LabyrinthGenerator.generate(size.x, size.y, Prng.new(seed_value))):
		return false
	var measure := LabyrinthMeasure.measure(LabyrinthPlan.build_from_seed(number, seed_value))
	var d := 1 + (number - 1) / 5
	return (
		measure.presses == PRESSES[number - 1]
		and measure.decisions >= d and measure.decisions <= d + 2
		and (number < 2 or measure.turns >= 2)
		and measure.items_on_path >= 1
		and measure.largest_side_branch <= maxi(6, measure.length)
	)
