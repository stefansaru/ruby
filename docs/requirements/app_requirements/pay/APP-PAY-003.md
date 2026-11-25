# APP-PAY-003 — Restorable, Works Offline, Price Before the Gate

**Tags:** Pay, Monetisation, Persistence, Honesty
**Status:** ❌ Pending (written 2026-11-25)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
The purchase can be restored on a reinstall or a new phone from the store account, through a visible "Restore purchase" action. Once made, the unlock is remembered on the device and every paid pack opens with no network. A locked pack is marked as locked in the case list, and the screen that offers the purchase shows the store's localised price before the player can buy. No countdown, fake discount or pre-ticked choice is used.

## Why
A lost purchase is a refund and a one-star review, and the stores require restore for non-consumables. The game plays offline, so a paid pack must too. Nobody should discover the price by trying to pay.

## Acceptance Criteria
- [ ] Restore returns the unlock on a fresh install with the same store account, checked on a device
- [ ] After a purchase, a paid case opens in aeroplane mode
- [ ] The price on the offer screen is the one the store returns, not a number written in the app
- [ ] A locked pack is visibly locked before it is tapped
- [ ] A failed or cancelled purchase leaves the game as it was and says so plainly

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-PAY-001](../../app_requirements/pay/APP-PAY-001.md) — One Purchase Unlocks Everything; No Ads Anywhere
- [APP-QAL-003](../../app_requirements/qal/APP-QAL-003.md) — Plays Offline
- [PROC-TST-002](../../process_requirements/PROC-TST-002.md) — Manual Test Plan Before a Release

## Related Docs
- [Monetisation.md](../../../strategy/Monetisation.md)
