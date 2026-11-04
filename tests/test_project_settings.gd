## Spec 14.1 test 11: the project settings of spec 3.4, and the move actions of spec 5.1.
extends RefCounted


func test_settings_of_spec_3_4(t) -> bool:
	var expected := {
		"application/config/name": "Labyrinth",
		"application/run/main_scene": "res://main.tscn",
		"display/window/size/viewport_width": 1920,
		"display/window/size/viewport_height": 1200,
		"display/window/size/mode": 4,
		"display/window/stretch/mode": "canvas_items",
		"display/window/stretch/aspect": "expand",
	}
	for key in expected:
		t.assert_eq(ProjectSettings.get_setting(key), expected[key], key)
	t.assert_eq(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, 4, "mode 4 is exclusive fullscreen")
	return true


func test_move_actions_use_only_the_arrow_keys(t) -> bool:
	var expected := {
		"move_up": KEY_UP,
		"move_down": KEY_DOWN,
		"move_left": KEY_LEFT,
		"move_right": KEY_RIGHT,
	}
	for action in expected:
		t.assert_true(InputMap.has_action(action), action + " exists")
		var keys := []
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				keys.append([event.physical_keycode, event.keycode])
			else:
				keys.append(event.get_class())
		t.assert_eq(keys, [[expected[action], KEY_NONE]], action + " is bound to one physical arrow key")
	return true


func test_esc_fires_no_move_action(t) -> bool:
	var esc := InputEventKey.new()
	esc.physical_keycode = KEY_ESCAPE
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	for action in ["move_up", "move_down", "move_left", "move_right"]:
		t.assert_true(not InputMap.event_is_action(esc, action), "Esc is not " + action)
	return true
