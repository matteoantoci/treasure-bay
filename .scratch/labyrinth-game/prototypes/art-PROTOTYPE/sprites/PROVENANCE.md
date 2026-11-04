# Sprite provenance

- Generated on 2026-11-03 with `xai-oauth/grok-imagine-image` (the Parent's xAI subscription), called through the
  omp `generate_image` tool by a headless `xai-oauth/grok-4.7` session. Output: 1024x1024 JPEG, no alpha, white background.
- Style references passed as `input`: `ref/kenney-pirate-sample.png` (Kenney Pirate Pack, CC0) for every image, plus
  `gen/dolphin.jpg` (the earlier good test) as Image 2 from batch02 onwards.
- Command per batch (`tools/run_batch.sh <batch>`, run from `art-PROTOTYPE/`):
  `omp -p --model xai-oauth/grok-4.7 --thinking high --config omp-imagegen.yml --no-session --auto-approve --no-title --max-time 10m --max-cost 3 @gen/<batch>.md "Follow the instructions in the attached file."`
- Prompt files: `gen/batch01-crab.md` was written by hand; the others come from `tools/make_batch.py` (one style
  block, one subject per asset). Raw images: `gen/raw/<name>.jpg`. Logs and run times: `gen/logs/`.
- Cleanup: `tools/cutout.py gen/raw/<name>.jpg sprites/<friends|items|goal>/<name>.png` with the defaults (tolerance 48,
  erode 1 px, pad 4 %, longest side 512). Only background connected to the image border is removed (flood fill), so
  white and pink parts inside the dark outline stay. No manual seeds were needed. All 30 files pass
  `asset_report.py --require-alpha`.
- Contact sheets: `tools/contact_sheets.py` (wraps the skill's `build_preview_sheet.py`) → `contact-light.png`, `contact-dark.png`.
  They show friends, then items, then the goal chests.
- Batches 09 to 11 (5 new Items and the 2 chests, spec §13.2) were generated on 2026-11-04 with the same method, models and references.

| Asset | Kind | Prompt file | References | Attempts | Notes |
|---|---|---|---|---|---|
| crab | friend | gen/batch01-crab.md | Kenney | 1 | Front view, not side; kept (crabs read best from the front). |
| octopus | friend | gen/batch02.md | Kenney + dolphin | 1 | |
| dolphin | friend | gen/batch02.md | Kenney + dolphin | 1 | New image; replaces the small pink-background test. |
| fish | friend | gen/batch02.md | Kenney + dolphin | 1 | Clownfish. |
| blowfish | friend | gen/batch02.md | Kenney + dolphin | 1 | |
| spouting_whale | friend | gen/batch03.md | Kenney + dolphin | 1 | Light blue, water spout. |
| whale | friend | gen/batch03.md | Kenney + dolphin | 1 | Navy humpback, no spout; low outline contrast on dark backgrounds. |
| shark | friend | gen/batch03.md | Kenney + dolphin | 1 | No teeth. |
| squid | friend | gen/batch03.md | Kenney + dolphin | 1 | Mint green, to differ from the purple octopus. |
| lobster | friend | gen/batch04.md | Kenney + dolphin | 1 | Orange, to differ from the red crab. |
| shrimp | friend | gen/batch04.md | Kenney + dolphin | 1 | Thin antennae may vanish at small sizes. |
| oyster | friend | gen/batch04.md | Kenney + dolphin | 1 | No pearl inside (the pearl is an Item). |
| seal | friend | gen/batch04.md | Kenney + dolphin | 1 | Generator drew a light ground shadow; the flood fill removed it. |
| turtle | friend | gen/batch05.md | Kenney + dolphin | 1 | |
| jellyfish | friend | gen/batch05.md | Kenney + dolphin | 1 | |
| otter | friend | gen/batch05.md | Kenney + dolphin | 1 | |
| penguin | friend | gen/batch05.md | Kenney + dolphin | 1 | Ground shadow removed by the flood fill. |
| duck | friend | gen/batch08-duck.md | Kenney + dolphin | 2 | Attempt 1 (gen/batch06.md, raw kept as `gen/raw/duck-attempt1.jpg`) looked like a yellow rubber toy; attempt 2 is a mallard. |
| swan | friend | gen/batch06.md | Kenney + dolphin | 1 | Ground shadow removed by the flood fill. |
| flamingo | friend | gen/batch06.md | Kenney + dolphin | 1 | |
| spiral_shell | item | gen/batch07.md | Kenney + dolphin | 1 | No face (Items are objects, not characters). |
| starfish | item | gen/batch07.md | Kenney + dolphin | 1 | No face. |
| pearl | item | gen/batch07.md | Kenney + dolphin | 1 | |
| coral | item | gen/batch09-items.md | Kenney + dolphin | 1 | Pink, rounded tips. |
| sand_dollar | item | gen/batch09-items.md | Kenney + dolphin | 1 | Near-white; the dark outline keeps it visible on light water. |
| gem_stone | item | gen/batch09-items.md | Kenney + dolphin | 1 | Blue, flat facets. |
| glowing_star | item | gen/batch11-glowing-star.md | Kenney + dolphin | 2 | Attempt 1 (gen/batch09-items.md, raw kept as `gen/raw/glowing_star-attempt1.jpg`) drew thin pale rays with no outline; the cutout dropped them as specks, so it looked like the plain star. Attempt 2 asks for outlined chunky rays (7 rays kept). |
| star | item | gen/batch09-items.md | Kenney + dolphin | 1 | No rays. |
| chest_closed | goal | gen/batch10-chest.md | Kenney + dolphin | 1 | Kind "item" in make_batch.py (no face). |
| chest_open | goal | gen/batch10-chest.md | Kenney + dolphin | 1 | Same chest as chest_closed (planks, gold bands, lock), gold coins inside. |

No asset failed. Rights: the Kenney reference is CC0; the generated images follow the xAI terms of the Parent's subscription.
- Cost: the full batch of 23 sprites used about 2% of the weekly xAI subscription quota (Parent report, 2026-11-03).
