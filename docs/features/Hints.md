# Hints

**Status, 2026-11-25: hints are free. A first draft is built; the hint ladder
below is the design target and is not built.** There are no coins and no ads:
the owner ruled on 2026-11-25 that the game carries no advertising, and the coin
balance existed only to be topped up by a rewarded video
([Monetisation.md](../strategy/Monetisation.md)). What is outstanding is in
[TODO.md](../../TODO.md).

> **Who owns what.** This page owns the hints and their flow.
> [APP-GAM-006](../requirements/app_requirements/gam/APP-GAM-006.md) is the
> requirement. The coin economy
> ([APP-GAM-007](../requirements/app_requirements/gam/APP-GAM-007.md)) is
> retired.

## What is free, always

**Tapping a clue shows what the clue means**: the squares that clue allows on
the bare grid, ignoring everyone else. This is not a hint.
*Why:* it is the remedy for the genre's first complaint, ambiguous wording, and
a player must never pay, in any model, to learn what a sentence means
([APP-UX-002](../requirements/app_requirements/ux/APP-UX-002.md)).

## What is built (2026-11-25)

A draft, free, with draft wording that waits for the owner's review
(PROC-CNT-003):

- **One hint button** on the case screen.
- **First tap:** says who to look at, and gives any step that cannot be read
  off the grid (a ruling-out the player would otherwise have to work out).
- **Second tap:** gives the square.
- **The hint card has a close button.**
- **A wrong placement is named first.** If someone on the board is not where
  the certified solution puts them, the hint says so before anything else, and
  gives no next step on a wrong board.
- **Statements show a tick or a cross** as people are placed: a tick when the
  placements fit the statement, a cross when they contradict it, an empty ring
  until then.
- **Extra statements.** A "+" on a character card reveals one more true
  statement by that person. Free. Whether these are ever sold is open (below).

The engine side is `CaseSession.hint` in `lib/engine/session.dart` and
`describeStep` in `lib/engine/wording.dart`.

## The hint ladder (design target, not built)

Each step gives more. The player chooses the step. All three are free.

| Step | Name | What the player gets |
|---|---|---|
| 1 | **Show squares** | For the suspect the player selects: every square that suspect can still occupy, given all clues and everyone already placed. The work of combining clues is done for them; the conclusion is not. |
| 2 | **Who is next** | The person (or the row, column or area) the next logical step concerns is highlighted, with the technique's name: "Look at Ben", "Look at row 3". No square is given away. |
| 3 | **Explain and place** | The full step in words, naming the technique and the square ("Only one square in column C is still free, so someone is at C4; Ben is the only one who can be there"), and a **Place** button that makes the move. |

The draft's two taps are steps 2 and 3 without the technique's name and
without the Place button. Step 1 is not built.

Rules:

1. **A hint is always the next step of the logical solver from the player's
   current position**, never a look-up of the stored solution. *Why:* the hint
   must be a reason, and a reason has to follow from what is on the board.
2. **If the board contradicts the solution, the hint says so first** ("Dana
   cannot be at B2: she was beside a tree"). *Why:* explaining a next step on a
   wrong board would teach a falsehood. The stored solution is read for this
   and for nothing else.
3. **Step 3 never places without the player pressing Place.** *Why:* some
   players want the reason and their own hand on the move.
4. **A hint can be reread until the board changes.**
5. **The technique names are the ones in [Techniques.md](../Techniques.md)** and
   in the glossary; the hint text comes from templates, like clue text.
6. **A hint is never held back by a timer, a count per day or a balance.**
   *Why:* the game has no energy and no coins (Monetisation.md rules 3 and 8).
   If the owner later decides to sell something hint-like, this rule is
   reworded first.

### What the engine gives (2026-11-25)

`solveLogic(case, fixed: placements)` in `lib/engine/logic_solver.dart` returns
the steps from the player's position. Each `LogicStep` carries the technique,
the person, the clue index (or the victim rule or the no-touch rule), the
square placed and the (person, square) pairs ruled out. That is enough for
steps 2 and 3 of the ladder. Step 1 (the squares one suspect can still occupy)
is not returned as such: the solver keeps those sets internally and has no
call that hands them out. Still open:

- **Hint sentences.** `describeStep` gives one draft sentence per step; the
  wording is not approved, and the technique is not yet named to the player.
- **The reason for a wrong placement.** The draft names the misplaced person by
  comparing the board with the certified solution; it does not yet say which
  statement the placement breaks.
- **A step is a ruling-out, not always a placement.** The "next step" may
  remove squares without placing anyone. The draft runs on to the next `single`
  step and shows the rulings-out that concern that person as the reason.
- **The square of a hint is the solver's own** (`LogicStep.placed`), in keeping with
  rule 1 (2026-11-25; it used to be read from the stored solution). The stored
  solution is read only to name a wrong placement (rule 2).
- **When the solver cannot go on** the next person is named from the stated answer.
  This cannot happen in a shipped case, which is solved by logic from any correct
  board (GEN-014); it exists so that a hand-written case that needs guessing still
  gets help.
- **Liar cases** (2026-11-25): the hint first says that trying each statement as the
  false one leaves one, names it ("The false statement is Ben's: ..."), and never
  quotes it as something Ben said.
- **Two grids** (2026-11-25): a square is "A4 (Upper Deck)" and a line "Row 4 of the
  Upper Deck", because both grids have an A4 and a row 4.
- **Asking again** without moving anyone returns the same hint; the solver runs once
  per board. The slowest hint measured in the audit was 23 ms on the PC.

## Open, for the owner

- **Whether extra statements or hints are ever sold.** The owner said on
  2026-11-25: "perhaps these hints could be purchased at some point, for now
  they could be free." Recorded as open, not decided
  ([Monetisation.md](../strategy/Monetisation.md)).
- Whether a solved-with-hints case is marked differently from a clean solve.
- Whether a case solved with extra statements is marked differently.
- The hint sentences (TODO.md).

## No longer true

Until 2026-11-24 this page planned a coin balance (a starting grant, a grant per
first solve, a grant per rewarded ad), a price per hint step, and an ad flow in
which a rewarded video paid for a hint the player could not afford. All of that
is retired with the ads ([Ads.md](../architecture/ads/Ads.md),
[History.md](../History.md)).
