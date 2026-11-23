# PROC-DOC-002 — One Source for Every Number

**Tags:** Process, Documentation
**Status:** ⚠️ Partial (written 2026-11-24)

> Partial: a convention, not checked by a tool.

## Requirement
A number that can change (case counts, prices, awards, thresholds, grid sizes shipped) lives in one place, in code or generated data, and docs name that place instead of repeating the value.

## Why
Two copies of a price is one stale price. amethyst and pushy both adopted this after counts in docs went wrong.

## Acceptance Criteria
- [ ] Docs name constants, not values, for prices and thresholds
- [ ] No doc or listing states a case count typed by hand

## Implementation
Followed in the docs written on 2026-11-24; targets in Objectives.md are marked as targets.

## Related Tests
None yet.

## Related Docs
- [Hints.md](../../features/Hints.md)
- [Objectives.md](../../strategy/Objectives.md)
