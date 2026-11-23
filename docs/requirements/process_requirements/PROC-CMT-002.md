# PROC-CMT-002 — Commit Only When Asked; Never the Working Folders

**Tags:** Process, Commit
**Status:** ⚠️ Partial (written 2026-11-24)

> Partial: the ignore rules exist; nothing automated checks a commit for secrets.

## Requirement
The agent commits and pushes only when the owner asks. `input/` and `output/` are git-ignored and nothing from them is ever committed. No secret is committed.

## Why
`input/` holds photographs of a published book. A commit is the owner's decision.

## Acceptance Criteria
- [ ] `.gitignore` lists `/input/` and `/output/`
- [ ] `git status` shows neither before a commit

## Implementation
`.gitignore` carries both rules since 2026-11-24.

## Related Tests
None yet.

## Related Requirements
- [STRAT-VAL-003](../strategy_requirements/STRAT-VAL-003.md) — Our Own Work

## Related Docs
- [CommitChecklist.md](../../process/CommitChecklist.md)
