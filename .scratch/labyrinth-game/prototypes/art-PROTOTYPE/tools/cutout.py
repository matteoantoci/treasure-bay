#!/usr/bin/env python3
"""Cut a generated sprite out of its flat background.

The generator returns a JPEG (no alpha) with a plain light background. This script:
1. estimates the background colour from the image border,
2. removes ONLY background pixels connected to the border (flood fill with a
   colour tolerance) -- never a global colour key, so white/pink parts inside the
   dark outline stay,
3. optionally clears extra enclosed background pockets from manual seed points,
4. erodes the alpha edge (default 1 px) and darkens the remaining fringe so no
   light halo is left, then antialiases the edge,
5. trims to the object, pads 4 % of the longest side, scales the longest side to 512 px.

Usage: cutout.py IN OUT [--tol 48] [--erode 1] [--seed X,Y ...]
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage


def parse_seed(text: str) -> tuple[int, int]:
    x, y = text.split(",")
    return int(x), int(y)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src", type=Path)
    ap.add_argument("dst", type=Path)
    ap.add_argument("--tol", type=int, default=48, help="max per-channel difference from the background colour")
    ap.add_argument("--erode", type=int, default=1, help="alpha erosion in px at full size (1-2)")
    ap.add_argument("--pad", type=float, default=0.04, help="padding as a fraction of the longest side")
    ap.add_argument("--size", type=int, default=512, help="longest side of the output")
    ap.add_argument("--seed", type=parse_seed, action="append", default=[],
                    help="x,y (full-size pixels) of an enclosed background pocket to clear as well")
    args = ap.parse_args()

    rgb = np.asarray(Image.open(args.src).convert("RGB")).astype(np.int16)
    h, w, _ = rgb.shape

    border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
    bg = np.median(border, axis=0)
    near_bg = np.abs(rgb - bg).max(axis=2) <= args.tol

    labels, _ = ndimage.label(near_bg)
    edge_labels = np.unique(np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]]))
    keep = set(int(v) for v in edge_labels if v != 0)
    for x, y in args.seed:
        if not near_bg[y, x]:
            print(f"warning: seed {x},{y} is not background-coloured; ignored", file=sys.stderr)
            continue
        keep.add(int(labels[y, x]))
    background = np.isin(labels, list(keep))

    obj = ~background
    # Drop specks: keep only the largest connected object component(s) >= 1 % of the biggest.
    obj_labels, n = ndimage.label(obj)
    if n > 1:
        sizes = ndimage.sum(obj, obj_labels, range(1, n + 1))
        big = [i + 1 for i, s in enumerate(sizes) if s >= 0.01 * sizes.max()]
        obj = np.isin(obj_labels, big)

    if args.erode > 0:
        obj = ndimage.binary_erosion(obj, iterations=args.erode, border_value=0)

    # Defringe: in the outer 2 px band, use the darkest colour of the 5x5 neighbourhood
    # inside the object, so JPEG-blended light pixels become the dark outline colour.
    band = obj & ~ndimage.binary_erosion(obj, iterations=2, border_value=0)
    lum = rgb @ np.array([299, 587, 114]) // 1000
    lum_masked = np.where(obj, lum, 10_000)
    darkest = ndimage.minimum_filter(lum_masked, size=5)
    out_rgb = rgb.copy()
    by, bx = np.nonzero(band)
    for dy in range(-2, 3):
        for dx in range(-2, 3):
            yy = np.clip(by + dy, 0, h - 1)
            xx = np.clip(bx + dx, 0, w - 1)
            hit = (lum_masked[yy, xx] == darkest[by, bx])
            out_rgb[by[hit], bx[hit]] = rgb[yy[hit], xx[hit]]
    outline = np.median(rgb[band], axis=0) if band.any() else np.zeros(3)
    out_rgb[~obj] = outline

    # Antialias: keep the object opaque, add a soft (outline-coloured) rim just outside it.
    blurred = np.asarray(Image.fromarray((obj * 255).astype(np.uint8), "L").filter(ImageFilter.GaussianBlur(0.6)))
    alpha_np = np.maximum((obj * 255).astype(np.uint8), blurred)
    rgba = np.dstack([out_rgb.clip(0, 255).astype(np.uint8), alpha_np])
    img = Image.fromarray(rgba, "RGBA")

    ys, xs = np.nonzero(alpha_np > 8)
    if len(xs) == 0:
        print("error: nothing left after cutout", file=sys.stderr)
        return 1
    img = img.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    cw, ch = img.size
    pad = round(max(cw, ch) * args.pad)
    canvas = Image.new("RGBA", (cw + 2 * pad, ch + 2 * pad), (*outline.astype(np.uint8).tolist(), 0))
    canvas.paste(img, (pad, pad))
    scale = args.size / max(canvas.size)
    if scale > 1:
        print(f"warning: upscaling x{scale:.2f} (object only {max(canvas.size)} px)", file=sys.stderr)
    new = (max(1, round(canvas.width * scale)), max(1, round(canvas.height * scale)))
    # Resize premultiplied to avoid colour bleeding from transparent pixels.
    out = canvas.convert("RGBa").resize(new, Image.Resampling.LANCZOS).convert("RGBA")

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    out.save(args.dst, optimize=True)
    removed = background.mean() * 100
    print(f"{args.dst}: {out.size[0]}x{out.size[1]} bg={bg.astype(int).tolist()} removed={removed:.1f}% "
          f"object_px={max(cw, ch)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
