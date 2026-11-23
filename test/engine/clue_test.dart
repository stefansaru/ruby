import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/model.dart';

import 'fixtures.dart';

void main() {
  final c = board();
  final pos = boardPlacement(c);
  int kind(String code) => c.kinds.indexWhere((ObjectKind k) => k.code == code);

  /// Whether the single clue [line] holds for the board placement.
  bool holds(String line) {
    final d = board(<String>['clue $line']);
    return d.clues.single.holds(d, pos);
  }

  group('placement rules', () {
    test('GEN-001 two people never share a row or a column', () {
      expect(c.conflict(at(c, 1, 1), at(c, 1, 5)), isTrue);
      expect(c.conflict(at(c, 1, 1), at(c, 5, 1)), isTrue);
      expect(c.conflict(at(c, 1, 1), at(c, 2, 2)), isFalse);
      final shared = List<int>.of(pos)..[1] = at(c, 2, 4);
      expect(c.check(shared), contains('share a line'));
    });

    test('GEN-002 a blocking object cannot hold a person, a chair can', () {
      expect(c.canOccupy(at(c, 1, 3)), isFalse);
      expect(c.canOccupy(at(c, 2, 1)), isTrue);
      expect(c.canOccupy(at(c, 1, 1)), isTrue);
      final onTable = List<int>.of(pos)..[1] = at(c, 1, 3);
      expect(c.check(onTable), contains('blocked'));
    });

    test('GEN-003 the murderer is the one other person in the victim area', () {
      expect(c.murdererIn(pos), 3);
      expect(c.check(pos), isNull);
      // Victim alone in the Hall: everyone else is elsewhere.
      final alone = <int>[
        at(c, 2, 1),
        at(c, 1, 2),
        at(c, 3, 5),
        at(c, 4, 4),
        at(c, 5, 3),
      ];
      expect(c.murdererIn(alone), -1);
      expect(c.check(alone), contains('victim'));
      // Two people with the victim: Anna joins the Hall.
      final crowd = <int>[
        at(c, 3, 1),
        at(c, 1, 4),
        at(c, 2, 5),
        at(c, 4, 3),
        at(c, 5, 2),
      ];
      expect(c.murdererIn(crowd), -1);
    });
  });

  group('GEN-005 words about one square', () {
    test('beside is up, down, left or right and in the same area', () {
      final table = BesideKind(kind('t'));
      expect(table.test(c, at(c, 1, 2)), isTrue);
      expect(table.test(c, at(c, 2, 3)), isTrue);
      // The Garden square next to the Kitchen table is across a wall.
      expect(table.test(c, at(c, 1, 4)), isFalse);
      // Diagonal does not count.
      expect(table.test(c, at(c, 2, 2)), isFalse);
      expect(BesideKind(kind('e'), exactly: 1).test(c, at(c, 1, 4)), isTrue);
      expect(BesideKind(kind('e'), exactly: 2).test(c, at(c, 1, 4)), isFalse);
    });

    test('in front of a door or window is either side of it', () {
      const door = FrontOf(door: true);
      expect(door.test(c, at(c, 2, 3)), isTrue);
      expect(door.test(c, at(c, 2, 4)), isTrue);
      expect(door.test(c, at(c, 1, 3)), isFalse);
      const window = FrontOf(door: false);
      expect(window.test(c, at(c, 1, 1)), isTrue);
      expect(window.test(c, at(c, 1, 2)), isFalse);
    });

    test('corners and the edge', () {
      expect(const GridCorner().test(c, at(c, 1, 1)), isTrue);
      expect(const GridCorner().test(c, at(c, 1, 2)), isFalse);
      expect(const OnBorder().test(c, at(c, 1, 2)), isTrue);
      expect(const OnBorder().test(c, at(c, 3, 3)), isFalse);
      // The Kitchen corner by the door: walls to the south and east.
      expect(const AreaCorner().test(c, at(c, 2, 3)), isTrue);
      expect(const AreaCorner().test(c, at(c, 1, 2)), isFalse);
    });

    test('seeing stops at walls without an opening and at objects', () {
      final chair = Sees(kind('c'));
      // West through the door, along the Kitchen row to the chair.
      expect(chair.test(c, at(c, 2, 4)), isTrue);
      // The Kitchen chair is right above, behind a wall with no opening.
      expect(chair.test(c, at(c, 3, 1)), isFalse);
      // The table hides nothing here but is itself seen.
      expect(Sees(kind('t')).test(c, at(c, 1, 1)), isTrue);
      expect(Sees(kind('e')).test(c, at(c, 3, 5)), isTrue);
    });

    test('an object in the same row or column', () {
      expect(LineHas(kind('t'), row: true).test(c, at(c, 1, 1)), isTrue);
      expect(LineHas(kind('t'), row: true).test(c, at(c, 2, 1)), isFalse);
      expect(LineHas(kind('t'), row: false).test(c, at(c, 2, 3)), isTrue);
    });
  });

  group('GEN-004 each clue has one meaning', () {
    test('statements about one person', () {
      expect(holds('A is in K'), isTrue);
      expect(holds('A is in G|H'), isFalse);
      expect(holds('A is on c'), isTrue);
      expect(holds('B is not on c'), isTrue);
      expect(holds('B is row 1'), isTrue);
      expect(holds('B is col 4'), isTrue);
      expect(holds('B is col 1'), isFalse);
      expect(holds('B is border'), isTrue);
      expect(holds('D is not border'), isTrue);
      expect(holds('B is grid Home'), isTrue);
    });

    test('two people', () {
      expect(holds('A dir C -1 0'), isTrue);
      expect(holds('A dir C 1 0'), isFalse);
      expect(holds('A dir C -1 -1'), isTrue);
      expect(holds('B offset D -3 1'), isTrue);
      expect(holds('B offset D -3 *'), isTrue);
      expect(holds('B offset D * 2'), isFalse);
      expect(holds('A diag D'), isTrue);
      expect(holds('A diag B'), isFalse);
      expect(holds('B with C'), isTrue);
      expect(holds('B notwith A'), isTrue);
      expect(holds('A dist B 4'), isTrue);
      expect(holds('A samegrid B'), isTrue);
      expect(holds('A samepos B'), isFalse);
    });

    test('company', () {
      expect(holds('A alone'), isTrue);
      expect(holds('B alone'), isFalse);
      expect(holds('B alonewith C'), isTrue);
      expect(holds('B alonewith A'), isFalse);
      expect(holds('D others any 1'), isTrue);
      expect(holds('B others f 1'), isTrue);
      expect(holds('B others m 0'), isTrue);
      expect(holds('B others hat 1'), isTrue);
      expect(holds('A only on c'), isFalse);
      expect(holds('A only in K'), isTrue);
      expect(holds('D allothers border'), isTrue);
    });

    test('general clues', () {
      expect(holds('* count 2 on c'), isTrue);
      expect(holds('* count 1 on c'), isFalse);
      expect(holds('* more G K'), isTrue);
      expect(holds('* more K G'), isFalse);
      expect(holds('* group hat on c'), isTrue);
      expect(holds('* group m on c'), isFalse);
      expect(holds('* group !hat not on c'), isTrue);
    });

    test('negate gives the opposite of every clue', () {
      for (final line in <String>[
        'A is in K',
        'A is not in K',
        'A dir C -1 0',
        'A alone',
        'B others f 1',
      ]) {
        final d = board(<String>['clue $line']);
        final clue = d.clues.single;
        expect(negate(clue).holds(d, pos), !clue.holds(d, pos), reason: line);
        expect(negate(negate(clue)).holds(d, pos), clue.holds(d, pos));
      }
    });
  });

  test('GEN-012 no-touch: nobody is next to anybody, even diagonally', () {
    final d = board(<String>['rule notouch']);
    expect(d.touching(at(d, 1, 1), at(d, 2, 2)), isTrue);
    expect(d.touching(at(d, 1, 1), at(d, 3, 2)), isFalse);
    // Dan (4,3) and Eva (5,2) touch diagonally.
    expect(d.check(pos), contains('touch'));
  });
}
