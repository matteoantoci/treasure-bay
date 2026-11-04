## The volume steps and the settings file (spec 11.2 and 12.4). Each test uses its own folder in
## the OS temp folder, never user://.
extends RefCounted

const Fixtures := preload("res://tests/fixtures.gd")
const WarningLog := preload("res://tests/warning_log.gd")


func test_no_file_gives_the_default_steps(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var settings := SettingsStore.new(dir).load_settings()
	t.assert_eq(settings.music_step, 2, "music step 2")
	t.assert_eq(settings.effects_step, 3, "effects step 3")
	t.assert_eq(DirAccess.get_files_at(dir), PackedStringArray(), "the load writes no file")
	Fixtures.remove_save_dir(dir)
	return true


func test_the_file_has_the_fields_of_spec_12_4(t) -> bool:
	var dir := Fixtures.new_save_dir()
	t.assert_eq(SettingsStore.new(dir).save(VolumeSettings.new()), OK, "save")
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(dir.path_join("settings.json")))
	t.assert_eq(data, {"version": 1.0, "music_step": 2.0, "effects_step": 3.0}, "settings.json")
	t.assert_true(not FileAccess.file_exists(dir.path_join("settings.json.tmp")), "the rename leaves no .tmp file")
	Fixtures.remove_save_dir(dir)
	return true


func test_a_save_and_a_load_give_the_same_steps(t) -> bool:
	var dir := Fixtures.new_save_dir()
	for steps in [[0, 4], [4, 0], [1, 2]]:
		var settings := VolumeSettings.new()
		settings.music_step = steps[0]
		settings.effects_step = steps[1]
		SettingsStore.new(dir).save(settings)
		var loaded := SettingsStore.new(dir).load_settings()
		t.assert_eq([loaded.music_step, loaded.effects_step], steps, "steps %s" % [steps])
	Fixtures.remove_save_dir(dir)
	return true


func test_a_broken_file_gives_the_default_steps(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var path := dir.path_join("settings.json")
	var cases := {
		"no JSON": "{\"version\": 1, ",
		"not a dictionary": "[1, 4, 0]",
		"no version": "{\"music_step\": 4, \"effects_step\": 0}",
		"no music step": "{\"version\": 1, \"effects_step\": 0}",
		"no effects step": "{\"version\": 1, \"music_step\": 4}",
		"a step as text": "{\"version\": 1, \"music_step\": \"4\", \"effects_step\": 0}",
		"a step with a fraction": "{\"version\": 1, \"music_step\": 4, \"effects_step\": 0.5}",
		"a step below 0": "{\"version\": 1, \"music_step\": 4, \"effects_step\": -1}",
		"a step above 4": "{\"version\": 1, \"music_step\": 5, \"effects_step\": 0}",
		"version 0": "{\"version\": 0, \"music_step\": 4, \"effects_step\": 0}",
		"version -1": "{\"version\": -1, \"music_step\": 4, \"effects_step\": 0}",
	}
	_write(path, "{\"version\": 1, \"music_step\": 4, \"effects_step\": 0}")
	var good := SettingsStore.new(dir).load_settings()
	t.assert_eq([good.music_step, good.effects_step], [4, 0], "the good file loads")
	for case_name in cases:
		_write(path, cases[case_name])
		var settings := SettingsStore.new(dir).load_settings()
		t.assert_eq([settings.music_step, settings.effects_step], [2, 3], "%s: the default steps" % case_name)
	Fixtures.remove_save_dir(dir)
	return true


## Test 12 of the play improvements: a settings file of a newer build gives the default steps in
## memory. It stays in place with the same bytes, and the store does not write it in this session.
func test_a_newer_file_gives_the_default_steps_and_stays(t) -> bool:
	var dir := Fixtures.new_save_dir()
	var path := dir.path_join("settings.json")
	var text := "{\"version\": 2, \"music_step\": 4, \"effects_step\": 0, \"voice_step\": 1}"
	_write(path, text)
	var store := SettingsStore.new(dir)
	var settings := store.load_settings()
	t.assert_eq([settings.music_step, settings.effects_step], [2, 3], "the default steps")
	var log := WarningLog.new()
	log.start()
	settings.music_step = 4
	store.save(settings)
	log.stop()
	t.assert_eq(log.warnings().size(), 1, "the save call logs one warning")
	t.assert_eq(FileAccess.get_file_as_string(path), text, "settings.json has the same bytes")
	t.assert_eq(DirAccess.get_files_at(dir), PackedStringArray(["settings.json"]), "no other file")
	Fixtures.remove_save_dir(dir)
	return true


func test_a_step_stays_between_0_and_4(t) -> bool:
	var settings := VolumeSettings.new()
	settings.set_step(Sound.MUSIC_BUS, 7)
	t.assert_eq(settings.music_step, 4, "music step at most 4")
	settings.set_step(Sound.EFFECTS_BUS, -2)
	t.assert_eq(settings.effects_step, 0, "effects step at least 0")
	t.assert_eq(settings.step_of(Sound.MUSIC_BUS), 4, "step_of music")
	t.assert_eq(settings.step_of(Sound.EFFECTS_BUS), 0, "step_of effects")
	return true


## The value of a step is step / 4, and the bus volume is value * value. Step 0 mutes the bus.
func test_each_step_sets_its_bus_volume(t) -> bool:
	Sound.add_buses()
	var linear := [0.0, 0.0625, 0.25, 0.5625, 1.0]
	var settings := VolumeSettings.new()
	for step in 5:
		settings.music_step = step
		settings.effects_step = 4 - step
		settings.apply()
		_check_bus(t, Sound.MUSIC_BUS, linear[step], "music step %d" % step)
		_check_bus(t, Sound.EFFECTS_BUS, linear[4 - step], "effects step %d" % (4 - step))
	VolumeSettings.new().apply()
	return true


func _check_bus(t, bus: StringName, linear: float, label: String) -> void:
	var index := AudioServer.get_bus_index(bus)
	t.assert_eq(AudioServer.is_bus_mute(index), linear == 0.0, "%s: mute" % label)
	if linear > 0.0:
		t.assert_true(is_equal_approx(AudioServer.get_bus_volume_linear(index), linear), "%s: volume %f, got %f" % [label, linear, AudioServer.get_bus_volume_linear(index)])


func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
