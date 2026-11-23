# APP-PRV-002 — No Account, Data Stays on the Device

**Tags:** Privacy
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
The game needs no account and no sign-in. Progress, notes, settings and coins are stored on the device only. The app itself sends nothing to a server; the only network use is the ad and consent SDKs. The game plays fully offline.

## Why
It is the least data that can run the game, and competitors advertise 'no account needed' as a feature.

## Acceptance Criteria
- [ ] No analytics or crash SDK is added without an owner decision and a privacy-policy change
- [ ] Every case and every non-ad feature works in aeroplane mode

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-QAL-003](../../app_requirements/qal/APP-QAL-003.md) — Plays Offline

## Related Docs
- [Ads.md](../../../architecture/ads/Ads.md)
