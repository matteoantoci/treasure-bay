## Acceptance criteria of spec 15 that no other test file checks: the game shows no words
## (criterion 2), only the arrow keys act in play (criterion 3), and the game has no network code
## (criterion 21).
extends RefCounted

const Scene := preload("res://tests/scene_helpers.gd")
## Keys that are not arrow keys, also with the Cmd and Ctrl modifiers.
const OTHER_KEYS := [KEY_ESCAPE, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_TAB, KEY_BACKSPACE, KEY_W,
	KEY_A, KEY_S, KEY_D, KEY_Q, KEY_F, KEY_1, KEY_F11, KEY_HOME, KEY_PAGEDOWN, KEY_KP_2, KEY_KP_8]
## Text in the source that would show words (spec 1 rule 1) or use the network (spec 1 rule 5).
const FORBIDDEN_SOURCE := ["draw_string", "draw_char", "draw_multiline_string", "HTTPRequest",
	"HTTPClient", "StreamPeerTCP", "StreamPeerTLS", "TCPServer", "PacketPeerUDP", "UDPServer",
	"WebSocket", "WebRTC", "ENetMultiplayerPeer", "MultiplayerPeer", "IP.resolve", "shell_open",
	"JavaScriptBridge", "DTLSServer"]


## Criterion 2 and spec 10: the only text is the total Item count number in the Collection strip,
## also with the settings panel open. No Control has a tooltip.
func test_the_only_text_is_the_total_item_count(t) -> bool:
	var dir := Scene.Fixtures.new_save_dir()
	var saved := Progress.new()
	saved.labyrinth_number = 7
	saved.collection = SeaFriends.IDS.slice(0, 6)
	saved.total_items = 23
	SaveStore.new(dir).save(saved)
	var main := await Scene.add_main(t, dir)
	var panel: SettingsPanel = main.get_node("Settings")
	panel.open()
	await t.process_frame
	var texts := []
	var tooltips := []
	for node in _all_nodes(main):
		var text: Variant = node.get("text")
		if text is String and not text.is_empty():
			texts.append(text)
		if node is Control and not node.tooltip_text.is_empty():
			tooltips.append(node.tooltip_text)
	t.assert_eq(texts, ["23"], "the only text is the total Item count")
	t.assert_eq(tooltips, [], "no tooltips")
	await Scene.remove(t, main)
	return true


## Criterion 3: keys other than the arrow keys do nothing in play. No button takes key focus, so no
## key presses a settings button.
func test_keys_other_than_the_arrow_keys_do_nothing(t) -> bool:
	var main := await Scene.add_main(t)
	t.assert_true(await t.wait_for(main.labyrinth_ready, Scene.MOVE_TIMEOUT), "the fade-in ends")
	var events := []
	for event_name in ["move_started", "bumped", "move_finished"]:
		main.connect(event_name, func() -> void: events.append(event_name))
	var boat: BoatView = main.get_node("Boat")
	var panel: SettingsPanel = main.get_node("Settings")
	var rotation := boat.rotation
	var mode := DisplayServer.window_get_mode()
	for key in OTHER_KEYS:
		for modifiers in [[], ["meta_pressed"], ["ctrl_pressed"], ["ctrl_pressed", "meta_pressed"]]:
			_send_key(key, modifiers)
	t.assert_true(not await t.wait_for(main.move_finished, Scene.NO_MOVE_SECONDS), "no move")
	t.assert_eq(events, [], "no move, no bump")
	t.assert_eq(main.boat_square, Vector2i(0, 0), "the boat stays on the start square")
	t.assert_eq(boat.rotation, rotation, "the boat does not turn")
	t.assert_true(not panel.is_open(), "the settings stay closed")
	t.assert_true(not t.paused, "play is not paused")
	t.assert_eq(DisplayServer.window_get_mode(), mode, "the window mode stays")
	for node in _all_nodes(main):
		if node is BaseButton:
			t.assert_eq(node.focus_mode, Control.FOCUS_NONE, "%s takes no key focus" % node.get_path())
	# A slide or a bump: both end with move_finished, so the check needs no Labyrinth shape.
	t.assert_true(await Scene.press(t, main, KEY_DOWN), "an arrow key still acts")
	await Scene.remove(t, main)
	return true


## Criterion 21 and spec 1 rules 1 and 5: no game script or scene uses the network or draws text.
func test_the_game_has_no_network_code_and_draws_no_text(t) -> bool:
	var files := ["res://main.tscn", "res://project.godot"]
	for file_name in DirAccess.get_files_at("res://src"):
		if file_name.ends_with(".gd") or file_name.ends_with(".gdshader"):
			files.append("res://src/" + file_name)
	t.assert_true(files.size() > 30, "the source files are found")
	for path: String in files:
		var text := FileAccess.get_file_as_string(path)
		t.assert_true(not text.is_empty(), path + " is read")
		for word: String in FORBIDDEN_SOURCE:
			t.assert_true(not text.contains(word), "%s has no %s" % [path, word])
	return true


## Presses and releases `key` with the modifier properties in `modifiers`.
func _send_key(key: Key, modifiers: Array) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.keycode = key
		event.pressed = pressed
		for modifier: String in modifiers:
			event.set(modifier, true)
		Input.parse_input_event(event)
	Input.flush_buffered_events()


func _all_nodes(root: Node) -> Array[Node]:
	var nodes: Array[Node] = [root]
	for child in root.get_children(true):
		nodes.append_array(_all_nodes(child))
	return nodes
