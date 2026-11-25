# History

What is no longer true, and decisions that were reversed, newest first. The other
docs describe the present; this one keeps the reasons from being lost.

## 2026-11-25 — the audit

- **The case screen decided what a tap meant and who was next.** That is in
  `CaseSession` now.
- **A tap on an empty square after the case was solved moved the last person and
  un-solved the board.** A solved board no longer changes.
- **The grid was sized from its width only**, so on a phone on its side or a short
  window its bottom rows were cut off and could not be tapped.
- **A hint in a liar case quoted the false statement as "Ben said: ...".** It now names
  it as the false one.
- **A hint took its square from the stored answer.** It takes it from the solver.
- **On two grids a hint said "A4" and "Row 4"** though both grids have them.
- **Liar cases had extra statements.** A true one beside the lie named the liar.
- **The random-case button could spin for ever** (an error, or a tier that yields
  nothing) and was not checked like a shipped case.
- **Clues carried a `scope` nothing read.** Removed.
- **`generateCase` caught a case its own writer could not read back and drew again.**
  That would hide a fault in the writer; it is no longer caught.

## 2026-11-25 — after the second play on a phone

- **The game was going to have ads** (a banner and a rewarded video for hint coins, the
  "4 Pics 1 Word" model). Owner ruling: no ads. The plan is a free tutorial and easy pack
  and one purchase for the rest ([strategy/Monetisation.md](strategy/Monetisation.md)).
  The ad design and its requirements are retired, not deleted: APP-ADS-001 to 004,
  APP-PRV-001 (consent before the ad SDK) and APP-GAM-007 (hint coins) are retired and
  APP-PAY-001 to 003 replace them. Hints are free.
- **"No purchase ever locks a case"** (APP-GAM-009, STRAT-VAL-002) no longer holds: the
  packs beyond the free ones are to be unlocked by the one purchase. Still true: no
  timers, energy or keys.
- **Risk R10 (ads) is retired**; R13 (a paid unlock converts few players) and R14 (billing
  mistakes) were added to the risk analysis.
- **The app never imported the generator.** It does now, through one service, to make a
  case on request. The reason for the old rule was that the generator is a build tool;
  the owner asked for a "generate random" button and the generator is fast enough.
- **Titles came from one list for every place** ("The Muddy Matchbox" on a train). Each
  setting now has its own words (GEN-033).
- **Scenes used to keep every door and window drawn**, used or not. Unused ones are removed
  (GEN-034); tutorial and easy cases have none.
- **A lamp blocked squares on the Train.** It is a suitcase now.
- **Placing on an occupied square used to replace the person there.** Now a tap on a
  placed person only lifts them.
- **The hint listed every step**, including the person's own statement, and could not be
  closed. It now names the person, adds only steps that cannot be read off the grid, and
  has a close button.
- **Packs held 6, 48, 48, 48 and 36 cases.** Now 100, 100, 100, 100 and 36. Every case of
  the second build is gone again: all packs were regenerated.
- **Progress was lost when the app closed.** It is saved on the device.
- **The area legend was the only place area names appeared.** They are on the grid now;
  the legend is gone.

## 2026-11-24 — after the first play on a phone

- **Objects used to be placed by "inside" or "outside" only**, so boats stood in the
  Pines and on the Path. Each area now lists its objects (GEN-029).
- **The victim could have any later initial** (Will, Zoe). Now always a V (GEN-030).
- **The solver used to place the victim as soon as one square was left**, and the hint
  said so. The victim is now placed last (GEN-031).
- **Easy used to allow "last in line"** (a row that must hold someone). That step ran
  through the victim's squares and the owner could not follow it. Easy is now clue and
  single only; last in line starts the normal tier (GEN-032). All packs were
  regenerated, so every case from the first build is gone.
- **The hint used to give the square at once and no reason.** It now says who and why
  first, and the square on a second tap.

## 2026-11-24 — first round

- **Compass words dropped.** The puzzle books this genre comes from say "north of"
  and "two columns east of". The game says "in a row above" and "2 columns to the
  right of", and letters the columns and numbers the rows. Reason: wording that can
  be read two ways is the most reported fault in the existing apps.
- **"With two women" became "exactly 2 other women".** The loose form does not say
  whether anyone else was there. Every count in the game is exact.
- **Empty rows are stated by the game.** In a non-square scene the books print
  "three empty rows" as a clue. Here it follows from the grid and is shown as a rule
  sentence automatically, so it cannot be forgotten or wrong.
- **The either-area clue used to give itself away.** "In the Kitchen or the Hall"
  always named the true area first. Areas are now listed in a fixed order. Found by
  review the same day, before any pack shipped.
- **Titles used to be drawn at random** and could repeat within a pack. Each slot now
  has its own title index.
- **The first exact solver was too slow** for the expert tier; see
  [Performance.md](Performance.md).
- **The plan listed the well-formed gate first.** In the code the order is scene,
  unique, wellFormed, logic, tier, variety, because a case has to exist before it can
  be written out and parsed back. The docs follow the code.
- **Planned but not built this round:** grid capacities with empty grids, partly
  usable large objects (vehicle seats), "someone who..." clues, and the later rules
  listed at the end of [GameRules.md](GameRules.md). They are in
  [../TODO.md](../TODO.md).
