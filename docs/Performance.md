# Performance

Measured costs, with the date and the machine. Add a dated entry when a number
changes by a lot; do not edit old entries.

## 2026-11-24, owner's Windows 11 desktop, Dart 3.13 (JIT, `dart run`)

### Generating the packs

| What | Time |
|---|---|
| All five packs, `dart run tool/generate_cases.dart` | about 20 s |
| Tutorial and easy packs | under 1 s each |
| Normal pack | about 5 s (many draws are thrown away at the tier gate) |
| Hard pack | about 5 s |
| Expert pack | about 8 s |
| `dart run tool/check_cases.dart`, every case | a few seconds |
| `flutter test`, whole suite | a few seconds after compiling |

The funnel printed by the tool shows where draws are lost. On this date the narrow
gate for the normal tier was `tier` (most unique cases were easier or harder than
"pair"), and for the expert tier it was `logic` (about three quarters of unique
cases could not be finished by the logic solver and were thrown away).

### The exact solver, before and after

The first version placed people in a fixed order and checked most clues only when
everyone was placed. Proving that a 9x9 expert case had one solution could take
tens of seconds, a single expert slot took up to 46 s, and the expert pack did not
finish in twenty minutes.

The current version (same day) places the person with the fewest squares left,
removes squares from everyone else after each placement (row, column, and every
two-person piece), and abandons a branch as soon as a count is exceeded. The same
9x9 slots take 0.2 to 3 s.

Lesson: prove uniqueness with the clues doing the pruning, not as a filter at the
end. The generator calls the exact solver once per added clue and once per clue it
tries to drop, so its speed is the generator's speed.

### Not measured yet

Solver time on a phone (hints run the logic solver on the device), memory, and
release-mode numbers. They matter once the hint button exists.
