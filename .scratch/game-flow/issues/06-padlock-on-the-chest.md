# 06: Padlock on the chest

**What to build:** The chest has a padlock while at least one Item of the Labyrinth is not collected. A visit to the locked chest does nothing bad. The last Item pops the padlock off. Spec: [spec.md](../spec.md), Part 2. Prototype: [screens-PROTOTYPE](../prototypes/screens-PROTOTYPE/index.html).

**Blocked by:** 03 (Voyage), 04 (New crab and padlock art)

**Status:** ready-for-agent

- [ ] The padlock sprite `assets/sprites/goal/padlock.png` sits on the front of the chest while an Item is not collected.
- [ ] The move rule does not change. The boat still stops on the Goal square.
- [ ] Arrival at the locked chest: the chest shakes (offsets and time of the spec), a soft CC0 "locked" sound plays with the level rules of the other effects, and each empty Item slot pulses two times. No Goal celebration, no new Sea friend, no change to the progress, and no save.
- [ ] One press in the open direction of the Goal square takes the boat away.
- [ ] The last Item: when it arrives in its slot, the padlock grows to 1.3 times and fades out in 300 ms, with 6 sparkles, and an "unlock" sound plays. The chest sparkle starts only now.
- [ ] Arrival at the open chest starts the Goal celebration, as now.
- [ ] A load with all Items collected shows the open chest with its sparkle and no padlock.
- [ ] Main-scene test: the boat on the Goal square with an Item still uncollected gives no celebration, no new Sea friend, the same progress, and pulsing empty slots. After the last Item, a visit to the chest starts the celebration.
- [ ] The tests that send the boat to the Goal with Items left still pass: they collect all Items first, or they test the locked chest.
- [ ] `credits.txt` gets the lines of the new sounds.
- [ ] `GLOSSARY.md`: the **Item** entry no longer says that the Child does not need Items to finish a Labyrinth.
- [ ] The screenshot tool adds a shot of the locked chest during its shake, and a shot of the open chest after the padlock pops.
- [ ] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.
