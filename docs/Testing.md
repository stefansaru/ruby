# Testing

Dated 2026-11-24. The inventory of test files is [testing/Tests.md](testing/Tests.md);
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
- **The solvers** (`test/engine/solver_test.dart`): one solution found, two detected,
  rules applied, a liar handled, hints from a partial placement, a wrong placement
  found out.
- **The generator** (`test/gen/gen_test.dart`): the same seed gives the same case,
  bad configs are refused by field, the funnel narrows, statements never give the
  murderer away.
- **The shipped packs** (`test/data/packs_test.dart`): every case passes the honest
  check, is stored exactly as written, reads as plain sentences, belongs to its tier
  and is not solvable without its hardest technique.
- **The structure** (`test/architecture_test.dart`): the layer rules.
- **The register** (`test/requirements_test.dart`): every GEN requirement is cited by
  a test and every cited id exists.

## 3. The honest check

`checkShipped` (lib/gen/gen_check.dart) is the heart of gate 4 and of the data tests.
It takes the stored text and trusts nothing the generator said:

1. it parses (so the stated solution obeys every rule and clue);
2. the exact solver finds exactly one solution, the stated one;
3. the logic solver finishes it and lands on the same answer;
4. the hardest technique used lies in the tier's range;
5. every suspect says something;
6. no clue can be removed without losing uniqueness (a suspect's only statement is
   exempt).

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

There is no UI, so there are no widget or integration tests. No coverage floor is
set yet; it is a TODO item, to be set when the app layers exist. The generator's
quality as a puzzle setter (are the cases fun?) is not something a test can decide;
that is the paper-solving check in the manual test plan.
