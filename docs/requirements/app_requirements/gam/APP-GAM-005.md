# APP-GAM-005 — Undo, Redo and Restart

**Tags:** Gameplay
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Every board action can be undone and redone: placing, removing, notes, shortcuts and a hint's Place. Undoing a placement restores the notes that were there. Restart clears the case after a confirmation.

## Why
A deduction puzzle is explored by trying. A competitor's undo that loses notes is listed as a reason players return to paper.

## Acceptance Criteria
- [ ] Undo and redo have no depth limit within a case
- [ ] A shortcut or auto-elimination is one step
- [ ] Notes survive undo of a placement
- [ ] Restart asks first

## Implementation
Nothing built yet.

## Related Tests
None yet.

## Related Requirements
- [APP-GAM-003](../../app_requirements/gam/APP-GAM-003.md) — Notes per Suspect

## Related Docs
- [Notes.md](../../../features/Notes.md)
