# APP-GAM-002 — Accusation and Win Check

**Tags:** Gameplay, Core
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
When everyone is placed the player can submit. The engine checks the board against the rules and the clues. If it is right, the solved screen names the murderer and the area. If it is wrong, the game says so without revealing which placement is wrong; finding the fault is a hint.

## Why
The engine is the only judge, so a case can never be 'correct' once and 'wrong' later. Revealing the wrong person for free would make the hint ladder pointless.

## Acceptance Criteria
- [ ] Submit is enabled only when everyone is placed
- [ ] The check is the engine's own validator
- [ ] A right answer always succeeds, on every replay
- [ ] A wrong answer costs nothing and loses nothing

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-006](../../app_requirements/gam/APP-GAM-006.md) — Hint Ladder
- [APP-UX-005](../../app_requirements/ux/APP-UX-005.md) — A Line of Story
- [APP-QAL-002](../../app_requirements/qal/APP-QAL-002.md) — Every Shipped Case Is Replayed by Tests

## Related Docs
- [GameRules.md](../../../GameRules.md)
