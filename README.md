# Detective Sudoku

A cosy murder-mystery logic puzzle. Everyone stood somewhere on the grid, one person
per row and column. Each suspect tells you one thing. Work out where everybody was;
whoever was alone with the victim did it. Codename **ruby**.

## Status

The rules engine, the solvers, the generator, the case packs and a playable draft
(placeholder shapes, saved ticks, free hint) are built and tested. The purchase,
notes, art and release are not. [TODO.md](TODO.md) lists what is left.

## Getting started

```
flutter pub get
flutter test
dart run tool/show_case.dart easy 1            # read a case
dart run tool/show_case.dart easy 1 --answer   # with the answer and the steps
```

## Gates

```
flutter analyze
flutter test --reporter=failures-only
dart run tool/generate_cases.dart --dry-run    # the packs are what the generator makes
dart run tool/check_cases.dart                 # every case: one answer, no guessing
```

`./doctor.sh` or `.\doctor.ps1` runs them all.

## Where things are

- [docs/README.md](docs/README.md): the map of the documentation.
- [docs/GameRules.md](docs/GameRules.md): the rules and every clue.
- [CLAUDE.md](CLAUDE.md) and [AGENTS.md](AGENTS.md): how to work in this repository.
