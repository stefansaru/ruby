# APP-PRV-001 — Consent Before the Ad SDK

**Tags:** Privacy, Ads, Legal
**Status:** ⛔ Retired (2026-11-25)
**NORM Sources:** (derived; no normative register exists yet)

> Retired 2026-11-25. Owner ruling: the game carries no ads, so there is no ad SDK to hold back and no consent flow for ads. Replaced by [APP-PAY-001](../pay/APP-PAY-001.md) (no ad SDK is linked) and [APP-PRV-002](APP-PRV-002.md) (the app sends nothing of its own). The rest of this file is kept as history.

## Requirement
The ad SDK is not initialised and no ad request is made until consent has been gathered where the law requires it. One property, `ConsentService.adsReady`, is the only definition of 'ads may run'. The player can reopen the consent choice from settings.

## Why
Initialising before consent is unlawful in several markets. Two definitions of readiness will eventually disagree.

## Acceptance Criteria
- [ ] No `MobileAds` call precedes `adsReady`, checked by a test
- [ ] The consent form can be reopened
- [ ] The request configuration reflects the consent and age answers

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-ADS-001](../../app_requirements/ads/APP-ADS-001.md) — Banner
- [APP-PRV-003](../../app_requirements/prv/APP-PRV-003.md) — Privacy Policy and Age Handling

## Related Docs
- [Ads.md](../../../architecture/ads/Ads.md)
- [RiskAnalysis.md](../../../strategy/RiskAnalysis.md)
