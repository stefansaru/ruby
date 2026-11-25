# Exploratory testing

Written 2026-11-25. The ordinary tests check the cases we thought of. This file is about
finding the flaws we did not think of: the rules that are explored by tests that draw their
own inputs, how to run them deeper, how to prove they can fail, and how a person explores
the game by hand with the same rules in mind.

## 1. Why the ordinary tests are not enough

The engine has one meaning for a clue and derives everything from it: the solvers, the
ticks, the hints, the wording (GEN-004). That is what keeps its parts in step. It is also
its blind spot: **if the one meaning is a misreading of the rules, every part agrees with
the misreading and every test built on the engine passes.** The same goes for a sentence
that says "left" where the clue means "right": nothing checks English against meaning.

Three kinds of test see past that:

1. **A second witness.** `test/support/oracle.dart` states the rules a second time, from
   `docs/GameRules.md`, reading the case text itself, sharing no code with the game.
   Where the two disagree, one misread the rules. *Never repair a disagreement by copying
   the engine's logic into the oracle; go back to the rules document.*
2. **A change that must not matter.** A case in a mirror is the same puzzle. A true extra
   statement cannot add an answer. Asking for a hint twice gives the same hint.
3. **A player who does anything.** Random taps, with a list of things that must be true
   after every single one.

## 2. The rules explored

Each rule is checked by a test in `test/explore/` whose name begins with the GEN id and the
rule's letter. "Boards" are drawn at random from a fixed seed: half keep one person per row
and column, half do not, so wrong boards are explored as much as right ones.

| Rule | What must hold | Test file | GEN |
|---|---|---|---|
| M1 | On any board a clue is true for the engine exactly when it is true for the oracle. | meaning | 038 |
| M2 | A board is an answer for the engine exactly when it is for the oracle. | meaning | 038 |
| M3 | Trying every board the slow way finds one answer, the certified one. | meaning | 038 |
| M4 | Every clue form the notation allows is compared, not only those the generator draws. | meaning | 038 |
| X1 | For every clue form, alone, in pairs, with no-touch and with one liar, the exact solver finds exactly the answers the slow search finds. | solvers | 038, 011 |
| X2 | The logic solver never rules out a square some answer uses, with any technique switched off, also on cases with many answers and on grids with rows to spare. | solvers | 013, 027 |
| X3 | A placement never pushes someone off a square. | solvers | 001 |
| S1 | Mirrored left to right or top to bottom, a case has exactly one answer: the mirror of the original, with the same murderer. | symmetry | 039 |
| S2 | The mirrored case is still solved by logic. | symmetry | 039 |
| S3 | With its extras counted as clues a case keeps its one answer and is no harder. | symmetry | 039 |
| S4 | Mirroring twice gives the case back. | symmetry | 039 |
| P1 | Nobody on a square that cannot hold a person; no two on one square. | play | 040 |
| P2 | The clashes shown are exactly the people sharing a row or column (or touching). | play | 040 |
| P3 | A square is crossed exactly when it is free, can hold a person and is in a taken row or column. | play | 040 |
| P4 | "Solved" exactly when the board is an answer for the oracle. | play | 040 |
| P5 | No mark while the speaker is not placed; on a full board tick means true, cross means false. | play | 040 |
| P6 | A tick or a cross on a part-filled board is final: no way of placing the others changes it. | play | 036 |
| P7 | A hint names a wrong placement first; otherwise an unplaced person on their true square, the victim last; nothing once solved. Hints alone finish any board. | play | 040, 026 |
| P8 | The solver never rules out a true square from any correct board. | play | 013 |
| W1 | A sentence names what its clue names. | words | 041 |
| W2 | Above/below, left/right and the number of rows or columns match the clue. | words | 041 |
| W3 | A sentence denies exactly when its clue is a denial. | words | 041 |
| W4 | He/his for a man, she/her for a woman. | words | 041 |
| W5 | Counts are the clue's; "more in A than in B" keeps its order. | words | 041 |
| F1 | Damaged case text is refused with a `CaseFormatException` or is a case that writes and reads back unchanged. | fuzz | 006 |
| F2 | An answer the parser accepts in damaged text is one the oracle accepts. | fuzz | 006 |
| F3 | A case made on request passes the shipped check, the oracle, the slow search when small, and both mirrors. | fuzz | 037 |
| F4 | Random taps on the real screen, at four sizes, raise no error. | fuzz | 040 |

Several tests end by checking themselves: that both outcomes really happened (true and
false, refused and parsed, solved and wrong), and that a deliberately wrong input is
noticed (`words_test` is fed thirty wrong sentences; the mirror test checks the mirror
changed the answer). *Why:* a comparison that never sees a "false" proves nothing.

