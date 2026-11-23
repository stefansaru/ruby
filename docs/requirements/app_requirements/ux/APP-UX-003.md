# APP-UX-003 — Plain, Exact Clue Wording

**Tags:** UX, Clarity, Content
**Status:** ⚠️ Partial (2026-11-24)
**NORM Sources:** (derived; no normative register exists yet)

## Requirement
Clue text is produced from one template per clue type and language. Templates use the grid labels and the glossary's words: 'in column C', 'in a row above Ben', 'exactly 2 columns to the right of Ben', 'beside a tree'. Phrases whose meaning depends on interpretation, such as 'the right column' or 'near', are not used. Key words are emphasised.

## Why
One loosely worded clue undoes the product's main claim.

## Acceptance Criteria
- [x] No clue text is written by hand for a single case
- [ ] Each template has a fixture test pairing the text with the squares it allows
- [ ] Template changes follow PROC-CNT-003

## Implementation
Engine side built (2026-11-24): `describeClue` in `lib/engine/wording.dart` makes every sentence from the clue object; packs store the typed notation, never a sentence (GEN-004, GEN-024). `test/engine/wording_test.dart` pins the sentences; `test/engine/clue_test.dart` pins the meanings. Open: a fixture that pairs each sentence with the squares it allows, sentences not yet pinned (grid, door, two-grid forms), and the owner's review of the wording (PROC-CNT-003).

## Related Tests
`test/engine/wording_test.dart`, `test/engine/clue_test.dart`, `test/data/packs_test.dart` (GEN-004, GEN-024).

## Related Requirements
- [STRAT-VAL-001](../../strategy_requirements/STRAT-VAL-001.md) — One Exact Meaning per Clue
- [APP-L10N-001](../../app_requirements/l10n/APP-L10N-001.md) — All Player Text from Templates
- [PROC-CNT-003](../../process_requirements/PROC-CNT-003.md) — Player-Facing Words Are Proposed First

## Related Docs
- [GameRules.md](../../../GameRules.md)
- [Glossary.md](../../../Glossary.md)
- [PainPointsAndConcepts.md](../../../strategy/PainPointsAndConcepts.md)
