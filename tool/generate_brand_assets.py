#!/usr/bin/env python3
"""Generate HZN Systems brand assets from the source logo.

Requires: pip install pillow

Usage (from repo root):
    python tool/generate_brand_assets.py
"""

from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image

REPO_ROOT = Path(__file__).resolve().parent.parent
ASSETS_DIR = REPO_ROOT / "assets" / "icons"
FULL_SIZE = 1024
MARK_SIZE = 512
BRAND_BG = (0, 0, 0)
# Top fraction of source containing cloud + </> (excludes "HZN systems" text).
MARK_CROP_TOP_FRACTION = 0.58
# Pixels with R,G,B all below this threshold become transparent in the mark.
MARK_BG_THRESHOLD = 30


def _resolve_source() -> Path:
    candidates = [
        REPO_ROOT / "hzn_systems_logo.png",
        REPO_ROOT / "hzn_systems_logo.jpg",
        ASSETS_DIR / "hzn_systems_logo.png",
        ASSETS_DIR / "hzn_systems_logo.jpg",
    ]
    for path in candidates:
        if path.exists():
            return path
    raise FileNotFoundError(
        "Source logo not found. Add hzn_systems_logo.png or .jpg at repo root."
    )


def _sync_source_copy(source: Path) -> Path:
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    dest = ASSETS_DIR / source.name
    shutil.copy2(source, dest)
    return dest


def _fit_square(img: Image.Image, size: int, *, transparent: bool) -> Image.Image:
    rgba = img.convert("RGBA")
    if transparent:
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    else:
        background = Image.new("RGBA", rgba.size, (*BRAND_BG, 255))
        rgba = Image.alpha_composite(background, rgba)
        canvas = Image.new("RGB", (size, size), BRAND_BG)
        rgba = rgba.convert("RGB")

    scale = min(size / rgba.width, size / rgba.height)
    resized = rgba.resize(
        (max(1, int(rgba.width * scale)), max(1, int(rgba.height * scale))),
        Image.Resampling.LANCZOS,
    )
    offset_x = (size - resized.width) // 2
    offset_y = (size - resized.height) // 2
    if transparent:
        canvas.paste(resized, (offset_x, offset_y), resized)
        return canvas
    canvas.paste(resized, (offset_x, offset_y))
    return canvas


def _save_full_logo_variants(img: Image.Image) -> None:
    variants = {
        "app_icon.png": False,
        "app_icon_mac.png": False,
        "app_icon_transparent.png": True,
    }
    for name, transparent in variants.items():
        full = _fit_square(img, FULL_SIZE, transparent=transparent)
        full.save(ASSETS_DIR / name, format="PNG", optimize=True)
        mode = "RGBA" if transparent else "RGB"
        print(f"  wrote {ASSETS_DIR / name} ({FULL_SIZE}x{FULL_SIZE}, {mode})")


def _extract_mark(img: Image.Image) -> Image.Image:
    w, h = img.size
    crop_h = int(h * MARK_CROP_TOP_FRACTION)
    cropped = img.crop((0, 0, w, crop_h)).convert("RGBA")

    pixels = cropped.load()
    for y in range(cropped.height):
        for x in range(cropped.width):
            r, g, b, a = pixels[x, y]
            if a <= 16:
                pixels[x, y] = (r, g, b, 0)
                continue
            if (
                r <= MARK_BG_THRESHOLD
                and g <= MARK_BG_THRESHOLD
                and b <= MARK_BG_THRESHOLD
            ):
                pixels[x, y] = (r, g, b, 0)

    mark_w, mark_h = cropped.size
    side = max(mark_w, mark_h)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    offset_x = (side - mark_w) // 2
    offset_y = (side - mark_h) // 2
    canvas.paste(cropped, (offset_x, offset_y), cropped)

    return canvas.resize((MARK_SIZE, MARK_SIZE), Image.Resampling.LANCZOS)


def _on_brand_background(img: Image.Image) -> Image.Image:
    """Flatten RGBA logos onto the HZN black brand background."""
    return _fit_square(img, FULL_SIZE, transparent=False)


def _icon_on_black(img: Image.Image, size: int) -> Image.Image:
    return _fit_square(img, size, transparent=False)


def _write_icon_pack_web(full: Image.Image, mark: Image.Image) -> None:
    """Refresh reference web icons under icon_pack/."""
    web_dir = REPO_ROOT / "icon_pack" / "web"
    web_dir.mkdir(parents=True, exist_ok=True)

    favicon_sizes = (16, 32, 48, 96)
    for size in favicon_sizes:
        filename = f"favicon-{size}x{size}.png"
        _icon_on_black(mark, size).save(web_dir / filename, format="PNG", optimize=True)
        print(f"  wrote {web_dir / filename} ({size}x{size})")

    for filename, size in (
        ("apple-touch-icon.png", 180),
        ("android-chrome-192x192.png", 192),
        ("android-chrome-512x512.png", 512),
    ):
        _icon_on_black(full, size).save(web_dir / filename, format="PNG", optimize=True)
        print(f"  wrote {web_dir / filename} ({size}x{size})")

    manifest = web_dir / "site.webmanifest"
    manifest.write_text(
        """{
  "name": "HZN Gyms",
  "short_name": "HZN Gyms",
  "icons": [
    {
      "src": "/android-chrome-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/android-chrome-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "theme_color": "#000000",
  "background_color": "#000000",
  "display": "standalone"
}
""",
        encoding="utf-8",
    )
    print(f"  wrote {manifest}")


def main() -> None:
    source = _resolve_source()
    print(f"Source: {source}")
    source_copy = _sync_source_copy(source)
    print(f"  copied to {source_copy}")

    with Image.open(source) as img:
        print("Generating full-logo variants...")
        _save_full_logo_variants(img)

        print("Generating cloud mark (transparent)...")
        mark = _extract_mark(img)
        mark_path = ASSETS_DIR / "app_icon_mark.png"
        mark.save(mark_path, format="PNG", optimize=True)
        print(f"  wrote {mark_path} ({MARK_SIZE}x{MARK_SIZE}, RGBA)")

        print("Refreshing icon_pack/web reference assets...")
        full = _on_brand_background(img)
        _write_icon_pack_web(full, mark)

    print("Done.")


if __name__ == "__main__":
    main()
