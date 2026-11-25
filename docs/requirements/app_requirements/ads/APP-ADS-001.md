# APP-ADS-001 — Banner

**Tags:** Ads, Monetisation
**Status:** ⛔ Retired (2026-11-25)
**NORM Sources:** (derived; no normative register exists yet)

> Retired 2026-11-25. Owner ruling: the game carries no ads, so there is no banner. Replaced by [APP-PAY-001](../pay/APP-PAY-001.md) (one purchase unlocks everything; no ads anywhere). The rest of this file is kept as history.

## Requirement
One adaptive anchored banner sits at the bottom of every screen, placed once for the whole app. It is not shown during the consent flow, never overlaps content, loads once at a time and backs off after a failed load.

## Why
A passive banner earns without interrupting. The loading rules are the ones amethyst arrived at through audits.

## Acceptance Criteria
- [ ] The banner is injected in one place
- [ ] No banner request is made before `ConsentService.adsReady`
- [ ] A manual test on a small phone shows the bottom controls are not mis-tapped onto the ad
- [ ] There is no gap between the divider and the creative

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-PRV-001](../../app_requirements/prv/APP-PRV-001.md) — Consent Before the Ad SDK
- [APP-ADS-004](../../app_requirements/ads/APP-ADS-004.md) — Ad Unit Ids: Test by Default, Production at Release

## Related Docs
- [Ads.md](../../../architecture/ads/Ads.md)
- [Monetisation.md](../../../strategy/Monetisation.md)
