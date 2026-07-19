#!/usr/bin/env python3
import json
import os
import struct
import zlib


CELL_W = 192
CELL_H = 40
ROWS = [
    ("repair", "Repair"),
    ("buy_damage", "Buy Damage"),
    ("buy_health", "Buy Health"),
    ("continue", "CONTINUE"),
]
STATES = ["active", "passive", "pressed", "focus"]
OUT_PNG = os.path.join("img", "workshop_shop_buttons_atlas.png")
OUT_JSON = os.path.join("img", "workshop_shop_buttons_atlas.json")


PALETTE = {
    "transparent": (0, 0, 0, 0),
    "ink": (26, 42, 35, 255),
    "ink2": (41, 58, 45, 255),
    "shadow": (18, 31, 28, 255),
    "panel": (99, 119, 75, 255),
    "panel2": (124, 139, 84, 255),
    "panel_dark": (71, 89, 65, 255),
    "panel_disabled": (64, 78, 62, 255),
    "line": (52, 71, 55, 255),
    "light": (184, 188, 119, 255),
    "cream": (231, 229, 201, 255),
    "muted": (129, 141, 102, 255),
    "orange": (198, 142, 73, 255),
    "orange_dark": (127, 86, 48, 255),
    "red": (171, 80, 80, 255),
    "red_dark": (100, 52, 55, 255),
    "green": (122, 159, 94, 255),
    "green_dark": (60, 95, 68, 255),
    "focus": (230, 205, 118, 255),
}


FONT = {
    "A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
    "B": ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
    "C": ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
    "D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
    "E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
    "H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
    "I": ["11111", "00100", "00100", "00100", "00100", "00100", "11111"],
    "N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
    "O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
    "R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
    "T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
    "U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
    "a": ["00000", "01110", "00001", "01111", "10001", "10011", "01101"],
    "b": ["10000", "10000", "10110", "11001", "10001", "10001", "11110"],
    "c": ["00000", "01110", "10000", "10000", "10000", "10001", "01110"],
    "e": ["00000", "01110", "10001", "11111", "10000", "10001", "01110"],
    "g": ["00000", "01101", "10011", "10001", "01111", "00001", "11110"],
    "h": ["10000", "10000", "10110", "11001", "10001", "10001", "10001"],
    "i": ["00100", "00000", "01100", "00100", "00100", "00100", "01110"],
    "l": ["01100", "00100", "00100", "00100", "00100", "00100", "01110"],
    "m": ["00000", "11010", "10101", "10101", "10101", "10101", "10101"],
    "p": ["00000", "11110", "10001", "10001", "11110", "10000", "10000"],
    "r": ["00000", "10110", "11001", "10000", "10000", "10000", "10000"],
    "t": ["01000", "01000", "11110", "01000", "01000", "01001", "00110"],
    "u": ["00000", "10001", "10001", "10001", "10001", "10011", "01101"],
    "y": ["00000", "10001", "10001", "10001", "01111", "00001", "11110"],
    " ": ["000", "000", "000", "000", "000", "000", "000"],
}


class Canvas:
    def __init__(self, w, h):
        self.w = w
        self.h = h
        self.pixels = bytearray(PALETTE["transparent"] * (w * h))

    def set_px(self, x, y, color):
        if 0 <= x < self.w and 0 <= y < self.h:
            i = (y * self.w + x) * 4
            self.pixels[i : i + 4] = bytes(color)

    def rect(self, x, y, w, h, color):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.set_px(xx, yy, color)

    def line_h(self, x, y, w, color):
        self.rect(x, y, w, 1, color)

    def line_v(self, x, y, h, color):
        self.rect(x, y, 1, h, color)

    def pixel_rect(self, x, y, w, h, color, scale=1):
        self.rect(x * scale, y * scale, w * scale, h * scale, color)


def write_png(path, canvas):
    rows = []
    stride = canvas.w * 4
    for y in range(canvas.h):
        rows.append(b"\x00" + bytes(canvas.pixels[y * stride : (y + 1) * stride]))
    raw = b"".join(rows)

    def chunk(kind, data):
        return (
            struct.pack(">I", len(data))
            + kind
            + data
            + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
        )

    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", canvas.w, canvas.h, 8, 6, 0, 0, 0)))
        f.write(chunk(b"IDAT", zlib.compress(raw, 9)))
        f.write(chunk(b"IEND", b""))


