# 03: Fanfare under the Sea friend sound

**What to build:** The Child hears the sound of each Sea friend clearly at the Goal. When the Sea friend appears, the fanfare goes down so that the Sea friend sound is louder than the fanfare. Spec: [spec.md](../spec.md), Part 4.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] At `sea_friend_appeared`, the volume of the Goal player goes from its level to its level − 12 dB in 0.2 s.
- [ ] At each `goal_reached`, the game kills an old duck tween, sets the Goal player to its level from the sound-levels table, and then plays the fanfare.
- [ ] The duck tween pauses with the game, like the Goal player.
- [ ] A reset during the celebration gives the full fanfare level at the next Goal.
- [ ] The sound-levels table, the bus volumes and the music do not change.
- [ ] The labyrinth-game build spec sections 9.3 and 9.7 describe the duck.
- [ ] The full test suite passes.
