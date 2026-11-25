# Pain Points and the Concepts That Answer Them

Written 2026-11-24 from [MarketResearch.md](MarketResearch.md). Ranked by how
strong the evidence is. The evidence base is small (three visible reviews per
app), so the ranking is a judgement, and it should be redone when more reviews
can be read. Each concept names the requirement that carries it; "GEN
register" means the machine-checked engine and generator requirements in
[requirements/gen](../requirements/gen/README.md).

| # | Pain point | Evidence | Our concept | Carried by |
|---|---|---|---|---|
| P1 | **Clues that can be read two ways** | Enigmic's most-upvoted review ("right column… use that wording!!!"); Caseoku ("row 3 but the rows… aren't numbered"); two apps shipped "clearer clues" updates; one new app sells itself on solver-checked wording | Columns lettered, rows numbered, printed on the grid. Clue wording from templates, one exact meaning each ("in column C", "in a row above Ben", "exactly 2 columns to the right of Ben"). Tap a clue to see the squares it allows. A glossary. | STRAT-VAL-001, APP-UX-001, APP-UX-002, APP-UX-003, APP-UX-004, GEN register |
| P2 | **Ads that interrupt or misbehave** | Enigmic mutes the phone's audio; Whodoku's playable ads cannot be closed; Caseoku "ads take so long"; an ad after every puzzle on iOS; 43% of puzzle players quit over too many ads | No ads of any kind (owner ruling 2026-11-25): no banner, no video, no ad SDK. The game is free to try and one purchase unlocks the rest. | STRAT-MIS-001, APP-PAY-001 |
| P3 | **Notes too weak to hold a deduction** | "XX was not in the Cloisters… no way to make a note of that"; marking controls "cumbersome" | Notes per suspect: mark where a suspect can be, cross where they cannot. Optional auto-elimination. Undo that keeps notes. | APP-GAM-003, APP-GAM-004, APP-GAM-005 |
| P4 | **Art that looks machine-made or hides the clue** | A star lost for "AI generated images"; a one-line "AI art" review; realistic images "make it hard to see clues" | One consistent pixel style, icon-like objects, letters on tokens, owner review of every sheet. Portraits are cosmetic. *Honest note: our art is generated from prompts, so this is a risk we carry, not one we have avoided (RiskAnalysis.md R3).* | STRAT-RSK-002, APP-AST-001, APP-AST-002, APP-AST-003 |
| P5 | **Gates and nags** | Daily keys; a rating prompt after every puzzle "including the first" | Every case in a tier is open in order with no keys, energy or timers. The only lock is the one purchase on the packs above easy, with its price shown first. No rating prompt before a set number of solved cases. | STRAT-VAL-002, APP-GAM-009, APP-PAY-002, APP-PAY-003, APP-UX-006 |
| P6 | **Wrong or unstable answers** | "Previously marked correct are now wrong" on replay | A case is text plus a certified solution; the solver proves one solution; tests replay every shipped case on every run. | STRAT-MIS-002, APP-QAL-002, GEN register |
| P7 | **Difficulty labels that mean nothing** | Praise where labels are honest ("easy ones are actually easy") shows it is noticed | Tier set by the hardest deduction technique a case needs, measured by the solver. | STRAT-MIS-002, GEN register |
| P8 | **Hints that give the answer without the reason** | The well-reviewed newcomers all explain the step | A three-step hint ladder; the last step names the technique and the square, then offers to place. | APP-GAM-006 |
| P9 | **No story** | A fan asks for case intros | One or two lines to open a case and a line naming the murderer and the room at the end. | APP-UX-005 |
| P10 | **Translation leaking** | Spanish strings in English screenshots (our observation, not a review) | Clue text comes from templates per language; English only until a language is complete. | APP-L10N-001, APP-L10N-002 |

## Concepts beyond the complaints

- **New rules** (count clues, traits, line of sight, distance, scene rules,
  one-liar cases) introduced one at a time, so the game deepens instead of
  only growing the grid. Most competitors stop at area, beside and direction.
- **Multiple grids and irregular grids**, which the books use and most apps do
  not.
- **Simple names.** Home, Beach, Forest; Kitchen, Garden, Pond. A player should
  never need a dictionary to read a clue.

## What we deliberately do not copy

Ranked duels, co-op, a level editor, community cases, PDF export, a
subscription. They are real features of real competitors, and each is a
product of its own. A solo studio wins this genre on clarity first.
