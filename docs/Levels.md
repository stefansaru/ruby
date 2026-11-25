# Levels: the case format, the gates and the packs

Written 2026-11-24. A level is called a **case**. A case is a piece of text plus a certified
solution. This file describes the text format, what a case must satisfy before it ships, the
difficulty ladder, and how the shipped packs are stored and rebuilt.

## 1. The case text format

One line per fact. Blank lines and lines starting with `#` are ignored. The reader is
`parseCase` and the writer is `writeCase`, both in `lib/engine/case_text.dart`. The parser is
also the validator: a case that parses is well formed. *Why:* one door in, so nothing
malformed can reach the game by another route.

### Example

The starter case from `test/engine/fixtures.dart`:

```
case test-starter
title The Quiet Garden
setting home
area G Garden
area K Kitchen
area P Pond
kind c sit chair
kind t block table
kind r block tree
grid Home 4 4
Gr. G.. G.. K..
G.. Gc. K.. Kt.
P.. G.. K.. K..
Pr. P.. P.. K..
person A Anna f
person B Ben m
person C Cora f
victim D Dan m
clue A is on c
clue B is beside t
clue C is in P
clue C is beside r
solution A=1:2:2 B=1:1:4 C=1:3:1 D=1:4:3
```

Anna is on the only chair (B2). Ben is beside the table, in the Kitchen, and row 2 is
Anna's, so he is at D1 or D3. Cora is in the Pond beside the tree: A3 or B4, and column B is
Anna's, so A3. That takes row 3, so Ben is at D1. Dan, the victim, gets the last free row
and column: C4, in the Pond with Cora. Cora is the murderer.

### Lines

| Line | Form | Notes |
|---|---|---|
| `case` | `case <id>` | Required. |
| `title` | `title <text>` | Shown to the player. |
| `setting` | `setting <id>` | A setting id from `lib/data/settings.dart`; chooses the art. |
| `rule` | `rule liar` or `rule notouch` | Case rules (`docs/GameRules.md` section 6). |
| `area` | `area <code> <name>` | One-character code, then the name (may contain spaces). |
| `kind` | `kind <code> sit\|block <name>` | An object kind. `sit`: a person can be on it. `block`: it makes its square unusable. |
| `grid` | `grid <name> <rows> <cols>` then one line per row | The name is one word; use `_` for a space (`Ground_Floor`). Sides are 1 to 26. Areas and kinds must be defined above the grid that uses them. |
| `open` | `open <grid name> <row> <col> N\|E\|S\|W door\|window` | A door or window on that side of that square. Rows and columns count from 1. That side must be a wall: the outline of the grid or the border between two areas. |
| `person` | `person <id> <name> m\|f [trait,trait]` | A suspect. One-character id. `_` in a name becomes a space. Traits are a comma-separated list with no spaces. Nothing may follow the traits. |
| `victim` | `victim <id> <name> m\|f [traits]` | Exactly one per case. Shipped cases: id V, listed last (GEN-030, checked by `checkShipped`, not the parser). |
| `clue` | `clue <id> ...` or `clue * ...` | A statement by that person, or a general clue. The notation for every clue is in the catalogue in `docs/GameRules.md` section 5. |
| `extra` | `extra <id> ...` | An extra statement by that person, in the same notation (GEN-035). True, never needed, shown only when the player asks. Needs a `solution` line to be checked against. |
| `solution` | `solution <id>=<grid>:<row>:<col> ...` | The certified answer: every person, grid number (1 for the first grid), row and column from 1. |

### Squares

Each square of a grid row is three characters:

1. the area code;
2. the kind code of the object on it, or `.` for none;
3. an instance mark: `.` for an object that stands alone, or any other character shared by
   the touching squares of one wide object (the two halves of a bed are `Kb1 Kb1`).

`---` means the grid has no square there (irregular outline). The instance mark is for
drawing only; rules and clues look at the kind of each square, never at which bed it is.

### What the parser rejects

Each with a message and the line number:

- an unknown line, rule, test, clue or selector; a wrong number of words on a line;
- an area, kind, person or grid defined twice;
- a square that is not three characters, or names an unknown area or kind, or has an
  instance mark without an object;
