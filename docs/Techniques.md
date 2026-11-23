# Techniques

Written 2026-11-24. A technique is one named way of ruling squares out. The logic solver
(`lib/engine/logic_solver.dart`) knows the techniques below and nothing else. It does three
jobs with them:

- **It proves a case needs no guessing.** A case ships only if the logic solver finishes it.
- **It grades the case.** The tier is decided by the hardest technique the solver had to
  use (`docs/Levels.md`).
- **It will explain hints.** Every step it takes is recorded (technique, person, clue,
  squares ruled out, square placed), which is what a hint needs to say.

The solver always tries the techniques in the order below and restarts from the top after
any progress, so the path it records uses the gentlest technique available at every moment.
*Why:* a case is as hard as the hardest step you cannot avoid, not the hardest step that
happens to work.

## How the solver sees a case

For every person it keeps the set of squares that person could still be on, starting from
every square that can hold a person. A person with one square left is placed. The case is
solved when everyone is placed **and** that placement obeys every rule and clue (the solver
checks it once more at the end); it is contradictory when somebody has no square left.
*Why the last check:* a run capped below some technique never applies the pieces that
technique owns, so "everyone has one square" alone would not prove the answer.

### Clues are first broken into simple pieces

Before solving, each clue is turned into one or more pieces (`Atoms` in
`lib/engine/atoms.dart`). Both solvers work on the same pieces, so they cannot disagree
about what a clue means. The split is exact: the pieces together say what the clue says.

| Clue | Becomes |
|---|---|
| A statement about the speaker's square | one *single-person piece*: a test on that person's square |
| A statement about two people (above, same area, steps...) | one *pair piece* |
| Alone | a pair piece "not in the same area" with every other person |
| Alone with X, Y | "same area" pair pieces with X and Y, "not same area" with everyone else |
| The only person who... | a single-person piece for everyone: true for the speaker, false for the rest |
| Everyone except... | the reverse |
| Every man / everyone with a hat... | a single-person piece for each person it covers |
| Exactly N others in the speaker's area | one *company piece* |
| Exactly N people... | one *count piece* |
| More people in A than in B | a *search piece* (no technique of its own; see Limits) |
| The victim rule | a company piece: exactly one other person in the victim's area |
| No touching | a pair piece "not touching" for every two people |

*Why:* a handful of piece kinds means a handful of techniques, and a new clue type usually
needs no new technique.

### Lines that must hold someone

When the people exactly fill the grids (always true for generated cases), every row of a
grid that has no more rows than columns must hold a person, and every column of a grid that
has no more columns than rows must too. On a square grid that is every row and every column;
on a 6 by 8 grid it is the six rows only. The technique "last in line" uses these lines.

## The techniques, easiest first

The weight is the cost of one use; a case's score is the sum over its steps. The score is
recorded but tiers are decided by the hardest technique alone.

### 1. Clue (weight 1)

A statement about one person rules out every square where it would be false.

*Example.* "Anna was on a chair." There are two chairs; Anna keeps those two squares.

*Hint (proposed wording).* "Read Anna's statement again: it leaves her only these squares."

### 2. Single (weight 1)

A person has one square left. Place them, then rule out the rest of their row and column
(on their grid) for everybody else.

*Example.* Only one chair is still free for Anna, at B2. She goes there; nobody else can be
in row 2 or column B.

*Hint.* "Anna can only be at B2. Place her and cross out row 2 and column B."

### 3. Last in line (weight 2)

A row or column that must hold someone has squares left for only one person. That person
is in that line.

*Example.* In column A, the shelf and the table block two squares and everyone but Cora has
been ruled out of the other two. Cora is in column A.

*Hint.* "Someone has to be in column A, and only Cora still can be."

### 4. Intersection (weight 3)

Take the squares still open for one person. Any square that shares a row or column with
*every one* of them cannot hold anybody else: wherever that person ends up, it is blocked.

*Example.* Ben is on one of two rugs, at B2 or B5. Both are in column B, so nobody else is
in column B. If the rugs were at B2 and E5 instead, the two "crossing" squares B5 and E2
would be ruled out for everyone else.

*Hint.* "Ben is at B2 or B5. Either way, column B is his."

### 5. Pair (weight 3)

A clue links two people. A square is ruled out for one of them when the other has no square
left that goes with it (and does not share its row or column).

*Example.* "Dana was in a row above Eli." Eli can only be in rows 1 to 3, so Dana is in
row 1 or 2. And since someone must be above Eli, Eli is not in row 1.

*Hint.* "Look at Dana's statement about Eli: Dana at D4 would leave Eli nowhere to stand."

