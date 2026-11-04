#!/usr/bin/env python3
"""Build sprites/contact-light.png and sprites/contact-dark.png.

The skill's build_preview_sheet.py has no background option (it draws a checkerboard), so each
sprite is first composited onto a solid light or dark colour, then the skill script builds the sheet.
"""

from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SKILL = ROOT.parents[3] / ".claude/skills/create-game-assets/scripts/build_preview_sheet.py"
BACKGROUNDS = {"light": (236, 244, 248), "dark": (28, 40, 64)}


def main() -> int:
    sprites = [p for folder in ("friends", "items", "goal") for p in sorted((ROOT / "sprites" / folder).glob("*.png"))]
    for label, colour in BACKGROUNDS.items():
        with tempfile.TemporaryDirectory() as tmp:
            flat = []
            for i, path in enumerate(sprites):
                im = Image.open(path).convert("RGBA")
                side = max(im.size)
                bg = Image.new("RGBA", (side, side), (*colour, 255))
                bg.alpha_composite(im, ((side - im.width) // 2, (side - im.height) // 2))
                # Prefix keeps the order friends, items, goal (the script sorts by path).
                out = Path(tmp) / f"{i:02d}-{path.parent.name[0]}-{path.stem}.png"
                bg.save(out)
                flat.append(str(out))
            subprocess.run([sys.executable, str(SKILL), *flat, "--out", str(ROOT / f"sprites/contact-{label}.png"),
                            "--columns", "6", "--cell-size", "192"], check=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
