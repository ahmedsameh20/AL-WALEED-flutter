from PIL import Image, ImageDraw

BROWN = (109, 76, 65, 255)      # 0xFF6D4C41 - matches app theme
CREAM = (245, 240, 237, 255)    # 0xFFF5F0ED - matches dashboard background
WHITE = (255, 255, 255, 255)


def draw_cup(img, cx, cy, scale, color, erase_color):
    draw = ImageDraw.Draw(img)

    # Cup body (trapezoid)
    body_w_top = 260 * scale
    body_w_bottom = 220 * scale
    body_h = 220 * scale
    top_y = cy - body_h / 2
    bottom_y = cy + body_h / 2

    # Saucer under the cup (drawn first so the body overlaps its top edge)
    saucer_w = body_w_bottom * 1.5
    saucer_h = 34 * scale
    draw.ellipse(
        [cx - saucer_w / 2, bottom_y - saucer_h / 2, cx + saucer_w / 2, bottom_y + saucer_h / 2],
        fill=color,
    )

    draw.polygon(
        [
            (cx - body_w_top / 2, top_y),
            (cx + body_w_top / 2, top_y),
            (cx + body_w_bottom / 2, bottom_y),
            (cx - body_w_bottom / 2, bottom_y),
        ],
        fill=color,
    )

    # Handle (ring on the right side) — punch the inner hole with erase_color
    # so it reads correctly whether the canvas is opaque or transparent.
    handle_cx = cx + body_w_top / 2 + 70 * scale
    handle_cy = cy - 10 * scale
    handle_r_outer = 95 * scale
    handle_r_inner = 55 * scale
    bbox_outer = [handle_cx - handle_r_outer, handle_cy - handle_r_outer,
                  handle_cx + handle_r_outer, handle_cy + handle_r_outer]
    draw.ellipse(bbox_outer, fill=color)
    bbox_inner = [handle_cx - handle_r_inner, handle_cy - handle_r_inner,
                  handle_cx + handle_r_inner, handle_cy + handle_r_inner]
    draw.ellipse(bbox_inner, fill=erase_color)

    # Steam (three wavy strokes) above the cup
    for dx in (-70, 0, 70):
        sx = cx + dx * scale
        sy = top_y - 40 * scale
        pts = []
        for i in range(6):
            t = i / 5
            y = sy - t * 140 * scale
            x = sx + (20 * scale) * ((-1) ** i) * (1 - t * 0.3)
            pts.append((x, y))
        draw.line(pts, fill=color, width=int(18 * scale), joint="curve")


def make_icon(path, size, bg, fg, fg_scale):
    img = Image.new("RGBA", (size, size), bg)
    erase_color = bg if bg[3] != 0 else (0, 0, 0, 0)
    scale = (size / 1024) * fg_scale
    # The handle bulges out to the right and the steam rises well above the
    # cup, so the visual center of the whole glyph sits up-and-left of the
    # geometric center passed to draw_cup; nudge it down-and-right to
    # compensate so the composition reads as centered in the square.
    cx = size / 2 - 65 * scale
    cy = size / 2 + 80 * scale
    draw_cup(img, cx, cy, scale, fg, erase_color)
    img.save(path)


# Full square icon with brown background (used as the main launcher icon)
make_icon("app_icon.png", 1024, BROWN, WHITE, 1.0)

# Adaptive-icon foreground: transparent background, smaller cup centered
# in the safe zone so Android's mask doesn't clip it.
make_icon("app_icon_foreground.png", 1024, (0, 0, 0, 0), WHITE, 0.62)

# Splash icon: transparent background, brown cup (shown on cream/dark splash bg)
make_icon("splash_icon.png", 1024, (0, 0, 0, 0), BROWN, 0.85)

print("done")
