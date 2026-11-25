# APP-QAL-003 — Plays Offline

**Tags:** Quality, Platform
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Every case, note, hint and setting works with no network, and so does every paid pack once the purchase has been made. Without a network the only things that cannot be done are buying and restoring the purchase; nothing else changes and nothing waits on a request. The game carries no ads (owner ruling 2026-11-25), so nothing else uses the network.

## Why
Competitors list offline play as a feature, and a puzzle is played on trains.

## Acceptance Criteria
- [ ] A manual test in aeroplane mode covers a full case with a hint, and a paid case after the purchase
- [ ] No screen blocks on a network call

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-PRV-002](../../app_requirements/prv/APP-PRV-002.md) — No Account, Data Stays on the Device
- [APP-PAY-003](../../app_requirements/pay/APP-PAY-003.md) — Restorable, Works Offline, Price Before the Gate

## Related Docs
- [ManualTestPlan.md](../../../testing/ManualTestPlan.md)