- a grid row with the wrong number of squares, a grid cut short, a side outside 1 to 26;
- an area with no squares, spread over two grids, or in more than one piece;
- no `case` line, no grid, fewer than two people, or not exactly one victim;
- more people than the grids can hold (the shorter side of each grid, added up);
- a door or window on a side that is not a wall;
- a row or column number that exists on no grid (`row 99`);
- stray words after a clue that takes none (`alone again`, `with B C`) or after a
  person's traits;
- a clue that names an unknown person, area, kind or grid; a clue relating a person to
  themselves; "on" an object nobody can be on; a trait nobody has; a `dir` that is not
  -1, 0 or 1 or is 0 on both axes; an `offset` with no axis or with a 0;
- a statement made by the victim;
- `rule liar` with fewer than two statements;
- an `extra` with no speaker, by the victim, false in the solution, or with no `solution`
  line (GEN-035, 2026-11-25);
- an `open` or `solution` entry pointing outside a grid or at a missing square;
- a solution that does not place everyone, or that breaks a placement rule, the victim
  rule, a clue or the liar rule.

What the parser does **not** check: that the case has only one solution, or that it can be
solved without guessing. Those need the solvers and are generator gates (below), the sweep
(`tool/check_cases.dart`) and tests.

## 2. What a shipped case must satisfy

The generator (`lib/gen/gen_case.dart`) draws a case and puts it through these gates in this
order. A draw that fails a gate is thrown away and the next one is drawn, up to the slot's
attempt limit. The tool prints, per tier, how many draws passed each gate (the **funnel**),
so a slot that keeps failing shows where.

| # | Gate | Passes when | Why |
|---|---|---|---|
| 1 | scene | A scene was drawn with a placement that obeys the rules: areas of sensible size, one person per row and column on usable squares, the victim alone with one suspect. | Nothing else is worth checking on a scene with no valid answer. |
| 2 | unique | A clue list was found and the exact solver finds exactly one placement, the intended one. | One solution is the first promise to the player. |
| 3 | wellFormed | The case, written as text, parses, and writes back to the same text. | What ships is the text; the text must carry everything. |
| 4 | logic | The logic solver finishes the parsed case. | No guessing is the second promise. |
| 5 | tier | The hardest technique needed lies in the requested tier's range. | "Easy" must be easy and "hard" must be hard. |
| 6 | variety | The clues come from at least two clue families (three from normal up) and no family supplies more than six clues in ten. | A case that says the same sentence eight times is dull. |

How the clue list is chosen (`lib/gen/gen_clues.dart`): every true statement the tier allows
is listed; each suspect is given one; then, while other placements still fit, the statement
that rules out most of them is added (at most two per suspect, three from hard up, and two
general clues); finally every statement the case does not need is dropped, as long as each
suspect keeps one. In a liar case one suspect is first given a false statement.

## 3. The tier ladder

A case's tier is decided by the hardest technique the logic solver needed, not by grid size
(`docs/Techniques.md`). Size and special shapes are chosen per slot and usually grow with
the tier, but an 8 by 8 case that needs only "single" is not a hard case and is not shipped
as one.

| Tier | Hardest technique needed | Clues that first appear |
|---|---|---|
| tutorial | clue or single | in an area, on an object, beside an object, row, column |
| easy | clue or single, like the tutorial, on larger grids | corner of the grid |
| normal | last in line, intersection or pair | not..., in front of, above/below/left/right, exactly N rows or columns, same area, alone, edge, corner of an area, object in my row or column, the only person |
| hard | subset or counting | alone with, exactly N others, diagonal, exactly N people, object on exactly 2 sides, one of two areas, not same area, same grid, same position, group clues, traits |
| expert | what if or liar split | can see, steps apart, more people in A than in B; the case rules no touching and one liar |

## 4. Packs

The shipped cases live in generated Dart source, one file per tier:
`lib/data/cases_<tier>.dart`, each a `const List<String>` named `<tier>Cases` whose entries
are cases in the text format above, solution included, as plain `'''` strings. Each file
starts with a header saying it is generated and must not be edited by hand. The hand-written
index `lib/data/cases.dart` maps each tier name to its pack (`casePacks`).

*Why Dart source and not asset files:* a broken case then fails a test (or fails to compile)
on the developer's machine instead of failing on a player's phone, and no asset loading is
needed to start a case.

### The campaign plan