def draw_text(c, x, y, text, color, scale=2):
    cursor = x
    for ch in text:
        glyph = FONT.get(ch)
        if glyph is None:
            cursor += 6 * scale
            continue
        glyph_w = len(glyph[0])
        for gy, row in enumerate(glyph):
            for gx, bit in enumerate(row):
                if bit == "1":
                    c.rect(cursor + gx * scale, y + gy * scale, scale, scale, color)
        cursor += (glyph_w + 1) * scale


def measure_text(text, scale=2):
    width = 0
    for ch in text:
        glyph = FONT.get(ch, FONT[" "])
        width += (len(glyph[0]) + 1) * scale
    return max(0, width - scale)


def draw_button(c, x, y, w, h, state):
    ox = 0
    oy = 2 if state == "pressed" else 0
    bx = x + 4 + ox
    by = y + 4 + oy
    bw = w - 8
    bh = h - 8

    if state == "passive":
        fill = PALETTE["panel_disabled"]
        top = PALETTE["muted"]
        text = PALETTE["muted"]
        accent = PALETTE["muted"]
    elif state == "pressed":
        fill = PALETTE["panel_dark"]
        top = PALETTE["line"]
        text = PALETTE["cream"]
        accent = PALETTE["orange_dark"]
    else:
        fill = PALETTE["panel"]
        top = PALETTE["light"]
        text = PALETTE["cream"]
        accent = PALETTE["orange"]

    c.rect(bx + 3, by + 3, bw, bh, PALETTE["shadow"])
    c.rect(bx, by, bw, bh, PALETTE["ink"])
    c.rect(bx + 2, by + 2, bw - 4, bh - 4, fill)
    c.line_h(bx + 4, by + 3, bw - 8, top)
    c.line_v(bx + 3, by + 4, bh - 8, PALETTE["panel2"] if state != "passive" else PALETTE["line"])
    c.line_h(bx + 4, by + bh - 4, bw - 8, PALETTE["shadow"])
    c.line_v(bx + bw - 4, by + 4, bh - 8, PALETTE["shadow"])

    for px, py in ((0, 0), (1, 0), (0, 1), (bw - 1, 0), (bw - 2, 0), (bw - 1, 1),
                   (0, bh - 1), (1, bh - 1), (0, bh - 2), (bw - 1, bh - 1), (bw - 2, bh - 1), (bw - 1, bh - 2)):
        c.set_px(bx + px, by + py, PALETTE["transparent"])

    if state == "focus":
        fc = PALETTE["focus"]
        c.rect(bx - 2, by - 2, bw + 4, 2, fc)
        c.rect(bx - 2, by + bh, bw + 4, 2, fc)
        c.rect(bx - 2, by - 2, 2, bh + 4, fc)
        c.rect(bx + bw, by - 2, 2, bh + 4, fc)
        c.rect(bx + 6, by - 4, 14, 2, fc)
        c.rect(bx + bw - 20, by + bh + 2, 14, 2, fc)

    return bx, by, bw, bh, text, accent


def draw_wrench(c, x, y, accent, disabled=False):
    dark = PALETTE["ink"] if not disabled else PALETTE["line"]
    metal = PALETTE["cream"] if not disabled else PALETTE["muted"]
    c.rect(x + 7, y + 13, 4, 12, dark)
    c.rect(x + 9, y + 11, 4, 12, metal)
    c.rect(x + 11, y + 9, 4, 4, metal)
    c.rect(x + 13, y + 7, 9, 4, metal)
    c.rect(x + 17, y + 3, 4, 4, metal)
    c.rect(x + 20, y + 5, 3, 3, dark)
    c.rect(x + 4, y + 23, 7, 4, accent)
    c.rect(x + 3, y + 26, 5, 3, dark)


