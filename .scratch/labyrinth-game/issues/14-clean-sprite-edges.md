# Clean sprite edges

Type: task
Status: resolved
Blocked by: none
Map: [Labyrinth game for a 5-year-old](../map.md)

## Question

How do the 23 sprites in `prototypes/art-PROTOTYPE/sprites/` get smooth edges?

The Parent saw the motion prototype on 2026-11-03 and said that the edges of the sprites are brittle.

## Context

Two possible causes were found by reading the code. The Result section below shows which one is real.

1. **Cutout (checked, not the cause):** `tools/cutout.py` makes a hard 0/1 mask from a JPEG (lines 60 to 71), and it fills the outer 2 px band with the darkest nearby colour (lines 73 to 86). But the script then shrinks the image to 512 px with LANCZOS (line 110), and this smooths the edge. Do not change the cutout.
2. **Scaling:** the sprites are 512 px, but the game shows them at about 44 to 110 px. The HTML prototype uses plain canvas `drawImage`, which has no mipmaps, so the edges look rough at small sizes. The Godot build can show the same problem.
   - Spec requirement: in the import settings of each sprite texture, switch on **Mipmaps > Generate** (see the Godot docs, [Importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)). Draw the sprites with `CanvasItem.texture_filter = TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` (see [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html), enum TextureFilter), or set Project Settings → Rendering → Textures → Default Texture Filter = "Linear Mipmap". Another option is to store the sprites at their display sizes.
   - The spec must contain this requirement. It is not a cutout fix.

## Acceptance

- No stepped or white-fringed edges on light water or on dark water (Area 4).
- The dark outline of each sprite stays complete.
- The Parent checks the motion prototype again and sees smooth edges.
- The spec requires **Mipmaps > Generate** and `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` for the sprite textures, or sprites at their display sizes.

## Result (2026-11-03)

Cause 2 (scaling) makes the brittle edges. Cause 1 (cutout) does not need a fix.

- **Cutout checked:** `sprites/friends/dolphin.png` at 512 px has 5,888 edge pixels with partial alpha (1 to 254). At 4× zoom the outline is smooth. The cutout is already antialiased, because `cutout.py` shrinks the image with LANCZOS (line 110).
- **Scaling checked:** the same dolphin, shrunk to 64 px with no filter (NEAREST), has a stepped outline. With a LANCZOS filter it is smooth. The shrimp gives the same result: with LANCZOS at 64 px, the thin antennae stay complete and smooth on dark water.
- **Prototype fixed:** `prototypes/motion-PROTOTYPE/index.html` now builds a mipmap chain for each sprite (512, 256, … 16 px) and draws the smallest level that is at least 2× the draw size. It also sets `imageSmoothingQuality='high'`.
- **Limit of the check:** in headless Chromium, PNG crops of the Item outlines look the same with and without the mipmap chain. [INFERENCE: the cause is probably `imageSmoothingQuality='high'`, which was on in both crops. Not tested without it.] The chain is there for browsers that shrink with a simple filter. [INFERENCE: Safari is probably one of them. Not tested.] The cutout check covers only the dolphin, and the scaling check covers the dolphin and the shrimp.
- **No new sprites:** the 23 sprites and `cutout.py` stay as they are.
- **For the build:** the Godot mipmap settings in the Context section are the real fix. They are a spec requirement.

## Second pass (2026-11-03)

The Parent said: "it's better, I wouldn't say perfect". Two more changes in the prototype:

- **Screen resolution:** the canvas was 960 px wide, and CSS stretched it to the window. This blurred the whole picture a second time. The canvas now uses the real screen pixels (`devicePixelRatio`) and scales its drawing to match.
- **Exact size:** each sprite now gets one copy at its exact size on the screen (rounded to 4 px), made from the next larger mipmap level. Before, the browser shrank a mipmap level by up to 2× while it drew.
- Check: headless Chromium at 1440 × 900, PNG crops of the Item outlines and the Collection strip. The edges are smooth, and the play from start to Labyrinth 2 still works.

**For the build:** the same blur can happen in Godot. The spec must set the window stretch mode to `canvas_items` (Project Settings → Display → Window → Stretch → Mode). Do not use `viewport` mode, because it draws at the base size and then scales the whole image. [INFERENCE: from the Godot stretch modes. Not tested in this project.]

## Answer

The Parent checked the prototype after the second pass on 2026-11-03 and said that the edges are smooth. The sprites and `cutout.py` stay as they are. The spec must require three things for the sprites:

- **Mipmaps > Generate** in the import settings of each sprite texture.
- `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` as the texture filter.
- The window stretch mode `canvas_items`, not `viewport`.
