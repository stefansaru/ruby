# APP-QAL-002 — Every Shipped Case Is Replayed by Tests

**Tags:** Quality, Content, Fairness
**Status:** ✅ Done (2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
A test loads every case in `lib/data/`, checks its stored solution against the engine, proves the solution unique, and solves it with the logical solver within its tier. A case that fails any of these fails the build.

## Why
A case that is wrong should fail on the developer's machine, not on a player's phone. 'Previously marked correct are now wrong' is a quoted competitor bug.

## Acceptance Criteria
- [x] The test covers every pack by discovery, not by a hand-kept list
- [x] Adding a broken case to a pack makes the suite fail

## Implementation
Built (2026-11-24). `test/data/packs_test.dart` runs `checkShipped` (`lib/gen/gen_check.dart`) on every entry of every pack: parse (which re-checks the stored solution), exactly one solution and it is the stored one, solved by the logic solver within the tier, every suspect speaks, no clue to spare. Packs are reached through `lib/data/cases.dart`; the same test fails unless there is a pack for every tier and a case for every campaign slot, so a pack cannot be left out. `dart run tool/check_cases.dart` runs the same check from the command line. A broken entry fails the per-case expectation; this is by construction and has no test of its own.

## Related Tests
`test/data/packs_test.dart` (GEN-009, GEN-010, GEN-013, GEN-014, GEN-015, GEN-019, GEN-020, GEN-022).

## Related Requirements
- [STRAT-MIS-002](../../strategy_requirements/STRAT-MIS-002.md) — Every Case Is Fair

## Related Docs
- [Testing.md](../../../Testing.md)
- [Levels.md](../../../Levels.md)
- [GEN register](../../../requirements/gen/README.md)
