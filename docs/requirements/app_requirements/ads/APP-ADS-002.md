# APP-ADS-002 — Rewarded Video for Hint Coins

**Tags:** Ads, Monetisation, Hints
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

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
