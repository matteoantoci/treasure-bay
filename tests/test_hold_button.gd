## The hold buttons of spec 11.2 (reset and quit): each one acts only after its own hold time, and a
## ring fills in its own colour while it is held. The tests drive the time with HoldButton.advance(),
## a fake clock, so they do not wait.
extends RefCounted

const YELLOW := Color("#ffd447")
const ORANGE := Color("#ff7a59")


func test_a_hold_of_3_seconds_acts_one_time(t) -> bool:
	var button := await _add_button(t, 3.0, YELLOW)
	var actions := [0]
	button.held.connect(func() -> void: actions[0] += 1)
	button.button_down.emit()
	button.advance(1.5)
	t.assert_eq(button.ring, 0.5, "the ring is half full after 1.5 s")
	button.advance(1.25)
	t.assert_eq(actions[0], 0, "nothing happens after 2.75 s")
	button.advance(0.25)
	t.assert_eq(actions[0], 1, "the button acts after 3 s")
	button.advance(5.0)
	t.assert_eq(actions[0], 1, "one hold acts one time")
	button.button_up.emit()
	t.assert_eq(button.ring, 0.0, "the ring is empty after the release")
	button.queue_free()
	return true


func test_a_shorter_hold_empties_the_ring_and_does_nothing(t) -> bool:
	var button := await _add_button(t, 3.0, YELLOW)
	var actions := [0]
	button.held.connect(func() -> void: actions[0] += 1)
	button.button_down.emit()
	button.advance(2.75)
	t.assert_eq(button.ring, 2.75 / 3.0, "the ring fills while the button is held")
	button.button_up.emit()
	t.assert_eq(button.ring, 0.0, "the release empties the ring")
	t.assert_eq(actions[0], 0, "no action")
	# A new hold starts from 0 s.
	button.button_down.emit()
	button.advance(0.5)
	t.assert_eq(actions[0], 0, "no action 0.5 s into the next hold")
	t.assert_eq(button.ring, 0.5 / 3.0, "the next hold starts with an empty ring")
	button.button_up.emit()
	# The time goes on only while the button is down.
	button.advance(5.0)
	t.assert_eq(button.ring, 0.0, "no ring without a hold")
	t.assert_eq(actions[0], 0, "no action without a hold")
	button.queue_free()
	return true


## Two hold buttons with different values: each one keeps its own hold time and ring colour.
func test_each_hold_button_has_its_own_hold_time_and_ring_colour(t) -> bool:
	var long_button := await _add_button(t, 8.0, ORANGE)
	var short_button := await _add_button(t, 3.0, YELLOW)
	var actions := [0, 0]
	long_button.held.connect(func() -> void: actions[0] += 1)
	short_button.held.connect(func() -> void: actions[1] += 1)
	t.assert_eq(long_button.ring_full_colour, ORANGE, "the full ring of the 8 s button")
	t.assert_eq(short_button.ring_full_colour, YELLOW, "the full ring of the 3 s button")
	long_button.button_down.emit()
	short_button.button_down.emit()
	long_button.advance(3.0)
	short_button.advance(3.0)
	t.assert_eq(actions, [0, 1], "after 3 s only the 3 s button acts")
	t.assert_eq(long_button.ring, 3.0 / 8.0, "the ring of the 8 s button is 3/8 full after 3 s")
	long_button.advance(4.9)
	t.assert_eq(actions[0], 0, "the 8 s button does nothing after 7.9 s")
	long_button.advance(0.1)
	t.assert_eq(actions[0], 1, "the 8 s button acts after 8 s")
	long_button.queue_free()
	short_button.queue_free()
	return true


## The game frames drive the hold. The test uses a short hold time, so it does not wait long.
func test_the_frames_fill_the_ring(t) -> bool:
	var button := await _add_button(t, 0.2, YELLOW)
	button.button_down.emit()
	t.assert_true(await t.wait_for(button.held, 2.0), "the button acts after its hold time")
	button.queue_free()
	return true


func _add_button(t, hold_seconds: float, ring_full_colour: Color) -> HoldButton:
	var button := HoldButton.new(SettingsPicture.Kind.RESET, hold_seconds, ring_full_colour)
	t.root.add_child(button)
	await t.process_frame
	return button
