// The corners of the engine the other tests do not reach: every refusal of
// the parser, the rarer clue forms and their sentences, the hint sentence
// of every technique, and what the solver and the session do when a case
// cannot be finished by logic.
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/atoms.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/logic_solver.dart';
import 'package:ruby/engine/session.dart';
import 'package:ruby/engine/wording.dart';

import 'fixtures.dart';

/// Expects [text] to be refused with a message containing [why].
void refused(String text, String why) {
  expect(
    () => parseCase(text),
    throwsA(
      isA<CaseFormatException>().having(
        (CaseFormatException e) => e.toString(),
        'message',
        contains(why),
      ),
    ),
    reason: why,
  );
}

String swap(String from, String to) {
  expect(starterCase, contains(from));
  return starterCase.replaceFirst(from, to);
}

void main() {
  group('the parser refuses', () {
    test('GEN-006 malformed header and scene lines, each with its reason', () {
      refused(
        swap('setting home\n', 'setting home\nrule sideways\n'),
        'unknown rule',
      );
      refused(swap('kind c sit chair', 'kind c sit'), 'kind <code> sit|block');
      refused(
        swap('kind t block table', 'kind c block table'),
        'defined twice',
      );
      refused(swap('grid Home 4 4', 'grid Home 0 4'), 'out of range');
      refused(swap('grid Home 4 4', 'grid Home 4 27'), 'out of range');
      refused(
        swap('person A Anna f', 'person A Anna f hat extra'),
        'm|f [traits]',
      );
      refused(swap('G.. Gc. K.. Kt.', 'G.. G.1 K.. Kt.'), 'needs an object');
      refused('${starterCase}grid Home 1 1\nG..\n', 'defined twice');
    });

    test('GEN-006 an area on two grids', () {
      refused('''
case test-split
title Split
setting home
area K Kitchen
grid Up 2 2
K.. K..
K.. K..
grid Down 2 2
K.. K..
K.. K..
person A Anna f
victim V Vera f
''', 'spread over two grids');
    });

    test('GEN-006 unknown tests and clues, and an offset of nothing', () {
      refused(swap('clue A is on c', 'clue A is under c'), 'unknown test');
      refused(
        swap('clue A is on c', 'clue * every in G'),
        'unknown general clue',
      );
      refused(
        swap('clue A is on c', 'clue A offset B * *'),
        'needs a row or a column',
      );
    });

    test('GEN-035 extras need a solution to be checked against', () {
      final text = starterCase.replaceFirst(RegExp('solution.*\n'), '');
      refused('${text}extra A is in G\n', 'need a stated solution');
    });

    test('a refusal names its line, or the case when it has none', () {
      expect(
        CaseFormatException('bad word', 7).toString(),
        'Case line 7: bad word',
      );
      expect(CaseFormatException('no grid', 0).toString(), 'Case: no grid');
    });
  });

  group('rarer clue forms', () {
    test('GEN-004 "everyone else" splits into one piece per person', () {
      final c = board(<String>['clue A allothers not in K']);
      final pos = boardPlacement(c);
      expect(c.clues.single.holds(c, pos), isTrue);
      expect(Atoms(c, c.clues).unary, hasLength(c.people.length));
      expect(writeCase(c), contains('clue A allothers not in K\n'));
      // Anna herself in the Garden breaks it: she must be the exception.
      final moved = List<int>.of(pos)..[0] = at(c, 2, 4);
      expect(c.clues.single.holds(c, moved), isFalse);
    });

    test('GEN-024 negated "exactly N sides" and "in my row" read plainly', () {
      final c = board(<String>[
        'clue A is not beside t x2',
        'clue B is not line row c',
      ]);
      final said = <String>[for (final x in c.clues) describeClue(c, x)];
      expect(
        said[0],
        contains('did **not** have a **table** on exactly **2**'),
      );
      expect(said[1], contains('had **no** chair in his **row**'));
    });

    test('GEN-011 a negated clue has a sentence but is never stored', () {
      final c = board(<String>['clue A alone']);
      final lie = negate(c.clues.single);
      expect(lie, isA<Negated>());
      expect(describeClue(c, lie), startsWith('This is **false**: '));
      expect(lie.subject, 0);
      expect(() => clueNotation(c, lie), throwsArgumentError);
    });

    test('GEN-027 a tall grid says how many rows stay empty', () {
      final c = parseCase('''
case test-tall
title Tall
setting home
area K Kitchen
area H Hall
grid Home 4 2
K.. K..
K.. K..
H.. H..
H.. H..
person A Anna f
victim V Vera f
''');
      expect(describeRules(c), <String>['**2** rows stay empty.']);
    });
  });

  group('hint sentences', () {
    final c = board(<String>['clue A is in K', 'clue * count 2 on c']);

    test('GEN-026 every technique has a sentence', () {
      String say(LogicStep s, [Mode mode = Mode.detective]) =>
          describeStep(c, s, mode: mode);
      expect(
        say(LogicStep(Technique.lastInLine, person: 1, line: (0, true, 2))),
        '**Row 3** must hold someone, and only **Ben** can still be there.',
      );
      expect(
        say(LogicStep(Technique.lastInLine, person: 1, line: (0, false, 2))),
        startsWith('**Column C** must hold someone'),
      );
      expect(
        say(LogicStep(Technique.intersection, person: 2)),
        contains('Every square left for **Cora** is in one line'),
      );
      expect(say(LogicStep(Technique.subset)), contains('rows or columns'));
      expect(
        say(LogicStep(Technique.whatIf, person: 3)),
        contains('**Dan** leads to a dead end'),
      );
      expect(
        say(LogicStep(Technique.liarSplit)),
        contains('one statement is false'),
      );
      expect(
        say(LogicStep(Technique.single, person: 0, placed: at(c, 2, 1))),
        '**Anna** is on **A2**, so **row 2** and **column A** are taken.',
      );
      expect(
        say(LogicStep(Technique.clue, person: 0, clue: 0)),
        '**Anna** said: She was in the **Kitchen**.',
      );
      expect(
        say(LogicStep(Technique.counting, clue: 1)),
        startsWith('Clue: Exactly **2**'),
      );
      expect(
        say(LogicStep(Technique.pair, clue: noTouchRule)),
        contains('next to'),
      );
      expect(say(LogicStep(Technique.counting)), isEmpty);
    });

    test('the victim rule is told in the words of the mode', () {
      final step = LogicStep(Technique.counting, clue: victimRule);
      expect(describeStep(c, step), contains('murderer'));
      expect(describeStep(c, step, mode: Mode.cat), contains('kitten'));
      expect(
        describeStep(c, step, mode: Mode.cat),
        isNot(contains('murderer')),
      );
    });

    test('a hint for the victim, and for a suspect with a harder step', () {
      final victim = describeHint(c, c.victim, const <LogicStep>[]);
      expect(victim.first, 'Look at **Eva**.');
      expect(victim[1], contains('**one** square is left for her'));
      expect(victim.last, contains('Tap the hint again'));

      final ben = describeHint(c, 1, <LogicStep>[
        // Seen on the grid already: not repeated in the hint.
        LogicStep(Technique.single, person: 0, placed: at(c, 2, 1)),
        LogicStep(Technique.lastInLine, person: 1, line: (0, true, 0)),
        LogicStep(Technique.lastInLine, person: 1, line: (0, true, 0)),
      ], square: at(c, 1, 4));
      expect(ben, <String>[
        'Look at **Ben**.',
        '**Row 1** must hold someone, and only **Ben** can still be there.',
        'His statements and the crossed-out squares leave **one** square.',
        '**Ben** was on **D1**.',
      ]);
    });

    test('the solved line and the rules sheet in both modes', () {
      final solved = board(<String>[
        'clue A is on c',
        'solution A=1:2:1 B=1:1:4 C=1:3:5 D=1:4:3 E=1:5:2',
      ]);
      final pos = solved.solution!;
      expect(
        describeSolved(solved, pos),
        '**Dan** was alone with Eva in the **Hall**. Dan is the murderer.',
      );
      expect(
        describeSolved(solved, pos, Mode.cat),
        contains('hiding the kitten'),
      );
      expect(describeVictim(solved, Mode.cat), contains('missing kitten'));
      for (final mode in Mode.values) {
        final steps = howToPlay(mode);
        expect(steps, hasLength(3));
        expect(steps[0], startsWith('**Read.**'));
        expect(steps[1], startsWith('**Place.**'));
        expect(steps[2], startsWith('**Find.**'));
      }
      expect(howToPlay(Mode.cat).join(), isNot(contains('murderer')));
      expect(howToPlay().join(), isNot(contains('kitten')));
    });
  });

  group('cases logic cannot finish', () {
    test('GEN-011 a liar case where every statement as the lie fails', () {
      final c = board(<String>[
        'rule liar',
        'clue A is row 1',
        'clue A is row 2',
        'clue A is row 3',
      ]);
      final r = solveLogic(c);
      expect(r.solved, isFalse);
      expect(r.contradiction, isTrue);
      expect(r.pos, everyElement(-1));
    });

    test('GEN-026 a hint still names someone, the victim last', () {
      // Without Cora\'s second statement the starter case has several
      // answers: the solver cannot finish it, the stated answer still stands.
      final c = parseCase(starterCase.replaceFirst('clue C is beside r\n', ''));
      expect(solveLogic(c).solved, isFalse);
      final s = CaseSession(c);
      final order = <int>[];
      for (var i = 0; i < c.people.length; i++) {
        final h = s.hint()!;
        expect(h.wrong, isFalse);
        expect(h.cell, c.solution![h.person]);
        order.add(h.person);
        s.place(h.person, h.cell);
      }
      expect(order.toSet(), hasLength(c.people.length));
      expect(order.last, c.victim);
      expect(s.solved, isTrue);
    });
  });
}
