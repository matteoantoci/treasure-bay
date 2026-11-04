# 21: Sprites

**What to build:** All art files that the game needs exist in the project, ready for import. Spec sections 7.3, 13.1, 13.2.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] The repo sprites and Kenney tiles are in the project (spec 13.1).
- [x] The 7 new sprites (5 Items, closed chest, open chest) exist in the Kenney-like style of the Sea friends (spec 13.2). This step uses the Parent's xAI quota.
- [ ] Each sprite has mipmaps on and the texture filter from spec 3.5.

## Comments

- 13.1: copied the 31 tiles, `boat_white_sail.png`, `License.txt` to `assets/kenney/`; 20 Sea friends to `assets/sprites/friends/`; 3 Items to `assets/sprites/items/`.
- 13.2: added the 7 subjects to `tools/make_batch.py`; ran `batch09-items`, `batch10-chest`, and `batch11-glowing-star` (3 omp runs, 8 images). Attempt 1 of `glowing_star` lost its pale, unoutlined rays in the cutout and looked like `star`. Attempt 2 asks for outlined chunky rays. All 10 Item and chest files pass `asset_report.py --require-alpha`. Each sprite was checked on light and dark water. The outlines are complete, and both chests show the same chest. `tools/contact_sheets.py` now also shows `sprites/goal/`. `sprites/PROVENANCE.md` has one line for each new sprite. The files are copied to `assets/sprites/items/` and `assets/sprites/goal/`.
- 3.5 step 1: all 62 PNG files have a committed `.png.import` with `mipmaps/generate=true`. The import ran twice in a temporary project copy, so no `project.godot` is committed. `tests/test_assets.gd` checks that each PNG of §7.3 exists, has `mipmaps/generate=true` in its `.import`, and loads as a texture with mipmaps. With a stand-in runner the result is `Results: 312 passed, 0 failed`. With one import flipped to false, 2 checks fail.
- Not done here: §3.5 step 2, `texture_filter = TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` on each top-level CanvasItem. That is a node property in `main.tscn` (ticket 20). Godot 4 has no texture filter import setting.
