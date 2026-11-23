# Store Listing — draft

**Draft 1, 2026-11-24. Not for publishing.** The game is not playable yet.
Each block below is tagged with what must exist before it may be used; before
release, delete every sentence whose feature did not ship
([PROC-REL-002](../requirements/process_requirements/PROC-REL-002.md)).
Player-facing copy is the owner's to approve
([PROC-CNT-003](../requirements/process_requirements/PROC-CNT-003.md)).

## Title (30 characters max)

- Working title: **Detective Sudoku** (16)
- With a descriptor, if the bare title is taken or too generic:
  **Detective Sudoku: Whodunit** (26) or **Detective Sudoku Logic Cases** (28)

The title is subject to the name check in RiskAnalysis.md R1. "Detective
Sudoku" is already another app's subtitle.

## Short description (80 characters max)

- A: *A cosy murder-mystery logic puzzle. One answer, no guessing, clear clues.*
- B: *Place the suspects, read the clues, find who was alone with the victim.*

## Full description

> **Someone was alone with the victim. Work out who.**
>
> Detective Sudoku is a logic puzzle with a small mystery inside. Every case
> is a place — a home, a beach, a train — drawn as a grid. Each suspect left
> one clue about where they were. Nobody shares a row, and nobody shares a
> column. Place everyone, and the last free square is the victim's. Whoever
> was alone in the same room is your murderer.
>
> **Fair by design** *[needs: shipped packs pass the solver tests]*
> • Every case has exactly one solution.
> • Every case can be solved by logic alone. You never need to guess.
> • Difficulty is graded by the reasoning a case needs, from first steps to expert.
>
> **Clues that mean one thing** *[needs: coordinates, clue preview, glossary]*
> • Columns have letters and rows have numbers, so "column C" is column C.
> • Tap any clue to see exactly which squares it allows.
> • Simple words and simple places.
>
> **Tools for thinking** *[needs: notes, undo, hint ladder]*
> • Notes for each suspect: mark where someone could be, and where they could not.
> • Undo that keeps your notes.
> • Hints that explain the next step instead of just giving the answer.
>
> **Calm** *[needs: ad rules built and tested; offline play verified]*
> • No ads interrupt you while you solve. Watch a short video only if you want hint coins.
> • No energy, no keys, no timers.
> • Plays offline.
>
> **Many places, more rules** *[needs: packs for each setting; name only settings that ship]*
> Home, Beach, Forest, City, Farm, School, Train, Ship, Camp, Hotel, Park and
> Museum, with cases that grow from a tiny 4×4 to two-grid mysteries.
>
> A cosy, bloodless mystery for anyone who likes sudoku, logic grids or a good
> whodunit.

Not in the listing: any case count (state it only when counted from the
release build), any language other than those complete, "daily case" (v2),
and the word "Murdoku".

Wording note: a banner is on screen during a case, so the listing says "no
ads *interrupt* you", not "no ads while you solve".

## Keywords and search phrases

Play has no keyword field; these are the phrases to work naturally into the
title, short and full description: detective sudoku, murder mystery puzzle,
logic puzzle, whodunit, crime puzzle, deduction game, logic grid, sudoku
mystery, brain game, offline puzzle.

For the App Store keyword field later (100 characters):
`murder,mystery,logic,whodunit,crime,deduction,grid,clue,brain,offline,cosy,case`

## Category, rating, tags

- Category: Puzzle.
- Content rating: to be set by the questionnaire, answered truthfully
  (RiskAnalysis.md R4). Competitors sit at Everyone or Everyone 10+.
- Contains ads: yes. In-app purchases: no (v1).

## Screenshot plan (phone, portrait)

All from the real build. Caption text is a draft.

| # | Shows | Caption |
|---|---|---|
| 1 | A mid-solve case with coordinates and the clue list | "Who was alone with the victim?" |
| 2 | A clue tapped, its squares lit | "Tap a clue. See exactly what it means." |
| 3 | Per-suspect notes on the grid | "Notes for every suspect." |
| 4 | A hint card naming the technique | "Hints that explain the step." |
| 5 | The case-solved screen | "One answer. No guessing." |
| 6 | Setting picker with several places | "Home, Beach, Train… new places, new rules." |
| 7 | A two-grid case | "Cases that grow with you." |

Feature graphic and icon: prompts to be written with the art list; see
`docs/Art.md`.
