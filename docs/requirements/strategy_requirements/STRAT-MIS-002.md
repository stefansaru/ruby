---
tags: Mission, Fairness, Generator
status: Done
strategic_sources: [VisionMissionValues.md, PainPointsAndConcepts.md, GEN register, Techniques.md]
---

# STRAT-MIS-002 — Every Case Is Fair

**Status:** ✅ Done (2026-11-24)

## Intent
This is the single promise of a logic puzzle. Competitors' reviews report answers that change on replay, and praise the apps whose difficulty labels are honest.

## Requirement
A case ships only if a solver has shown that it has exactly one solution and that it can be solved by deduction alone, with no guess. Its difficulty tier is set by the hardest technique the solver needed.

## Strategic Sources
- [VisionMissionValues.md](../../strategy/VisionMissionValues.md)
- [PainPointsAndConcepts.md](../../strategy/PainPointsAndConcepts.md)
- [GEN register](../../requirements/gen/README.md)
- [Techniques.md](../../Techniques.md)

## Acceptance Criteria
- [x] The generator rejects any case with zero or several solutions
- [x] The generator rejects any case the logical solver cannot finish
- [x] Tests replay every shipped case and fail on any that breaks either rule
- [x] Each case records its tier and the tier matches the solver's grading

## Evidence / Current State
Built and enforced (2026-11-24). The generator gates `unique`, `logic` and `tier` in `lib/gen/gen_case.dart` reject a draw with no or several solutions, one the logic solver cannot finish, or one graded outside its tier. `checkShipped` in `lib/gen/gen_check.dart` re-proves all of it from the stored text of every shipped case, in `test/data/packs_test.dart` and in `dart run tool/check_cases.dart`. A case records its tier by the pack it is in and its id (`easy-007`). Machine-checked rules: GEN-010, GEN-013, GEN-014, GEN-015 in the [GEN register](../gen/README.md). No case has reached a player yet; that is a release matter, not this requirement.

## Related Requirements
- [APP-QAL-002](../app_requirements/qal/APP-QAL-002.md) — Every Shipped Case Is Replayed by Tests
