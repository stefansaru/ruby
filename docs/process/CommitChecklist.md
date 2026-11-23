# Commit Checklist

Written 2026-11-24. Requirements:
[PROC-CMT-001](../requirements/process_requirements/PROC-CMT-001.md),
[PROC-CMT-002](../requirements/process_requirements/PROC-CMT-002.md).
**No tolerated red:** a gate that fails is fixed or the commit waits. The
exact command names are owned by `CLAUDE.md`; if a tool is renamed, change it
there and here together.

## Before every commit

| # | Gate | Command | Why |
|---|---|---|---|
| 1 | The owner asked for a commit | — | Never commit unasked |
| 2 | Analyzer clean | `flutter analyze` | Warnings left alone become noise that hides the next real one |
| 3 | Tests green | `flutter test --reporter=failures-only` | Includes the architecture test, the requirements test and the replay of every shipped case |
| 4 | Generator reproduces the packs | `dart run tool/generate_cases.dart --dry-run` | A pack that differs from its seed was edited by hand, or the generator changed without regenerating |
| 5 | Case sweep | `dart run tool/check_cases.dart` | Every shipped case, read back from the pack: parses, one solution and it is the certified one, solved by logic within its tier, every suspect speaks, no clue to spare |
| 6 | Nothing from `input/` or `output/` is staged | `git status` | `input/` holds photos of a published book; neither folder is ours to publish |
| 7 | No secrets | `git diff --cached` | No ad unit ids other than Google's public test ids, no keystore, no `.env` |

Gates 4 and 5 may be skipped only when the commit touches no file under
`lib/engine/`, `lib/gen/`, `lib/data/` or `tool/`.

## When the change touches…

- **A rule or a clue type:** `docs/GameRules.md` is updated in the same
  commit, with the reason and date; a fixture test covers it.
- **A requirement:** its file's status is true after the commit. A
  requirement is ✅ only when its acceptance criteria are met and tested.
- **Player-facing words** (clue templates, hint text, UI strings, store copy):
  proposed to the owner as before and after, and approved, before the commit
  ([PROC-CNT-003](../requirements/process_requirements/PROC-CNT-003.md)).
- **A TODO item:** closed items move to [DoneLog.md](DoneLog.md); numbers are
  never reused.
- **Something that stopped being true:** the old text moves to
  `docs/History.md`; the docs describe the present.

## Commit message

A short imperative subject; a body that says why. End with the attribution
line the session supplies.
