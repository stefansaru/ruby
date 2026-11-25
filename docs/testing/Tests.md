# Tests

Written 2026-11-24, revised 2026-11-25. An inventory of every test file under `test/`: what it covers and which
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
| `solver_test.dart` | The exact solver: one solution for the starter case, more than one when a clue is removed, every solution found obeys the rules and the limit, no solution leaves the victim alone or in a crowd, no-touch removes placements, exactly one false statement in a liar case. The logic solver: solves the starter case with `single` as the hardest technique; stops when capped below a technique the case needs; never calls a case with two answers solved; keeps the player's fixed squares and reports a contradiction on a wrong one; every step says what it did; a liar case is solved by testing each statement; the victim is the last person placed, and a victim the player has placed is taken as given (two tests). | 003, 010, 011, 012, 013, 014, 015, 026, 031 |
| `wording_test.dart` | The exact English sentence for each clue type, the victim's card and the case rules. Rows are numbers, columns are letters, no compass words. | 024 |
| `session_test.dart` | `CaseSession`: placing, replacing and removing people, and a person is never pushed off a square by another; people sharing a row or column are reported, not refused; solved only with everyone on the certified squares; hints walk a case from each pack to its solution, name a wrong placement first and carry the steps that explain them; the squares in the row and column of a placed person are crossed out. | 001, 003, 026 |
| `hardening_test.dart` | Added with the audit of 2026-11-25. Values the parser refuses (a header line twice, a missing setting, a name used twice, keyword traits, distances under 2, negative counts, sides outside 1 to 4, a person twice in a solution, two openings on one wall). `readHeader` agrees with `parseCase` on every shipped case and never throws. The session: a tap places, lifts, is refused or is ignored once solved; the victim waits; a card's statements and extras; a hint is worked out once per board. One statement's pieces without the case rules. Liar cases: the solver names the lie, a hint never quotes it as true, there are no extras. Two grids: squares and lines named with their grid. Capacity, clashes, random ids. Which openings the clues need, for every clue type. Config refusals; a case that does not parse, a clue to spare and a silent suspect are reported; every setting has areas for two grids. | 006, 007, 011, 017, 019, 020, 026, 034, 035, 036 |
| `edges_test.dart` | Added 2026-11-25. Parser refusals with their reasons (malformed header and scene lines, an area on two grids, unknown tests and clues, an offset of nothing, extras without a solution; a refusal names its line, or the case). The "everyone else" pieces, one per person. Negated wordings ("exactly N sides", "in my row"), and a negated clue has a sentence but is never stored. The rule sentence of a tall grid. A sentence for every technique; the victim rule in the words of the mode; hint lines for the victim and for a suspect with a harder step; the solved line and the rules sheet in both modes. A liar case where every statement as the lie fails; a hint still names someone, the victim last, when logic cannot finish. | 004, 006, 011, 024, 026, 027, 035 |

## Exploratory (`test/explore/`, helpers in `test/support/`)

Added 2026-11-25. These draw their own inputs from a fixed seed; the rules they explore are
listed in [Exploratory.md](Exploratory.md). `RUBY_EXPLORE=<n>` makes them draw n times more.

| File | What it covers | GEN ids |
|---|---|---|
| `meaning_test.dart` | The engine against the oracle: the certified answers; every shipped clue on random boards; whether a board is an answer; the slow search finds one answer on small cases; every clue form on the fixture board and on a two-grid scene; the rules of no-touch and cut-corner scenes. | 038 |
| `solvers_test.dart` | For every clue form, alone, in pairs, with no-touch and with one liar, the exact solver finds exactly what the slow search finds. No technique rules out a square an answer uses, also on a grid with rows to spare. A placement never pushes someone off a square. | 038, 011, 013, 027, 001 |
| `symmetry_test.dart` | Every case mirrored left to right and top to bottom has one answer, the mirror, and is solved by logic; the mirror changes what it should; mirroring twice gives the case back; extras counted as clues leave one answer. | 039 |
| `play_test.dart` | A random player on cases of every tier with eight invariants checked after every action; hints finish any board. A tick or cross on a part-filled board is final, for every clue form and on wrong boards. The solver never rules out a true square from any correct board. | 040, 036, 013, 026 |
| `words_test.dart` | Every shipped sentence against its notation: names, directions, counts, denials, pronouns; two-grid rows and columns say "of her grid"; thirty wrong sentences are noticed. | 041 |
| `fuzz_test.dart` | Damaged case text is refused or sound, and never throws anything else; junk is refused; cases made on request pass the shipped check, the oracle and both mirrors; random taps on the screen at four sizes raise no error. | 006, 037, 040 |

`test/support/oracle.dart` is the second witness (it may not import the game;
`architecture_test.dart` checks that). `transform.dart` mirrors case text. `explore.dart`
loads the packs and draws boards.

## Generator (`test/gen/`)

