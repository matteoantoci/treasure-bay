# 22: Labyrinths, Items, and rewards

**What to build:** The Child plays through the 20 fixed Labyrinths, then random ones. Items fill the outline row. At each Goal a Sea friend joins the Collection strip. After Labyrinth 20, a random Sea friend comes back. Spec sections 4.3, 4.4, 4.6, 4.7, 6.

**Blocked by:** 20 (Skeleton: sail one Labyrinth to the Goal)

**Status:** ready-for-agent

- [ ] Labyrinths 1 to 20 have the sizes and seeds of spec 4.3, and later ones are 10 × 7 random Labyrinths.
- [ ] Items sit on the squares of spec 4.6. Each Item fills one outline and counts only one time.
- [ ] At the Goal of Labyrinths 1 to 20, the Sea friend of spec 4.7 joins the Collection strip.
- [ ] After Labyrinth 20, a random Sea friend comes back, never the same one two times in a row (spec 6.4).
- [ ] Headless tests for sizes, seeds, Item placement, and the Sea friend order pass.
