# Game rules

Written 2026-11-24. This file is the authority on how Detective Sudoku behaves. The engine in
`lib/engine/` implements it; where the two ever disagree, that is a bug in one of them and
gets fixed, not explained away. The sentences quoted here are produced by
`lib/engine/wording.dart` from the same clue object the engine checks, so the text and the
check cannot drift apart.

## 1. The game in one paragraph

A crime scene is a grid of squares split into named areas (Kitchen, Garden, Pond). Some
squares hold objects. A handful of people were on the scene: the suspects, each of whom makes
one or more statements, and the victim. You work out the square each person stood on. Whoever
was in the same area as the victim, with nobody else there, is the murderer.

## 2. Base rules

1. **One person per row and per column, on each grid.** Two people never share a row or a
   column of the same grid, and never share a square. *Why:* this is the rule that makes it a
   sudoku-like puzzle; every other deduction leans on it.
2. **Where a person can be.** A bare square can hold a person. A square with an object can
   hold a person only if the object is one you can be on (chair, bed, rug, boat). Objects
   that block (table, shelf, tree) leave their square unusable. Each setting says which is
   which (`docs/Settings.md`). Every kind of area can hold people, water included.
3. **A wide object is still squares.** A bed or a car drawn across two squares is two usable
   squares; a person on it stands on one of them.
4. **The victim makes no statement.** Nothing tells you directly where the victim was. The
   parser rejects a case in which the victim speaks. *Why:* finding the victim by elimination
   is the last step of every case and the reveal.
5. **The murderer.** The victim's area holds exactly two people: the victim and the murderer.
   A placement in which the victim is alone, or has two or more companions, is not a
   solution. *Why:* this is itself a rule you can reason with (see `docs/Techniques.md`,
   counting).
6. **One solution, no guessing.** A shipped case has exactly one placement that satisfies
   every rule and statement, and it can be reached by the named techniques alone. Both are
   checked by machine before a case ships (`docs/Levels.md`). *Why:* ambiguous cases are the
   top complaint in this genre.
7. **Everyone counts.** Words like "people", "person", "nobody else" and "everyone" include
   the victim. *Why:* the statements describe where everybody was while the victim was still
   alive.

### Grid shapes

- **Not square.** A grid can have more rows than columns or the other way round. The people
  fill the shorter side: a 6 by 8 grid holds 6 people, one in every row, and two columns
  stay empty. The game states this itself ("**2** columns stay empty.") whenever the people
  exactly fill the grids; it is never left for the player to work out.
- **Irregular outline.** Squares can be missing from a grid (cut corners). A missing square
  does not exist: nobody can be on it and it is not part of any row's usable squares.
- **Two grids.** A case can be split over two grids (two floors, two halves of a beach). The
  one-per-row-and-column rule applies inside each grid separately. Any person can be on any
  grid. An area lies on one grid only.
- **The cast must fit.** A case never has more people than its grids can hold (the shorter
  side of each grid, added up); the parser refuses one that does.
- **Doors and windows sit on walls.** A wall is the outline of a grid or the border between
  two areas. The parser refuses a door or window anywhere else.

## 3. Coordinates

Columns are lettered from the left (A, B, C...) and rows are numbered from the top (1, 2,
3...). A square is written column then row: B3. Statements name a row or column outright:
"She was in **column C**.", "He was in **row 2**."

*Why:* competitors lose stars over "the right column" (which one?) and "row 3" on an
unnumbered grid (counted from where?). Letters on one axis and numbers on the other mean a
row can never be mistaken for a column.

On a two-grid case each grid has its own letters and numbers; "row 2" means row 2 of
whichever grid the person is on, and the sentence says so: "She was in **row 2** of her
grid.", "He was in **column C** of his grid." *Why:* a bare "row 2" with two grids on screen
is the same ambiguity the letters and numbers were meant to remove.

## 4. Words with one meaning

Each word below means exactly this, everywhere in the game.

