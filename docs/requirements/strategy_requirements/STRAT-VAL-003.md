---
tags: Values, Originality, Legal
status: Partial
strategic_sources: [VisionMissionValues.md, RiskAnalysis.md]
---

# STRAT-VAL-003 — Our Own Work

**Status:** ⚠️ Partial (written 2026-11-24)

> Partial: the rule is in force and the ignore rule exists, but nothing has shipped and the word search is not yet a test.

## Intent
The genre has a living author and publisher. Mechanics are common ground; their expression belongs to them. Copying would be wrong and would also put the listing at risk.

## Requirement
The game reuses the genre's mechanics and nothing else. No puzzle, character name, sentence, picture or trade name from the source books or from a competing app is shipped. The word 'Murdoku' appears in no code, asset or store copy.

## Strategic Sources
- [VisionMissionValues.md](../../strategy/VisionMissionValues.md)
- [RiskAnalysis.md](../../strategy/RiskAnalysis.md)

## Acceptance Criteria
- [ ] Every shipped case is produced by the generator from a pinned seed
- [ ] Test fixtures are written for this project
- [ ] `input/` is git-ignored and nothing from it is committed
- [ ] A search of `lib/`, `assets/`, `tool/` and the store copy for the word 'Murdoku' finds nothing

## Evidence / Current State
`input/` and `output/` are ignored in `.gitignore`. The search in the last criterion is not automated yet.

## Related Requirements
- [PROC-CNT-001](../process_requirements/PROC-CNT-001.md) — Cases Are Generated, Seeded and Never Hand-Edited
- [PROC-CNT-002](../process_requirements/PROC-CNT-002.md) — No Third-Party Content
