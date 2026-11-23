---
tags: Values, Clarity, Content
status: Partial
strategic_sources: [VisionMissionValues.md, Settings.md]
---

# STRAT-VAL-004 — Simple Words, Simple Places

**Status:** ⚠️ Partial (2026-11-24)

## Intent
A clue is read many times. An unfamiliar word in it costs the player every time, and costs more in translation.

## Requirement
Settings, areas and objects have short everyday names. A setting is a place a child could name (Home, Beach, Forest). An area or object name is one or two common words.

## Strategic Sources
- [VisionMissionValues.md](../../strategy/VisionMissionValues.md)
- [Settings.md](../../Settings.md)

## Acceptance Criteria
- [x] Every setting, area and object name is listed in Settings.md
- [ ] No name needs a footnote or a legend to be understood
- [ ] Two objects in one setting never differ only by an adjective the art cannot show

## Evidence / Current State
The twelve settings with their areas and objects are in `lib/data/settings.dart` and listed in Settings.md (2026-11-24). Open: the owner has not reviewed the names; Settings.md lists rough edges ("Room 1" and "Room 2", object and area pairings that read oddly); the third criterion needs the art.

## Related Requirements
- [APP-AST-002](../app_requirements/ast/APP-AST-002.md) — Objects Read at a Glance
- [APP-L10N-001](../app_requirements/l10n/APP-L10N-001.md) — All Player Text from Templates
