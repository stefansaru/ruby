# GEN register — engine and generator requirements

These are the rules the engine, the generator and the shipped packs must keep.
They are machine-checked: `test/requirements_test.dart` fails when a requirement
here is not cited by a test, or when a test cites an id that is not here.
(2026-11-24: copied from the register pushy uses, because a requirement nobody
tests is a wish.)

Conventions:

- One file per id, from `_TEMPLATE.md`: Requirement, Why, How it is enforced, Covered by.
- A test cites a requirement by putting the id at the start of its name.
- Ids are never reused or renumbered. A retired requirement keeps its file with
  `**Status:** retired` and the date; none are retired yet.
- Player-facing behaviour (screens, hints as shown, the purchase) is in the APP
  requirements, see [../Requirements.md](../Requirements.md).

| Id | Requirement |
|---|---|
| [GEN-001](GEN-001.md) | One person per row and column on each grid |
| [GEN-002](GEN-002.md) | A person stands on floor or on an object that can hold one |
| [GEN-003](GEN-003.md) | The murderer is the one other person in the victim's area |
| [GEN-004](GEN-004.md) | Every clue has one meaning |
| [GEN-005](GEN-005.md) | Words about a square mean one thing |
| [GEN-006](GEN-006.md) | The parser is the validator |
| [GEN-007](GEN-007.md) | A stated solution must solve the case |
| [GEN-008](GEN-008.md) | The victim gives no statement |
| [GEN-009](GEN-009.md) | Writing a parsed case gives the same text back |
| [GEN-010](GEN-010.md) | A shipped case has exactly one solution |
| [GEN-011](GEN-011.md) | One liar means exactly one false statement |
| [GEN-012](GEN-012.md) | No-touch means not even diagonally |
| [GEN-013](GEN-013.md) | The logic solver is never wrong |
| [GEN-014](GEN-014.md) | Every shipped case is solved without guessing |
| [GEN-015](GEN-015.md) | A case's tier is the hardest technique it needs |
| [GEN-016](GEN-016.md) | The same config gives the same case |
| [GEN-017](GEN-017.md) | A config that makes no sense is refused by field |
| [GEN-018](GEN-018.md) | Gates run in a fixed order and are counted |
| [GEN-019](GEN-019.md) | No statement can be left out |
| [GEN-020](GEN-020.md) | Every suspect says something |
| [GEN-021](GEN-021.md) | No statement gives the murderer away |
| [GEN-022](GEN-022.md) | Packs are generated source and can be rebuilt exactly |
| [GEN-023](GEN-023.md) | The engine decides, the view draws |
| [GEN-024](GEN-024.md) | Wording is plain and exact |
| [GEN-025](GEN-025.md) | Clues in a case are a mix |
| [GEN-026](GEN-026.md) | The solver explains itself and accepts the player's placements |
| [GEN-027](GEN-027.md) | Grids need not be square |
| [GEN-028](GEN-028.md) | Packs are well formed as a set |
| [GEN-029](GEN-029.md) | Every object stands in an area it belongs in |
| [GEN-030](GEN-030.md) | The victim is listed last and begins with V |
| [GEN-031](GEN-031.md) | The victim is placed last |
| [GEN-032](GEN-032.md) | Tutorial and easy cases need no technique beyond clue and single |
| [GEN-033](GEN-033.md) | A title belongs to its setting |
| [GEN-034](GEN-034.md) | No door or window unless a clue uses it |
| [GEN-035](GEN-035.md) | Extra statements are true and never needed |
| [GEN-036](GEN-036.md) | A statement's mark follows the placements |
| [GEN-037](GEN-037.md) | A case made on request is as sound as a shipped one |
