---
tags: Mission, Monetisation, PlayerRespect
status: Pending
strategic_sources: [VisionMissionValues.md, Monetisation.md, TargetAudience.md]
---

# STRAT-MIS-001 — Fair Monetisation Without Ads: Free to Try, One Purchase

**Status:** ❌ Pending (rewritten 2026-11-25; written 2026-11-24 as "Free to Play, Fair Monetisation")

> Until 2026-11-24 this requirement said the game was free, with a banner and an opt-in rewarded video for hint coins and no purchases. The owner ruled on 2026-11-25 that the game carries no ads. The purchase model below is a recommendation; the owner has not yet confirmed the price or what is free.

## Intent
Intrusive ads are the genre's second-ranked complaint, and 43% of puzzle players say they quit over too many ads. A player gated from a logic puzzle leaves. The audience already pays for puzzles: the book that made the genre lists at about $19.

## Requirement
The game shows no advertising of any kind. It is free to download, and the tutorial and easy packs are free and fully playable. Its only income is one one-time purchase that unlocks everything else. There is no subscription, no energy, no keys, no timers, no coin packs and no dark pattern around the purchase.

## Strategic Sources
- [VisionMissionValues.md](../../strategy/VisionMissionValues.md)
- [Monetisation.md](../../strategy/Monetisation.md)
- [TargetAudience.md](../../strategy/TargetAudience.md)

## Acceptance Criteria
- [ ] No ad and no ad SDK exists in the app
- [ ] Exactly one product is sold, once
- [ ] Every free case can be reached and solved without paying, waiting or watching anything
- [ ] The price is shown before the gate and the purchase can be restored
- [ ] The owner has confirmed the price and what is free

## Evidence / Current State
No ad code exists. Nothing about purchasing is built: no billing code, no unlock gate, and every pack is open in the draft (2026-11-25).

## Related Requirements
- [APP-PAY-001](../app_requirements/pay/APP-PAY-001.md) — One Purchase Unlocks Everything; No Ads Anywhere
- [APP-PAY-002](../app_requirements/pay/APP-PAY-002.md) — The Free Part Is Fully Playable
- [APP-PAY-003](../app_requirements/pay/APP-PAY-003.md) — Restorable, Works Offline, Price Before the Gate
- [APP-GAM-009](../app_requirements/gam/APP-GAM-009.md) — Case Selection Without Gates
- Retired with the ads: [APP-ADS-001](../app_requirements/ads/APP-ADS-001.md), [APP-ADS-002](../app_requirements/ads/APP-ADS-002.md), [APP-ADS-003](../app_requirements/ads/APP-ADS-003.md), [APP-GAM-007](../app_requirements/gam/APP-GAM-007.md)
