import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/data/cases.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/session.dart';
import 'package:ruby/engine/wording.dart';

import 'fixtures.dart';

void main() {
  test('placing, replacing and removing people', () {
    final c = parseCase(starterCase);
    final s = CaseSession(c);
    expect(s.complete, isFalse);
    expect(s.place(0, at(c, 2, 2)), isTrue);
    expect(s.personAt(at(c, 2, 2)), 0);
    // A table cannot hold a person.
    expect(s.place(1, at(c, 2, 4)), isFalse);
    expect(s.pos[1], -1);
    // Ben cannot take Anna's square: nobody is pushed off.
    expect(s.place(1, at(c, 2, 2)), isFalse);
    expect(s.pos[0], at(c, 2, 2));
    expect(s.pos[1], -1);
    // Anna can be put where she already is, and moved.
    expect(s.place(0, at(c, 2, 2)), isTrue);
    expect(s.place(0, at(c, 1, 2)), isTrue);
    expect(s.personAt(at(c, 2, 2)), -1);
    s.remove(0);
    expect(s.personAt(at(c, 1, 2)), -1);
  });

  test('GEN-001 people sharing a row or column are reported, not refused', () {
    final c = parseCase(starterCase);
    final s = CaseSession(c)
      ..place(0, at(c, 2, 2))
      ..place(1, at(c, 2, 3))
      ..place(2, at(c, 4, 1));
    expect(s.conflicts, <int>{0, 1});
    s.place(1, at(c, 1, 4));
    expect(s.conflicts, isEmpty);
  });

  test('GEN-003 solved only with everyone on the certified squares', () {
    final c = parseCase(starterCase);
    final s = CaseSession(c);
    for (var p = 0; p < 3; p++) {
      s.place(p, c.solution![p]);
    }
    expect(s.solved, isFalse);
    s.place(3, c.solution![3]);
    expect(s.complete, isTrue);
    expect(s.solved, isTrue);
    expect(c.people[s.murderer].name, 'Cora');
    s.clear();
    expect(s.pos.every((int x) => x == -1), isTrue);
  });

  test('GEN-026 hints walk any shipped case to its solution', () {
    for (final pack in casePacks.values) {
      final c = parseCase(pack.first);
      final s = CaseSession(c);
      for (var i = 0; i < c.people.length; i++) {
        final h = s.hint()!;
        expect(h.wrong, isFalse);
        expect(s.pos[h.person], -1);
        expect(h.cell, c.solution![h.person]);
        s.place(h.person, h.cell);
      }
      expect(s.solved, isTrue);
      expect(s.hint(), isNull);
    }
  });

  test('GEN-026 a hint points at a wrong placement first', () {
    final c = parseCase(starterCase);
    final s = CaseSession(c)..place(0, c.solution![2]);
    final h = s.hint()!;
    expect(h.wrong, isTrue);
    expect(h.person, 0);
    expect(h.cell, c.solution![2]);
  });

  test('GEN-026 a hint carries the steps that explain it', () {
    final c = parseCase(casePacks['easy']!.first);
    final s = CaseSession(c);
    for (var i = 0; i < c.people.length; i++) {
      final h = s.hint()!;
      expect(h.because, isNotEmpty);
      for (final step in h.because) {
        expect(step.removed.any(((int, int) r) => r.$1 == h.person), isTrue);
        expect(describeStep(c, step), isNotEmpty);
      }
      s.place(h.person, h.cell);
    }
  });

  test('squares in the row and column of a placed person are crossed out', () {
    final c = parseCase(starterCase);
    final s = CaseSession(c);
    expect(s.crossedOut, isEmpty);
    s.place(0, at(c, 2, 2));
    final crossed = s.crossedOut;
    // Row 2 and column B, without the person's own square and without
    // squares nobody could stand on anyway (the table on D2).
    expect(crossed, <int>{
      at(c, 2, 1),
      at(c, 2, 3),
      at(c, 1, 2),
      at(c, 3, 2),
      at(c, 4, 2),
    });
    s.remove(0);
    expect(s.crossedOut, isEmpty);
  });
}
