# APP-AST-001 — Pixel Art from Tracked Sheets and Prompts

**Tags:** Assets, Art, Pipeline
**Status:** ❌ Pending (written 2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Art is pixel art in one style. Every accepted sheet is kept in `sprites/` with the prompt that produced it in `sprites/prompts/`; game assets are cut from the sheets by the tools. Draft prompts and previews live in the ignored `output/` folder.

## Why
It is pushy's working pipeline: the sheet and its prompt are the only copy of art that no command can rebuild.

## Acceptance Criteria
- [ ] Every file under `assets/` that is art can be rebuilt from `sprites/` by a tool
- [ ] Every accepted sheet has its prompt
- [ ] Docs list the art still outstanding

## Implementation
The art list (`docs/Art.md`) and the prompt writer (`tool/write_sprite_prompts.py`) are written (2026-11-24; prompts regenerated 2026-11-25, now eleven: cat tokens and a TV banner added, the upright wide sheet dropped). No art exists; the cutter is not built.

## Related Tests
None yet.

## Related Requirements
- [STRAT-RSK-002](../../strategy_requirements/STRAT-RSK-002.md) — Art Review Gate

## Related Docs
- [Art.md](../../../Art.md)
