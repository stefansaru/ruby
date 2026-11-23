"""Write one paste-ready image-generation prompt per art sheet.

Same contract as pushy's tool of the same name: a prompt whose sheet has been
accepted (sprites/<name>.png exists) is written to sprites/prompts/<name>.txt
and kept in git with the art; every other prompt is a draft and goes to
output/prompts/<name>.txt. Drafts are rewritten from scratch on every run, so
output/prompts/ always lists exactly the art that is still outstanding.

What must be drawn is NOT listed here by hand. The areas and the object kinds
are read from lib/data/settings.dart, the same file the generator builds
scenes from, so a new object there is a new cell here. This script only holds
what settings.dart cannot know: which floor an area uses (FLOOR_OF), how each
floor and object looks (FLOORS, LOOKS), and which sheet an object is on
(the SHEET_* lists). It stops with an error when settings.dart has an area or
an object this file does not place, or when this file places something
settings.dart no longer has. That check is what keeps the two in step; there
is no second copy of the lists to review (2026-11-24).

Sheets (docs/Art.md section 6):

  terrain                4 x 4  floors, butted, magenta grid (must tile)
  objects_sit            4 x 3  one-square objects a person can be on
  objects_indoor         4 x 3  one-square objects that block, indoors
  objects_outdoor        4 x 3  one-square objects that block, outdoors,
                                plus the door and the window
  objects_wide           4 x 4  two-square objects lying left-right
  objects_wide_vertical  4 x 4  the same objects lying top-bottom
  people                 4 x 3  suspect tokens, victim, reveal
  ui                     4 x 4  marks, buttons, coin, stamp
  icon                   1      the app icon
  feature_graphic        1      the store banner

Usage:  py -3 tool/write_sprite_prompts.py [--output output]
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SETTINGS = ROOT / "lib" / "data" / "settings.dart"

# ---------------------------------------------------------------------------
# Read settings.dart.


def read_settings():
    """Returns (areas, kinds): areas is {name: indoor}; kinds is
    {name: dict(sit=bool, wide=bool, settings=[ids])}."""
    text = SETTINGS.read_text(encoding="utf-8")
    areas, kinds = {}, {}
    blocks = re.split(r"SettingDef\(\s*'", text)[1:]
    if not blocks:
        sys.exit(f"{SETTINGS}: no SettingDef found - has the format changed?")
    for block in blocks:
        setting = block.split("'", 1)[0]
        for name, rest in re.findall(r"AreaSpec\(\s*'([^']+)'([^)]*)\)", block):
            indoor = "indoor: false" not in rest
            if areas.setdefault(name, indoor) != indoor:
                sys.exit(f"area {name!r} is indoor in one setting and outdoor in another")
        for name, rest in re.findall(r"KindSpec\(\s*'.'\s*,\s*'([^']+)'([^)]*)\)", block):
            sit = "sit: true" in rest
            wide = "wide: true" in rest
            k = kinds.setdefault(name, dict(sit=sit, wide=wide, settings=[]))
            if (k["sit"], k["wide"]) != (sit, wide):
                sys.exit(f"object {name!r} differs between settings (sit/wide); "
                         "one sprite cannot be both")
            k["settings"].append(setting)
    return areas, kinds


# ---------------------------------------------------------------------------
# Floors. Sixteen tiles cover every area; an area picks one by name.

FLOORS = [
    ("wood", "warm honey-brown WOODEN FLOORBOARDS running left-right"),
    ("tile", "pale cream-and-blue CHECKED FLOOR TILES, four small tiles per cell"),
    ("carpet", "soft plum-red CARPET with a faint woven texture"),
    ("stone", "grey STONE FLAGS, large irregular slabs with thin dark joints"),
    ("concrete", "plain light-grey CONCRETE with a few hairline cracks"),
    ("cobble", "rounded warm-grey COBBLESTONES"),
    ("deck", "weathered grey-brown SHIP DECK PLANKS running top-bottom"),
    ("metal", "dark blue-grey RIVETED METAL PLATE"),
    ("grass", "short bright GREEN GRASS with a few lighter tufts"),
    ("meadow", "taller yellow-green MEADOW GRASS with tiny white and yellow flowers"),
    ("soil", "brown TILLED SOIL in soft furrows"),
    ("forest", "dark green FOREST FLOOR with fallen needles and a few small leaves"),
    ("sand", "pale golden SAND with a few darker speckles"),
    ("rock", "rough grey-brown BARE ROCK"),
    ("path", "light tan PACKED-EARTH PATH with small pebbles"),
    ("water", "calm blue WATER with a few short lighter ripple strokes"),
]

FLOOR_OF = {
    # home
    "Kitchen": "tile", "Bedroom": "carpet", "Bathroom": "tile", "Living Room": "wood",
    "Hall": "wood", "Garden": "grass", "Garage": "concrete",
    # beach
    "Sand": "sand", "Sea": "water", "Pier": "deck", "Cafe": "wood", "Dunes": "meadow",
    "Rocks": "rock",
    # forest
    "Clearing": "grass", "Pines": "forest", "Lake": "water", "Cabin": "wood",
    "Path": "path", "Cave": "rock",
    # city
    "Street": "cobble", "Shop": "tile", "Square": "stone", "Bank": "carpet", "Park": "grass",
    # farm
    "Barn": "wood", "Field": "soil", "Yard": "path", "House": "carpet", "Pond": "water",
    "Orchard": "meadow",
    # school
    "Classroom": "wood", "Library": "carpet", "Gym": "wood", "Canteen": "tile",
    # train
    "Engine": "metal", "First Class": "carpet", "Second Class": "wood",
    "Dining Car": "tile", "Sleeper": "carpet", "Luggage Car": "metal",
    # ship
    "Deck": "deck", "Bridge": "wood", "Galley": "tile", "Hold": "metal", "Bow": "deck",
    # camp
    "Fire Ring": "path", "Tents": "grass", "Woods": "forest",
    # hotel
    "Lobby": "stone", "Room 1": "carpet", "Room 2": "wood", "Bar": "wood", "Pool": "water",
    # park
    "Lawn": "grass", "Playground": "sand", "Rose Garden": "meadow",
    # museum
    "Gallery": "wood", "Dino Room": "stone", "Gift Shop": "tile",
}

# ---------------------------------------------------------------------------
# Objects: how each looks, and which sheet it is on. Cell order is the order
# of the list; '-' leaves a cell empty.

LOOKS = {
    # a person can be on these
    "chair": "a small wooden CHAIR with a red seat cushion, seen from above and slightly in front",
    "seat": "a padded blue TRAIN SEAT with a headrest",
    "rug": "a round woven RUG in warm red and cream rings, flat on the floor",
    "mat": "a flat blue GYM MAT with a lighter border",
    "towel": "a striped yellow-and-white BEACH TOWEL laid flat",
    "sunbed": "a cream SUNBED with a turquoise mattress",
    "log": "a short fallen LOG to sit on, bark brown with pale cut ends",
    "bench": "a green slatted PARK BENCH",
    "hay bale": "a golden HAY BALE tied with two cords",
    "tent": "a small orange ridge TENT with its flap open",
    "swing": "a red playground SWING: a seat on two chains under a small frame",
    "bed": "a single BED with a wooden frame, a cream pillow and a blue blanket",
    "car": "a small rounded red CAR seen from above",
    "boat": "a wooden ROWING BOAT with two oars laid inside",
    "tractor": "a green farm TRACTOR with big rear wheels, seen from above",
    "lifeboat": "an orange LIFEBOAT with a cream rim",
    "canoe": "a slim yellow CANOE with one paddle inside",
    "sofa": "a plump teal two-seat SOFA with two cushions",
    # these block the square
    "table": "a square wooden TABLE with a small vase on it",
    "desk": "a school DESK with an open book and a pencil on it",
    "shelf": "a tall BOOKSHELF full of coloured books",
    "plant": "a leafy green POT PLANT in a terracotta pot",
    "lamp": "a tall LAMP POST with a glowing yellow lantern",
    "bin": "a round metal LITTER BIN with a lid",
    "trunk": "a brown travel TRUNK with brass corners and two straps",
    "crate": "a wooden CRATE with crossed planks",
    "barrel": "a wooden BARREL with two metal hoops",
    "vase": "a large blue-and-white VASE on a small plinth",
    "statue": "a grey stone STATUE: a simple bust on a pedestal",
    "skeleton": "a small museum DINOSAUR SKELETON on a low stand, cream bones, friendly not scary",
    "tree": "a round leafy green TREE with a short brown trunk",
    "palm": "a PALM TREE with a curved trunk and five fronds",
    "bush": "a thick round green BUSH with a few red berries",
    "rock": "a big grey BOULDER with a mossy patch",
    "umbrella": "a red-and-white striped BEACH UMBRELLA, open, seen from above and slightly in front",
    "campfire": "a small CAMPFIRE: a ring of stones, crossed logs, a cheerful orange flame",
    "fountain": "a round stone FOUNTAIN with blue water and a small jet",
    "cow": "a cute black-and-white COW standing, facing right",
    "pig": "a cute pink PIG standing, facing right",
}

SHEET_SIT = ["chair", "seat", "rug", "mat", "towel", "sunbed", "log", "bench",
             "hay bale", "tent", "swing", "-"]
SHEET_INDOOR = ["table", "desk", "shelf", "plant", "lamp", "bin", "trunk", "crate",
                "barrel", "vase", "statue", "skeleton"]
SHEET_OUTDOOR = ["tree", "palm", "bush", "rock", "umbrella", "campfire", "fountain",
                 "cow", "pig"]  # then door, window, one empty cell
SHEET_WIDE = ["bed", "car", "boat", "tractor", "lifeboat", "canoe", "sofa"]

CELL = 192  # sheet pixels per cell, as in pushy's object sheets

# ---------------------------------------------------------------------------
# Shared text.

GAME = (
    'These sprites are for "Detective Sudoku", a cosy murder-mystery logic puzzle for phones. '
    "The screen shows a small map seen from above: a grid of square cells divided into named areas "
    "(Kitchen, Garden, Pond...) by thick walls. Objects stand on some cells. The player reads short "
    "clues (\"She was beside a table\", \"He was on a chair\") and places one suspect token per row and "
    "column until only one square is left for the victim; whoever shared the victim's area is the "
    "murderer. The mood is a board game on a rainy afternoon: warm, tidy, friendly. Nothing is shown "
    "of the crime itself.\n\n"
    "In the game one cell is drawn 30-56 pixels wide, so everything must read instantly at that size, "
    "and the player must be able to tell at a glance WHICH object is on a cell, because the clues name "
    "objects."
)

STYLE = (
    "- Crisp, low-resolution retro RPG pixel art, like a classic 16-bit game.\n"
    "- Crisp square pixels, a dark 1-2 pixel outline, a limited warm palette, subtle pixel shading only.\n"
    "- No anti-aliasing, no blur, no gradients, no painterly rendering, no smooth vector edges, no 3D, "
    "no photorealism.\n"
    "- Hand-made look: simple shapes, a few well-chosen details, the same outline weight and the same "
    "light direction (from the top left) on every drawing.\n"
    "- Cosy and family-friendly: no blood, no weapons, no bodies, nothing frightening."
)

WHITE_GRID = (
    "- ONE image divided into EXACTLY {cols} columns x {rows} rows = {n} equal SQUARE cells, each cell "
    "{cell} x {cell} pixels, so the whole image is {w} x {h}.\n"
    "- Draw the cell borders as THIN 1-PIXEL SOLID BLACK LINES (#000000) between all cells and around "
    "the outside edge, so every cell is a closed box.\n"
    "- The background inside every cell is plain solid WHITE (#FFFFFF). It is cut away afterwards, so "
    "draw NO floor, NO grass, NO shadow and NO scenery behind anything.\n"
    "- NO PURE WHITE INSIDE A DRAWING: white is cut away by colour. Use cream, pale grey or pale blue "
    "instead, and give every drawing a dark 1-2 pixel outline all the way round.\n"
    "- No text, labels, numbers or arrows anywhere on the image."
)


def grid_text(cols, rows):
    return WHITE_GRID.format(cols=cols, rows=rows, n=cols * rows, cell=CELL,
                             w=cols * CELL, h=rows * CELL)


def cells_text(items, cols):
    """'Row 1: 1. ...; 2. ...' for a list of (label, look) or None."""
    lines = []
    for r in range(0, len(items), cols):
        parts = []
        for i, item in enumerate(items[r:r + cols], start=r + 1):
            parts.append(f"{i}. leave this cell EMPTY (plain white)" if item is None
                         else f"{i}. {item}")
        lines.append(f"Row {r // cols + 1}: " + "; ".join(parts) + ".")
    return "\n".join(lines)


def head(what):
    return (f"Create ONE pixel-art sheet of {what} for the game described below.\n\n"
            f"ABOUT THE GAME\n\n{GAME}\n\nART STYLE\n\n{STYLE}\n\n")


# ---------------------------------------------------------------------------
# The prompts.


def terrain_prompt(areas):
    used = {}
    for area in sorted(areas):
        used.setdefault(FLOOR_OF[area], []).append(area)
    rows = []
    for i, (name, look) in enumerate(FLOORS, start=1):
        where = ", ".join(used.get(name, [])) or "spare"
        rows.append(f"{i}. {look}. (Used for: {where}.)")
    listing = "\n".join(rows)
    return (
        head("sixteen FLOOR TILES")
        + "WHAT THESE ARE FOR\n\n"
        "Every cell of the map has a floor. Each area has one floor, repeated on all its cells, so each "
        "tile below must TILE SEAMLESSLY with copies of itself in all four directions: its left edge "
        "continues its right edge and its top continues its bottom. Walls between areas are drawn by "
        "the game, so draw NO walls, NO borders and NO frame inside a tile. Floors sit under objects "
        "and tokens, so keep them QUIET: low contrast, small texture, no large features, nothing that "
        "could be mistaken for an object. Indoor floors and outdoor floors must look clearly different "
        "from each other, and water must be unmistakable.\n\n"
        "WHAT TO DRAW - 16 CELLS, LEFT TO RIGHT, ROW BY ROW (four per row)\n\n"
        f"{listing}\n\n"
        "SHEET LAYOUT - ONE IMAGE, 4 COLUMNS x 4 ROWS\n\n"
        f"- ONE square image divided into EXACTLY 4 columns x 4 rows = 16 equal SQUARE cells, each "
        f"{CELL} x {CELL} pixels ({4 * CELL} x {4 * CELL} in all).\n"
        "- Each cell is FILLED EDGE TO EDGE with its floor: no margin, no white, no transparent "
        "pixels.\n"
        "- Separate the cells with 2-PIXEL lines of PURE MAGENTA (#FF00FF), and draw the same line "
        "around the outside. Magenta appears NOWHERE else on the image. These lines are how the tiles "
        "are found and cut, so they must be straight, unbroken and exactly this colour.\n"
        "- All sixteen tiles are seen from directly above, at the same scale: a floorboard, a "
        "flagstone and a ripple are all sized for a cell that is about one metre across.\n"
        "- No text, labels or numbers.\n\n"
        "FINAL CHECK\n\n"
        "- 4 x 4 cells, 2-pixel pure magenta lines, every cell filled edge to edge.\n"
        "- Each tile repeats seamlessly; no tile has a border or a picture in it.\n"
        "- Sixteen floors that cannot be confused with each other at 40 pixels.\n"
    )


def objects_prompt(title, purpose, names, extra=(), cols=4, rows=3):
    items = [None if n == "-" else LOOKS[n] for n in names] + list(extra)
    items += [None] * (cols * rows - len(items))
    return (
        head(title)
        + f"WHAT THESE ARE FOR\n\n{purpose}\n\n"
        f"WHAT TO DRAW - {cols * rows} CELLS, LEFT TO RIGHT, ROW BY ROW\n\n"
        f"{cells_text(items, cols)}\n\n"
        f"SHEET LAYOUT - ONE IMAGE, {cols} COLUMNS x {rows} ROWS\n\n"
        f"{grid_text(cols, rows)}\n"
        "- Each drawing is centred in its cell and fills about 80% of it, with a clear white margin of "
        "at least 10% on every side. NOTHING touches a grid line.\n"
        "- All drawings share one scale and one viewpoint: seen from above and slightly in front, as "
        "in a classic top-down RPG.\n\n"
        "FINAL CHECK\n\n"
        f"- {cols} x {rows} square cells, thin black grid, white background.\n"
        "- Every object is recognisable on its own at 40 pixels and cannot be mistaken for another "
        "object on this sheet.\n"
        "- No pure white inside anything; dark outlines everywhere.\n"
    )


SIT_RULE = (
    "Each of these fills ONE map cell and a suspect token can be placed ON it (\"She was on a chair\"). "
    "So each must read as something low and flat that you could sit, lie or stand on, and it must "
    "leave room for the token: keep the middle of the drawing simple and flat, with no tall part in "
    "the centre. Give all of them a LIGHT, WARM look and a soft rounded shape; this is how the player "
    "tells them apart from the objects that block a square."
)

BLOCK_RULE = (
    "Each of these fills ONE map cell and NOBODY can be on it: it blocks the square (a suspect can only "
    "be beside it). So each must read as tall, solid and in the way, filling its cell with a strong "
    "DARK silhouette. This is how the player tells them apart from chairs and rugs, which a token "
    "can be placed on."
)


def wide_prompt(vertical):
    names = SHEET_WIDE
    if vertical:
        layout = (
            "- ONE image divided into EXACTLY 4 columns x 4 rows of equal SQUARE cells, each cell "
            f"{CELL} x {CELL} pixels, so the whole image is {4 * CELL} x {4 * CELL}.\n"
            "- Each object is TWO CELLS TALL: it fills a cell and the cell directly BELOW it. Rows 1-2 "
            "hold four objects side by side (one per column), rows 3-4 hold four more.\n"
            "- Draw THIN 1-PIXEL SOLID BLACK LINES (#000000) between the COLUMNS, around the outside, "
            "and between row 2 and row 3. Draw NO line between rows 1 and 2 or between rows 3 and 4: "
            "an object crosses that boundary.\n")
        slots = [f"Column {i % 4 + 1}, rows {'1-2' if i < 4 else '3-4'}: {LOOKS[n]}, lying TOP TO "
                 f"BOTTOM (its head or front at the top)." for i, n in enumerate(names)]
        slots.append("Column 4, rows 3-4: leave EMPTY (plain white).")
        way = "top-bottom"
    else:
        layout = (
            "- ONE image divided into EXACTLY 4 columns x 4 rows of equal SQUARE cells, each cell "
            f"{CELL} x {CELL} pixels, so the whole image is {4 * CELL} x {4 * CELL}.\n"
            "- Each object is TWO CELLS WIDE: it fills a cell and the cell directly to its RIGHT. "
            "Columns 1-2 hold one object per row, columns 3-4 hold another.\n"
            "- Draw THIN 1-PIXEL SOLID BLACK LINES (#000000) between the ROWS, around the outside, and "
            "between column 2 and column 3. Draw NO line between columns 1 and 2 or between columns 3 "
            "and 4: an object crosses that boundary.\n")
        slots = [f"Row {i // 2 + 1}, columns {'1-2' if i % 2 == 0 else '3-4'}: {LOOKS[n]}, lying LEFT "
                 f"TO RIGHT (its head or front on the left)." for i, n in enumerate(names)]
        slots.append("Row 4, columns 3-4: leave EMPTY (plain white).")
        way = "left-right"
    listing = "\n".join(slots)
    return (
        head(f"seven LARGE OBJECTS, each two cells long, lying {way},")
        + "WHAT THESE ARE FOR\n\n"
        "Each of these covers TWO neighbouring map cells, and a suspect token can be placed on either "
        "half (\"He was on a bed\"). The two halves are cut apart and drawn on two cells, so the "
        "object must be spread evenly over both: no half may be nearly empty, and the middle of each "
        "half must be simple and flat enough to carry a token. Like the small objects a person can be "
        "on, they are LIGHT, WARM and rounded.\n\n"
        f"WHAT TO DRAW\n\n{listing}\n\n"
        "SHEET LAYOUT\n\n"
        f"{layout}"
        "- The background is plain solid WHITE (#FFFFFF); it is cut away afterwards. Draw NO floor and "
        "NO shadow. NO PURE WHITE inside a drawing (use cream or pale grey), and a dark 1-2 pixel "
        "outline all the way round.\n"
        "- Each object is centred in its two-cell slot with a white margin of about 8% on every side, "
        "and is the SAME object, in the same colours, as on the other sheet of large objects.\n"
        "- No text, labels or numbers.\n\n"
        "FINAL CHECK\n\n"
        f"- Eight two-cell slots, seven filled, each object lying {way} across exactly two cells.\n"
        "- Each half of each object still reads as part of that object when seen alone.\n"
    )


PEOPLE = [
    "a WOMAN token: a round-headed pawn seen from above and slightly in front, shoulder-length hair, "
    "a simple dress shape; face left blank except two dot eyes",
    "the same WOMAN wearing a wide-brimmed HAT",
    "the same WOMAN wearing round GLASSES",
    "the same WOMAN wearing the HAT and the GLASSES",
    "a MAN token: the same pawn shape with short hair and a simple jacket shape; two dot eyes",
    "the same MAN wearing a flat-topped HAT",
    "the same MAN wearing round GLASSES",
    "the same MAN wearing the HAT and the GLASSES",
    "the VICTIM marker: the same pawn, pale lilac instead of cream, with a small closed-eyes face and "
    "three tiny stars circling above its head (it has fainted; nothing gory)",
    "an UNKNOWN PERSON token: the pawn as a plain grey silhouette with a question mark shape cut out "
    "of its chest",
    "the CAUGHT reveal: the cream pawn with wide surprised eyes behind three dark vertical bars, as if "
    "seen through a jail window",
    None,
]


def people_prompt():
    return (
        head("the PEOPLE TOKENS")
        + "WHAT THESE ARE FOR\n\n"
        "Every suspect is a token on the map. The game draws a coloured disc under the token and the "
        "suspect's LETTER beside it, so the token itself carries NO letter and NO colour of its own: "
        "draw every suspect token in the same neutral CREAM with a dark outline. What the token must "
        "show is only what clues can mention: whether it is a man or a woman, and whether it wears a "
        "HAT and/or GLASSES. Those must be readable at 30 pixels, so make the hat and the glasses "
        "large and dark. These are board-game pawns, not portraits: no detailed faces.\n\n"
        "WHAT TO DRAW - 12 CELLS, LEFT TO RIGHT, ROW BY ROW\n\n"
        f"{cells_text(PEOPLE, 4)}\n\n"
        "SHEET LAYOUT - ONE IMAGE, 4 COLUMNS x 3 ROWS\n\n"
        f"{grid_text(4, 3)}\n"
        "- Each token is centred in its cell and fills about 70% of it. All tokens are exactly the "
        "same size and stand on the same line; the eight suspect tokens differ ONLY in hair, hat and "
        "glasses.\n\n"
        "FINAL CHECK\n\n"
        "- 4 x 3 cells, thin black grid, white background, no pure white inside a token.\n"
        "- Man and woman tell apart at 30 pixels; so do hat / no hat and glasses / no glasses.\n"
        "- No letters, no numbers, no realistic faces.\n"
    )


UI = [
    "a red hand-drawn CROSS mark (an X, two brush strokes) - 'not here'",
    "a small solid CANDIDATE DOT, dark blue, with a lighter rim - 'maybe here'",
    "a green TICK mark - 'placed and sure'",
    "a red ring HIGHLIGHT: an empty circle outline that would sit around a cell",
    "a HINT button face: a yellow light bulb on a round cream button",
    "a gold COIN with a magnifying-glass emblem",
    "a small STACK of three of the same gold coins",
    "a film-clapper 'WATCH' icon: a small play triangle on a clapperboard",
    "a round red rubber STAMP mark reading as a ring with a tick in it (no letters) - 'case solved'",
    "a brass MAGNIFYING GLASS",
    "an UNDO arrow curling to the left",
    "an ERASER, pink with a blue band",
    "a cream PAPER CARD panel with a torn bottom edge and a small pin at the top - the clue card; "
    "its centre is plain so text can be written on it and it can be stretched",
    "a rounded wooden BUTTON, plain, not pressed",
    "the same wooden BUTTON pressed in (darker, one pixel lower)",
    "a small gold STAR",
]


def ui_prompt():
    return (
        head("sixteen INTERFACE PIECES")
        + "WHAT THESE ARE FOR\n\n"
        "The marks a player puts on the map while solving, and the buttons and badges around it. The "
        "marks (cells 1-4) are drawn over floors and objects, so they need a strong dark outline and "
        "flat bright colour. The look is a detective's desk: paper, brass, wood, a rubber stamp. "
        "Letters and numbers, including the A-H and 1-8 labels around the map, are drawn by the game's "
        "font, so draw NO letters or numbers on anything.\n\n"
        "WHAT TO DRAW - 16 CELLS, LEFT TO RIGHT, ROW BY ROW\n\n"
        f"{cells_text(UI, 4)}\n\n"
        "SHEET LAYOUT - ONE IMAGE, 4 COLUMNS x 4 ROWS\n\n"
        f"{grid_text(4, 4)}\n"
        "- Each piece is centred in its cell and fills about 80% of it. NOTHING touches a grid "
        "line.\n\n"
        "FINAL CHECK\n\n"
        "- 4 x 4 cells, thin black grid, white background, no pure white inside a piece.\n"
        "- No letters or numbers anywhere.\n"
    )


def icon_prompt():
    return (
        "Create ONE square app icon, 1024 x 1024 pixels, for the game described below.\n\n"
        f"ABOUT THE GAME\n\n{GAME}\n\nART STYLE\n\n{STYLE}\n\n"
        "WHAT TO DRAW\n\n"
        "A 3 x 3 piece of the game's map seen from above, filling the icon: nine square cells with "
        "thick dark walls splitting them into two or three areas with different floors (wooden "
        "boards, green grass, blue water). On it: one chair, one tree, and two cream pawn tokens on "
        "different rows and columns. Over the lower right corner, large, a brass MAGNIFYING GLASS "
        "tilted at 45 degrees, its lens over one of the tokens. Big chunky pixels: the whole icon "
        "should look as if drawn on a 64 x 64 grid and scaled up.\n\n"
        "RULES\n\n"
        "- The picture fills the whole square, edge to edge, on a warm deep-red background showing "
        "behind the map's rounded corners. No transparent pixels, no border, no drop shadow.\n"
        "- Keep everything important inside the central 66% of the square: the icon is cropped to a "
        "circle or a rounded square on some phones.\n"
        "- NO text, NO letters, NO numbers.\n"
        "- It must still read at 48 x 48 pixels: a grid, two pawns, a magnifying glass.\n"
    )


def feature_prompt():
    return (
        "Create ONE wide banner image, 1024 x 500 pixels, for the store page of the game described "
        "below.\n\n"
        f"ABOUT THE GAME\n\n{GAME}\n\nART STYLE\n\n{STYLE}\n\n"
        "WHAT TO DRAW\n\n"
        "On the RIGHT two thirds: a 6 x 6 map seen from above, in the game's pixel art - a house with a "
        "Kitchen (checked tiles), a Living Room (wooden boards), a Bedroom (carpet) and a Garden "
        "(grass), divided by thick dark walls, with a table, two chairs, a bed, a bookshelf, a rug and "
        "two trees, and five cream pawn tokens standing on different rows and columns. A brass "
        "magnifying glass rests over one corner of the map. On the LEFT third: plain warm deep-red "
        "background with a subtle paper texture, left EMPTY so the game's name can be added later.\n\n"
        "RULES\n\n"
        "- Exactly 1024 x 500, filled edge to edge, no transparent pixels, no border.\n"
        "- NO text, NO letters, NO numbers, no logos.\n"
        "- Nothing important within 40 pixels of any edge.\n"
        "- Cosy and inviting: a puzzle to settle into, not a crime scene.\n"
    )


# ---------------------------------------------------------------------------


def check(areas, kinds):
    """settings.dart and this file must agree; say exactly where they do not."""
    problems = []
    floor_names = {name for name, _ in FLOORS}
    for area in sorted(areas):
        if area not in FLOOR_OF:
            problems.append(f"area {area!r} has no floor: add it to FLOOR_OF")
        elif FLOOR_OF[area] not in floor_names:
            problems.append(f"area {area!r} uses unknown floor {FLOOR_OF[area]!r}")
    for area in sorted(set(FLOOR_OF) - set(areas)):
        problems.append(f"FLOOR_OF lists area {area!r}, which settings.dart no longer has")
    placed = {}
    for sheet, names in (("objects_sit", SHEET_SIT), ("objects_indoor", SHEET_INDOOR),
                         ("objects_outdoor", SHEET_OUTDOOR), ("objects_wide", SHEET_WIDE)):
        for n in names:
            if n == "-":
                continue
            if n in placed:
                problems.append(f"object {n!r} is on two sheets")
            placed[n] = sheet
    for name, k in sorted(kinds.items()):
        if name not in LOOKS:
            problems.append(f"object {name!r} has no description: add it to LOOKS")
        sheet = placed.get(name)
        if sheet is None:
            problems.append(f"object {name!r} is on no sheet: add it to a SHEET_* list")
        elif k["wide"] != (sheet == "objects_wide"):
            problems.append(f"object {name!r}: wide={k['wide']} but it is on {sheet}")
        elif not k["wide"] and k["sit"] != (sheet == "objects_sit"):
            problems.append(f"object {name!r}: sit={k['sit']} but it is on {sheet}")
    for name in sorted(set(placed) - set(kinds)):
        problems.append(f"object {name!r} is on {placed[name]} but settings.dart no longer has it")
    if problems:
        sys.exit("write_sprite_prompts.py and lib/data/settings.dart disagree:\n  "
                 + "\n  ".join(problems))


def build_prompts():
    areas, kinds = read_settings()
    check(areas, kinds)
    door = ("a DOOR seen from above: a short brown wooden bar with a brass handle, lying LEFT-RIGHT "
            "across the middle of the cell (the game lays it over a wall line and rotates it)")
    window = ("a WINDOW seen from above: a short pale-blue glass bar in a cream frame, lying "
              "LEFT-RIGHT across the middle of the cell")
    return {
        "terrain": terrain_prompt(areas),
        "objects_sit": objects_prompt(
            "eleven SMALL OBJECTS A PERSON CAN BE ON", SIT_RULE, SHEET_SIT),
        "objects_indoor": objects_prompt(
            "twelve INDOOR OBJECTS THAT BLOCK A SQUARE", BLOCK_RULE, SHEET_INDOOR),
        "objects_outdoor": objects_prompt(
            "nine OUTDOOR OBJECTS THAT BLOCK A SQUARE, plus a door and a window",
            BLOCK_RULE + " The last two drawings, the door and the window, are different: they are "
            "thin bars laid over the wall between two cells, and block nothing.",
            SHEET_OUTDOOR, extra=[door, window]),
        "objects_wide": wide_prompt(vertical=False),
        "objects_wide_vertical": wide_prompt(vertical=True),
        "people": people_prompt(),
        "ui": ui_prompt(),
        "icon": icon_prompt(),
        "feature_graphic": feature_prompt(),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--output", type=Path, default=ROOT / "output")
    args = ap.parse_args()

    # A prompt whose sheet has been accepted - sprites/<name>.png exists - is
    # kept with the art in git; every other prompt is a draft. Drafts are
    # rewritten from scratch each run so a stale one never lingers.
    accepted_dir = ROOT / "sprites" / "prompts"
    drafts_dir = args.output / "prompts"
    accepted_dir.mkdir(parents=True, exist_ok=True)
    if drafts_dir.exists():
        for old in drafts_dir.glob("*.txt"):
            old.unlink()
    drafts_dir.mkdir(parents=True, exist_ok=True)

    for name, text in build_prompts().items():
        accepted = (ROOT / "sprites" / f"{name}.png").exists()
        path = (accepted_dir if accepted else drafts_dir) / f"{name}.txt"
        path.write_text(text, encoding="utf-8")
        tag = "accepted" if accepted else "draft"
        print(f"{tag:8} {path}  ({len(text.split())} words)")


if __name__ == "__main__":
    main()
