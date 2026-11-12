"""Generate the Ridlers launcher and web icons from the cartoon brand mark.

Requires Pillow (python3 -m pip install pillow). The hand-authored SVG reference
lives at assets/brand/ridlers_icon.svg; this renderer mirrors its geometry for
crisp raster exports at every platform size.
"""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SCALE = 4
SIZE = 512
INK = "#22303C"
PAPER = "#F4F7F8"
YELLOW = "#FFF085"
MINT = "#CBFBF1"
CORAL = "#FF9A76"
PINK = "#FFD3E0"
SHADOW = "#B4D1E6"
LAVENDER = "#C7C8FF"


def px(value: float) -> int:
    return round(value * SCALE)


def box(coords: tuple[float, float, float, float]) -> tuple[int, int, int, int]:
    return tuple(px(value) for value in coords)  # type: ignore[return-value]


def bezier(
    start: tuple[float, float],
    control1: tuple[float, float],
    control2: tuple[float, float],
    end: tuple[float, float],
    steps: int = 24,
) -> list[tuple[int, int]]:
    points = []
    for i in range(steps + 1):
        t = i / steps
        u = 1 - t
        x = u**3 * start[0] + 3 * u**2 * t * control1[0] + 3 * u * t**2 * control2[0] + t**3 * end[0]
        y = u**3 * start[1] + 3 * u**2 * t * control1[1] + 3 * u * t**2 * control2[1] + t**3 * end[1]
        points.append((px(x), px(y)))
    return points


def draw_icon() -> Image.Image:
    image = Image.new("RGB", (px(SIZE), px(SIZE)), PAPER)
    draw = ImageDraw.Draw(image)

    # Yellow sticker tile with its short, hard offset shadow.
    draw.rounded_rectangle(box((52, 58, 460, 466)), radius=px(120), fill=SHADOW)
    draw.rounded_rectangle(
        box((52, 42, 460, 450)),
        radius=px(120),
        fill=YELLOW,
        outline=INK,
        width=px(18),
    )

    # Confetti marks around the piggy bank.
    for x, y, color, radius, width in [
        (111, 173, CORAL, 14, 10),
        (398, 179, "#8FE8D3", 11, 9),
    ]:
        draw.line((px(x), px(y - radius), px(x), px(y + radius)), fill=color, width=px(width))
        draw.line((px(x - radius), px(y), px(x + radius), px(y)), fill=color, width=px(width))
    draw.ellipse(box((377, 341, 395, 359)), fill=LAVENDER, outline=INK, width=px(5))

    # Curly tail, legs, and ear go behind the round body.
    tail = bezier((126, 274), (92, 263), (76, 279), (87, 296))
    tail += bezier((87, 296), (98, 315), (125, 311), (116, 287))[1:]
    draw.line(tail, fill=INK, width=px(14), joint="curve")
    draw.rounded_rectangle(box((157, 345, 215, 411)), radius=px(22), fill=MINT, outline=INK, width=px(14))
    draw.rounded_rectangle(box((282, 345, 340, 411)), radius=px(22), fill=MINT, outline=INK, width=px(14))
    draw.ellipse(box((285, 155, 339, 217)), fill=CORAL, outline=INK, width=px(13))

    # Piggy bank silhouette and the coin slot.
    draw.ellipse(box((101, 178, 387, 394)), fill=MINT, outline=INK, width=px(16))
    draw.rounded_rectangle(box((207, 190, 281, 203)), radius=px(7), fill=INK)

    # A little coin hovering above its slot.
    draw.ellipse(box((209, 110, 279, 180)), fill=CORAL, outline=INK, width=px(13))
    draw.line((px(244), px(126), px(244), px(164)), fill=INK, width=px(6))
    draw.line((px(233), px(135), px(251), px(135)), fill=INK, width=px(6))
    draw.line((px(237), px(155), px(255), px(155)), fill=INK, width=px(6))

    # One bright eye and a rosy snout keep the expression friendly at small size.
    draw.ellipse(box((296, 227, 312, 243)), fill=INK)
    draw.ellipse(box((310, 265, 330, 285)), fill="#FFB8C9")
    draw.ellipse(box((310, 265, 330, 285)), outline=INK, width=px(4))
    draw.ellipse(box((310, 231, 404, 305)), fill=PINK, outline=INK, width=px(12))
    draw.ellipse(box((340, 259, 350, 277)), fill=INK)
    draw.ellipse(box((364, 259, 374, 277)), fill=INK)

    return image.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def save_icon(image: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize((size, size), Image.Resampling.LANCZOS).save(path, format="PNG", optimize=True)


def main() -> None:
    icon = draw_icon()
    vector_mark = ROOT / "assets/brand/ridlers_icon.svg"
    (ROOT / "web/favicon.svg").write_text(vector_mark.read_text())
    save_icon(icon, ROOT / "web/favicon.png", 32)
    save_icon(icon, ROOT / "web/icons/Icon-192.png", 192)
    save_icon(icon, ROOT / "web/icons/Icon-512.png", 512)
    save_icon(icon, ROOT / "web/icons/Icon-maskable-192.png", 192)
    save_icon(icon, ROOT / "web/icons/Icon-maskable-512.png", 512)

    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, size in android_sizes.items():
        save_icon(icon, ROOT / "android/app/src/main/res" / folder / "ic_launcher.png", size)

    app_icon_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((app_icon_dir / "Contents.json").read_text())
    for entry in contents["images"]:
        filename = entry.get("filename")
        if not filename:
            continue
        point_size = float(entry["size"].split("x")[0])
        scale = float(entry.get("scale", "1x").removesuffix("x"))
        save_icon(icon, app_icon_dir / filename, round(point_size * scale))


if __name__ == "__main__":
    main()
