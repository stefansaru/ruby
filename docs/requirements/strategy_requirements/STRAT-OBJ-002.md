---
tags: Objectives, Quality
status: Partial
strategic_sources: [Objectives.md, CommitChecklist.md, Testing.md]
---

# STRAT-OBJ-002 — Gates Green Before Anything Ships

**Status:** ⚠️ Partial (2026-11-24)

## Intent
A tolerated failure hides the next real one. Players of this genre have 'zero tolerance for bugs'.

## Requirement
No commit and no release is made with a failing gate: analyzer, tests, generator reproduction and case sweep.

## Strategic Sources
- [Objectives.md](../../strategy/Objectives.md)
- [CommitChecklist.md](../../process/CommitChecklist.md)
- [Testing.md](../../Testing.md)

## Acceptance Criteria
- [ ] The gates in CommitChecklist.md all pass on the release commit
- [ ] A continuous-integration run repeats analyze and test on every push

## Evidence / Current State
The four gates exist and pass locally on 2026-11-24: `flutter analyze`, `flutter test`, `dart run tool/generate_cases.dart --dry-run`, `dart run tool/check_cases.dart`. Open: there is no release commit yet, and no continuous-integration run.

## Related Requirements
- [PROC-CMT-001](../process_requirements/PROC-CMT-001.md) — Commit Gates
- [APP-QAL-001](../app_requirements/qal/APP-QAL-001.md) — Analyzer Clean, Tests Green