| Word | Meaning |
|---|---|
| **beside** an object | The object is directly above, below, left or right of the person's square **and in the same area**. Diagonals do not count. An object across a wall does not count. A person on a chair can be beside another chair. Being beside one does not rule out being beside more. |
| **on** an object | The person's own square holds that object. Only objects you can be on. |
| **in front of** a door or window | The door or window is on one side of the person's square. Both squares that share the door are in front of it. |
| **edge** of the grid | The square has at least one side on the outline of its grid (including the outline around a cut corner). |
| **corner of the grid** | The square has an outline side above or below it **and** an outline side left or right of it. On a plain rectangle these are the four corners; an irregular grid has more. |
| **corner of an area** | Same, with walls: a wall above or below and a wall left or right. A wall is the outline of the grid or the border between two areas. |
| **see** an object | Looking straight up, down, left or right from the person's square, the first object met is of that kind. Any object stops the view behind it. A wall stops the view unless it has a door or window at that point. The object on the person's own square does not count. People do not block the view. |
| had an object **in his/her row** (column) | Some other square of the same row (column) of the same grid holds that object. Walls and distance do not matter. |
| **alone** | Nobody else was in the person's area, not even the victim. |
| **alone with** X (and Y) | The person's area held exactly the person and the people named. |
| exactly N **other** people / men / women / people with a hat | Counting everyone except the speaker, exactly N of that description were in the speaker's area. |
| the **only** person who... | The statement is true of the speaker and false of everybody else, the victim included. |
| **everyone except** him/her | The statement is true of everybody else and false of the speaker. |
| in a row **above** / **below** X | On the same grid, in a row with a smaller / larger number than X. Any number of rows, any column. |
| in a column to the **left** / **right** of X | On the same grid, in a column with an earlier / later letter than X. Any number of columns, any row. |
| **above and to the left** of X (and the other three pairs) | Both at once. Any distance on each axis; not necessarily on a diagonal. |
| **exactly N rows above/below** X | On the same grid, row number differs by exactly N in that direction. The column is free. |
| **exactly N columns to the left/right** of X | Likewise for columns; the row is free. |
| same **diagonal** | On the same grid, as many rows apart as columns apart. |
| N **steps** from X | On the same grid, rows apart plus columns apart equals N. |
| **same position**, on another grid | Same row number and same column letter, on different grids. |
| **same grid** | On the same grid. |

Two people on the same grid are never in the same row or column, so no statement says so.

## 5. The clue catalogue

A *statement* has a speaker. A *general clue* has none and is always true. The "Tier" column
is the first tier whose cases the generator may give that clue to (`Family` in
`lib/gen/gen_clues.dart`); "-" means the engine supports it and hand-written cases may use
it, but the generator does not draw it yet. "Source": G = common in the genre, N = new here
(not in the puzzle books we studied, or sharpened beyond them).

In the notation, `A` and `B` are person ids, `K` and `G` area codes, `c` and `t` kind codes.
Any test can be turned round with `not` (`is not beside t`); the sentence then reads "was
**not**...", "could **not** **see**...", "had **no** tree in her **row**".

### Statements about the speaker's own square (`clue A is <test>`)

| Clue | Notation | Sentence shown | Tier | Source |
|---|---|---|---|---|
| In an area | `A is in K` | She was in the **Kitchen**. | tutorial | G |
| Not in an area | `A is not in K` | She was **not** in the **Kitchen**. | normal | G |
| In one of several areas | `A is in K\|G` | She was in the **Kitchen** or the **Garden**. | hard | G |
| On an object | `A is on c` | She was on a **chair**. | tutorial | G |
| Not on an object | `A is not on c` | She was **not** on a **chair**. | normal | G |
| Beside an object | `A is beside t` | She was beside a **table**. | tutorial | G |
| Not beside an object | `A is not beside t` | She was **not** beside a **table**. | normal | G |
| Object on exactly N sides | `A is beside t x2` | She had a **table** on exactly **2** sides. | hard | G (sharpened) |
| In a row | `A is row 2` | She was in **row 2**. | tutorial | G |
| In a column | `A is col 3` | She was in **column C**. | tutorial | G |
| Corner of the grid | `A is corner` | She was in a **corner** of the grid. | easy | G |
| Edge of the grid | `A is border` | She was on the **edge** of the grid. | normal | G |
| Not on the edge | `A is not border` | She was **not** on the **edge** of the grid. | normal | G |
| Corner of her area | `A is areacorner` | She was in a **corner** of her area. | normal | G |
| In front of a door / window | `A is front door` | She was in front of a **door**. | normal | G |
| Object in her row / column | `A is line row t` | She had a **table** in her **row**. | normal | G |
| Can see an object | `A is sees t` | She could **see** a **table**. | expert | N |
| Cannot see an object | `A is not sees t` | She could **not** **see** a **table**. | expert | N |
| On a grid | `A is grid Upstairs` | She was on the **Upstairs** grid. | hard (two grids) | G |

