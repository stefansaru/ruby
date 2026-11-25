// Tests written with the audit of 2026-11-25: values the parser must refuse,
// the session owning selection and taps, hints in liar and two-grid cases,
// the header reader, and the checks that guard shipped and random cases.
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/data/cases.dart';
import 'package:ruby/data/settings.dart';
import 'package:ruby/engine/atoms.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/logic_solver.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/openings.dart';
import 'package:ruby/engine/session.dart';
import 'package:ruby/engine/wording.dart';
import 'package:ruby/gen/gen_check.dart';
import 'package:ruby/gen/gen_config.dart';

import 'fixtures.dart';

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

/// The door and window lines of the fixture board, as text to append.
String boardWith(List<String> lines) => lines.join('\n');

void main() {
  group('the parser refuses what can never be true', () {
    test('GEN-006 a header line given twice, and a missing setting', () {
      refused(
        swap('title The', 'title Again\ntitle The'),
        '"title" is given twice',
      );
      refused(
        swap('case test', 'case other\ncase test'),
        '"case" is given twice',
      );
      refused(
        swap('setting home', 'setting home\nsetting farm'),
        '"setting" is given twice',
      );
      refused(
        '${starterCase}solution A=1:2:2 B=1:1:4 C=1:3:1 D=1:4:3\n',
        '"solution" is given twice',
      );
      refused(swap('setting home\n', ''), 'missing "setting');
    });

    test('GEN-006 people: a name used twice, a trait that is a keyword', () {
      refused(
        swap('person B Ben m', 'person B Anna m'),
        'two people are called Anna',
      );
      for (final trait in <String>['m', 'f', 'any', '!hat', 'hat,,cap']) {
        refused(
          swap('person A Anna f', 'person A Anna f $trait'),
          'cannot be a trait',
        );
      }
    });

    test('GEN-006 numbers out of range', () {
      refused(swap('clue A is on c', 'clue A dist B 1'), 'at least 2 steps');
      refused(swap('clue A is on c', 'clue A dist B 0'), 'at least 2 steps');
      refused(swap('clue A is on c', 'clue A is beside t x5'), '1 to 4 sides');
      refused(swap('clue A is on c', 'clue A is beside t x0'), '1 to 4 sides');
      refused(
        swap('clue A is on c', 'clue * count -1 on c'),
        'cannot be negative',
      );
      refused(
        swap('clue A is on c', 'clue A others any -2'),
        'cannot be negative',
      );
      refused(
        swap('clue A is on c', 'clue A alonewith B B'),
        'names someone twice',
      );
    });

    test('GEN-007 a solution that places someone twice', () {
      refused(
        swap('solution A=1:2:2 B', 'solution A=1:2:2 A=1:1:1 B'),
        'places A twice',
      );
    });

    test('GEN-006 two openings on one side of one square', () {
      expect(
        () => board(<String>['open Home 2 3 E window']),
        throwsA(isA<CaseFormatException>()),
      );
    });
  });

  group('the header of a case', () {
    test('agrees with the parsed case for every shipped case', () {
      for (final pack in casePacks.values) {
        for (final text in pack) {
          final c = parseCase(text);
          final h = readHeader(text);
          expect(h.id, c.id);
          expect(h.title, c.title);
          expect(h.setting, c.setting);
          expect(h.people, c.people.length);
          expect(h.sizes, <(int, int)>[
            for (final g in c.grids) (g.rows, g.cols),
          ]);
        }
      }
    });

    test('never throws, whatever the text', () {
      final h = readHeader('grid\ngrid Home x y\ngrid Home 4\n\nnonsense');
      expect(h.id, isEmpty);
      expect(h.title, isEmpty);
      expect(h.setting, isEmpty);
      expect(h.sizes, isEmpty);
      expect(h.people, 0);
    });
  });

  group('the session owns selection and taps', () {
    test('a tap places the selected person and moves on, victim last', () {
      final c = parseCase(starterCase);
      final s = CaseSession(c);
      expect(s.selected, 0);
      expect(s.nextWaiting, 0);
      expect(s.tap(c.solution![0]), TapOutcome.placed);
      expect(s.selected, 1);
      // A table is refused and nothing moves.
      expect(s.tap(at(c, 2, 4)), TapOutcome.refused);
      expect(s.selected, 1);
      expect(s.pos[1], -1);
      // Squares off the board are refused too.
      expect(s.place(1, -1), isFalse);
      expect(s.place(1, c.cells.length), isFalse);
      // A tap on Anna lifts her, whoever is selected.
      expect(s.tap(c.solution![0]), TapOutcome.lifted);
      expect(s.selected, 0);
      expect(s.pos[0], -1);
      for (var p = 0; p < c.people.length; p++) {
        s.select(p);
        expect(s.tap(c.solution![p]), TapOutcome.placed);
      }
      expect(s.nextWaiting, -1);
      expect(s.solved, isTrue);
    });

    test('once solved, taps change nothing', () {
      final c = parseCase(starterCase);
      final s = CaseSession(c);
      for (var p = 0; p < c.people.length; p++) {
        s.place(p, c.solution![p]);
      }
      final before = List<int>.of(s.pos);
      final empty = c.cells.indexWhere(
        (Cell x) => c.canOccupy(x.index) && s.personAt(x.index) < 0,
      );
      expect(s.tap(empty), TapOutcome.ignored);
      expect(s.tap(c.solution![0]), TapOutcome.ignored);
      expect(s.pos, before);
      expect(s.hint(), isNull);
    });

    test('the victim waits until every suspect is placed', () {
      final c = parseCase(starterCase);
      final s = CaseSession(c);
      final order = <int>[];
      while (s.nextWaiting >= 0) {
        final p = s.nextWaiting;
        order.add(p);
        s.place(p, c.solution![p]);
      }
      expect(order.last, c.victim);
      s.clear();
      expect(s.selected, 0);
      expect(() => s.select(99), throwsRangeError);
    });

    test('a card shows the statements, then as many extras as were opened', () {
      final c = parseCase(casePacks['tutorial']!.first);
      final s = CaseSession(c);
      final needed = c.clues.where((Clue x) => x.subject == 0).length;
      final extras = s.extrasOf(0).length;
      expect(extras, greaterThan(0));
      expect(s.statementsOf(0), hasLength(needed));
      expect(s.statementsOf(0, shown: 1), hasLength(needed + 1));
      expect(s.statementsOf(0, shown: 99), hasLength(needed + extras));
      expect(s.statementsOf(0, shown: -3), hasLength(needed));
      expect(s.statementsOf(c.victim, shown: 9), isEmpty);
    });

    test('GEN-026 a hint is worked out once per board, from the solver', () {
      final c = parseCase(casePacks['normal']!.first);
      final s = CaseSession(c);
      final first = s.hint()!;
      expect(identical(s.hint(), first), isTrue);
      expect(first.cell, c.solution![first.person]);
      s.place(first.person, first.cell);
      final second = s.hint()!;
      expect(identical(second, first), isFalse);
      expect(second.person, isNot(first.person));
    });

    test('GEN-036 one statement is marked from its own pieces alone', () {
      final c = board(<String>['rule notouch', 'clue A alone']);
      final pieces = Atoms(c, c.clues, rules: false);
      expect(pieces.others, isEmpty);
      expect(pieces.binary, hasLength(c.people.length - 1));
      final all = Atoms(c, c.clues);
      expect(all.others, hasLength(1));
      expect(all.binary.length, greaterThan(pieces.binary.length));
    });
  });

  group('liar cases', () {
    final liars = <CaseDef>[
      for (final text in casePacks['expert']!)
        if (parseCase(text).liar) parseCase(text),
    ];

    test('there are liar cases to test', () {
      expect(liars, isNotEmpty);
    });

    test('GEN-011 the solver says which statement is the lie', () {
      for (final c in liars) {
        final r = solveLogic(c);
        expect(r.solved, isTrue, reason: c.id);
        final lie = r.lie!;
        expect(c.clues[lie].holds(c, c.solution!), isFalse, reason: c.id);
        for (var i = 0; i < c.clues.length; i++) {
          if (i != lie) expect(c.clues[i].holds(c, c.solution!), isTrue);
        }
      }
      // A case without the rule has no lie.
      expect(solveLogic(parseCase(starterCase)).lie, isNull);
    });

    test('GEN-026 a hint never quotes the false statement as true', () {
      for (final c in liars) {
        final s = CaseSession(c);
        for (var i = 0; i < c.people.length; i++) {
          final h = s.hint()!;
          final lie = h.lie!;
          final liar = c.people[c.clues[lie].subject!].name;
          final falsehood = describeClue(c, c.clues[lie]);
          final lines = describeHint(c, h.person, h.because, lie: lie);
          expect(
            lines,
            contains("The false statement is **$liar**'s: $falsehood"),
          );
          expect(lines, isNot(contains('**$liar** said: $falsehood')));
          if (h.person == c.clues[lie].subject) {
            expect(lines.join(), isNot(contains('statements and the crossed')));
            expect(lines.join(), contains('With that and the crossed-out'));
          }
          s.place(h.person, h.cell);
        }
        expect(s.solved, isTrue, reason: c.id);
      }
    });

    test('GEN-035 a liar case has no extras: one would name the liar', () {
      for (final c in liars) {
        expect(c.extras, isEmpty, reason: c.id);
      }
    });
  });

  group('two grids', () {
    final c = parseCase(
      casePacks['hard']!.firstWhere(
        (String t) => parseCase(t).grids.length == 2,
      ),
    );
    final second = c.cells.firstWhere((Cell x) => x.grid == 1).index;

    test('a square is named with its grid', () {
      final grid = c.grids[1].label;
      expect(c.placeLabel(second), '${c.cellLabel(second)} ($grid)');
      expect(describeWrong(c, 0, second), contains('($grid)'));
      expect(
        describeStep(c, LogicStep(Technique.single, person: 0, placed: second)),
        allOf(contains('($grid)'), contains('there are taken')),
      );
      expect(
        describeStep(
          c,
          LogicStep(Technique.lastInLine, person: 0, line: (1, true, 0)),
        ),
        startsWith('**Row 1** of the $grid must hold someone'),
      );
      expect(
        describeHint(c, 0, const <LogicStep>[], square: second).last,
        contains('($grid)'),
      );
    });

    test('with one grid the square stands alone', () {
      final one = parseCase(starterCase);
      expect(one.placeLabel(at(one, 2, 2)), 'B2');
      expect(
        describeWrong(one, 0, at(one, 2, 2)),
        '**Anna** was not on **B2**.',
      );
      expect(colLabel(0), 'A');
      expect(colLabel(25), 'Z');
    });
  });

  group('model helpers', () {
    test('capacity, full grids, clashes and random ids', () {
      final c = parseCase(starterCase);
      expect(c.capacity, 4);
      expect(c.isFull, isTrue);
      expect(c.grids.single.capacity, 4);
      expect(c.clash(at(c, 1, 1), at(c, 1, 3)), isTrue);
      expect(c.clash(at(c, 1, 1), at(c, 2, 2)), isFalse);
      final strict = board(<String>['rule notouch']);
      expect(strict.clash(at(strict, 1, 1), at(strict, 2, 2)), isTrue);
      expect(strict.isFull, isTrue);
      expect(isRandomId('random-easy-7'), isTrue);
      expect(isRandomId('easy-007'), isFalse);
      expect(
        const GridDef('Upper_Deck', 2, 3, <List<int>>[]).label,
        'Upper Deck',
      );
    });

    test('GEN-034 which openings the clues need', () {
      List<Opening> used(List<String> clues) {
        final c = board(clues);
        return usedOpenings(c, c.clues);
      }

      expect(used(<String>['clue A is in K']), isEmpty);
      expect(used(<String>['clue A is front door']).single.isDoor, isTrue);
      expect(
        used(<String>['clue A is not front window']).single.isDoor,
        isFalse,
      );
      expect(used(<String>['clue A only front door']), hasLength(1));
      expect(used(<String>['clue A allothers not front window']), hasLength(1));
      expect(used(<String>['clue * count 0 front door']), hasLength(1));
      expect(used(<String>['clue * group f not front door']), hasLength(1));
      // What someone can see depends on every opening.
      expect(used(<String>['clue A is sees t']), hasLength(2));
      expect(used(<String>['clue A alone', 'clue B with C']), isEmpty);
      final c = board(<String>['clue A alone']);
      expect(usedOpenings(c, <Clue>[negate(c.clues.single)]), isEmpty);
    });
  });

  group('checks on configs and shipped cases', () {
    test('GEN-017 too many people and a negative title are refused', () {
      GenConfig make({List<(int, int)>? grids, int titleIndex = 0}) =>
          GenConfig(
            id: 'x',
            tier: Tier.easy,
            setting: 'home',
            grids: grids ?? <(int, int)>[(5, 5)],
            seed: 1,
            titleIndex: titleIndex,
          );
      expect(
        () => make(grids: <(int, int)>[(12, 12), (3, 3)]),
        throwsA(
          isA<ArgumentError>()
              .having((ArgumentError e) => e.name, 'name', 'grids')
              .having((ArgumentError e) => e.invalidValue, 'value', 15),
        ),
      );
      expect(
        () => make(titleIndex: -1),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError e) => e.name,
            'name',
            'titleIndex',
          ),
        ),
      );
    });

    test('GEN-006 a case that does not parse is reported, not thrown', () {
      expect(checkShipped('nonsense', Tier.easy), contains('unknown line'));
      final noAnswer = casePacks['tutorial']!.first
          .split('\n')
          .where(
            (String l) => !l.startsWith('solution') && !l.startsWith('extra'),
          )
          .join('\n');
      expect(checkShipped(noAnswer, Tier.tutorial), 'no certified solution');
    });

    test('GEN-019 a statement that could be left out is reported', () {
      // Turning an extra into a clue gives a clue the case does not need.
      final text = casePacks['tutorial']!.first;
      final padded = text.replaceFirst('\nextra ', '\nclue ');
      expect(padded, isNot(text));
      expect(checkShipped(padded, Tier.tutorial), contains('is not needed'));
    });

    test('GEN-020 a suspect with nothing to say is reported', () {
      final text = casePacks['tutorial']!.first;
      final c = parseCase(text);
      final silent = c.clues
          .where((Clue x) => x.subject == 0)
          .fold(
            text,
            (String s, Clue x) =>
                s.replaceFirst('clue ${clueNotation(c, x)}\n', ''),
          );
      expect(silent, isNot(text));
      expect(
        checkShipped(silent, Tier.tutorial),
        '${c.people[0].name} says nothing',
      );
    });

    test('every setting has areas enough for two grids', () {
      for (final s in settings) {
        expect(s.areas.length, greaterThanOrEqualTo(4), reason: s.id);
        expect(s.gridNames, hasLength(2), reason: s.id);
      }
    });
  });
}
