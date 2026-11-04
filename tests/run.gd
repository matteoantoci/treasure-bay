## Headless test runner (spec section 14.1).
##
## Run from the repository root:
##   godot --headless --path . --import
##   godot --headless --path . --script res://tests/run.gd
## The runner prints "Results: N passed, M failed" and exits with code 1 if a check failed, else 0.
##
## Test file shape. Add new files; do not edit this runner to add tests.
## - The runner runs every file tests/test_*.gd, in file name order.
## - A test file extends RefCounted and has no class_name.
## - A test is a method whose name starts with "test_". It takes one argument `t`, this runner.
##   It returns `true` at its end. The runner counts any other return value as a failure, also
##   the value of a test that stopped on a script error.
## - Check values with `t.assert_eq(actual, expected, label)` or `t.assert_true(condition, label)`.
##   assert_eq passes only when both values have the same Variant type and are equal, so 7 and
##   7.0, or Vector2 and Vector2i, are different. Never use bare assert(): a failed assert() stops
##   the runner before it quits.
## - A test may `await`. `t` is the SceneTree, so `t.root` and `await t.process_frame` work.
##   To wait for a signal, use `await t.wait_for(signal, timeout_seconds)`. It returns false
##   when the timeout comes first, so a test never hangs.
## - Helpers that several test files share go in tests/ files whose names do not start with
##   "test_", for example tests/fixtures.gd.
##
## Example, tests/test_example.gd:
##   extends RefCounted
##
##   func test_seed_0_gives_the_outputs_of_seed_1(t) -> bool:
##       t.assert_eq(Prng.new(0).next(), Prng.new(1).next(), "first output")
##       return true
extends SceneTree

const TESTS_DIR := "res://tests/"

var passed := 0
var failed := 0


func _initialize() -> void:
	# The root is not in the tree during _initialize(). Wait one frame, so tests can add nodes.
	await process_frame
	for file_name in _test_file_names():
		await _run_file(TESTS_DIR + file_name)
	print("Results: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)


func assert_eq(actual: Variant, expected: Variant, label: String) -> void:
	if typeof(actual) == typeof(expected) and actual == expected:
		passed += 1
	else:
		failed += 1
		push_error("FAIL %s: expected %s, got %s" % [label, var_to_str(expected), var_to_str(actual)])


func assert_true(condition: bool, label: String) -> void:
	assert_eq(condition, true, label)


## Waits until `sig` fires or `timeout_seconds` pass. Returns true if the signal fired.
func wait_for(sig: Signal, timeout_seconds: float) -> bool:
	var fired := [false]
	var on_signal := func(...args: Array) -> void: fired[0] = true
	sig.connect(on_signal, CONNECT_ONE_SHOT)
	var timer := create_timer(timeout_seconds)
	while not fired[0] and timer.time_left > 0.0:
		await process_frame
	if sig.is_connected(on_signal):
		sig.disconnect(on_signal)
	return fired[0]


func _test_file_names() -> PackedStringArray:
	var names := PackedStringArray()
	for file_name in DirAccess.get_files_at(TESTS_DIR):
		if file_name.begins_with("test_") and file_name.ends_with(".gd"):
			names.append(file_name)
	names.sort()
	return names


func _run_file(path: String) -> void:
	var script := load(path) as GDScript
	if script == null or not script.can_instantiate():
		failed += 1
		push_error("FAIL %s: the script does not load" % path)
		return
	var suite: Object = script.new()
	for method in script.get_script_method_list():
		var test_name: String = method["name"]
		if not test_name.begins_with("test_"):
			continue
		var result: Variant = await suite.call(test_name, self)
		if not (result is bool and result == true):
			failed += 1
			push_error("FAIL %s:%s did not return true (script error?)" % [path, test_name])