The sentence lists the areas of an either-or clue in the order the clue is written. The
generator always writes them in the order the case defines its areas, whichever one is
true, so the order tells the player nothing; a hand-written case must do the same. On a two-grid case the row and
column sentences end "of her grid" / "of his grid" (section 3).

### Statements about two people

| Clue | Notation | Sentence shown | Tier | Source |
|---|---|---|---|---|
| Row above / below | `A dir B -1 0` / `1 0` | She was in a row **above** **Ben**. | normal | G (reworded) |
| Column left / right | `A dir B 0 -1` / `0 1` | She was in a column to the **left** of **Ben**. | normal | G (reworded) |
| Both directions | `A dir B -1 1` | She was **above** and to the **right** of **Ben**. | normal | G (reworded) |
| Exactly N rows | `A offset B -2 *` | She was exactly **2 rows above** **Ben**. | normal | G |
| Exactly N columns | `A offset B * 1` | She was exactly **1 column to the right** of **Ben**. | normal | G |
| Exact rows and columns | `A offset B 2 -1` | She was exactly **2 rows below** and **1 column to the left** of **Ben**. | - | G |
| Same area | `A with B` | She was in the **same area** as **Ben**. | normal | G |
| Not same area | `A notwith B` | She was **not** in the same area as **Ben**. | hard | G |
| Same diagonal | `A diag B` | She was on the same **diagonal** as **Ben**. | hard | G |
| Steps apart | `A dist B 3` | She was exactly **3 steps** from **Ben** (rows plus columns). | expert | N |
| Same grid | `A samegrid B` | She was on the **same grid** as **Ben**. | hard (two grids) | G |
| Same position, other grid | `A samepos B` | She was in the **same position** as **Ben**, on another grid. | hard (two grids) | G |

In `dir`, the two numbers are the row sign and the column sign (-1 above or left, 1 below or
right, 0 free). In `offset` they are the speaker's row minus the other's row, and likewise
for columns; `*` leaves an axis free and 0 is refused because it is impossible.

### Statements about company

| Clue | Notation | Sentence shown | Tier | Source |
|---|---|---|---|---|
| Alone | `A alone` | She was **alone** in her area. | normal | G |
| Alone with | `A alonewith B C` | She was **alone with** **Ben** and **Cora** in her area. | hard | G |
| Exactly N others | `A others any 2` | She had exactly **2** other people in her area. | hard | N (sharpened) |
| Exactly N other men / women | `A others f 1` | She had exactly **1** other woman in her area. | hard | N (sharpened) |
| No other man / woman | `A others m 0` | She had **no** other man in her area. | hard | G |
| Exactly N others with a trait | `A others hat 1` | She had exactly **1** other person with a **hat** in her area. | hard | N |
| The only one | `A only on c` | She was the **only** person who was on a **chair**. | normal | G |
| Everyone except | `A allothers on c` | **Everyone except** her was on a **chair**. | - | G |

The generator never gives a company statement to someone standing in the victim's area: it
would name the murderer outright.

### General clues (`clue * ...`)

| Clue | Notation | Sentence shown | Tier | Source |
|---|---|---|---|---|
| Exactly N people | `* count 2 on c` | Exactly **2** people were on a **chair**. | hard | G |
| More in one area | `* more K G` | **More** people were in the **Kitchen** than in the **Garden**. | expert | N |
| Everyone of a kind | `* group hat border` | Everyone **with** a **hat** was on the **edge** of the grid. | hard | G (by trait: N) |

