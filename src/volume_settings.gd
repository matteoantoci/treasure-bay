## The volume steps of the settings (spec 11.2): each bus has 5 steps, 0 to 4. The value of a step
## is step / 4. The bus volume is value * value, and step 0 mutes the bus.
class_name VolumeSettings
extends RefCounted

const MAX_STEP := 4
const DEFAULT_MUSIC_STEP := 2
const DEFAULT_EFFECTS_STEP := 3

var music_step := DEFAULT_MUSIC_STEP
var effects_step := DEFAULT_EFFECTS_STEP


## The step of the `Music` or the `Effects` bus.
func step_of(bus: StringName) -> int:
	return music_step if bus == Sound.MUSIC_BUS else effects_step


## Sets the step of a bus. A step below 0 becomes 0, and a step above 4 becomes 4.
func set_step(bus: StringName, step: int) -> void:
	step = clampi(step, 0, MAX_STEP)
	if bus == Sound.MUSIC_BUS:
		music_step = step
	else:
		effects_step = step


## Sets the volume of the `Music` and the `Effects` bus. At step 0 the bus is muted, because
## linear_to_db(0) is -inf. Call Sound.add_buses() first.
func apply() -> void:
	for bus in [Sound.MUSIC_BUS, Sound.EFFECTS_BUS]:
		var index := AudioServer.get_bus_index(bus)
		var step := step_of(bus)
		AudioServer.set_bus_mute(index, step == 0)
		if step > 0:
			var value := float(step) / MAX_STEP
			AudioServer.set_bus_volume_linear(index, value * value)
