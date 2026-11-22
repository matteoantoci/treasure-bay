# 06: Padlock on the chest

**What to build:** The chest has a padlock while at least one Item of the Labyrinth is not collected. A visit to the locked chest does nothing bad. The last Item pops the padlock off. Spec: [spec.md](../spec.md), Part 2. Prototype: [screens-PROTOTYPE](../prototypes/screens-PROTOTYPE/index.html).

**Blocked by:** 03 (Voyage), 04 (New crab and padlock art)

**Status:** resolved

- [x] The padlock sprite `assets/sprites/goal/padlock.png` sits on the front of the chest while an Item is not collected.
- [x] The move rule does not change. The boat still stops on the Goal square.
- [x] Arrival at the locked chest: the chest shakes (offsets and time of the spec), a soft CC0 "locked" sound plays with the level rules of the other effects, and each empty Item slot pulses two times. No Goal celebration, no new Sea friend, no change to the progress, and no save.
- [x] One press in the open direction of the Goal square takes the boat away.
- [x] The last Item: when it arrives in its slot, the padlock grows to 1.3 times and fades out in 300 ms, with 6 sparkles, and an "unlock" sound plays. The chest sparkle starts only now.
- [x] Arrival at the open chest starts the Goal celebration, as now.
- [x] A load with all Items collected shows the open chest with its sparkle and no padlock.
- [x] Main-scene test: the boat on the Goal square with an Item still uncollected gives no celebration, no new Sea friend, the same progress, and pulsing empty slots. After the last Item, a visit to the chest starts the celebration.
- [x] The tests that send the boat to the Goal with Items left still pass: they collect all Items first, or they test the locked chest.
- [x] `credits.txt` gets the lines of the new sounds.
- [x] `GLOSSARY.md`: the **Item** entry no longer says that the Child does not need Items to finish a Labyrinth.
- [x] The screenshot tool adds a shot of the locked chest during its shake, and a shot of the open chest after the padlock pops.
- [x] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.

Build note (gf/06-padlock-on-the-chest): `LabyrinthView` has the `Padlock` sprite after the chest, the `locked` flag, `shake_chest()` and `pop_padlock()`. The padlock is 36 % of a tile tall. Its centre is 0.19 tile right of and 0.14 tile below the chest centre, so its shackle hangs from the hasp of `chest_closed.png`. The spec gives no size and no place: a person must check them in `shots/motion-locked.png`. The shake tweens `chest_shake_px` (px of the 130 px tile) through 0, -10, 8, -6, 4, -2, 0, linear, 60 ms for each step, and the padlock moves with the chest. `ItemRow.pulse_empty()` gives each empty slot its own tween: the outline and its fill sprite go to 1.15 times in 300 ms and back in 300 ms (`inout`, the spec gives no curve), two times. When an Item arrives in a pulsing slot, the pulse stops and the bounce plays. `main.gd` emits `locked_chest_reached` at the locked arrival and `chest_unlocked` at the pop. `Sound` plays `locked.wav` and `unlock.wav` on them. The pop waits until no Item flies, so with two Items in flight it comes at the arrival of the last one. If the boat reaches the open chest before the pop, `open_chest()` removes the padlock at once. The 6 pop sparkles use the Item sparkle colours, 100 px/s and 500 ms, like the slot sparkles: the spec gives only the count. Sounds (Kenney, CC0): `locked.wav` is `impactWood_light_000` and `impactWood_light_003` of Impact Sounds, mixed 0.16 s apart, a soft "knock knock". `unlock.wav` is `metalLatch` of RPG Audio. Both have a silence pad to 0.6 s and 0.5 s, because ebur128 gives -70 LUFS for a file shorter than its 400 ms block. Measured: locked -24.4 LUFS, true peak -0.9 dBTP, level -0.1 dB. Unlock -20.2 LUFS, true peak 0.4 dBTP, level -1.4 dB. The true-peak limit sets both levels. A person must listen to both sounds. Tests: `tests/test_padlock.gd` (view, slot pulse, locked visit, unlock, load). `Scene.sail_to_goal()` now collects all Items first, with `Scene.first_press()`, a breadth-first search over the stops of the move rule. `Scene.sail_main_path_to_goal()` keeps the old main-path sail. `tools/smoke_run.gd` and `tools/take_motion_shots.gd` use `first_press()` too. The new shots: `motion-locked.png` (60 ms into the shake) and `motion-unlocked.png` (0.3 s after the unlock: the padlock is gone, the open chest with faint sparkles). The other motion shots are not in this commit.
