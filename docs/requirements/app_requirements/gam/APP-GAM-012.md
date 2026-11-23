# APP-GAM-012 — Save and Resume a Case

**Tags:** Gameplay, Persistence
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
The board, the notes and the undo history of the case in progress are saved on every change and restored when the player returns, including after the app was closed by the system.

## Why
The median puzzle session is about four minutes; a 9×9 case will be interrupted.

## Acceptance Criteria
- [ ] Leaving and reopening a case restores placements and notes exactly
- [ ] Killing the app loses at most the action in progress
- [ ] A saved case that no longer matches its pack (after an update) is discarded with a message, never loaded wrongly

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-003](../../app_requirements/gam/APP-GAM-003.md) — Notes per Suspect

## Related Docs
- [TargetAudience.md](../../../strategy/TargetAudience.md)
- [Notes.md](../../../features/Notes.md)
