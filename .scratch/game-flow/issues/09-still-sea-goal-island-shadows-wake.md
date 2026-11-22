# 09: Still sea, Goal island, shadows and wake

**What to build:** A still background with a soft foam edge, a larger chest on its own 2-tile island with a palm, static shadows under the boat and the Items, and a soft foam wake. Spec: [spec.md](../spec.md), Part 5, fixes 2, 4, 8 (shadows and light) and 9. Mockup: [polish-MOCKUP](../prototypes/polish-MOCKUP/index.html).

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Water: the light patterns go away. The wave lines stay but do not move. Nothing in the background moves.
- [ ] Foam: a still soft edge along each coast (a white line of 6 px at 35 % with soft edges, under the islands) replaces the moving dashed foam. It uses the coast lines that the game already computes.
- [ ] The islands keep all their Kenney details: sand, grass dots, rocks and bushes.
- [ ] Goal island: the tile right of the Goal island tile, outside the Labyrinth, becomes island too. The Goal island is 2 tiles wide, with a sand coast all around, and no rock and no bush on these 2 tiles.
- [ ] The chest sits on the seam of the 2 tiles, 115 % of a tile wide, fully on land. The palm sits on the outer tile, up and to the right of the chest, inside the coast.
- [ ] Shadows: the boat and each Item on the water get a static ellipse shadow (80 % of the sprite wide, 22 % high, black at 20 %, 28 % of the sprite below its centre and a little to the right). The boat shadow moves with the boat. No shadow in the Item column or in the strip.
- [ ] Wake: soft white dots behind the stern replace the ellipse rings (radius from 9 % of a tile, smaller and fainter with age, start opacity 42 %, life 0.6 s, a new dot every 40 ms while the boat moves). The dots stay under the islands.
- [ ] Tests check what the Child can see: for example no moving water parameter, the chest fully on land in all 20 Labyrinths, and the wake dots under the islands.
- [ ] The play shots of all 4 Areas are taken again.
- [ ] The build spec (`.scratch/labyrinth-game/spec.md`) gets errata for each section that this ticket changes.
