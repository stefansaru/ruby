// A player who taps at random, and what must stay true whatever they do.
//
// Rules explored here (checked after every single action):
//   P1  Nobody stands on a square that cannot hold a person, and no two
//       people on one square.
//   P2  The people ringed as clashing are exactly those sharing a row or
//       column (or touching, in a no-touch case), worked out separately.
//   P3  A square is crossed out exactly when it is free, can hold a
//       person, and lies in the row or column of someone placed.
//   P4  "Solved" is shown exactly when the board is an answer for the
//       oracle. So no second answer can be reached by play, and the true
//       answer is never refused.
//   P5  A statement whose speaker is not placed has no mark. On a full
//       board a tick means true and a cross means false, for the oracle.
//   P6  A cross on a part-filled board is final: no way of placing the
//       others makes the statement true. A tick likewise is never undone
//       by placing the others.
//   P7  A hint names a wrongly placed person if there is one; otherwise a
//       person not yet placed, on their true square, the victim only when
//       every suspect is placed; and nothing once the case is solved.
//   P8  The solver never rules out a true square, from any correct board
//       and with any technique switched off.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/logic_solver.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/session.dart';
import 'package:ruby/engine/tier.dart';

import '../engine/fixtures.dart';
import '../support/explore.dart';
import '../support/oracle.dart';

/// Checks P1 to P5 and P7 on the board as it stands.
void checkBoard(Shipped s, CaseSession play, String trail) {
  final c = s.c;
  final answer = c.solution!;
  final placed = <int, Sq>{
    for (var p = 0; p < c.people.length; p++)
      if (play.pos[p] >= 0)
        p: (
          c.cells[play.pos[p]].grid,
          c.cells[play.pos[p]].row,
          c.cells[play.pos[p]].col,
        ),
  };

  // P1
  expect(placed.values.toSet(), hasLength(placed.length), reason: trail);
  for (final sq in placed.values) {
    expect(s.oracle.canHold(sq), isTrue, reason: trail);
  }
  expect(
    play.selected,
    inInclusiveRange(0, c.people.length - 1),
    reason: trail,
  );

  // P2, from rows and columns alone.
  bool clash(Sq a, Sq b) =>
      a.$1 == b.$1 &&
      (a.$2 == b.$2 ||
          a.$3 == b.$3 ||
          (s.oracle.noTouch &&
              (a.$2 - b.$2).abs() <= 1 &&
              (a.$3 - b.$3).abs() <= 1));
  final clashing = <int>{
    for (final p in placed.keys)
      for (final q in placed.keys)
        if (p != q && clash(placed[p]!, placed[q]!)) p,
  };
  expect(play.conflicts, clashing, reason: trail);

  // P3
  final crossed = <Sq>{
    for (final x in play.crossedOut)
      (c.cells[x].grid, c.cells[x].row, c.cells[x].col),
  };
  final shouldCross = <Sq>{
    for (final sq in s.oracle.squares)
      if (s.oracle.canHold(sq) &&
          !placed.values.contains(sq) &&
          placed.values.any((Sq o) => clash(sq, o)))
        sq,
  };
  expect(crossed, shouldCross, reason: trail);

  // P5, the part every board can check.
  final all = <Clue>[...c.clues, ...c.extras];
  final truths = <Truth>[...s.oracle.clues, ...s.oracle.extras];
  for (var i = 0; i < all.length; i++) {
    final speaker = all[i].subject;
    final mark = play.markOf(all[i]);
    if (speaker != null && play.pos[speaker] < 0) {
      expect(mark, ClueMark.open, reason: trail);
    }
    if (play.complete) {
      final truth = truths[i](toOracle(c, play.pos));
      expect(
        mark,
        truth ? ClueMark.met : ClueMark.broken,
        reason: '$trail: clue $i',
      );
    }
  }

  // P4
  if (play.complete) {
    final board = toOracle(c, play.pos);
    expect(
      play.solved,
      s.oracle.wrong(board) == null,
      reason: '$trail: ${s.oracle.wrong(board)}',
    );
    if (play.solved) {
      expect(play.victimMark, ClueMark.met, reason: trail);
      expect(
        c.people[play.murderer].id,
        s.oracle.murderer(board),
        reason: trail,
      );
    }
  }

  // P7
  final hint = play.hint();
  final wrong = <int>[
    for (final p in placed.keys)
      if (play.pos[p] != answer[p]) p,
  ];
  if (wrong.isNotEmpty) {
    expect(hint!.wrong, isTrue, reason: trail);
    expect(wrong, contains(hint.person), reason: trail);
    expect(hint.cell, play.pos[hint.person], reason: trail);
  } else if (play.complete) {
    expect(hint, isNull, reason: trail);
  } else {
    expect(hint!.wrong, isFalse, reason: trail);
    expect(play.pos[hint.person], -1, reason: trail);
    expect(hint.cell, answer[hint.person], reason: trail);
    if (hint.person == c.victim) {
      expect(placed.length, c.people.length - 1, reason: trail);
    }
  }
}