`lib/gen/gen_campaign.dart` lists the **slots** of each pack: a slot is an id
(`easy-007`), a tier, a setting, the grid shapes, the special flags and a pinned seed. The
settings rotate through the list in `lib/data/settings.dart`, so every pack visits every
place. The seed is fixed by tier and slot number, and everything random in a draw comes
from it, so the same slot always produces the same case. Each slot also carries a title
index, and `titleFor` (`lib/gen/gen_scene.dart`) gives a different title for every index
within a setting; no title word is in two settings (GEN-033), so no title is used twice
across the packs.

The shapes per tier (how many of each is in the file and changes there, not here):

| Tier | Shapes |
|---|---|
| tutorial | one 4 by 4 grid |
| easy | 5 by 5; 6 by 6 |
| normal | 6 by 6; 7 by 7 |
| hard | 7 by 7 and 8 by 8 with traits; two 4 by 4 grids; 6 by 8 with traits (two empty columns); 8 by 8 with cut corners |
| expert | 8 by 8 and 9 by 9 with traits; 7 by 7 with one liar; 8 by 8 with no touching |

### Rebuilding

```
dart run tool/generate_cases.dart              write every pack
dart run tool/generate_cases.dart --only=easy  one tier
dart run tool/generate_cases.dart --dry-run    build, compare with the files on disk, write nothing
dart run tool/generate_cases.dart --probe=6    first 6 slots per tier, funnel only, write nothing
  --verbose                                    add one line per slot (draws, time, hardest technique)
```

The tool exits with an error when a slot produced no case, or when `--dry-run` finds a pack
that differs from the file on disk. The dry run is a commit gate: the packs in the
repository must be exactly what the generator produces.

### Checking what is on disk

```
dart run tool/check_cases.dart                 the honest sweep over every shipped case
dart run tool/show_case.dart easy 3            print a case as a player reads it
dart run tool/show_case.dart easy 3 --answer   ... with the answer and the solving steps
dart run tool/bench_gen.dart                   time a sample of slots from every tier
```

The sweep (`checkShipped` in `lib/gen/gen_check.dart`) starts from the stored text and
trusts nothing else: the case parses; the exact solver finds exactly one solution and it is
the certified one; the logic solver finishes it, reaches the same answer, and the hardest
technique lies in the pack's tier; every suspect says something; and no clue can be removed
without losing uniqueness (a suspect's only statement always stays). It also refuses a
misplaced object, a victim not listed last or not V, an unused door or window, a repeated
statement, and a victim not placed last; the complete list is in
[Testing.md](Testing.md) section 3 (2026-11-25). The same function runs
over every case in `test/data/packs_test.dart`. *Why a second check after the gates:* the
gates judge a case while it is being made; the sweep judges what was actually written to
the file, so a bug in rendering or a hand edit cannot hide.

Changing anything a draw depends on (a setting, a clue family, the solver, the order of
random calls) changes the cases. That is expected; regenerate, read the funnel, and commit
the packs with the change that caused them.

## Additions of 2026-11-25

- **Pack sizes.** Tutorial, easy, normal and hard hold 100 cases each; expert holds 36.
  Shapes inside a tier keep the proportions of the table above. *Why:* the owner asked for
  a hundred per category; expert was not named and waits for a ruling.
- **Extra statements.** After a case is accepted the generator adds `extra` lines until each
  suspect has three statements in all, where the scene has that many true things left to
  say. They are drawn last so they never decide which draw is accepted, and the solvers
  never read them (GEN-035).
- **Doors and windows.** A draw still places them, because clues may use them; once the
  clues are chosen, every opening no clue needs is removed (GEN-034).
- **Titles** come from the setting (GEN-033, `docs/Settings.md`).
- **Cases made on request.** `randomConfig(tier, seed)` describes a slot outside the packs;
  `lib/services/random_case.dart` builds it on the device with the same `generateCase`
  (GEN-037). Such a case has an id beginning `random-`, is not stored and gets no tick.
- **Attempts per slot** went from 400 to 1500: with a hundred normal cases one slot ran out.

## Additions of the audit, 2026-11-25

- The parser's new refusals are listed in GEN-006.
- A liar case carries no `extra` lines (GEN-035).
- `readHeader` reads the `case`, `title`, `setting`, `grid` and cast lines only; it is for
  lists and trusts the text.
- `tool/generate_cases.dart` refuses an unknown flag or tier (exit 64) and never writes
  or compares a pack that is missing a slot. *Why:* a mistyped `--dry-run` rewrote the
  packs, and a mistyped `--only` passed the gate by doing nothing.
