# Art

What Detective Sudoku needs drawn, in what format, and how a drawing becomes
an asset. Written 2026-11-24; every rule carries its reason.

**No art exists yet.** This round delivers the needs list, the sheet formats
and the prompts. `sprites/` holds no sheet, `assets/` holds no image, and the
app draws nothing. The steps that remain are in `TODO.md`.

The pipeline is pushy's (`pushy/docs/Art.md` sections 6, 8 and 8a), reused
because it already paid for its lessons: the owner generates sheets from
prompts written here, accepted sheets are tracked with their prompts, and
tools cut them into assets.

## 1. Direction

- **Top-down pixel art, 16-bit RPG look.** Crisp square pixels, a dark 1-2
  pixel outline, a limited warm palette. Reason: it is the studio's look
  (pushy), the owner chose it on 2026-11-24, and low-resolution art stays
  readable at the 30-56 px a square gets on a phone.
- **Cosy and bloodless.** No blood, weapons or bodies anywhere, including the
  victim marker and the icon. Reason: the tone decision of 2026-11-24, and a
  store rating that stays low (`docs/strategy/RiskAnalysis.md`).
- **An object must be nameable at a glance.** Clues name objects ("beside a
  table"), so a player who cannot tell a table from a desk cannot solve the
  case. This is a recorded complaint about a competitor whose realistic art
  hid the clue objects (`docs/strategy/MarketResearch.md`). Reason enough to
  prefer a plain icon-like drawing over a pretty one.
- **Objects a person can be on must read differently from objects that
  block.** The first group (chair, rug, bed...) is drawn light, warm, low and
  rounded, with a flat middle that leaves room for a token. The second
  (table, tree, shelf...) is drawn tall, dark and solid, filling its square.
  Reason: "can I put someone here?" is the first question about every square,
  and the answer must not depend on memorising a list.
- **Wide objects span two squares**, left-right or top-bottom, and a person
  can be on either half. Each orientation is drawn, not rotated. Reason: the
  view is "from above and slightly in front", so a rotated bed would show its
  front on its side.
- **Icons over portraits.** People are board-game pawns, not faces. Reason:
  see section 9.

## 2. The scene: floors

Every square has a floor; an area uses one floor on all its squares. Sixteen
floor tiles cover all 12 settings, because many areas share a material and a
floor only has to say "indoors, wood" or "water", not "this is the Library"
(the area's name is written on it by the game).

| # | Floor | Areas that use it |
|---|---|---|
| 1 | wood | Bar, Barn, Bridge, Cabin, Cafe, Classroom, Gallery, Gym, Hall, Living Room, Room 2, Second Class |
| 2 | tile | Bathroom, Canteen, Dining Car, Galley, Gift Shop, Kitchen, Shop |
| 3 | carpet | Bank, Bedroom, First Class, House, Library, Room 1, Sleeper |
| 4 | stone | Dino Room, Lobby, Square |
| 5 | concrete | Garage |
| 6 | cobble | Street |
| 7 | deck | Bow, Deck, Pier |
| 8 | metal | Engine, Hold, Luggage Car |
| 9 | grass | Clearing, Garden, Lawn, Park, Tents |
| 10 | meadow | Dunes, Orchard, Rose Garden |
| 11 | soil | Field |
| 12 | forest | Pines, Woods |
| 13 | sand | Playground, Sand |
| 14 | rock | Cave, Rocks |
| 15 | path | Fire Ring, Path, Yard |
| 16 | water | Lake, Pond, Pool, Sea |

The mapping lives in `FLOOR_OF` in `tool/write_sprite_prompts.py`, which
refuses to run when an area in `lib/data/settings.dart` has no floor. This
table is a copy for reading; the script is the authority.

Known weakness: two neighbouring areas of one case can draw the same floor
(Hall and Living Room are both wood). The wall and the name label still
separate them, and the game may tint the second one; whether that is enough
is an owner review item once tiles exist.

Floors must be quiet (low contrast, no large features) because objects,
tokens, notes and labels all sit on top of them.

## 3. The scene: walls, doors, windows, outside

- **Walls are drawn by the game, not sprited**: a thick dark line along every
  border between two areas and around the grid. Reason: areas have any shape,
  including the cut corners of irregular grids, and a line drawn in code is
  exact at every size, where a wall tileset needs a piece for every join
  (pushy's terrain page failed on exactly that, `pushy/docs/Art.md` 8a).
- **Door** and **window**: one sprite each, a short bar laid over a wall line,
  rotated by the game for vertical walls. They are flat and seen from straight
  above, so rotation is safe here. They sit on the `objects_outdoor` sheet.
- **Outside the grid** (squares cut out of an irregular grid, and the margin):
  the screen background, drawn by code as a plain dark colour. No sprite.
  Reason: a missing square must look like nothing, so it is never mistaken
  for a blocked one.

## 4. The scene: objects

Thirty-nine kinds across the 12 settings, read from `lib/data/settings.dart`.
An object shared by several settings is drawn once.

**A person can be on these (one square), 11:**

| Object | Settings |
|---|---|
| chair | home, beach, forest, city, farm, school, ship, camp, hotel, park, museum |
| seat | train |
| rug | home, forest, train, ship |
| mat | school |
| towel | beach |
| sunbed | beach, hotel |
| log | forest, camp |
| bench | city, school, park, museum |
| hay bale | farm |
| tent | camp |
| swing | park |

**A person can be on these (two squares), 7, each in two orientations:**

| Object | Settings |
|---|---|
| bed | home, farm, train, ship, hotel |
| car | home, city |
| boat | beach, forest, park |
| tractor | farm |
| lifeboat | ship |
| canoe | camp |
| sofa | hotel |

**These block their square, 21:**

| Object | Settings |
|---|---|
| table | every setting |
| desk | school, hotel |
| shelf | home, city, school, train, museum |
| plant | home, hotel, museum |
| lamp | city, train |
| bin | city, school |
| trunk | train |
| crate | ship |
| barrel | ship |
| vase | museum |
| statue | museum |
| skeleton | museum |
| tree | home, forest, city, farm, school, camp, hotel, park |
| palm | beach |
| bush | forest, park |
| rock | beach, forest, camp |
| umbrella | beach |
| campfire | camp |
| fountain | park |
| cow | farm |
| pig | farm |

Sheets are grouped by what an object does, not by setting. Reason: most
objects are shared, so per-setting sheets would draw the chair eleven times in
eleven slightly different ways, and the "light and low" against "dark and
tall" rule of section 1 is easiest to hold when all of one group is on one
page, drawn in one go.

The settings table in `docs/Settings.md` and this list both come from
`lib/data/settings.dart`. Adding an object there makes the prompt writer stop
until the object has a description and a sheet cell.

## 5. People, marks and interface

**People** (sheet `people`, 12 cells):

- Suspect tokens: woman and man, each plain, with a hat, with glasses, and
  with both: 8 tokens. These are the only things about a person a clue can
  mention (gender, hat, glasses), so they are the only things a token shows.
- All suspect tokens are the same neutral cream. The game draws a coloured
  disc under the token and the suspect's letter beside it. Reason: colour and
  letter come from the case, not from the drawing, so 8 sprites serve every
  cast, and the letter stays sharp and translatable as text.
- Victim marker: the pawn in pale lilac, fainted, with small stars. Nothing
  gory.
- Unknown person: a grey silhouette, for card slots not yet revealed.
- Caught: the pawn behind bars, for the reveal when a case is solved.

**Marks and interface** (sheet `ui`, 16 cells): cross ("not here"), candidate
dot ("maybe here"), tick, ring highlight, hint button, coin, coin stack,
watch-an-ad icon, case-solved stamp, magnifying glass, undo, eraser, clue card
panel, button and pressed button, star.

**Drawn by the font, not sprited:** the column letters and row numbers around
the grid, the suspect letters, area names, and all clue text. Reason: text in
a sprite cannot be translated or resized, and the coordinates are the fix for
the genre's top complaint (ambiguous rows and columns), so they must be the
sharpest thing on screen. The font itself is an open item in `TODO.md`.

**Store art:** the app icon (`icon`, 1024 x 1024) and the store banner
(`feature_graphic`, 1024 x 500). Neither carries text; the name is added on
the banner by hand, so it can change without a new drawing.

## 6. Sheets

Ten prompts, written by `tool/write_sprite_prompts.py`:

| Sheet | Grid | Cells used | Background | Holds |
|---|---|---|---|---|
| `terrain` | 4 x 4 | 16 | butted, magenta lines | the 16 floors |
| `objects_sit` | 4 x 3 | 11 | white, black lines | one-square objects a person can be on |
| `objects_indoor` | 4 x 3 | 12 | white, black lines | indoor blocking objects |
| `objects_outdoor` | 4 x 3 | 11 | white, black lines | outdoor blocking objects, door, window |
| `objects_wide` | 4 x 4 | 14 (7 slots of 2) | white, black lines | wide objects, left-right |
| `objects_wide_vertical` | 4 x 4 | 14 (7 slots of 2) | white, black lines | wide objects, top-bottom |
| `people` | 4 x 3 | 11 | white, black lines | tokens |
| `ui` | 4 x 4 | 16 | white, black lines | marks and interface |
| `icon` | single | 1 | filled | app icon |
| `feature_graphic` | single | 1 | filled | store banner |

Format rules, all taken from pushy with their reasons:

- **A sheet cell is 192 x 192 px**; no sheet has more than 16 cells. Reason:
  pushy's small object sheets (4 x 3 and 4 x 4 at this size) came back with a
  regular grid; its larger grids drifted.
- **Object sheets: thin black grid lines on plain white**, each drawing
  centred with a 10 % margin, no pure white inside a drawing. Reason: the
  cutter finds the lines rather than assuming them, and removes white by
  flood fill from the cell edge, which the dark outline stops.
- **Terrain: butted edge to edge, with 2 px pure magenta (#FF00FF) lines.**
  Reason: a floor must tile, so it cannot have a margin, and a floor is too
  dark for black lines to be found against; magenta is found exactly however
  far the cells drift.
- **A wide object's two halves share one slot with no line between them.**
  Reason: a line through the middle invites the model to draw two objects.
- **Assets are built at 24, 32, 40 and 48 px per square**, like pushy. Reason:
  pixel art scales cleanly only by whole steps, and these four cover the
  square sizes a 4 x 4 to 9 x 9 grid gets on phones and tablets.

## 7. Asset tree

```
sprites/                  accepted sheets, <name>.png        (tracked)
sprites/prompts/          the prompt of each accepted sheet  (tracked)
assets/
  art/<res>/              terrain.png, objects.png, people.png   atlases,
                          <res> = 24, 32, 40, 48
  ui/                     marks and interface pieces
  icon/                   the app icon sources
  fonts/                  the game font
input/                    raw sheets the owner drops in      (ignored)
output/prompts/           draft prompts                      (ignored)
output/                   cut frames, previews               (ignored)
```

None of `assets/` exists yet. Each folder is listed in `pubspec.yaml` when its
first file arrives, not before, so the build never names an empty folder.

## 8. Pipeline

1. `py -3 tool/write_sprite_prompts.py` writes every outstanding prompt to
   `output/prompts/<name>.txt`. That folder is therefore the list of art
   still to make. Today it holds all ten.
2. The owner pastes a prompt into the image generator and drops the result in
   `input/`.
3. The sheet is cut and previewed (step 5's tools) and the owner reviews the
   preview at real size, on a floor, with a token on it.
4. An accepted sheet moves to `sprites/<name>.png`. The next run of step 1
   then writes its prompt to `sprites/prompts/<name>.txt` and stops writing a
   draft, so the prompt that worked is kept beside the art it made. A sheet
   that needs changes has its prompt changed in the script, never in the
   `.txt`, because the `.txt` is rewritten on every run.
5. The cutter builds `assets/` from `sprites/`.

**Step 5 is not built.** `pushy/tool/cut_sheet.py` was not copied: it imports
pushy's character animation spec (`prepare_sprites.py`) and its default mode
cuts 9 x 11 creature sheets, so it does not run unchanged here. Its named-tile
mode (`--names --grid`, with `--even --opaque` for terrain) is the part ruby
needs, about a third of the file. Porting that part, plus a small atlas
builder after `pushy/tool/build_art.py`, is a `TODO.md` item to do when the
first sheet arrives, so it is tested against a real sheet and not a guess.
Two-square slots and magenta-line finding need care there: pushy's cutter
expects every cell boundary to be a drawn line.

Lessons carried over from pushy's cutter, to apply when porting:

- Find grid lines, never assume equal spacing; generated rows drift.
- Remove background by flood fill from the cell edge, not "white means
  transparent", or pale objects are eaten.
- Generated art is not true pixel art; it is pixelated down to the target
  size, and the light fringe along outlines is dropped first.

## 9. The risk: art that looks machine-made

Players of this genre punish art they read as AI-generated: one competitor
lost a star in a featured review over it and another drew a one-line "AI art"
review (`docs/strategy/MarketResearch.md`). Our sheets are generated from
prompts, so the risk applies to us directly and is not solved by this
document.

What is done about it, and why each helps:

- **One consistent pixel style on every sheet**, with the same outline, light
  and palette rules in every prompt. The tell of generated art is
  inconsistency between pieces more than any single piece.
- **Icons, not portraits.** Suspects are pawns with a letter. Painted suspect
  portraits are where the complaints landed, and they add nothing a clue uses.
- **Pixelated to a small fixed size by our own tool.** Low-resolution art cut
  to 24-48 px leaves little room for the smeared detail people recognise.
- **Owner review of every sheet before it is accepted**, at real size, with
  redrawing or hand correction of anything that looks off. Nothing reaches
  `sprites/` unreviewed.

What is not decided: whether to say in the store listing how the art is made.
That is an owner decision (section 10). The rule that already holds is risk R3
in `docs/strategy/RiskAnalysis.md`: say nothing false about how the art is made.

## 10. Open points for the owner

- View for wide objects: drawn in both orientations (this document) or strict
  top-down and rotated by code (half the drawing, flatter look).
- The victim marker (fainted pawn with stars): cosy enough, or too light for a
  murder mystery?
- Suspect colour as a disc under a neutral token (this document), or tokens
  drawn in several colours.
- The font: pushy ships OpenDyslexic; whether ruby uses the same.
