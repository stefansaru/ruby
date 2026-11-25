# PROC-TST-002 — Manual Test Plan Before a Release

**Tags:** Process, Testing, Release
**Status:** ❌ Pending (written 2026-11-24)

## Requirement
What cannot be tested automatically (the purchase and its restore on a device with a test account, a paid pack opening offline, small-screen readability, TalkBack) is listed as numbered manual cases and run on a real device before every store release, with results kept per build.

## Why
The promises most likely to break (a purchase that is honoured, restored and works offline) are ones unit tests cannot see. Until 2026-11-24 the list was about ads and audio; the game carries no ads (owner ruling 2026-11-25).

## Acceptance Criteria
- [ ] ManualTestPlan.md exists with numbered cases
- [ ] A filled copy exists for each released build

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-PAY-003](../app_requirements/pay/APP-PAY-003.md) — Restorable, Works Offline, Price Before the Gate
- [APP-QAL-003](../app_requirements/qal/APP-QAL-003.md) — Plays Offline

## Related Docs
- [ManualTestPlan.md](../../testing/ManualTestPlan.md)
