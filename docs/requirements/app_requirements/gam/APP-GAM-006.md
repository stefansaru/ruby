# APP-GAM-006 — Hint Ladder

**Tags:** Gameplay, Hints
**Status:** ⚠️ Partial (2026-11-25)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Three hints of rising value: show the squares a chosen suspect can still occupy; point to the person or line the next step concerns and name the technique; explain the next step in words and offer to place it. Each hint is the logical solver's next step from the current board. If the board is already wrong, the hint says what is wrong first. Hints are free: no price, no balance, no limit per day (2026-11-25; the coin economy of APP-GAM-007 is retired with the ads).

## Why
The well-reviewed newcomers all explain the step. A hint that only gives the answer teaches nothing and ends the puzzle.

## Acceptance Criteria
- [ ] The three hints exist and none has a price or a limit
- [ ] A hint never reads the stored solution to decide what to say, except to detect a wrong board
- [ ] The explanation names a technique from Techniques.md and a square by its coordinates
- [ ] Place happens only when the player presses it
- [ ] A hint can be reread until the board changes

## Implementation
A draft is built (2026-11-25), free: one hint button; the first tap says who to look at and gives any step that cannot be read off the grid, the second tap gives the square; the hint card has a close button; a wrong placement is named first (`CaseSession.hint`, `lib/engine/session.dart`). Missing: the three separate steps, "show squares", the technique's name in the hint, the Place button, approved hint sentences, and the reason a wrong placement is wrong. See [Hints.md](../../../features/Hints.md).

## Related Tests
`test/engine/session_test.dart` covers the session the draft hint comes from. No test cites this requirement.

## Related Requirements
- [APP-GAM-007](../../app_requirements/gam/APP-GAM-007.md) — Hint Economy: One Coin Balance (retired 2026-11-25)
- [APP-QAL-004](../../app_requirements/qal/APP-QAL-004.md) — A Hint Arrives Quickly

## Related Docs
- [Hints.md](../../../features/Hints.md)
- [Techniques.md](../../../Techniques.md)
