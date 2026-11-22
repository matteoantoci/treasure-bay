## What Labyrinth n is: its size, its seed, and its Item count (spec 4.3 and 4.4).
class_name LabyrinthPlan
extends RefCounted

## A Voyage has 20 Labyrinths. Labyrinth n uses the seed of slot n of the Voyage.
const FIXED_COUNT := 20
## The fixed seed table: one seed for each slot, by measured difficulty (play-improvements spec
## Part 3). The tool tools/seed_search.gd selects them and prints this table. The save migration
## gives it to a version 1 save in Labyrinths 1 to 20, a save of a newer build plays it in memory, and
## the tests use it.
const FIXED_SEEDS: Array[int] = [1, 17, 2, 9, 85, 10, 12, 9, 8, 23, 1, 69, 29, 73, 9, 28, 73, 127, 167, 30]
## Sizes in squares of Labyrinths 1 and 2, 3 and 4, and so on to 19 and 20.
const FIXED_SIZES: Array[Vector2i] = [
	Vector2i(4, 3), Vector2i(5, 3), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4),
	Vector2i(7, 5), Vector2i(8, 5), Vector2i(8, 6), Vector2i(9, 6), Vector2i(9, 7),
]
## Each Labyrinth has 2 to 8 Items.
const MIN_ITEMS := 2
const MAX_ITEMS := 8


static func size_for(number: int) -> Vector2i:
	return FIXED_SIZES[(number - 1) / 2]


## Item count: clamp(floor(W * H / 6), 2, 8) (spec 4.3).
static func item_count(number: int) -> int:
	var size := size_for(number)
	return clampi(size.x * size.y / 6, MIN_ITEMS, MAX_ITEMS)


## Generates Labyrinth `number` (1 to 20) with its Items from the seed of slot `number` of `seeds`.
static func build(number: int, seeds: Array[int] = FIXED_SEEDS) -> Labyrinth:
	return build_from_seed(number, seeds[number - 1])


## Generates Labyrinth `number` with its Items from `seed_value`. The W x H Labyrinth of the seed
## must have a free dead end (spec 4.6 rule 7). tools/seed_search.gd tries seeds with it.
static func build_from_seed(number: int, seed_value: int) -> Labyrinth:
	var size := size_for(number)
	var prng := Prng.new(seed_value)
	var labyrinth := LabyrinthGenerator.generate(size.x, size.y, prng)
	labyrinth.seed_value = seed_value
	var kinds := Area.item_kinds(Area.for_labyrinth(number))
	labyrinth.items = ItemPlacement.place(labyrinth, prng, item_count(number), kinds)
	return labyrinth