| File | What it covers | GEN ids |
|---|---|---|
| `gen_test.dart` | Same config, same case; a different seed, a different case. `GenConfig` refuses nonsense by field name. The funnel narrows gate by gate and ends in one case; a slot that cannot be filled says so. An accepted case mixes clue families. Drawn scenes obey the placement rules, have one victim and distinct tokens, and parse on their own; a non-square grid states its empty columns; cut-corner grids lose squares; titles differ per index and setting; no title word is in two settings. Clue candidates are all true, limited to the families the tier has reached, never about the victim or the victim's area; either-or area clues list areas in area order. Chosen clues leave one solution, give every suspect a statement and have none to spare. A generated liar case has exactly one false statement. The campaign: unique ids, seeds and title indexes; every pack after the tutorial visits every setting (the test skips the tutorial, which also holds all twelve since 2026-11-25). | 001, 002, 003, 004, 011, 015, 016, 017, 018, 019, 020, 021, 025, 027, 028, 033 |

## Shipped packs (`test/data/`)

| File | What it covers | GEN ids |
|---|---|---|
| `round3_test.dart` | A hundred cases in each of tutorial, easy, normal and hard. Titles end in a word of the case's setting and never repeat. No door or window without a clue that uses it; none in tutorial and easy; an unused door is refused. Extras are true, new, spoken by a suspect, never about company in the victim's area, at most three statements per suspect, and the case is the same puzzle without them; a false extra cannot be parsed. Statement marks: all ticked on the answer (one cross in a liar case), never a cross on correct placements, a cross on a contradicting placement, the victim with two companions crossed at once. Cases made on request: same seed same case, every tier passes `checkShipped`. Progress, mode and opened extras survive a restart. | 033, 034, 035, 036, 037 |
| `mapping_test.dart` | The settings list: every area lists only objects of its setting, every object has an area, boats are on water, cars on roads, furniture indoors, trees outdoors, no boat in the Pines. Every shipped case: each object stands in an area that lists it (and a misplaced one is reported with its square); the victim is listed last and begins with V; the solver places the victim after every suspect and hints never name the victim earlier; tutorial and easy cases are solved with clue and single only. | 029, 030, 031, 032 |
| `packs_test.dart` | There is a pack for every tier and a case for every campaign slot. For each tier: every case passes the honest check (`checkShipped`: parses, exactly one solution and it is the certified one, solved by logic to the same answer within the tier, every suspect speaks, no clue to spare); every case is stored exactly as `writeCase` writes it, matches its slot (id, setting, rules, cast size) and has a title no other case in the pack has; every clue reads as a full sentence with no compass words; no statement mentions the victim. Across tiers: each case is not solved when its hardest technique is taken away; a hint is available from every correct partial placement; pack files carry the generated header; regenerating the tutorial and easy packs reproduces the files byte for byte (the dry run covers all five); every case uses a known setting and only its areas and objects. | 009, 010, 013, 014, 015, 019, 020, 021, 022, 024, 026 |

## Screens (`test/screens/`)

| File | What it covers | GEN ids |
|---|---|---|
| `edges_test.dart` | Added with the audit of 2026-11-25. Nothing overflows and every square can be tapped on a phone on its side, a short wide window, a small phone and a tablet, for a tutorial, a two-grid and a 9 by 9 case. A solved board no longer changes and the hint says so. Everyone placed but wrong gives a notice. "Next case" and "Back to the list". Rules, general clues, traits, doors and two-grid squares are shown. A random case that cannot be made frees the button and says so; the real background maker returns a sound case; a tier that yields nothing is an error. The app starts from what the device saved, and without storage; a failing store does not stop the game; nonsense saved numbers are read as nothing. | 037 |
| `play_test.dart` | Widget tests of the playable draft. The app opens on the packs and into a case. A tutorial, an easy and a two-grid hard case are played to "Case solved" by tapping, including a refused blocked square, a hint on a wrong placement, "Start again" and the two-step hint (who and why, then the square). A solved case shows a green tick in the list. The menu opens "How to play" and switches to cat mode. The button under a pack makes and opens a new case. Statements are a checklist: a tick on a fitting square, a cross on a contradicting one, one more statement after "+". Tapping a placed person lifts them whoever is selected; a placed card is greyed and the next person is selected. A hint can be closed. Cat mode ends with "was hiding the kitten". | 037 |

## Whole-repository checks (`test/`)

| File | What it covers | GEN ids |
|---|---|---|
| `architecture_test.dart` | The layer rules, read from the import lines of the source files: the engine imports no Flutter, no `dart:io`, no generator and no data; the generator imports no Flutter and no `dart:io`; only `lib/services/random_case.dart` imports the generator; screens and widgets never name it; data files import only data files. A generated file says so in its first line and only generated files do. No hand-written source file reaches 2000 lines. | 022, 023 |
| `requirements_test.dart` | Keeps the GEN register and the tests in step: the register exists with its template; every requirement is cited by a test; every cited id is in the register; every requirement file starts with its id and has the four headings and a status; the index lists every requirement. | (cites none; it checks the others) |

## What has no automated test yet

- Notes, the hint ladder, the purchase and the daily case: not built, so their APP
  requirements have no tests. They are ❌ in
  [Requirements.md](../requirements/Requirements.md).
- The sentence of a few clue forms is not pinned by `wording_test.dart`: the grid clue
  ("was on the **Upstairs** grid"), in front of a door, same grid, same position, and the
  "of her grid" ending on two-grid cases. The data tests only check that such sentences are
  well formed.
- The Python art tool (`tool/write_sprite_prompts.py`) has no test; it checks its own
  tables against `lib/data/settings.dart` when it runs.
- Generating the normal, hard and expert packs inside the suite. They are compared by
  `dart run tool/generate_cases.dart --dry-run`, a commit gate.
