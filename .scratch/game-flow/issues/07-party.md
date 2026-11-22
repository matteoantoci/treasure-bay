# 07: Party

**What to build:** The end screen of a Voyage. After the Goal celebration of Labyrinth 20, all 20 Sea friends make a ring around the open chest, do a wave, and confetti falls. A key press goes back to the opening screen. Spec: [spec.md](../spec.md), Part 4. Prototype: [screens-PROTOTYPE](../prototypes/screens-PROTOTYPE/index.html), round 1, variant B "Friends on board".

**Blocked by:** 03 (Voyage), 05 (Name and opening screen)

**Status:** ready-for-agent

- [ ] After the flamingo arrives in its slot, the screen fades to the Party.
- [ ] Picture: the still water of Area 1, an island with the island rules (as on the opening screen), the open chest on it, and the boat below the island with its bow up.
- [ ] Timeline of the spec: the 20 Sea friends pop in every 120 ms on an ellipse in Labyrinth order, each with its sound; at 0.4 s the chest opens with the Goal sound, confetti, and 8 Items that fly out; at 3.0 s the star with the number 20 in the rounded font; from 3.0 s the wave loops; from 2.0 s a small confetti burst every 1.5 s.
- [ ] The Party loops until a key press.
- [ ] Input is locked for the first 3.0 s. After that, an arrow key, Space or Enter fades to the opening screen.
- [ ] A launch after a Party shows the opening screen and Labyrinth 1. The Party does not play again.
- [ ] The settings gear works on the Party.
- [ ] Main-scene test: the Goal of Labyrinth 20 makes the flamingo join the strip, the Party shows, presses in the first 3 s do nothing, a press after that shows the opening screen, and the next start shows Labyrinth 1 with an empty strip and the same total count.
- [ ] The screenshot tool adds a shot of the Party at about 4 s.
- [ ] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.
