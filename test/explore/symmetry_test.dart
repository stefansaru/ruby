// A case seen in a mirror is the same puzzle.
//
// Rules explored here:
//   S1  Mirror a case left to right, or top to bottom: it still parses,
//       it still has exactly one answer, and that answer is the mirror of
//       the original. A rule that mixes up left and right, above and
//       below, rows and columns, or the two sides of a door cannot pass
//       both mirrors.
//   S2  The mirrored case is still solved by logic alone.
//   S3  More true statements never add answers: with its extras counted
//       as clues a case still has its one answer.
//   S4  Mirroring twice gives the case back.
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/exact_solver.dart';
import 'package:ruby/engine/logic_solver.dart';
import 'package:ruby/engine/tier.dart';

import '../support/explore.dart';
import '../support/oracle.dart';
import '../support/transform.dart';

void main() {
  for (final columns in <bool>[true, false]) {
    final way = columns ? 'left to right' : 'top to bottom';

    test('GEN-039 S1 S2 every case mirrored $way is the same puzzle', () {
      var withDirections = 0;
      for (final tier in Tier.values) {
        // Every case of the quick tiers; a spread of the slow ones.
        final cases = tier.index <= Tier.normal.index
            ? shipped(tier)
            : spread(shipped(tier), 30 * depth);
        for (final s in cases) {
          final text = mirrored(s.text, columns: columns);
          // S1: the mirror parses, so its stated answer obeys every clue.
          final m = parseCase(text);
          expect(m.cells.length, s.c.cells.length, reason: '$s');
          final found = solveExact(m, limit: 3);
          expect(found, hasLength(1), reason: '$s mirrored $way');
          expect(found.single, m.solution, reason: '$s mirrored $way');
          // The oracle reads the mirror the same way.
          final oracle = Oracle(text);
          expect(oracle.wrong(oracle.solution!), isNull, reason: '$s');
          // The murderer is the same person.
          expect(
            m.people[m.murdererIn(m.solution!)].id,
            s.c.people[s.c.murdererIn(s.c.solution!)].id,
            reason: '$s',
          );
          // S2: still no guessing.
          final grade = solveLogic(m);
          expect(grade.solved, isTrue, reason: '$s mirrored $way');
          expect(grade.pos, m.solution, reason: '$s mirrored $way');
          if (text.contains(' dir ') || text.contains(' offset ')) {
            withDirections++;
          }
        }
      }
      // The mirror really met direction words.
      expect(withDirections, greaterThan(50));
    });

    test('GEN-039 S4 mirroring $way twice gives the case back', () {
      for (final s in spread(shipped(), 60)) {
        final twice = mirrored(
          mirrored(s.text, columns: columns),
          columns: columns,
        );
        expect(writeCase(parseCase(twice)), writeCase(s.c), reason: '$s');
      }
    });
  }

  test('GEN-039 S1 the mirror changes what it should', () {
    // A guard on the test itself: a mirror that changed nothing would
    // pass S1 without testing anything.
    final s = shipped(Tier.normal).firstWhere(
      (Shipped x) => x.text.contains(' dir ') && x.text.contains(' col '),
      orElse: () =>
          shipped(Tier.normal)
              .firstWhere((Shipped x) => x.text.contains(' dir ')),
    );
    final across = parseCase(mirrored(s.text, columns: true));
    final down = parseCase(mirrored(s.text, columns: false));
    expect(across.solution, isNot(s.c.solution));
    expect(down.solution, isNot(s.c.solution));
    expect(writeCase(across), isNot(writeCase(down)));
    final g = s.c.grids.first;
    for (var p = 0; p < s.c.people.length; p++) {
      final was = s.c.cells[s.c.solution![p]];
      final now = across.cells[across.solution![p]];
      expect(now.row, was.row);
      expect(now.col, g.cols - 1 - was.col);
      final below = down.cells[down.solution![p]];
      expect(below.col, was.col);
      expect(below.row, g.rows - 1 - was.row);
    }
  });

  test('GEN-039 S3 extras counted as clues leave the one answer', () {
    for (final s in spread(shipped(), 80 * depth)) {
      if (s.c.extras.isEmpty) continue;
      final more = s.c.copyWith(
        clues: <Clue>[...s.c.clues, ...s.c.extras],
        extras: const <Clue>[],
      );
      expect(solveExact(more, limit: 3), <List<int>>[
        s.c.solution!,
      ], reason: '$s');
      // And logic gets there at least as easily.
      final grade = solveLogic(more);
      expect(grade.solved, isTrue, reason: '$s');
      expect(
        grade.hardest.index,
        lessThanOrEqualTo(solveLogic(s.c).hardest.index),
        reason: '$s',
      );
    }
  });
}
