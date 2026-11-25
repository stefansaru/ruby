# Launch Campaign — draft

**Draft 1, 2026-11-24. Nothing here is scheduled.** A playable draft with
placeholder shapes exists (2026-11-25); nothing is releasable or filmable until
the art is in. Every claim below must be true of the build that ships before it
is used ([PROC-REL-002](../requirements/process_requirements/PROC-REL-002.md)).
No dates are set until a releasable build exists.

## Position

**"The detective puzzle that plays fair."**

One sentence for anyone who has tried the genre: *every clue means exactly one
thing, every case has exactly one answer, and nothing interrupts you while you
think.*

The proof points, each of which must exist before it is claimed:

| Claim | Is true when |
|---|---|
| "Every case checked by a solver: one answer, no guessing" | The shipped packs pass the data tests |
| "Tap any clue to see exactly what it means" | Clue preview is built |
| "Notes for each suspect" | Per-suspect notes are built |
| "No ads. None." | True of the draft today (2026-11-25): no ad SDK is in the project. Owner ruling 2026-11-25. A selling point: every rival with an audience carries ads |
| "Free to try. One purchase unlocks everything. No subscription." | The purchase is built, restorable and tested, and the owner has confirmed the price and what is free. Nothing of this is built |
| "Hints that explain the step" | Hint ladder is built |

## Who we talk to

In order (see [TargetAudience.md](../strategy/TargetAudience.md)): people who
finished a detective-sudoku book and want more; daily sudoku players; people
who saw a solving clip and are curious.

## Channels

| Channel | What | Why |
|---|---|---|
| Short video (TikTok, Reels, Shorts) | Solving clips, 20–40 s, see [ReelScripts.md](ReelScripts.md) | The genre spread this way |
| Play Store listing | Screenshots that show the clarity features, not the art | The listing is where a searcher compares twelve similar apps |
| Puzzle communities (Reddit puzzle and sudoku groups, puzzle forums) | One honest post by the owner, with a free puzzle to try | These readers test fairness first; self-promotion rules differ per group and must be read first |
| jini.solutions | App page and privacy policy | Required for the listing; the page is a TODO item |

Paid acquisition: none planned for launch. *Why:* no retention data exists to
justify a cost per install.

## Phases

1. **Before a playable build:** nothing public.
2. **Closed test:** a handful of book solvers and sudoku regulars. The one
   question: *did any clue confuse you?* Every yes is a defect.
3. **Open release:** listing live, three clips a week for four weeks, the
   community posts.
4. **After four weeks:** read every review, rank the complaints as
   PainPointsAndConcepts.md does for competitors, decide v2.

## What we do not say

- We do not name competitors or the books in public copy.
- We do not use the word "Murdoku" (RiskAnalysis.md R2).
- We do not say "hand-drawn" or "no AI": the art is generated from prompts and
  reviewed by the owner (RiskAnalysis.md R3).
- We do not quote a case count until it is counted from the shipped build.

## Measures

Installs, day-1 and day-7 return, the share of installs that buy the unlock,
and the count of reviews that mention wording, the price, "no ads" or notes
(good or bad). Targets are set after the closed test, not before. Note that
the app as designed collects no analytics of its own (APP-PRV-002); installs,
return and purchases come from the Play Console, and anything finer (cases
solved per player, share of players who use a hint) needs an owner decision on
analytics first.
