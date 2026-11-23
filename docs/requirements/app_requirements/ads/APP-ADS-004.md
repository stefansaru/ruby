# APP-ADS-004 — Ad Unit Ids: Test by Default, Production at Release

**Tags:** Ads, Build, Security
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Ad unit ids are read from `--dart-define`. When absent, Google's published test ids are used. A store build asserts that production ids are present. No production id is committed to the repository.

## Why
Shipping test ids earns nothing; clicking real ads in development risks the ad account.

## Acceptance Criteria
- [ ] Debug and internal builds show test ads
- [ ] The release script injects the ids and refuses to run off `main`
- [ ] A store build with test ids fails at start-up in a way a test catches

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [PROC-REL-001](../../process_requirements/PROC-REL-001.md) — Release Builds

## Related Docs
- [Ads.md](../../../architecture/ads/Ads.md)
