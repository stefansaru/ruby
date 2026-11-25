# APP-QAL-001 — Analyzer Clean, Tests Green

**Tags:** Quality, Process
**Status:** ⚠️ Partial (2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
`flutter analyze` reports nothing and `flutter test` passes on every commit. The strict analyzer options copied from pushy stay on.

## Why
A tolerated warning hides the next real one.

## Acceptance Criteria
- [x] Both commands pass locally before a commit
- [ ] Continuous integration repeats them on push

## Implementation
The analyzer reports nothing and the suite passes locally (2026-11-24) with the strict options copied from pushy. A workflow for continuous integration exists (`.github/workflows/dart.yml`) but has not been seen to run (TODO 55, 2026-11-25).

## Related Tests
Every file under `test/`; inventory in [Tests.md](../../../testing/Tests.md).

## Related Requirements
- [PROC-CMT-001](../../process_requirements/PROC-CMT-001.md) — Commit Gates

## Related Docs
- [Testing.md](../../../Testing.md)
- [CommitChecklist.md](../../../process/CommitChecklist.md)
