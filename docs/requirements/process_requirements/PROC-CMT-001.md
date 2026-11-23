# PROC-CMT-001 — Commit Gates

**Tags:** Process, Commit, Quality
**Status:** ⚠️ Partial (2026-11-24)

## Requirement
Before every commit: analyzer clean, tests green, and, when engine, generator, data or tools changed, the generator dry-run reproduces the shipped packs and the case sweep passes. A failing gate is fixed or the commit waits.

## Why
The gates are what make 'every case is fair' a fact about the repository instead of a hope.

## Acceptance Criteria
- [x] The gates and their commands are listed in CommitChecklist.md and CLAUDE.md, and agree
- [x] The dry-run compares generated output with the committed packs byte for byte

## Implementation
The tools exist (2026-11-24): `tool/generate_cases.dart --dry-run` compares each regenerated pack with the file on disk and exits 1 on any difference; `tool/check_cases.dart` is the sweep. The gates are listed in CommitChecklist.md. `CLAUDE.md` lists the same four commands. Open: no commit has passed the gates yet; set to Done after the first one does.

## Related Tests
`test/data/packs_test.dart` (GEN-022: the tutorial and easy packs are regenerated and compared in the suite; the dry run covers all five).

## Related Requirements
- [STRAT-OBJ-002](../strategy_requirements/STRAT-OBJ-002.md) — Gates Green Before Anything Ships
- [APP-QAL-001](../app_requirements/qal/APP-QAL-001.md) — Analyzer Clean, Tests Green

## Related Docs
- [CommitChecklist.md](../../process/CommitChecklist.md)
- [Testing.md](../../Testing.md)
