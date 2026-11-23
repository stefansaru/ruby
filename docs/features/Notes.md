# Notes

**Status: designed 2026-11-24, not built.** Requirements:
[APP-GAM-003](../requirements/app_requirements/gam/APP-GAM-003.md),
[APP-GAM-004](../requirements/app_requirements/gam/APP-GAM-004.md),
[APP-GAM-005](../requirements/app_requirements/gam/APP-GAM-005.md).

## The problem

In most apps of the genre a cross on a square means "nobody is here". The
deductions a solver actually makes are about one person: *"Dana was not in the
Kitchen"*, *"Ben is in one of these two squares"*. A reviewer of the market
leader put it exactly: there is "no way to make a note of that outside of
marking the WHOLE REST of the board". Notes that cannot hold the deduction
push the player back to paper.

## The model

Every mark belongs to a layer. One layer is **Everyone**; there is one layer
per person, the victim included.

| Mark | On the Everyone layer | On a person's layer |
|---|---|---|
| **Cross** | Nobody can be on this square | This person cannot be on this square |
| **Candidate** | (not used) | This person might be on this square |
| **Placed** | — | This person is on this square |

- The player picks a layer by tapping a person in the cast strip, or "Everyone".
- The grid shows the selected layer in full and the others faintly: a small
  letter for a candidate, a small crossed letter for a personal cross.
- **Area shortcut:** with a person selected, a long press on an area name
  crosses every square of that area for that person. *Why:* "not in the
  Kitchen" is one thought and should be one gesture.
- **Clue shortcut:** with a clue's preview showing, "Keep as notes" turns the
  previewed squares into candidates for that clue's person.

## Auto-eliminate

A setting, **on by default** for the tutorial and easy tiers and remembered
afterwards. When on, placing a person adds Everyone-crosses on the rest of
their row and column, and removing the person removes exactly those crosses.

- It only applies the row-and-column rule. It never applies a clue.
  *Why:* the row rule is bookkeeping; a clue is the puzzle.
- Automatic crosses are drawn differently from the player's own, and a
  player's own cross is never removed by the automation.
- In a case that announces empty rows or columns, or on a multi-grid case, it
  applies the rule as that case states it, taken from the engine, never a
  rule of its own.

## Undo

- Undo and redo cover every action: place, remove, cross, candidate, shortcut,
  and a hint's Place.
- **Undoing a placement keeps the notes** that were there before it.
- A shortcut or an auto-elimination is one undo step, not one per square.
- Restart clears the board and the notes after a confirmation.

## What notes are not

Notes are never checked and never corrected by the game, except through a
hint the player asks for. *Why:* a note is the player's thinking; marking it
wrong unasked is a hint they did not buy.
