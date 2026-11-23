# PROC-CNT-001 — Cases Are Generated, Seeded and Never Hand-Edited

**Tags:** Process, Content, Generator
**Status:** ⚠️ Partial (2026-11-24)

## Requirement
Every shipped case comes from the generator with a pinned seed and configuration recorded in the campaign. Generated files carry a header naming the command and are never edited by hand; to change a case, change the generator or the seed and regenerate.

## Why
A hand edit cannot be reproduced and silently escapes the gates that certified the original.

## Acceptance Criteria
- [x] Each pack file starts with the generated-file header
- [x] The dry-run gate detects any hand edit
- [ ] A sample from every pack is read by a person before release

## Implementation
Built (2026-11-24): every pack file starts with the generated header (GEN-022, checked in `test/architecture_test.dart` and `test/data/packs_test.dart`); each slot's seed and configuration are in `lib/gen/gen_campaign.dart` (GEN-016); the dry run reports a hand-edited pack as DIFFERS. Open: nobody has read a sample from every pack yet (ManualTestPlan MT-2).

## Related Tests
`test/data/packs_test.dart`, `test/architecture_test.dart`, `test/gen/gen_test.dart` (GEN-016, GEN-022).

## Related Requirements
- [STRAT-MIS-002](../strategy_requirements/STRAT-MIS-002.md) — Every Case Is Fair
- [STRAT-VAL-003](../strategy_requirements/STRAT-VAL-003.md) — Our Own Work

## Related Docs
- [Levels.md](../../Levels.md)
- [GEN register](../../requirements/gen/README.md)
- [CommitChecklist.md](../../process/CommitChecklist.md)
