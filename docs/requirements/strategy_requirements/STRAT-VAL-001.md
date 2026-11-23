---
tags: Values, Clarity, Wording
status: Partial
strategic_sources: [VisionMissionValues.md, PainPointsAndConcepts.md, GameRules.md, Glossary.md]
---

# STRAT-VAL-001 — One Exact Meaning per Clue

**Status:** ⚠️ Partial (2026-11-24)

## Intent
Ambiguous clue wording is the best-evidenced complaint in the genre: the market leader's most-upvoted review is about the phrase 'right column'.

## Requirement
Every clue type has one machine meaning, documented in GameRules.md, and one wording template per language. The grid carries lettered columns and numbered rows, and wording refers to them. No wording depends on which way the player counts or on an undefined word.

## Strategic Sources
- [VisionMissionValues.md](../../strategy/VisionMissionValues.md)
- [PainPointsAndConcepts.md](../../strategy/PainPointsAndConcepts.md)
- [GameRules.md](../../GameRules.md)
- [Glossary.md](../../Glossary.md)

## Acceptance Criteria
- [x] Each clue type in the engine has an entry in GameRules.md with its meaning and an example
- [ ] Each clue type has a wording template and a fixture test
- [x] Every term used in a clue is defined in the glossary
- [ ] The player can see the squares any clue allows

## Evidence / Current State
Engine side built (2026-11-24): each clue type is one object with one `holds` (GEN-004), its meaning and sentence are in GameRules.md sections 4 and 5, and the words are in the glossary. English is the only language. `test/engine/wording_test.dart` pins the sentence of most clue types, not yet all (the grid, door and two-grid forms have no fixture). Still open: fixtures for the remaining sentences, and the clue preview, which waits for the UI (APP-UX-002).

## Related Requirements
- [APP-UX-001](../app_requirements/ux/APP-UX-001.md) — Lettered Columns and Numbered Rows
- [APP-UX-002](../app_requirements/ux/APP-UX-002.md) — Clue Preview
- [APP-UX-003](../app_requirements/ux/APP-UX-003.md) — Plain, Exact Clue Wording
- [APP-UX-004](../app_requirements/ux/APP-UX-004.md) — Glossary and Object Guide in the Game
