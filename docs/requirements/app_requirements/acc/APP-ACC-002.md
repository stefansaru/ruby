# APP-ACC-002 — Tap Targets and Text Size

**Tags:** Accessibility, Layout
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Every control is at least 48 dp. On a grid too large for 48 dp squares on the device, the grid can be zoomed and panned. Clue text follows the system text size without clipping.

## Why
A 9×9 grid on a 360 dp phone gives 40 dp squares before any margin; 'cumbersome' marking is a quoted complaint.

## Acceptance Criteria
- [ ] Controls meet 48 dp
- [ ] The largest shipped grid is playable on a 360 dp wide screen
- [ ] Clues remain readable at the largest system text size

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-UX-001](../../app_requirements/ux/APP-UX-001.md) — Lettered Columns and Numbered Rows

## Related Docs
- [TargetAudience.md](../../../strategy/TargetAudience.md)