def draw_damage(c, x, y, accent, disabled=False):
    red = PALETTE["red"] if not disabled else PALETTE["muted"]
    red_dark = PALETTE["red_dark"] if not disabled else PALETTE["line"]
    c.rect(x + 6, y + 6, 16, 16, red_dark)
    c.rect(x + 8, y + 8, 12, 12, red)
    c.rect(x + 12, y + 12, 4, 4, PALETTE["cream"] if not disabled else PALETTE["panel_disabled"])
    c.line_h(x + 2, y + 14, 8, accent)
    c.line_h(x + 18, y + 14, 8, accent)
    c.line_v(x + 14, y + 2, 8, accent)
    c.line_v(x + 14, y + 18, 8, accent)
    c.rect(x + 19, y + 4, 3, 3, PALETTE["orange"] if not disabled else PALETTE["muted"])
    c.rect(x + 21, y + 2, 2, 2, PALETTE["cream"] if not disabled else PALETTE["line"])


def draw_health(c, x, y, accent, disabled=False):
    green = PALETTE["green"] if not disabled else PALETTE["muted"]
    green_dark = PALETTE["green_dark"] if not disabled else PALETTE["line"]
    c.rect(x + 6, y + 6, 18, 18, green_dark)
    c.rect(x + 8, y + 8, 14, 14, green)
    cross = PALETTE["cream"] if not disabled else PALETTE["panel_disabled"]
    c.rect(x + 13, y + 10, 4, 10, cross)
    c.rect(x + 10, y + 13, 10, 4, cross)
    c.rect(x + 4, y + 23, 7, 3, accent)
    c.rect(x + 21, y + 3, 3, 5, accent)


def draw_continue(c, x, y, accent, disabled=False):
    dark = PALETTE["ink"] if not disabled else PALETTE["line"]
    fill = PALETTE["cream"] if not disabled else PALETTE["muted"]
    c.rect(x + 4, y + 5, 20, 20, dark)
    c.rect(x + 6, y + 7, 16, 16, PALETTE["panel_dark"] if not disabled else PALETTE["panel_disabled"])
    c.rect(x + 11, y + 10, 4, 10, fill)
    c.rect(x + 15, y + 12, 4, 6, fill)
    c.rect(x + 19, y + 14, 3, 2, fill)
    c.rect(x + 3, y + 24, 7, 3, accent)
    c.rect(x + 21, y + 3, 3, 4, accent)


def draw_grime(c, x, y, w, h):
    flecks = [
        (17, 9), (24, 27), (43, 13), (66, 30), (89, 8), (118, 29), (151, 12), (172, 25)
    ]
    for fx, fy in flecks:
        c.set_px(x + fx % w, y + fy % h, PALETTE["line"])


def main():
    os.makedirs("img", exist_ok=True)
    atlas = Canvas(CELL_W * len(STATES), CELL_H * len(ROWS))
    metadata = {"cell_size": [CELL_W, CELL_H], "states": STATES, "buttons": {}}

    for row, (key, label) in enumerate(ROWS):
        metadata["buttons"][key] = {}
        for col, state in enumerate(STATES):
            x = col * CELL_W
            y = row * CELL_H
            bx, by, bw, bh, text_color, accent = draw_button(atlas, x, y, CELL_W, CELL_H, state)
            disabled = state == "passive"
            icon_x = bx + 13
            icon_y = by + 5
            if key == "repair":
                draw_wrench(atlas, icon_x, icon_y, accent, disabled)
            elif key == "buy_damage":
                draw_damage(atlas, icon_x, icon_y, accent, disabled)
            elif key == "buy_health":
                draw_health(atlas, icon_x, icon_y, accent, disabled)
            else:
                draw_continue(atlas, icon_x, icon_y, accent, disabled)

            text_x = bx + 48
            text_y = by + 10
            if state == "pressed":
                text_y += 1
            draw_text(atlas, text_x + 2, text_y + 2, label, PALETTE["shadow"], scale=2)
            draw_text(atlas, text_x, text_y, label, text_color, scale=2)
            draw_grime(atlas, bx + 2, by + 2, bw - 4, bh - 4)
            metadata["buttons"][key][state] = {
                "x": x,
                "y": y,
                "w": CELL_W,
                "h": CELL_H,
                "label": label,
                "text_rect": [text_x, text_y, measure_text(label, 2), 14],
                "icon_rect": [icon_x, icon_y, 28, 28],
            }

    write_png(OUT_PNG, atlas)
    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)
        f.write("\n")
    print(OUT_PNG)
    print(OUT_JSON)


if __name__ == "__main__":
    main()
