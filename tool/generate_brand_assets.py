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
# Pixels with R,G,B all below this threshold become transparent in the mark.
MARK_BG_THRESHOLD = 30
# Fraction of canvas reserved as empty margin around trimmed content.
# ~21% matches Android adaptive-icon safe zone (works with the 16% inset).
MARK_SAFE_PAD_FRACTION = 0.21
# Modest padding for full-logo splash / mac variants (less empty black).
FULL_PAD_FRACTION = 0.08


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


def _is_content_pixel(r: int, g: int, b: int, a: int) -> bool:
    if a <= 16:
        return False
    return r > MARK_BG_THRESHOLD or g > MARK_BG_THRESHOLD or b > MARK_BG_THRESHOLD


def _content_bands(img: Image.Image) -> list[tuple[int, int]]:
    """Return contiguous vertical bands of non-background content as (y0, y1)."""
    rgba = img.convert("RGBA")
    pixels = rgba.load()
    w, h = rgba.size
    occupied = [False] * h
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if _is_content_pixel(r, g, b, a):
                occupied[y] = True
                break

    bands: list[tuple[int, int]] = []
    in_band = False
    start = 0
    for y, has_content in enumerate(occupied):
        if has_content and not in_band:
            in_band = True
            start = y
        elif not has_content and in_band:
            in_band = False
            bands.append((start, y - 1))
    if in_band:
        bands.append((start, h - 1))
    return bands


def _content_bbox(img: Image.Image) -> tuple[int, int, int, int] | None:
    """Return inclusive (left, top, right, bottom) of non-background pixels."""
    rgba = img.convert("RGBA")
    pixels = rgba.load()
    w, h = rgba.size
    min_x, min_y, max_x, max_y = w, h, -1, -1
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if _is_content_pixel(r, g, b, a):
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    if max_x < 0:
        return None
    return min_x, min_y, max_x, max_y


def _trim_to_content(img: Image.Image) -> Image.Image:
    bbox = _content_bbox(img)
    if bbox is None:
        return img.convert("RGBA")
    left, top, right, bottom = bbox
    return img.convert("RGBA").crop((left, top, right + 1, bottom + 1))


