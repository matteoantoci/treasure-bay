# Gaps before the spec

Type: decision
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

The spec needs 7 decisions from the Parent. No source file decides them. The full audit is in [research/gap-audit.md](../research/gap-audit.md).

Recommendation:
1. **Items for Areas 2 to 4:** only the Area 1 Items exist. Do not use Tropical fish, because it looks like the Fish Sea friend. Use Coral and a sand dollar in Area 2, Gem stone and Spiral shell in Area 3, and Glowing star and Star in Area 4. The agent makes them with the Grok method on your xAI subscription.
2. **Area colours:** use the water colours from the motion prototype. The islands keep the same colours in all Areas.
3. **Area decoration:** make the old ideas with water effects. Area 1 has waves, Area 2 has rising bubbles, Area 3 has droplets, and Area 4 has small stars that twinkle.
4. **Collection:** the strip at the bottom of the play screen is the Collection. The total count of Items shows as a number at the left end of the strip. The game has no separate Collection screen.
5. **Goal island:** only the Goal island has a palm. The wall islands have rocks and bushes.
6. **Sound downloads:** Freesound needs an account. You log in one time in your own Chrome. Then the agent downloads the 22 files through it.
7. **Keys that the test cannot block:** accept Cmd+Tab, Cmd+H, Cmd+M, and Cmd+Option+Esc. If Ctrl+Cmd+F leaves fullscreen, the game goes back to fullscreen. The game also blocks a macOS logout, so quit with the door button before you log out.

Gaps 8 to 41 use the recommended defaults in research/gap-audit.md. The conflicts use the listed winner. The spec writer fixes the stale text.

## Decision (2026-11-04)

- Q1, Q2, Q3, Q4, Q7: the Parent accepted the recommendation.
- Q5: the Goal island has a palm and a treasure chest. The Kenney Pirate Pack has no chest (checked: `PNG/Default size/` has Effects, Ship parts, Ships, Tiles only). The build generates a closed chest and an open chest with the Grok method in ticket 13, the same as the Items. The chest opens at the start of the Goal celebration. The wall islands get rocks and bushes, no palm.
- Q6: no login and no Parent action.
  - Effects and Sea friend sounds: the build uses the Freesound `-hq.mp3` preview files (about 128 kbps). They download with no login. Openverse returns the same preview URLs for Freesound sounds (checked with `api.openverse.org/v1/audio/?source=freesound`). The licences (CC0, CC BY) cover the preview files too. For clips of 2.5 s or less in a laptop game, the quality difference is not audible.
  - Music: the 4 Pixabay MP3 files download with no login (round 3 downloaded all 6 candidates from Pixabay's file server, HTTP 200).
  - Music generation (the HyperFrames `media-use` skill: HeyGen catalog or local MusicGen) is not necessary, because the Parent chose 4 tracks.
- Gaps 8 to 41: the recommended defaults in `research/gap-audit.md`.
