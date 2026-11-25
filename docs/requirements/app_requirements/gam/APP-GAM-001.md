# APP-GAM-001 — Placing and Removing People

**Tags:** Gameplay, Core
**Status:** ⚠️ Partial (2026-11-25)
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
Draft built (2026-11-25). `CaseSession` (`lib/engine/session.dart`) places, moves and removes anyone, the victim included; it refuses a square nobody can stand on and a square someone else is on, and reports people who share a row or column (`conflicts`) without refusing them. `lib/screens/case_screen.dart` asks it and says "Nobody can stand there." on a refusal; `lib/widgets/case_grid.dart` marks the clashing people. Missing: the draft draws placeholder shapes, it is not laid out for small phones, a half-solved board is not saved (APP-GAM-012), and undo is not built (APP-GAM-005). The criteria stay open until the owner has played the build.

## Related Tests
`test/engine/session_test.dart` (GEN-001), `test/screens/play_test.dart`.

## Related Requirements
- [APP-GAM-002](../../app_requirements/gam/APP-GAM-002.md) — Accusation and Win Check
- [APP-GAM-005](../../app_requirements/gam/APP-GAM-005.md) — Undo, Redo and Restart

## Related Docs
- [GameRules.md](../../../GameRules.md)
- [Architecture.md](../../../Architecture.md)
