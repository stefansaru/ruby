# APP-GAM-001 — Placing and Removing People

**Tags:** Gameplay, Core
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
The player selects a person and taps a square to place them, and can move or remove them at any time. A square that cannot be occupied refuses the placement and shows why. Placing two people in one row or column is allowed but marked as a conflict; the game does not block the player from being wrong.

## Why
Placement is the whole game. Refusing impossible squares is bookkeeping; refusing wrong-but-possible moves would be an unrequested hint.

## Acceptance Criteria
- [ ] Every person, the victim included, can be placed, moved and removed
- [ ] A blocking object or a square outside the grid cannot be chosen
- [ ] A row or column conflict is shown on both people
- [ ] The rules applied come from the engine, never re-implemented in the view

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-002](../../app_requirements/gam/APP-GAM-002.md) — Accusation and Win Check
- [APP-GAM-005](../../app_requirements/gam/APP-GAM-005.md) — Undo, Redo and Restart

## Related Docs
- [GameRules.md](../../../GameRules.md)
- [Architecture.md](../../../Architecture.md)
