// The two solvers against the slow search of the oracle, on small scenes
// where every board can be tried.
//
// The shipped cases only use the clue forms the generator draws and are
// always "full" (as many people as the grid has rows). A flaw in a form
// nobody draws yet, or in a rule that only matters on a grid with spare
// rows, would never show there. These tests go where the packs do not.
//
// Rules explored here:
//   X1  For every clue form, alone and in pairs, the exact solver finds
//       exactly the answers the slow search finds: none missing, none
//       invented.
//   X2  The logic solver never rules out a square that some answer uses,
//       and never calls a case with answers contradictory, whatever
//       technique is switched off. This holds for cases with many
//       answers too, and on grids that are not full.
//   X3  A session never lets a placement push someone off a square.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/exact_solver.dart';
import 'package:ruby/engine/logic_solver.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/session.dart';

import '../engine/fixtures.dart';
import '../support/explore.dart';
import '../support/oracle.dart';

/// One line per form of the notation that fits the fixture board.
const List<String> forms = <String>[
  'A is in K',
  'A is in K|H',
  'A is not in G',
  'A is on c',
  'A is not on c',
  'A is beside t',
  'A is not beside t',
  'A is beside t x1',
  'A is front door',
  'A is front window',
  'A is row 2',
  'A is col 3',
  'A is border',
  'A is not border',
  'A is corner',
  'A is areacorner',
  'A is sees t',
  'A is not sees c',
  'A is line row c',
  'A is line col t',
  'A dir B -1 0',
  'A dir B 0 1',
  'A dir B 1 -1',
  'A offset B 2 *',
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
  'A others hat 1',
  'A others !hat 1',
  'A only on c',
  'A only in K',
  'A only not border',
  'A allothers not in K',
  'A allothers border',
  '* count 2 on c',
  '* count 0 in K',
  '* count 3 border',
  '* more H K',
  '* more G H',
  '* group f in G',
  '* group m not on c',
  '* group hat border',
];

/// Every answer as a set of "A=g:r:c ..." strings, from the oracle.
Set<String> slowAnswers(Oracle oracle) => <String>{
  for (final a in oracle.everyAnswer(limit: 1 << 30))
    (a.entries.map((MapEntry<String, Sq> e) => '${e.key}=${e.value}').toList()
          ..sort())
        .join(' '),
};

Set<String> fastAnswers(CaseDef c) => <String>{
  for (final pos in solveExact(c, limit: 1 << 30))
    (toOracle(c, pos).entries
            .map((MapEntry<String, Sq> e) => '${e.key}=${e.value}')
            .toList()
          ..sort())
        .join(' '),
};

/// X2 for one case: no technique removes a square some answer uses.
void checkSound(CaseDef c, Oracle oracle, String what) {
  final answers = oracle.everyAnswer(limit: 1 << 30);
  final used = <int, Set<int>>{
    for (var p = 0; p < c.people.length; p++)
      p: <int>{
        for (final a in answers)
          c.cells.indexWhere((Cell x) {
            final (g, r, k) = a[c.people[p].id]!;
            return x.grid == g && x.row == r && x.col == k;
          }),
      },
  };
  for (final max in Technique.values) {
    final r = solveLogic(c, max: max);
    final label = '$what up to ${max.name}';
    if (answers.isNotEmpty) {
      expect(r.contradiction, isFalse, reason: label);
    }
    for (final step in r.steps) {
      for (final (p, x) in step.removed) {
        expect(
          used[p],
          isNot(contains(x)),
          reason:
              '$label: ${step.technique.name} ruled out '
              '${c.people[p].id} on ${c.cellLabel(x)}, which an answer uses',
        );
      }
    }
    // What the solver calls solved is one of the answers.
    if (r.solved) {
      expect(answers, hasLength(greaterThan(0)), reason: label);
      expect(oracle.wrong(toOracle(c, r.pos)), isNull, reason: label);
    }
  }
}

