#!/usr/bin/env python3
"""
HarrisonOS Wallpaper Generator

Generates a branded wallpaper for the distro.
Requires: pip install Pillow

Usage:
    python3 wallpaper.py
    python3 wallpaper.py --width 2560 --height 1440
"""

import argparse
import math
import sys

try:
    from PIL import Image, ImageDraw, ImageFont, ImageFilter
except ImportError:
    print("Pillow is required: pip install Pillow")
    sys.exit(1)


def generate_wallpaper(width: int = 1920, height: int = 1080, output: str = "wallpaper.png"):
    """Generate a dark-themed gradient wallpaper with subtle geometric accents."""

    img = Image.new("RGB", (width, height))
    draw = ImageDraw.Draw(img)

    # ── Background gradient (deep navy → dark blue-gray) ────────────────
    for y in range(height):
        t = y / height
        # Ease-in-out curve for smoother gradient
        t = t * t * (3 - 2 * t)
        r = int(10 + t * 25)
        g = int(15 + t * 30)
        b = int(35 + t * 35)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # ── Subtle radial glow in upper-right ───────────────────────────────
    glow = Image.new("RGB", (width, height), (0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    cx, cy = int(width * 0.75), int(height * 0.25)
    max_radius = int(min(width, height) * 0.6)

    for radius in range(max_radius, 0, -2):
        t = 1 - (radius / max_radius)
        intensity = int(20 * t * t)
        color = (intensity // 3, intensity // 2, intensity)
        glow_draw.ellipse(
            [cx - radius, cy - radius, cx + radius, cy + radius],
            fill=color,
        )

    # Blend glow onto background
    img = Image.blend(img, glow, 0.5)
    draw = ImageDraw.Draw(img)

    # ── Geometric accent lines ──────────────────────────────────────────
    line_color = (255, 255, 255)
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)

    # Diagonal accent lines (very subtle)
    for i in range(5):
        offset = int(width * 0.3) + i * int(width * 0.12)
        alpha = 8 + i * 2
        overlay_draw.line(
            [(offset, 0), (offset - int(height * 0.4), height)],
            fill=(*line_color, alpha),
            width=1,
        )

    img = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
    draw = ImageDraw.Draw(img)

    # ── Distro name text ────────────────────────────────────────────────
    try:
        # Try to use a nice font if available
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf", 42)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf", 16)
    except (OSError, IOError):
        try:
            font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 42)
            font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
        except (OSError, IOError):
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()

    # Position text in lower-left
    text_x = int(width * 0.05)
    text_y = int(height * 0.88)

    # Draw text with slight shadow
    shadow_offset = 2
    draw.text((text_x + shadow_offset, text_y + shadow_offset), "HarrisonOS", font=font_large, fill=(0, 0, 0))
    draw.text((text_x, text_y), "HarrisonOS", font=font_large, fill=(200, 210, 230))

    draw.text((text_x + shadow_offset, text_y + 52 + shadow_offset), "Aurora • 1.0", font=font_small, fill=(0, 0, 0))
    draw.text((text_x, text_y + 52), "Aurora • 1.0", font=font_small, fill=(120, 140, 170))

    # ── Save ────────────────────────────────────────────────────────────
    img.save(output, "PNG", optimize=True)
    print(f"Wallpaper saved to {output} ({width}x{height})")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate HarrisonOS wallpaper")
    parser.add_argument("--width", type=int, default=1920, help="Width in pixels")
    parser.add_argument("--height", type=int, default=1080, help="Height in pixels")
    parser.add_argument("--output", type=str, default="wallpaper.png", help="Output filename")
    args = parser.parse_args()

    generate_wallpaper(args.width, args.height, args.output)
