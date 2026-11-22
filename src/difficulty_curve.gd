## The difficulty curve of a Voyage (game-flow spec Part 1, play-improvements spec Part 3). It holds
## the conditions that the seed of each slot n (Labyrinth n, 1 to 20) meets, and it picks 20 new
## seeds for a new Voyage from the seed pool. The game and tools/seed_search.gd share it.
class_name DifficultyCurve
extends RefCounted

## T(n): the arrow presses along the main path of Labyrinth n.
const PRESSES: Array[int] = [3, 5, 5, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]


## True if Labyrinth `number` with `seed_value` meets the conditions of its slot, with
## d = 1 + (number - 1) div 5: presses T(n), decisions from d to d + 2, at least 2 turns from
## Labyrinth 2, an Item on the main path, a largest side branch of at most max(6, main path
## length), and a free dead end (spec 4.6 rule 7).
static func meets_conditions(number: int, seed_value: int) -> bool:
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


## The 20 seeds of a new Voyage. The own PRNG with `start_value` picks one seed of the seed pool
## (src/seed_pool.gd) for each slot, so the call does no search (Parent decision of 2026-11-22).
## The second slot of a size never gets the layout of the first slot of that size: on the same
## layout, it takes the next seed of its pool row. No two seeds of a pool row have the same layout,
## so the next seed has a different layout.
static func new_voyage(start_value: int) -> Array[int]:
	var prng := Prng.new(start_value)
	var seeds: Array[int] = []
	var first_layout := 0
	for number in range(1, LabyrinthPlan.FIXED_COUNT + 1):
		var row: Array = SeedPool.SEEDS[number - 1]
		var layouts: Array = SeedPool.LAYOUTS[number - 1]
		var index := prng.next() % row.size()
		if number % 2 == 1:
			first_layout = layouts[index]
		elif layouts[index] == first_layout:
			index = (index + 1) % row.size()
		seeds.append(row[index])
	return seeds


## The layout of `labyrinth`: the wall bits of each square row by row, then the Item IDs in
## placement order (the ID of an Item is its square). Two Labyrinths of one size with the same key
## look the same. tools/seed_search.gd keeps one seed for each layout of a slot.
static func layout_key(labyrinth: Labyrinth) -> String:
	var parts := PackedStringArray()
	for y in labyrinth.height:
		for x in labyrinth.width:
			parts.append(str(labyrinth.wall_bits(Vector2i(x, y))))
	for item in labyrinth.items:
		parts.append(item.id)
	return " ".join(parts)


## The first seed from `start_seed` upward that meets the conditions of slot `number` and is not
## `taken`, within `max_tries` seeds. Returns 0 when no seed of these meets them.
static func find_seed(number: int, start_seed: int, max_tries: int, taken: int = 0) -> int:
	var seed_value := Prng.nonzero_seed(start_seed)
	for i in max_tries:
		if seed_value != taken and meets_conditions(number, seed_value):
			return seed_value
		seed_value = Prng.nonzero_seed(seed_value + 1)
	return 0


## The tries that slot `number` needs from `start_seed`: 1 when the start seed meets the conditions.
## Returns 0 when no seed within `max_tries` meets them. tools/seed_search.gd measures the cost
## with it.
static func tries_from(number: int, start_seed: int, max_tries: int) -> int:
	var seed_value := Prng.nonzero_seed(start_seed)
	for i in max_tries:
		if meets_conditions(number, seed_value):
			return i + 1
		seed_value = Prng.nonzero_seed(seed_value + 1)
	return 0