void main() {
  test('GEN-040 P1 to P5, P7: a random player never breaks the board', () {
    final rnd = Random(40);
    var solvedBoards = 0;
    var fullBoards = 0;
    for (final tier in Tier.values) {
      for (final s in spread(shipped(tier), 8 * depth)) {
        final c = s.c;
        final play = CaseSession(c);
        final free = <int>[for (final x in c.cells) x.index];
        final trail = <String>[];
        checkBoard(s, play, '$s start');
        for (var step = 0; step < 90; step++) {
          final roll = rnd.nextInt(100);
          if (roll < 55) {
            // Any square at all, blocked ones included.
            final cell = free[rnd.nextInt(free.length)];
            trail.add('tap ${c.cellLabel(cell)}=${play.tap(cell).name}');
          } else if (roll < 70) {
            final p = rnd.nextInt(c.people.length);
            play.select(p);
            trail.add('select ${c.people[p].id}');
          } else if (roll < 88) {
            // Take the hint: lift a wrong person, or place the next one.
            final hint = play.hint();
            if (hint == null) {
              trail.add('hint: solved');
            } else if (hint.wrong) {
              play.remove(hint.person);
              trail.add('hint: lift ${c.people[hint.person].id}');
            } else {
              play.select(hint.person);
              trail.add('hint: ${play.tap(hint.cell).name}');
            }
          } else if (roll < 96) {
            // The true square for the selected person.
            trail.add('true: ${play.tap(c.solution![play.selected]).name}');
          } else {
            play.clear();
            trail.add('clear');
          }
          final last = trail.length > 12
              ? trail.sublist(trail.length - 12)
              : trail;
          checkBoard(s, play, '$s after ${last.join(', ')}');
          if (play.complete) fullBoards++;
          if (play.complete && play.solved) solvedBoards++;
        }
        // From wherever the player ended, the hints alone finish the case.
        for (
          var guard = 0;
          !play.solved && guard < 4 * c.people.length;
          guard++
        ) {
          final hint = play.hint()!;
          if (hint.wrong) {
            play.remove(hint.person);
          } else {
            play.select(hint.person);
            expect(play.tap(hint.cell), TapOutcome.placed, reason: '$s');
          }
          checkBoard(s, play, '$s finishing by hints');
        }
        expect(play.solved, isTrue, reason: '$s');
        expect(play.tap(free.first), TapOutcome.ignored, reason: '$s');
      }
    }
    // The walk really reached full boards, right and wrong.
    expect(fullBoards, greaterThan(solvedBoards));
    expect(solvedBoards, greaterThan(0));
  });

  /// P6 for one statement on one part-filled board: every way of placing
  /// the people still waiting is tried against the oracle.
  void checkFinal(
    CaseDef c,
    Oracle oracle,
    Clue clue,
    Truth truth,
    CaseSession play,
    String what,
  ) {
    final mark = play.markOf(clue);
    if (mark == ClueMark.open) return;
    final waiting = <int>[
      for (var p = 0; p < c.people.length; p++)
        if (play.pos[p] < 0) p,
    ];
    final free = <int>[
      for (final x in c.cells)
        if (c.canOccupy(x.index) && !play.pos.contains(x.index)) x.index,
    ];
    final pos = List<int>.of(play.pos);
    void fill(int k) {
      if (k == waiting.length) {
        expect(
          truth(toOracle(c, pos)),
          mark == ClueMark.met,
          reason: '$what is ${mark.name} on ${play.pos} but not on $pos',
        );
        return;
      }
      for (final x in free) {
        if (pos.contains(x)) continue;
        pos[waiting[k]] = x;
        fill(k + 1);
        pos[waiting[k]] = -1;
      }
    }

    fill(0);
  }

  test('GEN-036 P6 a tick or a cross on a part-filled board is final', () {
    const forms = <String>[
      'A is in K',
      'A is not on c',
      'A is beside t',
      'A is sees t',
      'A is line row c',
      'A dir B -1 0',
      'A dir B 1 1',
      'A offset B * 2',
      'A diag B',
      'A dist B 3',
      'A with B',
      'A notwith B',
      'A alone',
      'A alonewith B',
      'A alonewith B C',
      'A others any 1',
      'A others f 0',
      'A others hat 1',
      'A only on c',
      'A only in K',
      'A allothers not in K',
      '* count 2 on c',
      '* count 0 in K',
      '* more K G',
      '* group f in G',
      '* group hat border',
    ];
    final rnd = Random(36);
    var marked = 0;
    for (final form in forms) {
      final c = board(<String>['clue $form']);
      // The fixture has no stated answer; the session needs one to exist.
      final withAnswer = c.copyWith(
        clues: const <Clue>[],
        solution: boardPlacement(c),
      );
      final oracle = Oracle(writeCase(c));
      for (var n = 0; n < 25 * depth; n++) {
        final play = CaseSession(withAnswer);
        final all = anyPlacement(c, rnd);
        // Three or four of the five people on any free squares.
        final count = 3 + rnd.nextInt(2);
        final who = List<int>.generate(c.people.length, (int p) => p)
          ..shuffle(rnd);
        for (final p in who.take(count)) {
          play.place(p, all[p]);
        }
        if (play.markOf(c.clues.single) != ClueMark.open) marked++;
        checkFinal(c, oracle, c.clues.single, oracle.clues.single, play, form);
      }
    }
    expect(marked, greaterThan(100));
  });

  test('GEN-036 P6 on shipped tutorial cases, wrong boards included', () {
    final rnd = Random(361);
    for (final s in spread(shipped(Tier.tutorial), 25 * depth)) {
      final c = s.c;
      final all = <Clue>[...c.clues, ...c.extras];
      final truths = <Truth>[...s.oracle.clues, ...s.oracle.extras];
      for (var n = 0; n < 6; n++) {
        final play = CaseSession(c);
        final pos = anyPlacement(c, rnd);
        final count = 1 + rnd.nextInt(c.people.length - 1);
        for (var p = 0; p < count; p++) {
          play.place(p, pos[p]);
        }
        for (var i = 0; i < all.length; i++) {
          checkFinal(c, s.oracle, all[i], truths[i], play, '$s clue $i');
        }
      }
    }
  });

  test('GEN-013 P8 the solver never rules out a true square', () {
    final rnd = Random(13);
    var steps = 0;
    for (final tier in Tier.values) {
      for (final s in spread(shipped(tier), 10 * depth)) {
        final c = s.c;
        final answer = c.solution!;
        for (var n = 0; n < 4; n++) {
          // Any correct part-board, the victim sometimes placed early.
          final fixed = <int, int>{
            for (var p = 0; p < c.people.length; p++)
              if (n > 0 && rnd.nextInt(3) == 0) p: answer[p],
          };
          for (final max in Technique.values) {
            final r = solveLogic(c, max: max, fixed: fixed);
            final what = '$s fixed $fixed up to ${max.name}';
            expect(r.contradiction, isFalse, reason: what);
            for (final step in r.steps) {
              steps++;
              for (final (p, x) in step.removed) {
                expect(x, isNot(answer[p]), reason: '$what: ${step.technique}');
              }
              if (step.placed != null) {
                expect(step.placed, answer[step.person!], reason: what);
              }
            }
            for (var p = 0; p < c.people.length; p++) {
              if (r.pos[p] >= 0) expect(r.pos[p], answer[p], reason: what);
            }
            if (r.solved) expect(r.pos, answer, reason: what);
            // With everything switched on, logic always finishes.
            if (max == Technique.liarSplit) {
              expect(r.solved, isTrue, reason: what);
            }
            // A technique above the tier is never needed.
            if (max == tier.hardest && fixed.isEmpty) {
              expect(r.solved, isTrue, reason: what);
            }
          }
        }
      }
    }
    expect(steps, greaterThan(5000));
  });

  test('GEN-026 P7 from any correct board the hints lead to the answer', () {
    final rnd = Random(26);
    for (final tier in Tier.values) {
      for (final s in spread(shipped(tier), 10 * depth)) {
        final c = s.c;
        final play = CaseSession(c);
        for (var p = 0; p < c.people.length; p++) {
          if (rnd.nextInt(3) == 0) play.place(p, c.solution![p]);
        }
        var hints = 0;
        while (!play.solved) {
          final hint = play.hint()!;
          expect(hint.wrong, isFalse, reason: '$s');
          expect(hint.cell, c.solution![hint.person], reason: '$s');
          final suspectsWaiting = <int>[
            for (var p = 0; p < c.people.length; p++)
              if (p != c.victim && play.pos[p] < 0) p,
          ];
          if (hint.person == c.victim) {
            expect(suspectsWaiting, isEmpty, reason: '$s');
          }
          // A suspect's hint always has a reason to give.
          if (hint.person != c.victim && !c.liar) {
            expect(hint.because, isNotEmpty, reason: '$s');
          }
          play.place(hint.person, hint.cell);
          expect(++hints, lessThanOrEqualTo(c.people.length), reason: '$s');
        }
      }
    }
  });

  test('the fixture used for P6 has the answer the tests give it', () {
    final c = parseCase(starterCase);
    expect(CaseSession(c).nextWaiting, 0);
  });
}
