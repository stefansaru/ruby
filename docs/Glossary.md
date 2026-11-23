# Glossary

Written 2026-11-24. The words used across the docs and the code, each with one meaning.
Player-facing words are defined in `docs/GameRules.md` section 4; this file covers the words
we use when building the game.

## The case

| Term | Meaning |
|---|---|
| **case** | One puzzle: a scene, a cast, the clues and the certified solution. `CaseDef` in code; "level" in everyday talk. |
| **case text** | The line-per-fact text form of a case (`docs/Levels.md`). What ships. |
| **scene** | The physical part of a case: grids, areas, objects, doors and windows. No people, no clues. |
| **grid** | A rectangle of squares with its own rows and columns. A case has one or two. |
| **square** | One position of a grid. `Cell` in code. Players never see the word "cell". |
| **missing square** | A position cut out of an irregular grid; written `---`. It does not exist. |
| **row, column** | Rows are numbered from the top, columns lettered from the left. In code both count from 0. |
| **line** | A row or a column. |
| **area** | A named, connected group of squares on one grid (Kitchen, Pond). The genre's older word is "room". |
| **wall** | A side of a square that lies on the grid outline or between two areas. |
| **outline** | The outer boundary of a grid, including around cut corners. |
| **opening** | A door or a window on one side of a square. |
| **object** | A thing drawn on one or more squares. |
| **kind** | The type of an object (chair, tree). Rules and clues speak of kinds, never of one particular object. |
| **sit / block** | The two sorts of kind: one a person can be on, one that makes its square unusable. |
| **wide object** | An object drawn across two touching squares. |
| **instance mark** | The third character of a square in the case text; ties the squares of one wide object together for drawing. |
| **setting** | The place a case happens in (Home, Beach...); supplies area names, kinds and art. |
| **cast** | The people of a case. |
| **suspect** | A person who is not the victim. |
| **victim** | The one person who makes no statement. |
| **murderer** | The one other person in the victim's area in the solution. |
| **trait** | A visible feature of a person (hat, glasses) that a clue may name. |

## Clues

| Term | Meaning |
|---|---|
| **clue** | Any statement or general clue. `Clue` in code. |
| **statement** | A clue with a speaker ("She was beside a table."). Only statements can be the lie in a liar case. |
| **general clue** | A clue with no speaker ("Exactly 2 people were on a chair."). Always true. |
| **case rule** | A rule switched on for one case: no touching, one liar. |
| **test** | A yes/no question about one square ("is it in the Kitchen?"). `CellTest` in code. Most statements are a test on the speaker's square. |
| **selector** | Which people a counting clue is about: anyone, men, women, people with or without a trait. |
| **notation** | The compact form of a clue in the case text (`A is beside t`). |
| **wording** | The sentence shown to the player, built from the clue object by `wording.dart`. |
| **clue family** | A group of clue types the generator treats alike (area, beside, direction...), with the tier it first appears in and a draw weight. |

## Solving

| Term | Meaning |
|---|---|
| **placement** | A square for every person. |
| **solution** | A placement that obeys every rule and clue. |
| **certified solution** | The solution stated in the case text, which the parser re-checks on every load. |
| **unique** | Having exactly one solution. |
| **exact solver** | The program that tries placements exhaustively to count solutions. Proves uniqueness; explains nothing. |
| **logic solver** | The program that solves by named techniques and records its steps. Proves no guessing is needed; grades difficulty; feeds hints. |
| **candidate** (solving) | A square a person could still be on. |
| **technique** | One named way of ruling candidates out (`docs/Techniques.md`). |
| **step** | One use of a technique, as recorded by the logic solver. |
| **piece** | What a clue is broken into before solving: single-person, pair, count, company or search piece. `Atoms` in `lib/engine/atoms.dart`; both solvers use the same pieces. |
| **full line** | A row or column that must hold a person. |
| **conflict** | Two squares that cannot both hold a person: the same square, or the same row or column of one grid. |
| **contradiction** | A state in which some person has no square left. |
| **hardest technique** | The highest technique on the ladder among a case's steps; decides its tier. |
| **score** | The sum of the weights of a case's steps. Recorded, not yet used. |

## Generating

| Term | Meaning |
|---|---|
| **tier** | A difficulty level: tutorial, easy, normal, hard, expert. |
| **pack** | All the shipped cases of one tier; one generated Dart file. |
| **campaign** | The plan of every pack: the list of slots. |
| **slot** | One planned case: id, tier, setting, grid shapes, flags, seed and title index. `GenConfig` in code. |
| **title index** | The number that picks a slot's title; every index gives a different title, so no pack repeats one. |
| **shape** | The grid sizes and flags a group of slots share (7 by 7 with one liar). |
| **seed** | The number all of a slot's randomness comes from. Same seed, same case. |
| **draw** | One attempt at a slot: one scene, one clue list. |
| **attempt limit** | How many draws a slot may use before the tool reports "no case". |
| **candidate** (generating) | A true statement that could be added to a case's clue list. |
| **rival** | A placement other than the intended one that still fits the clues chosen so far. |
| **gate** | A check a draw must pass to ship (`docs/Levels.md` section 2). |
| **funnel** | Per tier, how many draws passed each gate. |
| **dry run** | Rebuilding the packs and comparing with the files on disk without writing. A commit gate. |
| **sweep** (honest check) | Re-checking every stored case from its text alone: parses, one solution, solved by logic in its tier, every suspect speaks, no clue to spare. `checkShipped`; run by `tool/check_cases.dart` and the data tests. |
| **GEN register** | The machine-checked engine and generator requirements in `docs/requirements/gen/`; each is cited by a test. |
| **probe** | Generating only the first few slots of each tier to read the funnel. |
