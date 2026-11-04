## The hold buttons of spec 11.2 (reset and quit): they act only after a hold of 3 s, and a ring
## fills while they are held. The tests drive the time with HoldButton.advance(), a fake clock, so
## they do not wait 3 s.
extends RefCounted


func test_a_hold_of_3_seconds_acts_one_time(t) -> bool:
	var button := await _add_button(t)
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
	var button := await _add_button(t)
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


## The game frames drive the hold. The test uses a short hold time, so it does not wait 3 s.
func test_the_frames_fill_the_ring(t) -> bool:
	var button := await _add_button(t)
	t.assert_eq(button.hold_seconds, 3.0, "the hold takes 3 s")
	button.hold_seconds = 0.2
	button.button_down.emit()
	t.assert_true(await t.wait_for(button.held, 2.0), "the button acts after its hold time")
	button.queue_free()
	return true


func _add_button(t) -> HoldButton:
	var button := HoldButton.new()
	t.root.add_child(button)
	await t.process_frame
	return button
