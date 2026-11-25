// Inputs nobody wrote by hand: damaged case text, cases made on the spot,
// and a finger that taps anywhere.
//
// Rules explored here:
//   F1  Damaged case text is either refused with a CaseFormatException or
//       is a case that can be written out and read back unchanged. It
//       never throws anything else.
//   F2  A damaged case that still parses and states an answer has an
//       answer the oracle accepts too: the parser's check and the oracle
//       agree on text nobody designed.
//   F3  A case made on request passes everything a shipped case passes,
//       including the oracle and the mirrors.
//   F4  Random taps on the real screen never raise an error.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/data/cases.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/exact_solver.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/tier.dart';
import 'package:ruby/gen/gen_check.dart';
import 'package:ruby/screens/case_screen.dart';
import 'package:ruby/services/progress.dart';
import 'package:ruby/services/random_case.dart';
import 'package:ruby/services/store.dart';
import 'package:ruby/widgets/case_grid.dart';

import '../support/explore.dart';
import '../support/oracle.dart';
import '../support/transform.dart';

/// One small damage to [text]: a character changed, a word or a line
/// dropped, doubled or swapped with another.
String damaged(String text, Random rnd) {
  final lines = text.trimRight().split('\n');
  final i = rnd.nextInt(lines.length);
  final words = lines[i].split(' ');
  const pool = 'ABCDKHGctrs.-123456789|!*x';
  switch (rnd.nextInt(7)) {
    case 0:
      lines.removeAt(i);
    case 1:
      lines.insert(i, lines[rnd.nextInt(lines.length)]);
    case 2:
      final j = rnd.nextInt(lines.length);
      final keep = lines[i];
      lines[i] = lines[j];
      lines[j] = keep;
    case 3:
      words.removeAt(rnd.nextInt(words.length));
      lines[i] = words.join(' ');
    case 4:
      words.insert(
        rnd.nextInt(words.length + 1),
        words[rnd.nextInt(words.length)],
      );
      lines[i] = words.join(' ');
    case 5:
      if (lines[i].isNotEmpty) {
        final k = rnd.nextInt(lines[i].length);
        lines[i] =
            lines[i].substring(0, k) +
            pool[rnd.nextInt(pool.length)] +
            lines[i].substring(k + 1);
      }
    default:
      final w = rnd.nextInt(words.length);
      final n = int.tryParse(words[w]);
      words[w] = n == null
          ? '${rnd.nextInt(12) - 2}'
          : '${n + rnd.nextInt(5) - 2}';
      lines[i] = words.join(' ');
  }
  return '${lines.join('\n')}\n';
}

