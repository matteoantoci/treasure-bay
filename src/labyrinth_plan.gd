## What Labyrinth n is: its size and its seed (spec 4.3 and 4.4).
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


static func is_random(number: int) -> bool:
	return number > FIXED_COUNT


static func size_for(number: int) -> Vector2i:
	if is_random(number):
		return RANDOM_SIZE
	return FIXED_SIZES[(number - 1) / 2]


## The seed of Labyrinth `number`. A random Labyrinth uses `random_seed`.
static func seed_for(number: int, random_seed: int = 0) -> int:
	return random_seed if is_random(number) else number


## A new seed for a random Labyrinth: randi(), and 0 becomes 1. Call randomize() one time at startup.
static func new_random_seed() -> int:
	var seed_value := randi()
	return seed_value if seed_value != 0 else 1


## Generates Labyrinth `number`. A random Labyrinth uses `random_seed`.
static func build(number: int, random_seed: int = 0) -> Labyrinth:
	var size := size_for(number)
	return LabyrinthGenerator.generate(size.x, size.y, Prng.new(seed_for(number, random_seed)))
