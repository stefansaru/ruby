# APP-ADS-003 — Ads Never Interrupt, Never Touch Audio

**Tags:** Ads, PlayerRespect
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

> If the SDK takes audio focus for a rewarded video regardless, the rule and the listing copy that rests on it must be reworded to what is true.

## Requirement
No interstitial, app-open, native or playable ad is used. No ad starts while a case is on screen except a rewarded video the player has just confirmed. The app does not mute, duck or pause the player's audio for an ad and requests ads muted where the SDK allows.

## Why
'App mutes phone during ads', 'playable ads that you cannot exit' and an ad after every puzzle are quoted one-star reasons.

## Acceptance Criteria
- [ ] The only ad formats in the code are banner and rewarded
- [ ] A manual test with music playing records what happens to audio during a rewarded video
- [ ] Playable and long unskippable formats are excluded in the ad console where possible

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [STRAT-MIS-001](../../strategy_requirements/STRAT-MIS-001.md) — Free to Play, Fair Monetisation

## Related Docs
- [Ads.md](../../../architecture/ads/Ads.md)
- [Monetisation.md](../../../strategy/Monetisation.md)
- [PainPointsAndConcepts.md](../../../strategy/PainPointsAndConcepts.md)
