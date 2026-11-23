# PROC-TST-002 — Manual Test Plan Before a Release

**Tags:** Process, Testing, Release
**Status:** ❌ Pending (written 2026-11-24)

## Requirement
What cannot be tested automatically (ads on a device, audio during an ad, thumb reach above the banner, small-screen readability, TalkBack) is listed as numbered manual cases and run on a real device before every store release, with results kept per build.

## Why
The promises most likely to break (ads and audio) are the ones unit tests cannot see.

## Acceptance Criteria
- [ ] ManualTestPlan.md exists with numbered cases
- [ ] A filled copy exists for each released build

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-ADS-003](../app_requirements/ads/APP-ADS-003.md) — Ads Never Interrupt, Never Touch Audio
- [APP-QAL-003](../app_requirements/qal/APP-QAL-003.md) — Plays Offline

## Related Docs
- [ManualTestPlan.md](../../testing/ManualTestPlan.md)
