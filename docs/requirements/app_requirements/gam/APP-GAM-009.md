# APP-GAM-009 — Case Selection Without Gates

**Tags:** Gameplay, Progression
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

> The exact unlock rule (strict order, or a few cases ahead) is the agent's proposal and waits for the owner. Revised 2026-11-25: the one purchase is now the only lock besides order; until 2026-11-24 this file said no purchase locked a case. Which packs are free is a recommendation the owner has not yet confirmed.

## Requirement
Cases are grouped by setting and tier. A case opens when the one before it in its pack is solved; the first case of every pack in the easy tier is open from the start. The packs above easy are unlocked by the one purchase (APP-PAY-001), with the price shown first (APP-PAY-003). Nothing else locks a case: no ads, coins, keys, timers or energy, and no second purchase.

## Why
Order gives a learning curve. Any other lock is a gate, and gates are a quoted reason for leaving a competitor.

## Acceptance Criteria
- [ ] The unlock rule is shown to the player
- [ ] No case is locked by anything but order and the one purchase
- [ ] Every tutorial and easy case can be reached without paying
- [ ] Progress is stored on the device and survives restart

## Implementation
A case list exists in the draft and every pack is open (2026-11-25): no unlock by order, no purchase gate. Solved ticks are saved on the device (`lib/services/progress.dart`); a half-solved board is not (APP-GAM-012).

## Related Tests
None yet.

## Related Requirements
- [STRAT-VAL-002](../../strategy_requirements/STRAT-VAL-002.md) — Respect: No Gates, No Nags
- [STRAT-MIS-001](../../strategy_requirements/STRAT-MIS-001.md) — Fair Monetisation Without Ads: Free to Try, One Purchase
- [APP-PAY-001](../../app_requirements/pay/APP-PAY-001.md) — One Purchase Unlocks Everything; No Ads Anywhere
- [APP-PAY-002](../../app_requirements/pay/APP-PAY-002.md) — The Free Part Is Fully Playable

## Related Docs
- [Levels.md](../../../Levels.md)
- [Monetisation.md](../../../strategy/Monetisation.md)
