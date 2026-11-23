# APP-QAL-004 — A Hint Arrives Quickly

**Tags:** Quality, Performance
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

> The budget is not set; it needs the benchmark first.

## Requirement
Computing the next logical step for a hint on the largest shipped case takes no longer than a budget, measured on a low-end device, and does not freeze the screen.

## Why
A solver that is fine on a desktop can stall a phone, and a hint that hangs looks like a crash.

## Acceptance Criteria
- [ ] The budget is a named constant, set from measurement
- [ ] The engine benchmark reports hint time per tier
- [ ] Long computations run off the UI thread

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-006](../../app_requirements/gam/APP-GAM-006.md) — Hint Ladder

## Related Docs
- [Techniques.md](../../../Techniques.md)
