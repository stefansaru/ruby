// The engine against a second witness (test/support/oracle.dart, written
// from docs/GameRules.md and sharing no code with the engine).
//
// Rules explored here:
//   M1  On any board, right or wrong, a clue is true for the engine
//       exactly when it is true for the oracle.
//   M2  A board is an answer for the engine exactly when it is one for
//       the oracle.
//   M3  Trying every board the slow way finds one answer, the certified
//       one (uniqueness does not rest on the solver's cleverness).
//   M4  Every clue form the notation allows is covered, not only the ones
//       the generator happens to draw.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/tier.dart';

import '../engine/fixtures.dart';
import '../support/explore.dart';
import '../support/oracle.dart';

void main() {
  test('GEN-038 M1 M2 the certified answer is an answer for both', () {
    for (final s in shipped()) {
      final c = s.c;
      final answer = toOracle(c, c.solution!);
      expect(s.oracle.solution, answer, reason: '$s');
      expect(s.oracle.wrong(answer), isNull, reason: '$s');
      expect(c.check(c.solution!), isNull, reason: '$s');
      expect(
        s.oracle.murderer(answer),
        c.people[c.murdererIn(c.solution!)].id,
        reason: '$s',
      );
      for (var i = 0; i < c.extras.length; i++) {
        expect(s.oracle.extras[i](answer), isTrue, reason: '$s extra $i');
      }
      expect(s.oracle.liar, c.liar);
      expect(s.oracle.noTouch, c.noTouch);
    }
  });

  test('GEN-038 M1 on random boards every clue means the same to both', () {
    final rnd = Random(38);
    var compared = 0;
    var trueOnes = 0;
    for (final s in shipped()) {
      final c = s.c;
      final all = <Clue>[...c.clues, ...c.extras];
      final truths = <Truth>[...s.oracle.clues, ...s.oracle.extras];
      final lines = <String>[...s.oracle.clueLines, ...s.oracle.extraLines];
      for (var n = 0; n < 12 * depth; n++) {
        // Half the boards keep one per row and column, half do not.
        final pos = n.isEven
            ? lawfulPlacement(c, rnd) ?? anyPlacement(c, rnd)
            : anyPlacement(c, rnd);
        final board = toOracle(c, pos);
        for (var i = 0; i < all.length; i++) {
          final engine = all[i].holds(c, pos);
          expect(
            engine,
            truths[i](board),
            reason: '$s: "${lines[i]}" on $board',
          );
          compared++;
          if (engine) trueOnes++;
        }
      }
    }
    // The boards are not all on one side: both answers were exercised.
    expect(compared, greaterThan(40000));
    expect(trueOnes / compared, inInclusiveRange(0.1, 0.9));
  });

  test('GEN-038 M2 a random board is an answer for both or for neither', () {
    final rnd = Random(382);
    var lawful = 0;
    for (final s in shipped()) {
      final c = s.c;
      for (var n = 0; n < 12 * depth; n++) {
        final pos = lawfulPlacement(c, rnd);
        if (pos == null) continue;
        lawful++;
        final board = toOracle(c, pos);
        expect(
          c.check(pos) == null,
          s.oracle.wrong(board) == null,
          reason:
              '$s on $board: engine "${c.check(pos)}", '
              'oracle "${s.oracle.wrong(board)}"',
        );
        // The rules alone, without the clues.
        final bare = c.copyWith(clues: const <Clue>[], liar: false);
        expect(
          bare.check(pos) == null,
          s.oracle.rulesBroken(board) == null,
          reason: '$s rules on $board',
        );
      }
    }
    expect(lawful, greaterThan(3000));
  });

  test('GEN-038 M3 the slow search finds the one certified answer', () {
    // Small boards only: the slow search tries every board.
    final cases = <Shipped>[
      ...spread(shipped(Tier.tutorial), 100),
      ...spread(
        shipped(Tier.easy)
            .where((Shipped s) => s.c.cells.length <= 25)
            .toList(),
        min(50, 16 * depth),
      ),
      ...spread(
        shipped(Tier.easy).where((Shipped s) => s.c.cells.length > 25).toList(),
        min(50, 3 * depth),
      ),
      ...spread(
        shipped(Tier.normal)
            .where((Shipped s) => s.c.cells.length <= 36)
            .toList(),
        min(50, 3 * depth),
      ),
    ];
    expect(cases.length, greaterThan(120));
    for (final s in cases) {
      final found = s.oracle.everyAnswer(limit: 2);
      expect(found, hasLength(1), reason: '$s');
      expect(found.single, toOracle(s.c, s.c.solution!), reason: '$s');
    }
  });

  test('GEN-038 M3 the slow search also sees a case with two answers', () {
    // Without one statement the starter case is no longer unique; the
    // oracle must say so too, or M3 would prove nothing.
    final loose = Oracle(starterCase.replaceFirst('clue C is beside r\n', ''));
    expect(loose.everyAnswer(limit: 5).length, greaterThan(1));
    expect(Oracle(starterCase).everyAnswer(limit: 5), hasLength(1));
  });

  test('GEN-038 M4 every clue form means the same to both', () {
    // One line per form of the notation, on the fixture board (five
    // people, three areas, a door and a window). Truth is not required:
    // the two sides only have to agree on every board.
    const forms = <String>[
      'A is in K',
      'A is in K|H',
      'A is not in G',
      'A is on c',
      'A is not on c',
      'A is beside t',
      'A is not beside t',
      'A is beside t x1',

      'A is not beside c x1',
      'A is front door',
      'A is front window',
      'A is not front door',
      'A is row 2',
      'A is col 3',
      'A is not row 5',
      'A is border',
      'A is not border',
      'A is corner',
      'A is not corner',
      'A is areacorner',
      'A is not areacorner',
      'A is sees t',
      'A is not sees c',
      'A is sees e',
      'A is line row c',
      'A is line col t',
      'A is not line row e',
      'A dir B -1 0',
      'A dir B 1 0',
      'A dir B 0 -1',
      'A dir B 0 1',
      'A dir B -1 -1',
      'A dir B -1 1',
      'A dir B 1 -1',
      'A dir B 1 1',
      'A offset B 2 *',
      'A offset B -1 *',
      'A offset B * 3',
      'A offset B * -2',
      'A offset B 1 -1',
      'A diag B',
      'A dist B 2',
      'A dist B 5',
      'A with B',
      'A notwith B',
      'A alone',
      'A alonewith B',
      'A alonewith B C',
      'A others any 0',
      'A others any 2',
      'A others m 1',
      'A others f 0',
      'A others hat 1',
      'A others !hat 1',
      'A others glasses 0',
      'A only on c',
      'A only in K',
      'A only not border',
      'A allothers not in K',
      'A allothers border',
      '* count 2 on c',
      '* count 0 in K',
      '* count 3 border',
      '* count 1 not line row t',
      '* more K G',
      '* more G H',
      '* group f in G',
      '* group m not on c',
      '* group hat border',
      '* group !hat not corner',
      '* group any not in K',
    ];
    final rnd = Random(384);
    final oneSided = <String>[];
    for (final form in forms) {
      final c = board(<String>['clue $form']);
      final oracle = Oracle(writeCase(c));
      final clue = c.clues.single;
      var yes = 0;
      const boards = 400;
      for (var n = 0; n < boards * depth; n++) {
        final pos = n.isEven
            ? lawfulPlacement(c, rnd) ?? anyPlacement(c, rnd)
            : anyPlacement(c, rnd);
        final engine = clue.holds(c, pos);
        expect(
          engine,
          oracle.clues.single(toOracle(c, pos)),
          reason: '"$form" on ${toOracle(c, pos)}',
        );
        if (engine) yes++;
      }
      // A form that was never true, or never false, was not really tested.
      if (yes == 0 || yes == boards * depth) oneSided.add(form);
    }
    expect(oneSided, isEmpty, reason: 'never true, or never false');
  });

  test('GEN-038 M4 the two-grid forms mean the same to both', () {
    const forms = <String>[
      'A is beside t x2',
      'A is not beside t x2',
      'A samegrid B',
      'A samepos B',
      'A is grid Downstairs',
      'A is not grid Upstairs',
      'A dir B -1 0',
      'A offset B * 1',
      'A diag B',
      'A dist B 3',
      'A is row 2',
      'A is col 3',
      'A is border',
      'A is corner',
      'A with B',
    ];
    const text = '''
case test-two
title Two Floors
setting home
area K Kitchen
area H Hall
area B Bedroom
area T Bathroom
kind c sit chair
kind t block table
grid Downstairs 3 3
K.. K.. H..
Kc. Kt. H..
K.. H.. H..
grid Upstairs 3 3
B.. Bt. T..
Bt. Bc. T..
Bt. B.. T..
person A Anna f
person B Ben m
person C Cora f
person D Dan m
person E Eli m
victim V Vera f
''';
    final rnd = Random(385);
    final oneSided = <String>[];
    for (final form in forms) {
      final c = parseCase('${text}clue $form\n');
      final oracle = Oracle(writeCase(c));
      var yes = 0;
      const boards = 400;
      for (var n = 0; n < boards * depth; n++) {
        final pos = n.isEven
            ? lawfulPlacement(c, rnd) ?? anyPlacement(c, rnd)
            : anyPlacement(c, rnd);
        final engine = c.clues.single.holds(c, pos);
        expect(
          engine,
          oracle.clues.single(toOracle(c, pos)),
          reason: '"$form" on ${toOracle(c, pos)}',
        );
        if (engine) yes++;
      }
      if (yes == 0 || yes == boards * depth) oneSided.add(form);
    }
    expect(oneSided, isEmpty, reason: 'never true, or never false');
  });

  test('GEN-038 the rules of a no-touch and an irregular scene agree', () {
    final rnd = Random(386);
    final cases = shipped(Tier.expert)
        .where((Shipped s) => s.c.noTouch)
        .followedBy(
          shipped(Tier.hard).where(
            (Shipped s) =>
                s.c.cells.length < s.c.grids.first.rows * s.c.grids.first.cols,
          ),
        )
        .toList();
    expect(cases.where((Shipped s) => s.c.noTouch), isNotEmpty);
    expect(cases.where((Shipped s) => !s.c.noTouch), isNotEmpty);
    for (final s in cases) {
      final bare = s.c.copyWith(clues: const <Clue>[]);
      for (var n = 0; n < 60 * depth; n++) {
        final pos = lawfulPlacement(s.c, rnd);
        if (pos == null) continue;
        expect(
          bare.check(pos) == null,
          s.oracle.rulesBroken(toOracle(s.c, pos)) == null,
          reason: '$s on ${toOracle(s.c, pos)}',
        );
      }
      // The edge and the corners of a cut grid, square by square.
      for (final x in s.c.cells) {
        final sq = (x.grid, x.row, x.col);
        expect(
          const OnBorder().test(s.c, x.index),
          s.oracle.squareTest(<String>['border'])(sq),
          reason: '$s border $sq',
        );
        expect(
          const GridCorner().test(s.c, x.index),
          s.oracle.squareTest(<String>['corner'])(sq),
          reason: '$s corner $sq',
        );
        expect(
          const AreaCorner().test(s.c, x.index),
          s.oracle.squareTest(<String>['areacorner'])(sq),
          reason: '$s areacorner $sq',
        );
        expect(s.c.canOccupy(x.index), s.oracle.canHold(sq), reason: '$s $sq');
      }
    }
  });

  test('the model helper used above builds real cases', () {
    expect(parseCase(starterCase).people, hasLength(4));
    expect(const GridDef('x', 1, 1, <List<int>>[]).capacity, 1);
  });
}
