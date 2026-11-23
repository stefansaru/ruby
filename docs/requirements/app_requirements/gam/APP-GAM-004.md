# APP-GAM-004 — Auto-Eliminate Toggle

**Tags:** Gameplay, Notes, Settings
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
A setting that, when on, crosses the rest of a placed person's row and column for everyone and removes exactly those crosses when the person is removed. It applies the row-and-column rule as the engine states it for the case and never applies a clue.

## Why
Row-and-column crossing is bookkeeping that beginners should not have to do by hand and experts may want to do themselves.

## Acceptance Criteria
- [ ] The toggle is in settings and remembered
- [ ] Automatic crosses look different from the player's own
- [ ] A player's own cross is never removed by the automation
- [ ] Cases with empty rows or columns, and multi-grid cases, follow the engine's rule

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-003](../../app_requirements/gam/APP-GAM-003.md) — Notes per Suspect

## Related Docs
- [Notes.md](../../../features/Notes.md)
