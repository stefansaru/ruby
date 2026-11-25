---
tags: Objectives, Content
status: Partial
strategic_sources: [Objectives.md, Settings.md, Levels.md]
---

# STRAT-OBJ-001 — Launch Content Floor

**Status:** ⚠️ Partial (2026-11-24)

## Intent
A player who likes the game must not run out in an evening, and each setting must be more than a single case.

## Requirement
At launch the game offers cases in all five tiers (tutorial, easy, normal, hard, expert) across all twelve settings, including multi-grid and irregular cases. The proposed size is about 200 cases; the owner sets the final figure.

## Strategic Sources
- [Objectives.md](../../strategy/Objectives.md)
- [Settings.md](../../Settings.md)
- [Levels.md](../../Levels.md)

## Acceptance Criteria
- [x] Every tier has at least one pack
- [x] Every setting appears in at least one pack
- [ ] The count is read from the shipped packs, never restated in docs or the listing by hand

## Evidence / Current State
A first set of packs exists for all five tiers (2026-11-24), with two-grid, non-square, cut-corner, one-liar and no-touch cases; every pack visits every setting (GEN-028, `test/gen/gen_test.dart`, which checks the packs after the tutorial; the tutorial has held all twelve since 2026-11-25). The count is whatever `lib/gen/gen_campaign.dart` plans and the packs hold. Open: the owner has not set the launch figure, and the store listing does not exist yet.

## Related Requirements
- [STRAT-MIS-002](../strategy_requirements/STRAT-MIS-002.md) — Every Case Is Fair
- [PROC-CNT-001](../process_requirements/PROC-CNT-001.md) — Cases Are Generated, Seeded and Never Hand-Edited