## 3. Running them

```
flutter test test/explore                        quick: about 10 seconds, part of `flutter test`
RUBY_EXPLORE=20 flutter test test/explore        deep, bash
$env:RUBY_EXPLORE=20; flutter test test/explore  deep, PowerShell
```

`RUBY_EXPLORE` multiplies how many boards, cases and steps every test draws. The quick run
is in the commit gates because it is part of `flutter test`. Run the deep one before a
release, after any change to `lib/engine/clue.dart`, `atoms.dart`, either solver or
`wording.dart`, and after adding a clue type.

A failure prints the case id, the clue in notation and the board. To reproduce, the seed is
the number in `Random(...)` at the top of the failing test.

## 4. Proving the tests can fail

```
py -3 tool/plant_bugs.py          about 6 minutes
```

The script plants one bug at a time in `lib/` (above and below swapped, a wall that no
longer stops the view, a tick given before everyone it depends on is placed, a sentence
that says left for right...), runs `test/explore`, restores the line, and reports which
bugs were caught.

**Result on 2026-11-25: 32 of 32 caught.** The first run caught 29. The three it missed
each showed a real gap, now closed:

| Missed bug | Why it was missed | Closed by |
|---|---|---|
| "Everyone except her" checked nobody's own square in the solver | The generator never draws that form, so no shipped case has it | X1: every form against the slow search |
| "This row must hold someone" used on a grid with rows to spare | Every shipped case fills its grid | X2 on a 4 by 4 scene with three people |
| A placement could push a person off a square | The random player only tapped, and a tap lifts first | X3: random placements |

*The lesson:* the shipped packs are a narrow sample of what the engine accepts. Rules M4,
X1 and X2 exist to test the engine where the packs do not go.

When a clue type, a technique or a rule is added, add a bug for it to the list in the
script. A bug the tests miss is the next test to write.

## 5. Exploring by hand

Automated exploration cannot judge whether a case is fun, a sentence reads naturally or a
screen is comfortable. A person can, and should explore with the same rules in mind. Take
one charter per session (20 to 30 minutes), on a phone, and write what you find in
`OpenIssues.md`.

**While playing anything, a finding is any moment where:**

- a tick or a cross appears and you cannot say which placement caused it (P5, P6);
- a tick turns into a cross, or back, without you moving the speaker or someone the
  statement names (P6);
- a square is crossed that is not in a taken row or column, or a free square in a taken
  row is not crossed (P3);
- two people share a row and neither is ringed, or someone is ringed for no reason (P2);
- a hint tells you something you cannot check on the grid, names the victim while a
  suspect waits, or contradicts a statement (P7);
- you can finish with every statement ticked and no "Case solved", or see "Case solved"
  with a cross showing (P4);
- you read a sentence two ways, or the picture and the sentence disagree (W1 to W5);
- the solved line names a murderer who was not alone with the victim.

**Charters:**

| Charter | Explore | Looking for |
|---|---|---|
| The second answer | Solve a case by guessing instead of logic: place people wherever the statements allow, ignoring hints. | A full board with all ticks that is not accepted, or one accepted that differs from the hints' answer (M3, P4). |
| The mirror reader | Pick ten statements with left, right, above, below or a column letter. Check each on the solved grid with a finger. | A direction or a letter that is off (S1, W2). |
| The wall | Find statements with "beside", "see", "in front of" near a wall or a door. | Beside across a wall counted; a view through a wall without an opening; a door that counts from one side (M1). |
| The liar | Play three liar cases with hints. | A hint that quotes the false statement as true; a case where two different statements could be the lie. |
| Two floors | Play three two-grid cases. | A row, column or square named without its grid; a statement about the other grid's row. |
| The impatient player | Tap fast, lift people, restart mid-case, ask for hints at every state, rotate the phone. | Any state the board cannot get out of; a hint for a board that changed (P1, P7). |
| The edge of the grid | Play cases with cut corners and 6 by 8 grids. | "Corner" and "edge" near a cut; an empty row or column the rule sentence did not announce. |
| One more statement | Open every "+" before placing anyone. | An extra that names the square outright, repeats a statement, or gives the murderer away. |
| The newcomer | Give the tutorial to someone who has never seen the genre; say nothing. | The first place they are stuck, and what they thought a word meant. |

## 6. What this does not cover

- Whether cases are fun, and whether difficulty feels right inside a tier (TODO 1).
- The look and comfort of the screen on real devices (ManualTestPlan part C).
- The slow search on boards larger than 6 by 6: there uniqueness rests on the exact solver,
  which X1 checks against the slow search on small scenes for every clue form.
- Translations: W1 to W5 read English only.
