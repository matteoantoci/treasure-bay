## Seed search of play-improvements spec Part 3 and game-flow spec Part 1. The conditions of each
## slot are in DifficultyCurve (src/difficulty_curve.gd), which the game also uses.
##
## Mode 1, the fixed seed table: for Labyrinth n, it takes the first seed from 1 upward that meets
## DifficultyCurve.meets_conditions(). The two Labyrinths of one size are Labyrinths 2i - 1 and 2i
## (spec 4.3), and Labyrinth 2i does not take the seed of Labyrinth 2i - 1. To tune the difficulty
## curve, change DifficultyCurve, run the tool, and copy the printed table into
## LabyrinthPlan.FIXED_SEEDS (src/labyrinth_plan.gd). Then update tests/spec_port.py and the pins of
## the tests that it gives.
##
## Mode 2, the cost (--cost): for each slot, the tries from COST_STARTS random start seeds (largest
## and median), the count of different valid seeds and Labyrinths that the two 4 x 3 slots find,
## and the time of one new Voyage.
##
## Mode 3, the seed pool (--pool): for each slot, the first POOL_SIZE seeds from 1 upward that meet
## DifficultyCurve.meets_conditions(). It writes them to src/seed_pool.gd, the const table that
## DifficultyCurve.new_voyage() picks from. Run it again after each change of the curve.
##
## Run from the repository root:
##   godot --headless --path . --script res://tools/seed_search.gd
##   godot --headless --path . --script res://tools/seed_search.gd -- --cost
##   godot --headless --path . --script res://tools/seed_search.gd -- --cost --slot 7
##   godot --headless --path . --script res://tools/seed_search.gd -- --cost --voyage-time
##   godot --headless --path . --script res://tools/seed_search.gd -- --pool
## With --slot n, the cost mode measures only slot n, so several runs can share the work. With
## --voyage-time, it gives only the time of one new Voyage.
## Mode 1 prints one table row for each Labyrinth, then the seed table, and exits with code 0. If no
## seed up to MAX_SEED meets the conditions, it prints "SEED SEARCH FAIL ..." and exits with code 1.
extends SceneTree

const MAX_SEED := 1000000
const COST_STARTS := 1000
## The seed of the random start seeds and start values of the cost mode. These come from
## RandomNumberGenerator and not from the own PRNG: new_voyage() uses the own PRNG, so start values
## from one own PRNG chain give Voyages with shifted seeds.
const COST_RNG_SEED := 20261122
## The new Voyages that the cost mode times.
const TIMED_VOYAGES := 1000
## The seeds of each slot in the seed pool.
const POOL_SIZE := 100
const POOL_PATH := "res://src/seed_pool.gd"


func _initialize() -> void:
	if OS.get_cmdline_user_args().has("--pool"):
		quit(_write_pool())
	elif OS.get_cmdline_user_args().has("--cost"):
		_print_cost()
		quit(0)
	else:
		quit(_print_fixed_table())


func _print_fixed_table() -> int:
	var seeds: Array[int] = []
	print("| n | size | seed | presses | decisions | Item IDs in placement order |")
	print("|---|---|---|---|---|---|")
	for number in range(1, LabyrinthPlan.FIXED_COUNT + 1):
		var taken: int = seeds[-1] if number % 2 == 0 else 0
		var seed_value := DifficultyCurve.find_seed(number, 1, MAX_SEED, taken)
		if seed_value == 0:
			print("SEED SEARCH FAIL: no seed up to %d for Labyrinth %d" % [MAX_SEED, number])
			return 1
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
	return 0


func _print_cost() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = COST_RNG_SEED
	var starts: Array[int] = []
	for i in COST_STARTS:
		starts.append(rng.randi())
	var args := OS.get_cmdline_user_args()
	var slots := range(1, LabyrinthPlan.FIXED_COUNT + 1)
	var slot_at := args.find("--slot")
	if slot_at >= 0:
		slots = [args[slot_at + 1].to_int()]
	elif args.has("--voyage-time"):
		slots = []
	var largest_all := 0
	if not slots.is_empty():
		print("| n | largest tries | median tries |")
		print("|---|---|---|")
	for number in slots:
		var tries: Array[int] = []
		for start in starts:
			var count := DifficultyCurve.tries_from(number, start, MAX_SEED)
			if count == 0:
				print("COST FAIL: no seed within %d tries for Labyrinth %d" % [MAX_SEED, number])
				return
			tries.append(count)
		tries.sort()
		largest_all = maxi(largest_all, tries[-1])
		print("| %d | %d | %d |" % [number, tries[-1], tries[tries.size() / 2]])
	if not slots.is_empty():
		print("largest tries of the measured slots: %d" % largest_all)
	for number in [1, 2]:
		if not slots.has(number):
			continue
		var valid := {}
		var layouts := {}
		for start in starts:
			var seed_value := DifficultyCurve.find_seed(number, start, MAX_SEED)
			valid[seed_value] = true
			layouts[_layout_key(LabyrinthPlan.build_from_seed(number, seed_value))] = true
		print("4 x 3 slot %d: %d different valid seeds, %d different Labyrinths (walls and Items)" % [number, valid.size(), layouts.size()])
	if slot_at >= 0:
		return
	var slowest := 0
	var total := 0
	for i in TIMED_VOYAGES:
		var before := Time.get_ticks_usec()
		DifficultyCurve.new_voyage(rng.randi())
		var used := Time.get_ticks_usec() - before
		slowest = maxi(slowest, used)
		total += used
	print("new Voyage: mean %.3f ms, slowest %.3f ms of %d" % [total / 1000.0 / TIMED_VOYAGES, slowest / 1000.0, TIMED_VOYAGES])


## The walls and the Item IDs of `labyrinth`: two seeds with the same key give the same Labyrinth.
func _layout_key(labyrinth: Labyrinth) -> String:
	var parts := PackedStringArray()
	for y in labyrinth.height:
		for x in labyrinth.width:
			parts.append(str(labyrinth.wall_bits(Vector2i(x, y))))
	for item in labyrinth.items:
		parts.append(item.id)
	return " ".join(parts)


## Writes the seed pool to POOL_PATH. Returns the exit code.
func _write_pool() -> int:
	var lines := PackedStringArray([
		"## The seed pool of a Voyage (game-flow spec Part 1, Parent decision of 2026-11-22). Row n - 1",
		"## holds %d seeds of slot n, the first seeds from 1 upward that meet" % POOL_SIZE,
		"## DifficultyCurve.meets_conditions(). tools/seed_search.gd -- --pool writes this file. Do not edit",
		"## it by hand.",
		"class_name SeedPool",
		"extends RefCounted",
		"",
		"const SEEDS := [",
	])
	for number in range(1, LabyrinthPlan.FIXED_COUNT + 1):
		var seeds := PackedStringArray()
		var seed_value := 1
		while seeds.size() < POOL_SIZE:
			if seed_value > MAX_SEED:
				print("SEED POOL FAIL: fewer than %d seeds up to %d for Labyrinth %d" % [POOL_SIZE, MAX_SEED, number])
				return 1
			if DifficultyCurve.meets_conditions(number, seed_value):
				seeds.append(str(seed_value))
			seed_value += 1
		lines.append("\t[%s]," % ", ".join(seeds))
		print("slot %d: %d seeds up to %d" % [number, POOL_SIZE, seed_value - 1])
	lines.append("]")
	var file := FileAccess.open(POOL_PATH, FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	return 0
