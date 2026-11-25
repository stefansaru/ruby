# APP-PRV-002 — No Account, Data Stays on the Device

**Tags:** Privacy
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
The game needs no account and no sign-in. Progress, notes and settings are stored on the device only. The app itself sends nothing to a server and carries no ad SDK (owner ruling 2026-11-25); the only network use is the store's billing when the player buys or restores the one purchase. The game plays fully offline.

## Why
It is the least data that can run the game, and competitors advertise 'no account needed' as a feature.

## Acceptance Criteria
- [ ] No analytics or crash SDK is added without an owner decision and a privacy-policy change
- [ ] Every case and every feature works in aeroplane mode, except buying or restoring the purchase

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-QAL-003](../../app_requirements/qal/APP-QAL-003.md) — Plays Offline
- [APP-PAY-003](../../app_requirements/pay/APP-PAY-003.md) — Restorable, Works Offline, Price Before the Gate

## Related Docs
- [Monetisation.md](../../../strategy/Monetisation.md)
