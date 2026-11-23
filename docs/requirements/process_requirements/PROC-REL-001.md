# PROC-REL-001 — Release Builds

**Tags:** Process, Release, Build
**Status:** ❌ Pending (written 2026-11-24)

## Requirement
A store build is made by a script that injects production ad ids, marks the build as a store build, runs the gates and refuses to run from any branch but `main`. Each release is logged with its version, date and commit.

## Why
A release made by hand eventually ships test ads or an untested commit.

## Acceptance Criteria
- [ ] PowerShell and bash release scripts exist and agree
- [ ] The script fails off `main` or with a red gate
- [ ] A release log entry exists per upload

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-ADS-004](../app_requirements/ads/APP-ADS-004.md) — Ad Unit Ids: Test by Default, Production at Release
- [PROC-TST-002](../process_requirements/PROC-TST-002.md) — Manual Test Plan Before a Release

## Related Docs
- [Ads.md](../../architecture/ads/Ads.md)
