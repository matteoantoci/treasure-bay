## Spec 14.1 test 1: the xorshift32 PRNG of spec 4.1.
extends RefCounted

# The first 5 xorshift32 (13, 17, 5) outputs for seed 1, from an independent Python run of spec 4.1.
const SEED_1_OUTPUTS := [270369, 67634689, 2647435461, 307599695, 2398689233]


func test_first_5_outputs_for_seed_1_are_pinned(t) -> bool:
	t.assert_eq(_outputs(1, 5), SEED_1_OUTPUTS, "first 5 outputs for seed 1")
	return true


func test_seed_0_gives_the_outputs_of_seed_1(t) -> bool:
	t.assert_eq(_outputs(0, 5), SEED_1_OUTPUTS, "first 5 outputs for seed 0")
	return true


func test_same_seed_gives_same_outputs(t) -> bool:
	t.assert_eq(_outputs(123456789, 50), _outputs(123456789, 50), "50 outputs for seed 123456789")
	return true


func test_outputs_are_from_1_to_2_pow_32_minus_1(t) -> bool:
	var in_range := true
	for seed_value in [1, 2, 0xFFFFFFFF, 0x80000000, 987654321]:
		var prng := Prng.new(seed_value)
		for i in 10000:
			var x := prng.next()
			if x < 1 or x > 0xFFFFFFFF:
				in_range = false
	t.assert_true(in_range, "all outputs from 1 to 2^32 - 1")
	return true


func _outputs(seed_value: int, count: int) -> Array:
	var prng := Prng.new(seed_value)
	var outputs := []
	for i in count:
		outputs.append(prng.next())
	return outputs
