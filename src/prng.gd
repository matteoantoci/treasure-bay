## The own xorshift32 PRNG of spec 4.1. Labyrinth generation uses only this PRNG.
class_name Prng
extends RefCounted

const MASK := 0xFFFFFFFF

var _state: int


func _init(seed_value: int) -> void:
	_state = nonzero_seed(seed_value)


## The low 32 bits of `seed_value`, and seed 0 becomes seed 1, because xorshift32 stays at 0.
static func nonzero_seed(seed_value: int) -> int:
	seed_value &= MASK
	return seed_value if seed_value != 0 else 1


## Returns the next output, from 1 to 2^32 - 1.
func next() -> int:
	var x := _state
	x ^= (x << 13) & MASK
	x ^= x >> 17
	x ^= (x << 5) & MASK
	_state = x
	return x
