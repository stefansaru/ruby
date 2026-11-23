import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/exact_solver.dart';
import 'package:ruby/engine/logic_solver.dart';

import 'fixtures.dart';

void main() {
  group('exact solver', () {
    test('GEN-010 the starter case has exactly one solution', () {
      final c = parseCase(starterCase);
      final found = solveExact(c, limit: 10);
      expect(found, hasLength(1));
      expect(found.single, c.solution);
    });

    test('GEN-010 a case with too few clues has more than one', () {
      final loose = parseCase(
        starterCase.replaceFirst('clue C is beside r\n', ''),
      );
      final found = solveExact(
        parseCase(writeCase(loose).replaceFirst(RegExp('solution.*\n'), '')),
        limit: 10,
      );
      expect(found.length, greaterThan(1));
      for (final pos in found) {
        expect(loose.check(pos), isNull);
      }
    });

    test('GEN-010 every solution found obeys the rules and the limit', () {
      final c = board(<String>['clue A is in K']);
      final found = solveExact(c, limit: 25);
      expect(found, hasLength(25));
      final seen = <String>{};
      for (final pos in found) {
        expect(c.check(pos), isNull);
        expect(seen.add(pos.join(',')), isTrue, reason: 'no repeats');
      }
    });

    test('GEN-003 no solution leaves the victim alone or in a crowd', () {
      final c = board();
      for (final pos in solveExact(c, limit: 200)) {
        expect(c.murdererIn(pos), isNot(-1));
      }
    });

    test('GEN-012 no-touch removes placements where people touch', () {
      final plain = board(<String>['clue A is on c', 'clue B is row 1']);
      final strict = board(<String>[
        'rule notouch',
        'clue A is on c',
        'clue B is row 1',
      ]);
      final all = solveExact(plain, limit: 1000);
      final apart = solveExact(strict, limit: 1000);
      expect(apart.length, lessThan(all.length));
      for (final pos in apart) {
        expect(strict.check(pos), isNull);
      }
    });

    test('GEN-011 with one liar exactly one statement is false', () {
      // Anna says she was in the Garden; she was on the Kitchen chair.
      final c = board(<String>[
        'rule liar',
        'clue A is in G',
        'clue A is on c',
        'clue B is row 1',
        'clue C is on c',
        'clue D is in H',
      ]);
      final pos = boardPlacement(c);
      expect(c.check(pos), isNull);
      final found = solveExact(c, limit: 500);
      expect(found.any((List<int> p) => p.join() == pos.join()), isTrue);
      for (final p in found) {
        final broken = c.statements
            .where((int i) => !c.clues[i].holds(c, p))
            .length;
        expect(broken, 1);
      }
      // With every statement true the same placement is not an answer.
      final honest = board(<String>[
        'rule liar',
        'clue A is in K',
        'clue A is on c',
        'clue B is row 1',
      ]);
      expect(honest.check(pos), contains('exactly one statement'));
    });
  });

  group('logic solver', () {
    test('GEN-014 the starter case is solved without guessing', () {
      final c = parseCase(starterCase);
      final r = solveLogic(c);
      expect(r.solved, isTrue);
      expect(r.contradiction, isFalse);
      expect(r.pos, c.solution);
      expect(r.hardest, Technique.single);
      expect(r.score, greaterThan(0));
    });

    test(
      'GEN-015 a capped solver stops where a harder technique is needed',
      () {
        // Ben is anywhere above Cora: only pair reasoning can use that.
        final c = board(<String>[
          'clue A is on c',
          'clue A is in K',
          'clue B dir C -1 0',
          'clue B is in G',
          'clue C is on c',
          'clue C is in G',
          'clue D is in H',
          'clue D is not border',
          'clue D is col 3',
        ]);
        expect(solveExact(c), hasLength(1));
        final capped = solveLogic(c, max: Technique.lastInLine);
        final full = solveLogic(c);
        expect(full.solved, isTrue);
        expect(full.pos, solveExact(c).single);
        expect(capped.solved, isFalse);
        expect(full.hardest.index, greaterThan(Technique.lastInLine.index));
      },
    );

    test('GEN-013 a case with two answers is never called solved', () {
      final c = board(<String>['clue A is on c', 'clue A is in K']);
      final r = solveLogic(c);
      expect(r.solved, isFalse);
      expect(r.contradiction, isFalse);
      // What it did decide is right: Anna is on the Kitchen chair.
      expect(r.pos[0], at(c, 2, 1));
    });

    test('GEN-026 fixed squares are kept and a wrong one is found out', () {
      final c = parseCase(starterCase);
      final good = solveLogic(c, fixed: <int, int>{0: c.solution![0]});
      expect(good.solved, isTrue);
      // Anna placed on Cora's square: the clues cannot all be true.
      final bad = solveLogic(c, fixed: <int, int>{0: c.solution![2]});
      expect(bad.contradiction, isTrue);
      expect(bad.solved, isFalse);
    });

    test('GEN-026 every step says what it did', () {
      final c = parseCase(starterCase);
      final r = solveLogic(c);
      final placed = r.steps
          .where((LogicStep s) => s.technique == Technique.single)
          .toList();
      expect(placed, hasLength(c.people.length));
      for (final s in placed) {
        expect(s.placed, c.solution![s.person!]);
      }
      for (final s in r.steps.where(
        (LogicStep s) => s.technique == Technique.clue,
      )) {
        expect(s.clue, isNotNull);
        expect(s.removed, isNotEmpty);
      }
    });

    test('GEN-011 a liar case is solved by testing each statement', () {
      final c = board(<String>[
        'rule liar',
        'clue A is in G',
        'clue A is on c',
        'clue A is row 2',
        'clue B is row 1',
        'clue B is col 4',
        'clue C is on c',
        'clue C is row 3',
        'clue D is in H',
        'clue D is col 3',
        'clue D is row 4',
      ]);
      final found = solveExact(c, limit: 5);
      expect(found, hasLength(1));
      final r = solveLogic(c);
      expect(r.solved, isTrue);
      expect(r.pos, found.single);
      expect(r.hardest, Technique.liarSplit);
      expect(solveLogic(c, max: Technique.whatIf).solved, isFalse);
    });
  });
}
