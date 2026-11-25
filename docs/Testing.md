# Testing

Dated 2026-11-24, revised 2026-11-25. The inventory of test files is [testing/Tests.md](testing/Tests.md);
checks a person runs are in [testing/ManualTestPlan.md](testing/ManualTestPlan.md).

## 1. The gates

Run before every commit, in this order. `doctor.sh` / `doctor.ps1` run them all and
stop at the first failure. CI (`.github/workflows/dart.yml`) runs the same four.

| # | Command | Why it is a gate |
|---|---|---|
| 1 | `flutter analyze` | The analyzer options are strict on purpose; a warning left in becomes ten. |
| 2 | `flutter test --reporter=failures-only` | Everything below. |
| 3 | `dart run tool/generate_cases.dart --dry-run` | The committed packs must be exactly what the committed generator makes. A difference means a pack was edited by hand or the generator changed without regenerating. |
| 4 | `dart run tool/check_cases.dart` | Every stored case, checked from its text alone. |

No tolerated red. A gate that fails is fixed, or the change is not committed.

## 2. What the tests are for

- **Meaning** (`test/engine/clue_test.dart`, `wording_test.dart`): each clue and each
  word ("beside", "corner", "see") on a hand-drawn board where the right answer is
  obvious to a reader. These are the tests to read when a rule is in doubt.
- **The format** (`test/engine/case_text_test.dart`): what the parser accepts, and
  every way it refuses a malformed case.
- **The edges** (`test/engine/edges_test.dart`, 2026-11-25): the parser refusals
  with their reasons, the rarer clue forms, a sentence for every technique, the
  hint and rules lines in both modes, and cases logic cannot finish.
- **The session** (`test/engine/session_test.dart`): placing, replacing and removing
  people, clashes reported and not refused, the win check, hints from where the
  player is.
- **The solvers** (`test/engine/solver_test.dart`): one solution found, two detected,
  rules applied, a liar handled, hints from a partial placement, a wrong placement
  found out.
- **The generator** (`test/gen/gen_test.dart`): the same seed gives the same case,
  bad configs are refused by field, the funnel narrows, statements never give the
  murderer away.
- **The shipped packs** (`test/data/packs_test.dart`): every case passes the honest
  check, is stored exactly as written, reads as plain sentences, belongs to its tier
  and is not solvable without its hardest technique.
- **The later pack rules** (`test/data/mapping_test.dart`, `round3_test.dart`):
  objects in their areas, the victim's name and turn, titles, doors and windows,
  extra statements, checklist marks, cases made on request.
- **The draft screens** (`test/screens/play_test.dart`): the app opens, a case of
  each tier is played to the end, the menu, the checklist, the hint, cat mode.
- **The structure** (`test/architecture_test.dart`): the layer rules.
- **The register** (`test/requirements_test.dart`): every GEN requirement is cited by
  a test and every cited id exists.

## 3. The honest check

`checkShipped` (lib/gen/gen_check.dart) is the heart of gate 4 and of the data tests.
It takes the stored text and trusts nothing the generator said:

1. it parses (so the stated solution obeys every rule and clue);
2. every object stands in an area that lists it (GEN-029);
3. the victim is listed last and has the id V and a name that begins with V (GEN-030);
4. every door and window is used by a clue (GEN-034);
5. no statement, extras included, is repeated;
6. the exact solver finds exactly one solution, the stated one;
7. the logic solver finishes it and lands on the same answer;
8. the hardest technique used lies in the tier's range;
9. the victim is the last person the logic solver places (GEN-031);
10. every suspect says something;
11. no clue can be removed without losing uniqueness (a suspect's only statement is
    exempt).

This list is the complete one (2026-11-25); other docs name the check and point
here, so the list is kept true in one place.

Reason for a second, independent check: the generator certifies its own output. If
its idea of "unique" or "solved" were wrong, a check that reused its verdict would
agree with it. This one recomputes everything from the text.

## 4. Lessons already paid for (2026-11-24)

- **A test fixture can be wrong.** The first hand-written case had a solution that
  broke its own clue; the parser refused it. That is the parser doing its job. Check
  a fixture on paper before blaming the code.
- **Formatters touch generated files.** `dart fix` rewrote the raw strings in the
  packs, and the dry run then reported every pack as different. The packs are now
  written the way the formatter leaves them, and the dry run is a gate.
- **Dart drops the first newline of a `'''` string.** A stored case equals
  `writeCase(...)` exactly, with no leading newline.
- **A capped solver must still check its answer.** With techniques switched off, the
  logic solver could reach one square per person without having used every clue. It
  now verifies the final placement against all clues before saying solved (GEN-013).

## 5. Not covered yet

Widget tests of the draft are in `test/screens/`; there are no integration tests on a
device. Line coverage of the hand-written code in `lib/` was 99.96% on 2026-11-25
(2610 of 2611 lines, `flutter test --coverage`; before the audit 95.6%). The one line
is a contradiction check in the subset technique that an easier technique always
reaches first. No floor is enforced by the doctor script yet (TODO 13). The generator's
quality as a puzzle setter (are the cases fun?) is not something a test can decide;
that is the paper-solving check in the manual test plan.

## 6. Exploring for the flaws nobody thought of (2026-11-25)

The tests above check what we thought to check, and almost all of them trust the engine's
own reading of the rules. [testing/Exploratory.md](testing/Exploratory.md) describes the
tests that do not: a second, independent statement of the rules that the engine must agree
with; mirrors and other changes that must not matter; a random player with invariants;
and a check of every English sentence against its clue. `tool/plant_bugs.py` plants
deliberate bugs to prove those tests can fail (32 of 32 caught on 2026-11-25).
