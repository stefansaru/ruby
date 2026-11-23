# APP-GAM-006 — Hint Ladder

**Tags:** Gameplay, Hints
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Three hints of rising value: show the squares a chosen suspect can still occupy; point to the person or line the next step concerns and name the technique; explain the next step in words and offer to place it. Each hint is the logical solver's next step from the current board. If the board is already wrong, the hint says what is wrong first.

## Why
The well-reviewed newcomers all explain the step. A hint that only gives the answer teaches nothing and ends the puzzle.

## Acceptance Criteria
- [ ] The three hints exist and are priced separately
- [ ] A hint never reads the stored solution to decide what to say, except to detect a wrong board
- [ ] The explanation names a technique from Techniques.md and a square by its coordinates
- [ ] Place happens only when the player presses it
- [ ] A paid hint can be reread until the board changes

## Implementation
The logical solver that will supply the steps is being built in round 1. No hint UI exists.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-007](../../app_requirements/gam/APP-GAM-007.md) — Hint Economy: One Coin Balance
- [APP-ADS-002](../../app_requirements/ads/APP-ADS-002.md) — Rewarded Video for Hint Coins
- [APP-QAL-004](../../app_requirements/qal/APP-QAL-004.md) — A Hint Arrives Quickly

## Related Docs
- [Hints.md](../../../features/Hints.md)
- [Techniques.md](../../../Techniques.md)
