# Working in this repository

Short recipes for the common changes. The rules are in [CLAUDE.md](CLAUDE.md); the
map of the docs is [docs/README.md](docs/README.md).

## Add a clue type

1. Add the class in `lib/engine/clue.dart` (a `CellTest` for a statement about one
   square, a `Clue` otherwise) with its `holds`/`test`.
2. The sealed switches now fail to compile until you handle it in
   `lib/engine/wording.dart` (sentence), `lib/engine/case_text.dart` (parse and
   write) and `lib/engine/atoms.dart` (pieces for the solvers; `GenericAtom` is the
   fallback).
3. Add it to `listCandidates` in `lib/gen/gen_clues.dart` under a `Family` with the
   tier it first appears in.
4. Tests: meaning in `test/engine/clue_test.dart`, sentence in
   `test/engine/wording_test.dart`, round trip in `test/engine/case_text_test.dart`.
5. Add the row to the clue table in `docs/GameRules.md`.
6. Regenerate the packs (they will change) and run the gates.

## Add a solving technique

1. Add the value to `Technique` in `lib/engine/logic_solver.dart`, in order of
   difficulty, with its weight, and the method to `_propagate`.
2. It must never remove the true square. `checkShipped` compares the solver's answer
   with the certified one on every case; keep it green.
3. Describe it in `docs/Techniques.md`, decide which `Tier` range it belongs to in
   `lib/gen/gen_config.dart`, regenerate.

## Add a setting, an area or an object

Edit `lib/data/settings.dart` only. Names are short everyday words
(see `docs/Settings.md`). A new object is a new sprite: run
`py -3 tool/write_sprite_prompts.py` and update `docs/Art.md`. Adding or removing a
setting changes which setting most slots get; regenerate.

## Change the packs

Edit `lib/gen/gen_campaign.dart` (shapes, counts, seeds), then:

```
dart run tool/generate_cases.dart
dart run tool/check_cases.dart
flutter test
```

Read a case as a player would with `dart run tool/show_case.dart hard 5 --answer`.
When a slot prints `NO CASE`, run with `--verbose --probe=N` and read the funnel: the
gate where the count collapses is the one to look at.

## Add a requirement

Engine or generator rule: copy `docs/requirements/gen/_TEMPLATE.md` to the next free
`GEN-nnn.md`, add the row to that folder's `README.md`, and start a test name with the
id. Anything else: follow `docs/requirements/Requirements.md`.

## Test layout

`test/` mirrors `lib/`: `engine/`, `gen/`, `data/`, plus `architecture_test.dart` and
`requirements_test.dart` at the root. Fixtures for hand-written cases are in
`test/engine/fixtures.dart`. The inventory is `docs/testing/Tests.md`.

## Style

The analyzer options are pushy's. Local variable types are omitted
(`dart fix --apply` does it). Do not run `dart fix` or a formatter with different
settings over `lib/data/cases_*.dart`; `--dry-run` must keep reporting "unchanged".