def _make_black_transparent(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
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
    return rgba


def _fit_square(
    img: Image.Image,
    size: int,
    *,
    transparent: bool,
    pad_fraction: float = 0.0,
) -> Image.Image:
    """Scale trimmed content into a square canvas with optional margin."""
    rgba = _trim_to_content(img)
    usable = max(1, int(size * (1.0 - 2.0 * pad_fraction)))

    if transparent:
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        scale = min(usable / rgba.width, usable / rgba.height)
        resized = rgba.resize(
            (max(1, int(rgba.width * scale)), max(1, int(rgba.height * scale))),
            Image.Resampling.LANCZOS,
        )
        offset_x = (size - resized.width) // 2
        offset_y = (size - resized.height) // 2
        canvas.paste(resized, (offset_x, offset_y), resized)
        return canvas

    background = Image.new("RGBA", rgba.size, (*BRAND_BG, 255))
    flat = Image.alpha_composite(background, rgba).convert("RGB")
    canvas = Image.new("RGB", (size, size), BRAND_BG)
    scale = min(usable / flat.width, usable / flat.height)
    resized = flat.resize(
        (max(1, int(flat.width * scale)), max(1, int(flat.height * scale))),
        Image.Resampling.LANCZOS,
    )
    offset_x = (size - resized.width) // 2
    offset_y = (size - resized.height) // 2
    canvas.paste(resized, (offset_x, offset_y))
    return canvas


def _save_full_logo_variants(img: Image.Image) -> None:
    variants = {
        "app_icon.png": False,
        "app_icon_mac.png": False,
        "app_icon_transparent.png": True,
    }
    for name, transparent in variants.items():
        full = _fit_square(
            img,
            FULL_SIZE,
            transparent=transparent,
            pad_fraction=FULL_PAD_FRACTION,
        )
        full.save(ASSETS_DIR / name, format="PNG", optimize=True)
        mode = "RGBA" if transparent else "RGB"
        print(f"  wrote {ASSETS_DIR / name} ({FULL_SIZE}x{FULL_SIZE}, {mode})")


def _extract_mark(img: Image.Image) -> Image.Image:
    """Crop the cloud + </> band only, trim, and pad into the adaptive safe zone."""
    bands = _content_bands(img)
    if not bands:
        raise ValueError("No content found in source logo for mark extraction.")

    # First band is the cloud mark; stop before the "HZN" wordmark band.
    cloud_top, cloud_bottom = bands[0]
    if len(bands) >= 2:
        crop_bottom = bands[1][0]  # exclusive end at start of wordmark
    else:
        crop_bottom = cloud_bottom + 1

    w, _ = img.size
    # Include a little top margin above the cloud, but not the wordmark.
    crop_top = max(0, cloud_top - 4)
    cropped = img.crop((0, crop_top, w, crop_bottom))
    transparent = _make_black_transparent(cropped)
    return _fit_square(
        transparent,
        MARK_SIZE,
        transparent=True,
        pad_fraction=MARK_SAFE_PAD_FRACTION,
    )


def _on_brand_background(img: Image.Image) -> Image.Image:
    """Flatten RGBA logos onto the HZN black brand background."""
    return _fit_square(
        img,
        FULL_SIZE,
        transparent=False,
        pad_fraction=FULL_PAD_FRACTION,
    )


def _icon_on_black(img: Image.Image, size: int) -> Image.Image:
    return _fit_square(img, size, transparent=False, pad_fraction=0.0)


def _icon_transparent(img: Image.Image, size: int) -> Image.Image:
    return _fit_square(img, size, transparent=True, pad_fraction=0.0)


def _write_web_favicons(mark: Image.Image, full: Image.Image) -> None:
    """Refresh web/ favicons referenced by index.html."""
    web_dir = REPO_ROOT / "web"
    web_dir.mkdir(parents=True, exist_ok=True)

    for size in (16, 32, 48, 96):
        filename = f"favicon-{size}x{size}.png"
        _icon_transparent(mark, size).save(web_dir / filename, format="PNG", optimize=True)
        print(f"  wrote {web_dir / filename} ({size}x{size})")

    apple = _icon_on_black(full, 180)
    apple.save(web_dir / "apple-touch-icon.png", format="PNG", optimize=True)
    print(f"  wrote {web_dir / 'apple-touch-icon.png'} (180x180)")

    # Multi-size ICO for browsers that request favicon.ico
    ico_sizes = []
    for size in (16, 32, 48):
        ico_sizes.append(_icon_transparent(mark, size))
    ico_sizes[0].save(
        web_dir / "favicon.ico",
        format="ICO",
        sizes=[(16, 16), (32, 32), (48, 48)],
        append_images=ico_sizes[1:],
    )
    print(f"  wrote {web_dir / 'favicon.ico'}")


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
        bands = _content_bands(img)
        print(f"  content bands: {bands}")

        print("Generating full-logo variants...")
        _save_full_logo_variants(img)

        print("Generating cloud mark (transparent)...")
        mark = _extract_mark(img)
        mark_path = ASSETS_DIR / "app_icon_mark.png"
        mark.save(mark_path, format="PNG", optimize=True)
        print(f"  wrote {mark_path} ({MARK_SIZE}x{MARK_SIZE}, RGBA)")

        # Opaque black mark for iOS (remove_alpha_ios composites onto white otherwise).
        print("Generating cloud mark on black (opaque)...")
        mark_opaque = _fit_square(
            mark,
            MARK_SIZE,
            transparent=False,
            pad_fraction=0.0,
        )
        mark_opaque_path = ASSETS_DIR / "app_icon_mark_opaque.png"
        mark_opaque.save(mark_opaque_path, format="PNG", optimize=True)
        print(f"  wrote {mark_opaque_path} ({MARK_SIZE}x{MARK_SIZE}, RGB)")

        print("Refreshing web/ favicons...")
        full = _on_brand_background(img)
        _write_web_favicons(mark, full)

        print("Refreshing icon_pack/web reference assets...")
        _write_icon_pack_web(full, mark)

    print("Done.")


if __name__ == "__main__":
    main()
