# APP-ADS-001 — Banner

**Tags:** Ads, Monetisation
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

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
