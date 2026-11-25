# APP-ADS-002 — Rewarded Video for Hint Coins

**Tags:** Ads, Monetisation, Hints
**Status:** ⛔ Retired (2026-11-25)
**NORM Sources:** (derived; no normative register exists yet)

> Retired 2026-11-25. Owner ruling: the game carries no ads, so there is no rewarded video and no hint coins to earn with one. Replaced by [APP-PAY-001](../pay/APP-PAY-001.md) (one purchase; no ads anywhere); hints are free ([APP-GAM-006](../gam/APP-GAM-006.md)). The rest of this file is kept as history.

## Requirement
A rewarded video is offered only when the player asks for a hint they cannot afford (or asks to earn coins), and plays only after they confirm a dialog that states the trade. On reward the coins are credited and the hint is used. A load failure after confirmation still pays, once per ad-health snapshot. An ad closed before the reward pays nothing. When no ad can be offered, unaffordable hints are disabled with the reason.

## Why
This is the trade the audience accepts when it is 'clear and honest'. The failure rules protect both the player and the economy.

## Acceptance Criteria
- [ ] One function pays for a hint or offers the ad
- [ ] The dialog names the coins earned
- [ ] The failure grant is bounded by a latch and tested
- [ ] No free fallback exists when ads are unavailable

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-006](../../app_requirements/gam/APP-GAM-006.md) — Hint Ladder
- [APP-GAM-007](../../app_requirements/gam/APP-GAM-007.md) — Hint Economy: One Coin Balance

## Related Docs
- [Hints.md](../../../features/Hints.md)
- [Ads.md](../../../architecture/ads/Ads.md)
- [Monetisation.md](../../../strategy/Monetisation.md)
