# APP-UX-002 — Clue Preview

**Tags:** UX, Clarity
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Tapping a clue highlights the squares that clue allows for its person on the bare grid, ignoring other people. It is free and unlimited. For a clue that depends on another person's position the preview says so and shows what can be shown.

## Why
It lets the player check what a sentence means instead of trusting their reading, which answers the genre's first complaint. Meaning must never cost anything.

## Acceptance Criteria
- [ ] Every clue type has a preview or a stated reason why none is possible
- [ ] The preview is computed by the engine's clue evaluator, the same code that judges the case
- [ ] The preview costs nothing and is not counted as a hint

## Implementation
The clue evaluator is built in the engine (`Clue.holds`, 2026-11-24). The draft screen has no clue preview (2026-11-25).

## Related Tests
None yet.

## Related Requirements
- [APP-UX-003](../../app_requirements/ux/APP-UX-003.md) — Plain, Exact Clue Wording
- [APP-GAM-006](../../app_requirements/gam/APP-GAM-006.md) — Hint Ladder

## Related Docs
- [Hints.md](../../../features/Hints.md)
- [PainPointsAndConcepts.md](../../../strategy/PainPointsAndConcepts.md)
- [GameRules.md](../../../GameRules.md)
