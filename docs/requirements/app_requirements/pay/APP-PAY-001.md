# APP-PAY-001 — One Purchase Unlocks Everything; No Ads Anywhere

**Tags:** Pay, Monetisation, PlayerRespect
**Status:** ❌ Pending (written 2026-11-25)
**NORM Sources:** (derived; no normative register exists yet)

> The no-ads part is an owner ruling of 2026-11-25. The purchase model and its price are a recommendation the owner has not yet confirmed ([Monetisation.md](../../../strategy/Monetisation.md)). Whether future packs are included, and whether extra statements or hints are ever sold, are open.

## Requirement
The app shows no advertising of any kind and links no ad SDK: no banner, no rewarded video, no interstitial, no consent flow for ads. The app sells exactly one product: a one-time, non-consumable purchase that unlocks every pack that is not free. There is no subscription, no coin pack, no consumable, no energy and no key.

## Why
The owner ruled on 2026-11-25 that this puzzle carries no ads. One purchase is a decision the player makes once; it is the pattern of the premium puzzle apps this audience already pays for. It replaces APP-ADS-001..004, APP-GAM-007 and APP-PRV-001.

## Acceptance Criteria
- [ ] No ad SDK is a dependency in `pubspec.yaml`, checked by a test
- [ ] The store lists one in-app product for this app and it is non-consumable
- [ ] After the purchase every pack is open
- [ ] No screen offers a second product
- [ ] The store listing declares "contains ads: no"

## Implementation
Nothing built yet. No billing code and no unlock gate exist; every pack is open in the draft (2026-11-25). No ad SDK is in the project.

## Related Tests
None yet.

## Related Requirements
- [APP-PAY-002](../../app_requirements/pay/APP-PAY-002.md) — The Free Part Is Fully Playable
- [APP-PAY-003](../../app_requirements/pay/APP-PAY-003.md) — Restorable, Works Offline, Price Before the Gate
- [STRAT-MIS-001](../../strategy_requirements/STRAT-MIS-001.md) — Fair Monetisation Without Ads: Free to Try, One Purchase
- [APP-GAM-009](../../app_requirements/gam/APP-GAM-009.md) — Case Selection Without Gates

## Related Docs
- [Monetisation.md](../../../strategy/Monetisation.md)
- [Ads.md](../../../architecture/ads/Ads.md) (retired)
