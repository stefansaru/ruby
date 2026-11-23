# APP-GAM-007 — Hint Economy: One Coin Balance

**Tags:** Gameplay, Hints, Monetisation, Persistence
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

> The values of the constants are an open owner decision.

## Requirement
One coin balance, kept on the device, pays for all hints. Coins come from a starting grant, from solving a case for the first time, and from watching a rewarded ad. The ad reward equals the price of the dearest hint. A spend the balance cannot cover debits nothing. Every price and award is a named constant in one file.

## Why
One balance lets the player compare hints and earn them by playing. One ad for one full explanation needs no arithmetic. This is amethyst's APP-GAM-015, which replaced per-hint counters for these reasons.

## Acceptance Criteria
- [ ] Prices and awards exist only as `hintCost*`, `hintReward*` and `hintBudgetStart` constants
- [ ] `hintRewardPerAd` equals `hintCostExplainStep`, checked by a test
- [ ] Spending is all-or-nothing
- [ ] Replaying a solved case awards nothing
- [ ] The balance survives restart

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-006](../../app_requirements/gam/APP-GAM-006.md) — Hint Ladder
- [APP-ADS-002](../../app_requirements/ads/APP-ADS-002.md) — Rewarded Video for Hint Coins

## Related Docs
- [Hints.md](../../../features/Hints.md)
- [Monetisation.md](../../../strategy/Monetisation.md)