void main() {
  test('GEN-038 X1 each clue form alone: the solver finds what the slow '
      'search finds', () {
    var withAnswers = 0;
    for (final form in forms) {
      final c = board(<String>['clue $form']);
      final oracle = Oracle(writeCase(c));
      final slow = slowAnswers(oracle);
      expect(fastAnswers(c), slow, reason: '"$form"');
      if (slow.isNotEmpty) withAnswers++;
    }
    // A few forms allow no board on this scene (every woman in the
    // Garden would crowd the victim); nearly all allow some.
    expect(withAnswers, greaterThan(forms.length - 6));
  });

  test('GEN-038 X1 clue forms in pairs, and with the case rules', () {
    final rnd = Random(381);
    for (var n = 0; n < 60 * depth; n++) {
      final lines = <String>[
        if (rnd.nextInt(4) == 0) 'rule notouch',
        for (var k = 0; k < 2 + rnd.nextInt(2); k++)
          'clue ${forms[rnd.nextInt(forms.length)].replaceFirst('A ', '${'ABCD'[rnd.nextInt(4)]} ').replaceFirst(' B', ' ${'ABCD'[rnd.nextInt(4)]}')}',
      ];
      final CaseDef c;
      try {
        c = board(lines);
      } on CaseFormatException {
        continue; // "A with A" and the like: refused, as it should be.
      }
      final oracle = Oracle(writeCase(c));
      expect(fastAnswers(c), slowAnswers(oracle), reason: lines.join(' / '));
    }
  });

  test('GEN-011 X1 one liar: the solver finds what the slow search finds', () {
    final rnd = Random(11);
    var withAnswers = 0;
    for (var n = 0; n < 25 * depth; n++) {
      final lines = <String>[
        'rule liar',
        for (final id in <String>['A', 'B', 'C', 'D'])
          'clue ${forms.where((String f) => f.startsWith('A is')).elementAt(rnd.nextInt(18)).replaceFirst('A ', '$id ')}',
        'clue A is row ${1 + rnd.nextInt(5)}',
      ];
      final c = board(lines);
      final oracle = Oracle(writeCase(c));
      final slow = slowAnswers(oracle);
      expect(fastAnswers(c), slow, reason: lines.join(' / '));
      if (slow.isNotEmpty) withAnswers++;
    }
    expect(withAnswers, greaterThan(5));
  });

  test('GEN-013 X2 no technique rules out a square an answer uses', () {
    for (final form in forms) {
      final c = board(<String>['clue $form']);
      checkSound(c, Oracle(writeCase(c)), '"$form"');
    }
    final rnd = Random(131);
    for (var n = 0; n < 40 * depth; n++) {
      final lines = <String>[
        if (rnd.nextInt(4) == 0) 'rule notouch',
        for (var k = 0; k < 3; k++)
          'clue ${forms[rnd.nextInt(forms.length)].replaceFirst('A ', '${'ABCD'[k]} ')}',
      ];
      final CaseDef c;
      try {
        c = board(lines);
      } on CaseFormatException {
        continue;
      }
      checkSound(c, Oracle(writeCase(c)), lines.join(' / '));
    }
  });

  test('GEN-013 GEN-027 X2 on a grid with rows to spare', () {
    // Three people on a 4 by 4 grid: a row and a column stay empty, so
    // "this row must hold someone" is false here and must not be used.
    const text = '''
case test-spare
title Room To Spare
setting home
area G Garden
area K Kitchen
area P Pond
kind c sit chair
kind t block table
grid Home 4 4
G.. G.. G.. K..
G.. Gc. K.. Kt.
P.. G.. K.. K..
P.. P.. P.. K..
person A Anna f
person B Ben m
victim V Vera f
''';
    for (final clues in <List<String>>[
      <String>[],
      <String>['clue A is on c'],
      <String>['clue A is in K', 'clue B is row 1'],
      <String>['clue A is beside t', 'clue B is in P'],
      <String>['clue A is row 4', 'clue B is col 1'],
      <String>['clue A dir B -1 -1'],
      <String>['clue A alone'],
    ]) {
      final c = parseCase('$text${clues.map((String l) => '$l\n').join()}');
      expect(c.isFull, isFalse);
      final oracle = Oracle(writeCase(c));
      expect(fastAnswers(c), slowAnswers(oracle), reason: '$clues');
      checkSound(c, oracle, 'spare rows $clues');
    }
  });

  test('GEN-001 X3 a placement never pushes someone off a square', () {
    final rnd = Random(1);
    for (final s in spread(shipped(), 20 * depth)) {
      final c = s.c;
      final play = CaseSession(c);
      for (var step = 0; step < 200; step++) {
        final p = rnd.nextInt(c.people.length);
        final cell = rnd.nextInt(c.cells.length + 2) - 1; // off-board too
        final before = List<int>.of(play.pos);
        final there = play.personAt(cell);
        final ok = play.place(p, cell);
        if (ok) {
          expect(c.canOccupy(cell), isTrue, reason: '$s');
          expect(there == -1 || there == p, isTrue, reason: '$s');
          expect(play.pos[p], cell, reason: '$s');
        } else {
          expect(play.pos, before, reason: '$s');
        }
        // Nobody else moved, and no square holds two people.
        for (var q = 0; q < c.people.length; q++) {
          if (q != p) expect(play.pos[q], before[q], reason: '$s');
        }
        final placed = play.pos.where((int x) => x >= 0).toList();
        expect(placed.toSet(), hasLength(placed.length), reason: '$s');
        if (rnd.nextInt(6) == 0) play.remove(rnd.nextInt(c.people.length));
      }
    }
  });

  test('the forms list is what the notation allows on this board', () {
    for (final form in forms) {
      expect(board(<String>['clue $form']).clues, hasLength(1), reason: form);
    }
    expect(
      negate(board(<String>['clue A alone']).clues.single),
      isA<Negated>(),
    );
  });
}
