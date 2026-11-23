# APP-UX-001 — Lettered Columns and Numbered Rows

**Tags:** UX, Clarity, Grid
**Status:** ⚠️ Partial (2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Every grid shows a letter over each column (A from the left) and a number beside each row (1 at the top). Clues, hints and the solved screen refer to squares, rows and columns by these labels. On a multi-grid case each grid has its own name and its own labels.

## Why
'Someone is in row 3 but the rows and columns aren't numbered so you don't know which way to start counting' is a quoted two-star review.

## Acceptance Criteria
- [ ] Labels are visible at every supported screen size
- [x] No clue wording uses an ordinal that depends on counting direction without the label
- [ ] Hints name squares as letter then number

## Implementation
Wording side built (2026-11-24): clue sentences name rows by number and columns by letter, squares are labelled letter then number (`CaseDef.cellLabel`), and on a two-grid case row and column sentences end "of her grid" / "of his grid" (GEN-024). The grid itself and the hint text wait for the UI.

## Related Tests
`test/engine/wording_test.dart`, `test/data/packs_test.dart` (GEN-024).

## Related Requirements
- [APP-UX-003](../../app_requirements/ux/APP-UX-003.md) — Plain, Exact Clue Wording
- [STRAT-VAL-001](../../strategy_requirements/STRAT-VAL-001.md) — One Exact Meaning per Clue

## Related Docs
- [PainPointsAndConcepts.md](../../../strategy/PainPointsAndConcepts.md)
- [GameRules.md](../../../GameRules.md)
