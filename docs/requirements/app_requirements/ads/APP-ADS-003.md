# APP-ADS-003 — Ads Never Interrupt, Never Touch Audio

**Tags:** Ads, PlayerRespect
**Status:** ⛔ Retired (2026-11-25)
**NORM Sources:** (derived; no normative register exists yet)

> Retired 2026-11-25. Owner ruling: the game carries no ads, so no ad can interrupt or touch audio. Replaced by [APP-PAY-001](../pay/APP-PAY-001.md) (no ads anywhere) and, for what may never interrupt a case, [APP-PAY-002](../pay/APP-PAY-002.md) (no purchase prompt inside a case). The rest of this file is kept as history.

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