`group` takes who it is about (`m`, `f`, a trait such as `hat`, or `!hat` for people without
it) and then a test: `* group hat border`, `* group f not border`, `* group !hat beside t`.
The sentence starts "Every **man**", "Every **woman**", "Everyone **with** a **hat**" or
"Everyone **without** a **hat**".

### Traits

A person can carry traits (the generator uses `hat` and `glasses`) that the portrait shows.
Traits matter only when a clue names them. *Why:* it gives counting clues something besides
gender to count, and lets a general clue pick out a group.

## 6. Case rules

A case rule changes the rules for one case. The game shows it above the statements.

- **No touching** (`rule notouch`): "No two people were next to each other, **not even
  diagonally**." No two people on the same grid stand on squares that touch by a side or a
  corner. *New here; borrowed from star-battle puzzles.* Expert tier.
- **One liar** (`rule liar`): "Exactly **one** statement is **false**." Exactly one of the
  statements made by suspects is false; all the others are true. General clues and case
  rules are always true. A liar case needs at least two statements. *New here.* Expert tier.
- **Empty rows or columns**: not a rule to switch on but a consequence of the grid shape,
  stated automatically (section 2).

## 7. What came from the puzzle-book genre and what we changed

The base rules (one per row and column, objects you can and cannot be on, beside means
orthogonal and same area, the victim is found last, alone with the victim) are the genre's.
We did not copy any published puzzle, name, sentence or drawing. What we changed, and why:

| Genre habit | Here | Why |
|---|---|---|
| Compass words: "north of", "southeast of" | "in a row above", "above and to the right of" | Nobody has to learn which way north is on a phone screen. |
| "second column", "last column", unlabelled grids | Lettered columns, numbered rows, named in the clue | Removes the most-reported ambiguity. |
| "with two women" (and anyone else?) | "had exactly **2** other women in her area" | One reading only. |
| "beside a shelf" on a wide grid drawn in perspective | Same meaning, plus a tap on the clue shows the squares it allows (UI, not built yet) | The player can check their reading. |
| "There are six empty columns" as a clue | Stated by the game whenever the shape implies it | It is a fact about the grid, not something a suspect says. |
| Sitting "in" a chair, "inside" the car, "on" the bed | Always "on" | One word for one relation. |
| Rooms | Areas | Half our places are outdoors. |
| Portraits are decoration | Traits are decoration unless a clue names them | Same rule, said once. |

## 8. Later: researched, not built

None of these is in the engine. Each needs its own entry here, with exact wording, before it
is built.

- **Grid capacities and empty grids.** Several small grids, each marked with how many people
  it holds; some stay empty. Design: a per-grid capacity line in the case format and a case
  rule "every grid is full or empty".
- **Partly usable large objects.** A truck with a front and a back seat, a float with only
  its rear half usable. Design: per-square "can be on" flags for one drawn object, and clues
  naming the part.
- **"Someone who..." clues.** "He was left of someone on a chair." Design: a relation whose
  other person is "anyone passing this test".
- **Two-time-slot timeline.** The same scene at 9 pm and 10 pm, each person moving at most
  one area. Design: two placements linked by a movement rule.
- **Testimony revealed as you place.** Placing a suspect unlocks their next statement.
  Design: statements carry a "revealed after" person; the generator must certify the order.
- **Weapon and motive.** After the placement, deduce the weapon from which object the
  murderer was beside. Design: a second, small deduction on top of the solved grid.
- **Locked doors and keys.** A door that only the key holder can have passed. Design: needs
  the timeline first.
- **Conditional clues.** "If Anna was in the Kitchen, Ben was by a window." Design: a clue
  made of two tests; wording must stay readable.
- **Margin counts.** Numbers beside a row saying how many people there stood on a rug.
  Design: general clues drawn on the grid edge instead of in the list.
- **Role-only zones as a named rule.** "Only cooks may be in the Kitchen." Today this can be
  written as a group clue (`* group !cook not in K`); as a named case rule it would get its
  own sentence and its own icon on the area.
