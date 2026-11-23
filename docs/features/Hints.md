# Hints

**Status: designed 2026-11-24, not built.** The engine side (finding the next
logical step) belongs to the logical solver; the screens, the coin balance and
the ad flow are TODO. Modelled on amethyst's `docs/features/Tips.md` and
`APP-GAM-015`, which are the working reference.

> **Who owns what.** This page owns the three hints and the flow.
> [APP-GAM-007](../requirements/app_requirements/gam/APP-GAM-007.md) owns the
> economy. Prices and awards are **named constants** in
> `lib/data/config_default.dart` (to be created); this page names them and
> never states their values, because two copies of a price is one stale price.

## What is free, always

**Tapping a clue shows what the clue means**: the squares that clue allows on
the bare grid, ignoring everyone else. This is not a hint and costs nothing.
*Why:* it is the remedy for the genre's first complaint, ambiguous wording, and
a player must never pay to learn what a sentence means
([APP-UX-002](../requirements/app_requirements/ux/APP-UX-002.md)).

## The hint ladder

Each step gives more and costs more. The player chooses the step.

| Step | Name | Price constant | What the player gets |
|---|---|---|---|
| 1 | **Show squares** | `hintCostShowSquares` | For the suspect the player selects: every square that suspect can still occupy, given all clues and everyone already placed. The work of combining clues is done for them; the conclusion is not. |
| 2 | **Who is next** | `hintCostWhoIsNext` | The person (or the row, column or area) the next logical step concerns is highlighted, with the technique's name: "Look at Ben", "Look at row 3". No square is given away. |
| 3 | **Explain and place** | `hintCostExplainStep` | The full step in words, naming the technique and the square ("Only one square in column C is still free, so someone is at C4; Ben is the only one who can be there"), and a **Place** button that makes the move. |

Rules:

1. **A hint is always the next step of the logical solver from the player's
   current position**, never a look-up of the stored solution. *Why:* the hint
   must be a reason, and a reason has to follow from what is on the board.
2. **If the board contradicts the solution, the hint says so first** ("Dana
   cannot be at B2: she was beside a tree") and costs the same as the step
   asked for. *Why:* explaining a next step on a wrong board would teach a
   falsehood.
3. **Step 3 never places without the player pressing Place.** *Why:* some
   players want the reason and their own hand on the move.
4. **A hint already paid for can be reread free until the board changes.**
5. **The technique names are the ones in [Techniques.md](../Techniques.md)** and
   in the glossary; the hint text comes from templates, like clue text.

### What the engine gives today (2026-11-24)

`solveLogic(case, fixed: placements)` in `lib/engine/logic_solver.dart` returns
the steps from the player's position. Each `LogicStep` carries the technique,
the person, the clue index (or the victim rule or the no-touch rule), the
square placed and the (person, square) pairs ruled out. That is enough for
steps 2 and 3 of the ladder. Step 1 (the squares one suspect can still occupy)
is not returned as such yet: the solver keeps those sets internally and has no
call that hands them out. Still to build on the engine side:

- **Hint sentences.** No template turns a `LogicStep` into words yet; the
  wording in Techniques.md is a proposal.
- **Naming the wrong placement (rule 2).** With a wrong placement the solver
  reports only that the board is contradictory, not which person is misplaced.
  The game can find that by comparing the board with the certified solution,
  then use the solver for the reason; that part is not written.
- **A step is a ruling-out, not always a placement.** The "next step" may
  remove squares without placing anyone; step 3 should run on to the next
  `single` step before offering Place.

## Coins

| Event | Award constant |
|---|---|
| Fresh install | `hintBudgetStart` |
| Solving a case not solved before | `hintRewardPerCase` |
| Watching one rewarded ad | `hintRewardPerAd` |

- **One balance**, kept on the device, carried across cases and restarts.
- **`hintRewardPerAd` equals `hintCostExplainStep`**, the dearest hint: one ad
  buys exactly one full explanation. *Why:* the offer needs no arithmetic.
- **Spending is all-or-nothing**: a spend that the balance cannot cover debits
  nothing.
- Replaying a solved case earns nothing. *Why:* otherwise the easiest case is
  a coin farm.

## The ad flow

One place in the code pays for a hint (amethyst's `_payOrOfferAd` pattern):

1. The player taps a hint.
2. If the balance covers it: debit, show the hint. Done.
3. If not, and a rewarded ad can be offered: a confirm dialog states the trade
   in one sentence: not enough coins, a short video plays, *n* coins are earned
   and the hint is used. **No / Yes.**
4. On **Yes** the ad loads and plays. On the reward callback the coins are
   credited and the same hint handler runs again, now affordable. The ad buys
   the hint the player asked for.
5. If the ad **fails to load** after Yes: the reward is granted anyway, **once
   per ad-health snapshot** (a snapshot is taken when a case opens).
6. If the ad loads but the player closes it before the reward: nothing is
   granted and nothing is debited.
7. If ads are unavailable (no consent, no network, SDK not ready): unaffordable
   hints are shown disabled with the reason. Prices do not drop to zero.

The rewarded video in step 4 is the only ad that may play while a case is
open, and it does so because the player asked for it. Details and the reasons
are in [Ads.md](../architecture/ads/Ads.md).

## Open, for the owner

- The three price values and the three awards.
- Whether step 1 should be free in the tutorial tier.
- Whether a solved-with-hints case is marked differently from a clean solve.
