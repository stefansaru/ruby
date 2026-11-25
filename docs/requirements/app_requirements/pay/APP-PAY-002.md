# APP-PAY-002 — The Free Part Is Fully Playable

**Tags:** Pay, Monetisation, PlayerRespect, Progression
**Status:** ❌ Pending (written 2026-11-25)
**NORM Sources:** (derived; no normative register exists yet)

> What exactly is free is a recommendation the owner has not yet confirmed ([Monetisation.md](../../../strategy/Monetisation.md)).

## Requirement
The tutorial pack and the easy pack are free and complete. Inside them nothing is held back: every case, the notes, the hints, the extra statements and undo work as they do in a paid pack. There is no timer, energy, key, daily limit or purchase prompt inside the free part. The offer to buy appears only when the player opens something locked, and in one fixed place in the menu.

## Why
The free part is the only advertisement the game has, and the game's claim (fair cases, exact clues) is one a player wants to test before paying. A crippled trial is a dark pattern, and gates are a quoted reason for leaving a competitor.

## Acceptance Criteria
- [ ] Every tutorial and easy case can be opened and solved on a fresh install with no purchase
- [ ] No tool available in a paid pack is missing or limited in a free pack
- [ ] No purchase prompt appears while a case is open or after a solve
- [ ] No timer, energy, key or daily limit exists

## Implementation
Nothing built yet. Every pack is open in the draft (2026-11-25), so there is no free part to tell from a paid part.

## Related Tests
None yet.

## Related Requirements
- [APP-PAY-001](../../app_requirements/pay/APP-PAY-001.md) — One Purchase Unlocks Everything; No Ads Anywhere
- [APP-GAM-009](../../app_requirements/gam/APP-GAM-009.md) — Case Selection Without Gates
- [STRAT-VAL-002](../../strategy_requirements/STRAT-VAL-002.md) — Respect: No Gates, No Nags

## Related Docs
- [Monetisation.md](../../../strategy/Monetisation.md)
- [Levels.md](../../../Levels.md)
