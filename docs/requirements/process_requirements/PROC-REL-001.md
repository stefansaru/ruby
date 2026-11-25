# PROC-REL-001 — Release Builds

**Tags:** Process, Release, Build
**Status:** ❌ Pending (written 2026-11-24)

## Requirement
A store build is made by a script that marks the build as a store build, runs the gates and refuses to run from any branch but `main`. Each release is logged with its version, date and commit. There are no ad ids to inject: the game carries no ads (owner ruling 2026-11-25).

## Why
A release made by hand eventually ships an untested commit or a debug setting.

## Acceptance Criteria
- [ ] PowerShell and bash release scripts exist and agree
- [ ] The script fails off `main` or with a red gate
- [ ] A release log entry exists per upload

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-PAY-001](../app_requirements/pay/APP-PAY-001.md) — One Purchase Unlocks Everything; No Ads Anywhere
- [PROC-TST-002](../process_requirements/PROC-TST-002.md) — Manual Test Plan Before a Release

## Related Docs
- [Monetisation.md](../../strategy/Monetisation.md)