### 6. Subset (weight 4)

Two (or three) people whose open squares all lie in the same two (three) rows of one grid
take those rows between them; nobody else can be in them. The same for columns.

*Example.* Anna is on a chair and Ben on a rug; the chairs and rugs are all in columns A and
B. Anna and Ben fill columns A and B in some order, so Cora is not in either.

*Hint.* "Anna and Ben share columns A and B between them. Nobody else fits there."

### 7. Counting (weight 5)

For a count ("exactly 2 people were on a chair"): once enough people certainly qualify,
nobody else can; once only just enough people still could, they all must.

For company ("exactly 1 other woman in her area", and the victim rule): an area is ruled
out for the speaker when too many of the others are certainly there or too few still can
be. Once the speaker's area is known, the same counting applies to the others.

*Example.* The victim has two squares left, one in the Hall and one in the Garden. Two
suspects are already placed in the Hall. The victim's area holds exactly two people, so the
victim is not in the Hall.

*Hint.* "The victim was alone with one person. The Hall already holds two, so the victim
was not there."

### 8. What if (weight 8)

Suppose a person is on one of their last two or three squares and follow the techniques
above. If that ends in a contradiction, the square is ruled out.

*Example.* Gus is at C4 or F4. If Gus were at C4, Hana would have to be in column F, which
would leave nobody for row 6. So Gus is at F4.

*Hint.* "Try Gus at C4 and see what happens to row 6."

### 9. Liar split (weight 10)

Only in a case with the rule "exactly one statement is false". Take each statement in turn,
suppose it is the false one (and all the others true), and solve. The case is solved by
logic when every supposition but one ends in a contradiction and that one solves.

*Hint.* "Suppose Ben's statement is the false one. Then Anna and Cora both need B2."

## Which tier needs what

A case belongs to the tier whose range contains the hardest technique it needed (`Tier` in
`lib/gen/gen_config.dart`).

| Tier | Hardest technique needed is between |
|---|---|
| tutorial | clue and single |
| easy | clue and last in line |
| normal | intersection and pair |
| hard | subset and counting |
| expert | what if and liar split |

Tutorial and easy overlap on purpose: a tutorial case is a small easy case. From normal up,
each tier *requires* at least one step from its own range; a case that turns out easier is
thrown away and drawn again.

## Hints

A hint is the next step the solver would take from the player's current placements: the
solver accepts squares already decided (`fixed`) and continues from there. If the player's
placements contradict the clues, the solver reports a contradiction instead of a step, and
the hint becomes "something already placed is wrong". The step record exists today
(`LogicStep`: technique, person, clue index, square placed, squares ruled out);
`dart run tool/show_case.dart <tier> <n> --answer` prints the steps of any shipped case. The
hint sentences above are proposals and the hint screen is not built
(`docs/features/Hints.md`).

## Limits, stated honestly

- **What-if is bounded.** It is tried only on people with two or three squares left, and
  the consequences are followed with techniques 1 to 7 only (no what-if inside a what-if).
  A case that needs deeper trial and error is rejected by the generator, not shipped.
- **Clues without a technique of their own** ("more people in A than in B", and in liar
  cases the opposite of a company or general clue) are handled by a bounded search: a square
  stays as long as some full placement using it satisfies that one clue. If the search runs
  out of budget before deciding, the square stays. This can make the solver give up on a
  case that is logically solvable; it can never make it rule out a correct square. Steps
  found this way are recorded as counting.
- **Liar cases** are solved only when every wrong supposition is refuted by the techniques.
  If one of them merely gets stuck, the solver gives up on the case even though the exact
  solver knows it is unique. Such cases are not shipped.
- **Subsets** look at groups of two and three people, not four or more.
- **The solver is sound, not complete.** Everything it rules out is truly impossible. It
  does not find every possible deduction, so "the solver could not solve it" means "we do
  not ship it", not "it needs guessing".
- **A capped run** (`max` below the default) that fills every square without having used
  every clue is reported as not solved when the placement breaks a clue. It never reports a
  wrong placement as solved.
- **Liar cases ignore a cap between what-if and liar split:** the suppositions always run
  with every technique up to what-if; a cap below liar split simply returns "not solved".
- **The exact solver** (`lib/engine/exact_solver.dart`) is a different program: it tries
  placements exhaustively to prove a case has exactly one solution. It works on the same
  pieces, always places next the person with the fewest squares left, removes from the
  others every square the new placement rules out (row, column, pair pieces), and stops a
  branch as soon as a count can no longer come out right. It explains nothing and grades
  nothing.
