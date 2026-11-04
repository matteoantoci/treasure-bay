## What Labyrinth n is: its size, its seed, and its Item count (spec 4.3 and 4.4).
class_name LabyrinthPlan
extends RefCounted

## Labyrinths 1 to 20 are fixed. Labyrinth n uses seed n.
const FIXED_COUNT := 20
## Sizes in squares of Labyrinths 1 and 2, 3 and 4, and so on to 19 and 20.
const FIXED_SIZES: Array[Vector2i] = [
	Vector2i(4, 3), Vector2i(5, 3), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4),
	Vector2i(7, 5), Vector2i(8, 5), Vector2i(8, 6), Vector2i(9, 6), Vector2i(9, 7),
]
## From Labyrinth 21, each Labyrinth is random at this size.
const RANDOM_SIZE := Vector2i(10, 7)
## Each Labyrinth has 2 to 8 Items.
const MIN_ITEMS := 2
const MAX_ITEMS := 8


static func is_random(number: int) -> bool:
	return number > FIXED_COUNT


static func size_for(number: int) -> Vector2i:
	if is_random(number):
		return RANDOM_SIZE
	return FIXED_SIZES[(number - 1) / 2]


## Item count: clamp(floor(W * H / 6), 2, 8) (spec 4.3).
static func item_count(number: int) -> int:
	var size := size_for(number)
	return clampi(size.x * size.y / 6, MIN_ITEMS, MAX_ITEMS)


## A new seed for a random Labyrinth: randi(), and 0 becomes 1. Call randomize() one time at startup.
static func new_random_seed() -> int:
	return Prng.nonzero_seed(randi())


## The first seed from `seed_value` on whose W x H Labyrinth has a dead end that is not the start
## or the Goal (spec 4.6 rule 7). Each step adds 1 to the seed. A seed of 0 becomes 1.
static func valid_seed(size: Vector2i, seed_value: int) -> int:
	seed_value = Prng.nonzero_seed(seed_value)
	while not ItemPlacement.has_free_dead_end(LabyrinthGenerator.generate(size.x, size.y, Prng.new(seed_value))):
		seed_value = Prng.nonzero_seed(seed_value + 1)
	return seed_value


## Generates Labyrinth `number` with its Items. Labyrinth n (1 to 20) uses seed n: all 20 are valid
## (tests/test_items.gd). A random Labyrinth uses the first valid seed from `random_seed` on.
static func build(number: int, random_seed: int = 0) -> Labyrinth:
	var size := size_for(number)
	var seed_value := valid_seed(size, random_seed) if is_random(number) else number
	var prng := Prng.new(seed_value)
	var labyrinth := LabyrinthGenerator.generate(size.x, size.y, prng)
	labyrinth.seed_value = seed_value
	var kinds := Area.item_kinds(Area.for_labyrinth(number))
	labyrinth.items = ItemPlacement.place(labyrinth, prng, item_count(number), kinds)
	return labyrinth