void main() {
  test('GEN-006 F1 F2 damaged case text is refused or is a sound case', () {
    final rnd = Random(6);
    final sources = spread(shipped(), 40);
    var refused = 0;
    var parsed = 0;
    for (var n = 0; n < 4000 * depth; n++) {
      var text = sources[n % sources.length].text;
      // One to three damages.
      for (var k = rnd.nextInt(3); k >= 0; k--) {
        text = damaged(text, rnd);
      }
      final CaseDef c;
      try {
        c = parseCase(text);
      } on CaseFormatException {
        refused++;
        continue;
      }
      // Anything other than a CaseFormatException fails the test here.
      parsed++;
      final written = writeCase(c);
      expect(writeCase(parseCase(written)), written, reason: text);
      readHeader(text);
      for (final clue in c.clues) {
        expect(clueNotation(c, clue), isNotEmpty);
      }
      // F2: the parser accepted the stated answer; so must the oracle.
      final answer = c.solution;
      if (answer != null) {
        final oracle = Oracle(written);
        expect(
          oracle.wrong(toOracle(c, answer)),
          isNull,
          reason: 'the parser accepts an answer the oracle refuses:\n$written',
        );
      }
    }
    // Both outcomes happened, in numbers.
    expect(refused, greaterThan(1000));
    expect(parsed, greaterThan(100));
  });

  test('GEN-006 F1 text that is not a case at all is refused', () {
    final rnd = Random(61);
    const junk = <String>[
      '',
      '\n\n',
      'case',
      'case x\n',
      'grid\n',
      'grid Home 2 2\nK..\n',
      'solution A=1',
      'clue',
      'person',
      'open',
      'area',
      'kind',
      'case x\nsetting home\ngrid Home 1 1\n---\n',
      'case x\nsetting home\narea K Kitchen\ngrid Home 1 1\nK..\nvictim V Vera f\n',
    ];
    for (final text in junk) {
      expect(
        () => parseCase(text),
        throwsA(isA<CaseFormatException>()),
        reason: text,
      );
      readHeader(text);
    }
    for (var n = 0; n < 300 * depth; n++) {
      // Printable characters with a new line now and then.
      int char(int _) => rnd.nextInt(4) == 0 ? 10 : 32 + rnd.nextInt(95);
      final text = String.fromCharCodes(
        List<int>.generate(1 + rnd.nextInt(200), char),
      );
      expect(
        () => parseCase(text),
        throwsA(isA<CaseFormatException>()),
        reason: text,
      );
      readHeader(text);
    }
  });

  test('GEN-037 F3 cases made on request pass every check there is', () {
    final rnd = Random(37);
    for (final tier in Tier.values) {
      for (var n = 0; n < 3 * depth; n++) {
        final text = RandomCases.make(tier, rnd.nextInt(1 << 30));
        final what = '${tier.name} case\n$text';
        expect(checkShipped(text, tier), isNull, reason: what);
        final c = parseCase(text);
        final oracle = Oracle(text);
        final answer = toOracle(c, c.solution!);
        expect(oracle.wrong(answer), isNull, reason: what);
        for (var i = 0; i < c.extras.length; i++) {
          expect(oracle.extras[i](answer), isTrue, reason: what);
        }
        // Random boards: the engine and the oracle agree clue by clue.
        for (var k = 0; k < 40; k++) {
          final pos = lawfulPlacement(c, rnd) ?? anyPlacement(c, rnd);
          for (var i = 0; i < c.clues.length; i++) {
            expect(
              c.clues[i].holds(c, pos),
              oracle.clues[i](toOracle(c, pos)),
              reason: '${oracle.clueLines[i]} in $what',
            );
          }
          expect(
            c.check(pos) == null,
            oracle.wrong(toOracle(c, pos)) == null,
            reason: what,
          );
        }
        // Small ones: the slow search finds one answer.
        if (c.cells.length <= 25) {
          expect(oracle.everyAnswer(limit: 2), hasLength(1), reason: what);
        }
        // Both mirrors are the same puzzle.
        for (final columns in <bool>[true, false]) {
          final m = parseCase(mirrored(text, columns: columns));
          expect(solveExact(m, limit: 3), <List<int>>[
            m.solution!,
          ], reason: what);
        }
      }
    }
  });

  testWidgets('GEN-040 F4 random taps on the screen never raise an error', (
    tester,
  ) async {
    final rnd = Random(404);
    for (final (tier, size) in <(String, Size)>[
      ('tutorial', const Size(360, 780)),
      ('normal', const Size(780, 360)),
      ('hard', const Size(1024, 768)),
      ('expert', const Size(320, 568)),
    ]) {
      Progress.init(MemoryStore());
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final pack = casePacks[tier]!;
      final index = rnd.nextInt(pack.length);
      final c = parseCase(pack[index]);
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey<String>(tier),
          home: CaseScreen(pack: pack, index: index),
        ),
      );
      for (var step = 0; step < 60 * depth; step++) {
        final roll = rnd.nextInt(100);
        if (roll < 60) {
          // Anywhere on a grid, squares or not.
          final g = rnd.nextInt(c.grids.length);
          final box = tester.getRect(find.byKey(ValueKey<String>('grid-$g')));
          await tester.tapAt(
            box.topLeft +
                Offset(
                  rnd.nextDouble() * box.width,
                  rnd.nextDouble() * box.height,
                ),
          );
        } else if (roll < 75) {
          await tester.tap(find.byTooltip('Hint'));
        } else if (roll < 85) {
          final card = find.byKey(
            ValueKey<String>(
              'person-${c.people[rnd.nextInt(c.people.length)].id}',
            ),
          );
          await tester.ensureVisible(card);
          await tester.pumpAndSettle();
          await tester.tap(card, warnIfMissed: false);
        } else if (roll < 92) {
          final plus = find.byTooltip('One more statement');
          if (plus.evaluate().isNotEmpty) {
            await tester.ensureVisible(plus.first);
            await tester.pumpAndSettle();
            await tester.tap(plus.first, warnIfMissed: false);
          }
        } else if (roll < 97) {
          final close = find.byTooltip('Close');
          if (close.evaluate().isNotEmpty) {
            await tester.tap(close.first, warnIfMissed: false);
          }
        } else {
          await tester.tap(find.byTooltip('Start again'));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$tier step $step');
        // The grid stays whole and on screen.
        expect(find.byType(CaseGrid), findsNWidgets(c.grids.length));
        // A solved card is never shown without the tick being saved.
        if (find.text('Case solved').evaluate().isNotEmpty) {
          expect(Progress.solved.value, contains(c.id), reason: tier);
        }
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
}
