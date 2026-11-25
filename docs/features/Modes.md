# Modes: detective and cat

**Status: built as a wording switch 2026-11-25; copy is a draft for the owner; no cat art.**

## What was asked

The owner pointed at three printable puzzle books on Etsy that use the same grid puzzle
without a murder (a missing kitten; "who stole the cookies") and asked for a setting that
switches between a detective mode and a cat mode, with the goal, rules and mechanics of
those books identified.

## What the research could and could not read (2026-11-25)

Etsy refused every automated read. Of the three listings:

- **Cat Logic Puzzles PDF, 50 cosy illustrated mysteries** was read in full through its
  Amazon edition ("Cat Sudoku: 50 Cozy Cat Logic Mysteries", Clara Ahrens,
  <https://www.amazon.co.uk/dp/B0HMZLQBN2>).
- **Cozy Cat Mystery Logic Puzzles, 60 sudoku-style detective cases** and **Sudoku Murder
  Mystery Logic Puzzle Book**: only title and price from search snippets. Their rules pages
  were **not** read. No product themed on "who stole the cookies" was found.

Other products read: Sudoku Detective's children's packs "Catch the Thief!" and "Who Saw
Santa?" (<https://sudokudetective.com/en/printable/kids/>), the app Dona Lupa
(<https://donalupa.com/>) and, for comparison, Cozy Culprits
(<https://cozyculprits.com/guides/how-to-play-murder-sudoku/>).

## What those products change

| Re-skin | Who is silent | Who is the answer | Example |
|---|---|---|---|
| Missing item | an item nobody placed; it is on the last free square | the only cat in that room took it | Ahrens: "Who made off with the ribbon?" |
| Inverted hero | the thief | whoever is alone with the thief catches her | Catch the Thief |
| Lucky witness | Santa | the child in the same area sees him | Who Saw Santa? |
| Small comic crime | a lunchbox | (not stated on the page) | Dona Lupa |

**The mechanics do not change.** Every product read keeps: one character per row and
column; one silent piece that makes no statement and is found last on the square that is
left; the answer read from who shares its area. Only Dona Lupa adds a rule (one per zone as
well), which is a different puzzle and not taken.

What they explain better than the murder books, and what we took:

- Three numbered steps: read, place, find. Taken as the "How to play" sheet (`howToPlay`).
- "Once you place a cat, cross off the other squares in its row and column." The grid does
  this itself since 2026-11-24.
- "Where there is furniture, there is nobody." Our sheet says a dark object blocks its
  square and a light one can be stood on.
- An answer box "Found in / Who did it". Our solved card names the area and the culprit.
- Graded hints that end by naming a square. Ours: who to look at, then the square.

## What is built

`Mode { detective, cat }` in `lib/engine/wording.dart`. The mode changes **words only**:
the same cases, clues, solvers and answers (GEN-004 is untouched). It is chosen in the menu
of the case list and saved.

| | Detective | Cat |
|---|---|---|
| Silent piece's card | The victim. She was alone with the murderer. | The missing kitten. She was hiding with exactly one cat. |
| Solved | Ben was alone with Vera in the Hall. Ben is the murderer. | Ben was the only cat with Vera in the Hall. Ben was hiding the kitten. |
| How to play, step 3 | Nothing is said about the victim... The one person in the same area as the victim is the murderer. | Nothing is said about the missing kitten... The one cat in the same area as the kitten was hiding it. |
| Hint, counting step | The victim was alone with the murderer, so that area holds exactly two people. | The kitten was hiding with one cat, so that area holds exactly two. |

Statements read the same in both modes ("She was in the Kitchen.").

## Not built, and open for the owner

- **The copy above** is a draft (CLAUDE.md: player-facing copy is proposed, not decided).
- **Cat names and art.** In cat mode the suspects are still Anna, Ben... with lettered
  discs. Cat names (Mochi, Biscuit...) need a second name list in the generator or a name
  map in the wording; cat sprites are an art request.
- **Statements still say "person" words** in a few clue types ("the only **person** on a
  rug", "exactly 2 other **women**"). Cat mode needs those sentences reworded too.
- **A third mode, "missing item"**, would fit the same engine: the silent piece is an item
  ("the cookies"), the answer "the only one in that room took them".
- **Titles** are shared ("The Last Ticket" works in both).
- **Store position.** A cat mode widens the audience to people who avoid a murder theme
  and to children; the content rating and listing copy would need to say which it is.
