# Detective Sudoku (codename ruby)

A cosy murder-mystery logic puzzle for phones, in Flutter. People stand on a grid of
areas, one per row and column; each suspect makes a statement; the murderer is the
one person who was alone with the victim. No ads (owner ruling 2026-11-25): free to
try, one purchase for the rest (docs/strategy/Monetisation.md). A "cat mode" tells the
same cases as a missing kitten (docs/features/Modes.md).

**Read [docs/README.md](docs/README.md) first.** It says which doc owns which subject.
[TODO.md](TODO.md) is the only list of outstanding work.

## State (2026-11-25)

Built: docs, the rules engine, both solvers, the generator, the case packs (436 cases),
the tests, and a playable draft: case list with saved ticks, a random case per tier,
case screen with placeholder shapes, area names on the grid, placing, crosses and
clash marks, statements as a tick/cross checklist with "+" for one more, a two-step
free hint, win check, detective and cat wording. Not built: the purchase and its gate,
notes, the hint ladder, daily case, art, sounds, translations, release. The name
"Detective Sudoku" is a working title that will change (TODO 49). Never describe an
unbuilt part as working; `TODO.md` says what exists.

## The one architectural rule

**The engine decides, the view draws.**

- `lib/engine/` is pure Dart: no Flutter, no `dart:io`, no generator, no data. It owns
  the rules, the clue meanings, the wording, both solvers and the case text format.
- `lib/gen/` is the generator: no Flutter, no `dart:io`. One app file imports it,
  `lib/services/random_case.dart` (a case made on request); screens and widgets never do.
- `lib/data/` holds `settings.dart` (hand-written) and the generated packs.
- `tool/` only reads arguments and files; the logic it runs lives in `lib/`.

`test/architecture_test.dart` enforces this on the import lines. The generator lives in
`lib/` and not in `tool/` so that test coverage measures it (same reason as in pushy).

## Gates before any commit

```
flutter analyze
flutter test --reporter=failures-only
dart run tool/generate_cases.dart --dry-run
dart run tool/check_cases.dart
```

`doctor.ps1` / `doctor.sh` run all four. No tolerated red: a failing gate is fixed or
the change is not committed.

## Cases

- A case is text (format in [docs/Levels.md](docs/Levels.md)) plus its certified
  solution. `parseCase` is also the validator: a malformed case cannot be built.
- Packs are generated Dart (`lib/data/cases_<tier>.dart`). Never edit them by hand;
  change the generator or `lib/gen/gen_campaign.dart` and regenerate.
- A case ships only when it has exactly one solution, is solved by the logic solver
  without guessing, and its hardest technique fits its tier.
- `extra` lines are true statements the player can ask for; nothing may depend on them.
- Every clue has one meaning: `Clue.holds`. Wording, notation and solver pieces are
  derived from the same object. A new clue type needs all of them plus a row in
  [docs/GameRules.md](docs/GameRules.md) and a test.
- Changing anything the generator draws from (settings, clue families, weights, the
  order of random calls) changes the packs. Regenerate and say so in the commit.

## Requirements

- Engine and generator rules: the machine-checked register in
  [docs/requirements/gen/](docs/requirements/gen/README.md). A test cites a
  requirement by starting its name with the id (`GEN-010 ...`).
  `test/requirements_test.dart` fails on an uncited or unknown id.
- Everything else (strategy, app, process): [docs/requirements/Requirements.md](docs/requirements/Requirements.md).

## Working agreement

- Never commit or push unless asked.
- Player-facing copy (clue sentences, rule sentences, store text) is not changed
  without asking: propose before and after.
- Art is supplied by the owner from prompts; never generate or commit placeholder art
  as if it were final. See [docs/Art.md](docs/Art.md).
- The game reuses a genre and its mechanics. It ships no puzzle, name, text or art
  from the *Murdoku* books or from any other app, and does not use that name.
- Every rule written into a doc carries its reason and its date. Present tense means
  now; what is no longer true moves to [docs/History.md](docs/History.md).
- `input/` is what the owner drops in; `output/` is what the agent writes back. Both
  are ignored by git. Long runs keep a progress note in `output/progress/`.
- Ask when something is unclear instead of assuming.

## Shell note

On this Windows machine, bash heredocs that contain apostrophes or triple quotes fail
with "unexpected EOF". Write file contents with the editor tools, not heredocs.
