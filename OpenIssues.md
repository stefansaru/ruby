# Open issues

One list of everything known to be wrong, rough or accepted with a risk. An item is
deleted when it is fixed. Work to do is in [TODO.md](TODO.md); this file is for
faults and for decisions not to fix.

Dated 2026-11-24.

## 1. Content

1.1 **Objects can land where they make no sense.** The generator filters objects only
by inside or outside, so a boat can be drawn on a Path and a car in a Hall. The rules
still hold; the picture will look odd. TODO 6.

1.2 **Two-grid cases deal areas at random.** "Upstairs" can get the Garden. TODO 7.

1.3 **Nobody has judged the cases for fun.** They are proven unique and solvable
without guessing; whether they are enjoyable is unmeasured. TODO 1.

1.4 **Expert cases lean on one technique.** Most expert cases need "what if"; liar cases are the only other
expert flavour.

1.5 **Some clue types are never drawn** although the engine supports them. TODO 5.

## 2. Engine

2.1 **The logic solver is weaker than a strong human on counting.** It reasons about
"exactly N in an area" per clue, not across clues. Cases that need more are thrown
away at the logic gate, so this costs yield, not correctness.

2.2 **"What if" is bounded** to people with two or three squares left and does not
nest. Deliberate: a hint must be something a person would do.

2.3 **A clue with no technique of its own** ("more people in A than in B", the
opposite of a company clue in liar cases) falls back to a bounded search and keeps
the square when the search runs out. Sound, but such a step is hard to explain as a
hint.

2.4 **On a cut-corner grid there are more than four corners.** A square beside a cut
counts as a corner of the grid. Documented as the rule; TODO 8 asks the owner.

2.5 **English only, and the wording is built in code.** TODO 43.

## 3. Product

3.1 **The name may collide.** "Detective Sudoku" is another app's subtitle. TODO 49.

3.2 **Generated art is itself a risk.** Players in this genre mark apps down for
AI-looking art; our art will come from prompts. Mitigation is in docs/Art.md and
docs/strategy/RiskAnalysis.md; it is not proven.

3.3 **No hint text exists.** The solver returns steps as data. The sentences in
docs/Techniques.md are proposals. TODO 24.

## 4. Accepted — do not re-raise

4.1 **The packs are source files, not assets.** They make the repository diff large
when regenerated. Accepted for the compile-time and test-time safety.

4.2 **The tutorial and easy tiers overlap in technique range.** The tutorial is told
apart by its 4x4 size and its guided steps, not by technique.

4.3 **`solution` names a grid by number while `open` names it by name** in the case
format. Harmless; changing it would rewrite every pack.
