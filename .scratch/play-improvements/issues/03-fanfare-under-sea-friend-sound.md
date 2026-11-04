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

## Comments

Build note: `src/sound.gd` has `play_goal()` (kills the old duck, sets the Goal player to its table level, plays the fanfare) and `_duck_goal()` after each Sea friend sound (tween on the Goal player, level − 12 dB in 0.2 s). The tween is made by the Goal player, so it pauses with it. No value differs from the spec. Tests in `tests/test_sound.gd`: the duck, the restore at the next Goal, and the pause. Build spec 9.3 and 9.7 describe the duck. A person must listen at a Goal: the crab sound must be clear over the fanfare.
