// The screens at their edges (audit of 2026-11-25): wide and short
// viewports, a board that is finished, a random case that cannot be made,
// starting the app with and without storage, and the parts of a case the
// first three play-throughs never show.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/data/cases.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/tier.dart';
import 'package:ruby/engine/wording.dart';
import 'package:ruby/main.dart' as app;
import 'package:ruby/screens/case_screen.dart';
import 'package:ruby/services/progress.dart';
import 'package:ruby/services/random_case.dart';
import 'package:ruby/services/store.dart';
import 'package:ruby/widgets/case_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => Progress.init(MemoryStore()));

  void screen(WidgetTester tester, Size logical) {
    tester.view.physicalSize = logical * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  Future<void> tapCell(WidgetTester tester, CaseDef c, int cell) async {
    final x = c.cells[cell];
    final box = tester.getRect(find.byKey(ValueKey<String>('grid-${x.grid}')));
    final g = GridGeometry(c.grids[x.grid], box.size);
    await tester.tapAt(box.topLeft + g.rectOf(x.row, x.col).center);
    await tester.pumpAndSettle();
  }

  Future<CaseDef> open(
    WidgetTester tester,
    String tier,
    bool Function(CaseDef c) want, {
    Size size = const Size(360, 780),
  }) async {
    screen(tester, size);
    final pack = casePacks[tier]!;
    final index = pack.indexWhere((String t) => want(parseCase(t)));
    expect(index, isNonNegative, reason: 'no such $tier case');
    await tester.pumpWidget(
      MaterialApp(
        home: CaseScreen(pack: pack, index: index),
      ),
    );
    return parseCase(pack[index]);
  }

  Future<void> solve(WidgetTester tester, CaseDef c) async {
    for (var p = 0; p < c.people.length; p++) {
      await tester.ensureVisible(
        find.byKey(ValueKey<String>('person-${c.people[p].id}')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(ValueKey<String>('person-${c.people[p].id}')),
      );
      await tester.pumpAndSettle();
      await tapCell(tester, c, c.solution![p]);
    }
  }

  for (final size in const <Size>[
    Size(780, 360), // a phone on its side
    Size(700, 760), // a short, wide window
    Size(320, 568), // a small phone
    Size(1024, 768), // a tablet on its side
  ]) {
    testWidgets('nothing overflows at ${size.width.round()} by '
        '${size.height.round()}, and every square can be tapped', (
      tester,
    ) async {
      for (final (tier, want) in <(String, bool Function(CaseDef))>[
        ('tutorial', (CaseDef c) => true),
        ('hard', (CaseDef c) => c.grids.length == 2),
        ('expert', (CaseDef c) => c.grids.first.rows == 9),
      ]) {
        final c = await open(tester, tier, want, size: size);
        expect(tester.takeException(), isNull, reason: '$tier $size');
        // The whole grid is on screen: its last row is inside the window.
        for (var g = 0; g < c.grids.length; g++) {
          final box = tester.getRect(find.byKey(ValueKey<String>('grid-$g')));
          expect(box.bottom, lessThanOrEqualTo(size.height), reason: tier);
          expect(box.right, lessThanOrEqualTo(size.width), reason: tier);
          expect(box.height, greaterThan(60), reason: tier);
        }
        // The victim goes on the last square of the solution.
        final last = c.solution!.last;
        await tester.tap(
          find.byKey(ValueKey<String>('person-${c.people.last.id}')),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        await tapCell(tester, c, last);
        expect(tester.takeException(), isNull, reason: '$tier $size');
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('a solved board no longer changes, and the hint says so', (
    tester,
  ) async {
    final c = await open(tester, 'tutorial', (CaseDef c) => true);
    await solve(tester, c);
    expect(find.text('Case solved'), findsOneWidget);
    final empty = c.cells.indexWhere(
      (Cell x) => c.canOccupy(x.index) && !c.solution!.contains(x.index),
    );
    await tapCell(tester, c, empty);
    await tapCell(tester, c, c.solution!.first);
    expect(find.text('Case solved'), findsOneWidget);
    await tester.tap(find.byTooltip('Hint'));
    await tester.pumpAndSettle();
    expect(find.text(noticeSolved), findsOneWidget);
  });

  testWidgets('everyone placed but wrong: a notice, no solved card', (
    tester,
  ) async {
    final c = await open(tester, 'tutorial', (CaseDef c) => true);
    // Two suspects on each other\'s squares.
    final pos = List<int>.of(c.solution!);
    final swap = pos[0];
    pos[0] = pos[1];
    pos[1] = swap;
    for (var p = 0; p < c.people.length; p++) {
      await tapCell(tester, c, pos[p]);
    }
    expect(find.text(noticeMisfit), findsOneWidget);
    expect(find.text('Case solved'), findsNothing);
    expect(Progress.solved.value, isEmpty);
  });

  testWidgets('"Next case" opens the next one, "Back to the list" leaves', (
    tester,
  ) async {
    screen(tester, const Size(360, 780));
    final pack = casePacks['tutorial']!.take(2).toList();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CaseScreen(pack: pack, index: 0),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final first = parseCase(pack[0]);
    final second = parseCase(pack[1]);
    await solve(tester, first);
    await tester.tap(find.text('Next case'));
    await tester.pumpAndSettle();
    expect(find.text(second.title), findsOneWidget);
    await solve(tester, second);
    // The last case of a pack has nowhere to go on to.
    expect(find.text('Next case'), findsNothing);
    await tester.tap(find.text('Back to the list'));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('rules, general clues, traits, doors and two-grid squares '
      'are all shown', (tester) async {
    final liar = await open(tester, 'expert', (CaseDef c) => c.liar);
    expect(liar.liar, isTrue);
    expect(find.textContaining('Rule: Exactly one statement'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());

    final general = await open(
      tester,
      'hard',
      (CaseDef c) =>
          c.clues.any((Clue x) => x.subject == null) &&
          c.people.any((Person p) => p.traits.isNotEmpty),
    );
    final clue = general.clues.firstWhere((Clue x) => x.subject == null);
    expect(
      find.text(describeClue(general, clue).replaceAll('**', '')),
      findsOneWidget,
    );
    final withTrait = general.people.firstWhere(
      (Person p) => p.traits.isNotEmpty,
    );
    expect(
      find.textContaining('${withTrait.name} (${withTrait.traits.first}'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());

    final doors = await open(
      tester,
      'normal',
      (CaseDef c) => c.openings.isNotEmpty,
    );
    expect(doors.openings, isNotEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());

    final two = await open(tester, 'hard', (CaseDef c) => c.grids.length == 2);
    await tapCell(tester, two, two.solution![0]);
    expect(
      find.textContaining(
        '${two.people[0].name}  ·  ${two.placeLabel(two.solution![0])}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a random case that cannot be made frees the button and '
      'says so', (tester) async {
    final normal = RandomCases.inBackground;
    addTearDown(() => RandomCases.inBackground = normal);
    var calls = 0;
    RandomCases.inBackground = (Tier tier) async {
      calls++;
      throw StateError('no case');
    };
    await tester.pumpWidget(const app.DetectiveSudokuApp());
    final button = find.byKey(const ValueKey<String>('random-tutorial'));
    await tester.scrollUntilVisible(
      button,
      3000,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text(noticeNoRandomCase), findsOneWidget);
    expect(find.byType(CaseGrid), findsNothing);
    expect(find.text('Generate a random case'), findsOneWidget);
    // The button works again.
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('GEN-037 the real background maker returns a sound case', (
    tester,
  ) async {
    final text = await tester.runAsync(
      () => RandomCases.inBackground(Tier.tutorial),
    );
    final c = parseCase(text!);
    expect(isRandomId(c.id), isTrue);
    expect(c.solution, isNotNull);
  });

  testWidgets('the app starts from what the device has saved', (tester) async {
    final first = readHeader(casePacks['tutorial']!.first);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'solved': first.id,
      'mode': 'cat',
    });
    await app.main();
    await tester.pump();
    expect(find.text('Detective Sudoku'), findsOneWidget);
    expect(Progress.solved.value, <String>{first.id});
    expect(Progress.mode.value, Mode.cat);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // What is done now is written back to the device.
    final store = await app.openStore();
    expect(store, isA<PrefsStore>());
    await store.write('mode', 'detective');
    expect(store.read('mode'), 'detective');
    Progress.markSolved('tutorial-002');
    await tester.pump();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('solved'), contains('tutorial-002'));
  });

  test(
    'with no storage the game starts and keeps progress in memory',
    () async {
      final store = await app.openStore(
        open: () => Future<KeyValueStore>.error(StateError('no plugin')),
      );
      expect(store, isA<MemoryStore>());
    },
  );

  test(
    'GEN-037 a tier that yields nothing is an error, not an endless wait',
    () {
      expect(
        () => RandomCases.make(Tier.easy, 5, tries: 0),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            'no easy case in 0 seeds from 5',
          ),
        ),
      );
    },
  );

  test('a store that fails to save does not stop the game', () async {
    Progress.init(_BrokenStore());
    Progress.markSolved('easy-001');
    Progress.setMode(Mode.cat);
    Progress.setExtrasShown('easy-001', <int>[1]);
    await Future<void>.delayed(Duration.zero);
    expect(Progress.solved.value, <String>{'easy-001'});
    expect(Progress.mode.value, Mode.cat);
  });

  test('saved numbers that make no sense are read as nothing opened', () {
    final store = MemoryStore()..write('extras.easy-001', '-1,x,99,');
    Progress.init(store);
    expect(Progress.extrasShown('easy-001', 5), <int>[0, 0, 99, 0, 0]);
  });

  test('the grid knows its own size', () {
    final c = parseCase(casePacks['tutorial']!.first);
    final g = GridGeometry(c.grids.first, const Size(460, 460));
    expect(g.size.width, closeTo(460, 0.01));
    expect(g.cellAt(const Offset(1, 1)), -1);
    expect(g.cellAt(g.rectOf(0, 0).center), c.grids.first.cellAt[0][0]);
    expect(g.cellAt(const Offset(4000, 4000)), -1);
  });
}

class _BrokenStore implements KeyValueStore {
  @override
  String? read(String key) => null;

  @override
  Future<void> write(String key, String value) =>
      Future<void>.error(StateError('disk full'));
}
