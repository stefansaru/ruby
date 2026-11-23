# Tests

Written 2026-11-24. An inventory of every test file under `test/`: what it covers and which
GEN requirements it cites. A test cites a requirement by putting the id at the start of its
name; `test/requirements_test.dart` fails when a requirement in
[the GEN register](../requirements/gen/README.md) is cited by no test, or a test cites an id
that is not in the register. *Why an inventory:* so that a reader can find the test for a
rule without opening every file, and can see which rules a file would stop guarding if it
were deleted.

Run everything with `flutter test`. Why each gate exists is in `docs/Testing.md`; checks a
person does by hand are in [ManualTestPlan.md](ManualTestPlan.md).

The number of tests is not written here; `flutter test` prints it.

## Engine (`test/engine/`)

| File | What it covers | GEN ids |
|---|---|---|
| `fixtures.dart` | Not a test. The hand-written starter case (4 by 4, three suspects) and the clue board (5 by 5 with a door, a window and five people, to which tests add clue lines), plus the board's reference placement. | — |
| `clue_test.dart` | The placement rules on the board (row and column conflict, blocking objects, the murderer is the one other person in the victim's area). The words about one square: beside, in front of, corners, edge, seeing, an object in the row or column. Every clue type's meaning against the reference placement: one person, two people, company, general clues. `negate` gives the opposite. The no-touch rule. | 001, 002, 003, 004, 005, 012 |
| `case_text_test.dart` | The case text format. The starter case parses into the model. A written case parses back to the same text, including every less common clue form. Everything the parser refuses: unknown names, a broken grid, a split area, a person on a blocking object, zero or two victims, reused ids, a cast too large for the grids, a door off a wall, numbers out of range, stray words, impossible relations. A stated solution that breaks the case; a statement by the victim; a liar case with one statement. | 006, 007, 008, 009, 011 |
| `solver_test.dart` | The exact solver: one solution for the starter case, more than one when a clue is removed, every solution found obeys the rules and the limit, no solution leaves the victim alone or in a crowd, no-touch removes placements, exactly one false statement in a liar case. The logic solver: solves the starter case with `single` as the hardest technique; stops when capped below a technique the case needs; never calls a case with two answers solved; keeps the player's fixed squares and reports a contradiction on a wrong one; every step says what it did; a liar case is solved by testing each statement. | 003, 010, 011, 012, 013, 014, 015, 026 |
| `wording_test.dart` | The exact English sentence for each clue type, the victim's card and the case rules. Rows are numbers, columns are letters, no compass words. | 024 |

## Generator (`test/gen/`)

| File | What it covers | GEN ids |
|---|---|---|
| `gen_test.dart` | Same config, same case; a different seed, a different case. `GenConfig` refuses nonsense by field name. The funnel narrows gate by gate and ends in one case; a slot that cannot be filled says so. An accepted case mixes clue families. Drawn scenes obey the placement rules, have one victim and distinct tokens, and parse on their own; a non-square grid states its empty columns; cut-corner grids lose squares; every title index gives a different title. Clue candidates are all true, limited to the families the tier has reached, never about the victim or the victim's area; either-or area clues list areas in area order. Chosen clues leave one solution, give every suspect a statement and have none to spare. A generated liar case has exactly one false statement. The campaign: unique ids, seeds and title indexes; every pack beyond the tutorial visits every setting. | 001, 002, 003, 004, 011, 015, 016, 017, 018, 019, 020, 021, 025, 027, 028 |

## Shipped packs (`test/data/`)

| File | What it covers | GEN ids |
|---|---|---|
| `packs_test.dart` | There is a pack for every tier and a case for every campaign slot. For each tier: every case passes the honest check (`checkShipped`: parses, exactly one solution and it is the certified one, solved by logic to the same answer within the tier, every suspect speaks, no clue to spare); every case is stored exactly as `writeCase` writes it, matches its slot (id, setting, rules, cast size) and has a title no other case in the pack has; every clue reads as a full sentence with no compass words; no statement mentions the victim. Across tiers: each case is not solved when its hardest technique is taken away; a hint is available from every correct partial placement; pack files carry the generated header; regenerating the tutorial and easy packs reproduces the files byte for byte (the dry run covers all five); every case uses a known setting and only its areas and objects. | 009, 010, 013, 014, 015, 019, 020, 021, 022, 024, 026 |

## Whole-repository checks (`test/`)

| File | What it covers | GEN ids |
|---|---|---|
| `architecture_test.dart` | The layer rules, read from the import lines of the source files: the engine imports no Flutter, no `dart:io`, no generator and no data; the generator imports no Flutter and no `dart:io`; nothing outside `lib/gen/` imports the generator; data files import only data files. A generated file says so in its first line and only generated files do. No hand-written source file reaches 2000 lines. | 022, 023 |
| `requirements_test.dart` | Keeps the GEN register and the tests in step: the register exists with its template; every requirement is cited by a test; every cited id is in the register; every requirement file starts with its id and has the four headings and a status; the index lists every requirement. | (cites none; it checks the others) |

## What has no automated test yet

- Anything a player sees or touches: there is no screen, so the APP requirements for
  placing, notes, hints as shown, ads and the daily case have no tests. They are ❌ in
  [Requirements.md](../requirements/Requirements.md).
- The sentence of a few clue forms is not pinned by `wording_test.dart`: the grid clue
  ("was on the **Upstairs** grid"), in front of a door, same grid, same position, and the
  "of her grid" ending on two-grid cases. The data tests only check that such sentences are
  well formed.
- The Python art tool (`tool/write_sprite_prompts.py`) has no test; it checks its own
  tables against `lib/data/settings.dart` when it runs.
- Generating the normal, hard and expert packs inside the suite. They are compared by
  `dart run tool/generate_cases.dart --dry-run`, a commit gate.
