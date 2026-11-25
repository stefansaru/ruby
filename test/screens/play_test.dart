import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/data/cases.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/wording.dart';
import 'package:ruby/main.dart';
import 'package:ruby/screens/case_screen.dart';
import 'package:ruby/services/progress.dart';
import 'package:ruby/services/random_case.dart';
import 'package:ruby/services/store.dart';
import 'package:ruby/widgets/case_grid.dart';

String plain(String s) => s.replaceAll('**', '');

void main() {
  setUp(() => Progress.init(MemoryStore()));

  void tallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// Taps the square of [cell] on the grid that holds it.
  Future<void> tapCell(WidgetTester tester, CaseDef c, int cell) async {
    final x = c.cells[cell];
    final finder = find.byKey(ValueKey<String>('grid-${x.grid}'));
    final box = tester.getRect(finder);
    final g = GridGeometry(c.grids[x.grid], box.size);
    await tester.tapAt(box.topLeft + g.rectOf(x.row, x.col).center);
    await tester.pumpAndSettle();
  }

  Finder card(String id) => find.byKey(ValueKey<String>('person-$id'));

  Future<void> tapPerson(WidgetTester tester, String id) async {
    await tester.ensureVisible(card(id));
    await tester.pumpAndSettle();
    await tester.tap(card(id));
    await tester.pumpAndSettle();
  }

  Finder inCard(String id, IconData icon) =>
      find.descendant(of: card(id), matching: find.byIcon(icon));

  Future<CaseDef> open(
    WidgetTester tester,
    String tier, [
    int index = 0,
  ]) async {
    tallPhone(tester);
    final pack = casePacks[tier]!;
    await tester.pumpWidget(
      MaterialApp(
        home: CaseScreen(pack: pack, index: index),
      ),
    );
    return parseCase(pack[index]);
  }

  testWidgets('the app opens on the packs and into a case', (tester) async {
    await tester.pumpWidget(const DetectiveSudokuApp());
    expect(find.text('Detective Sudoku'), findsOneWidget);
    expect(find.text('Tutorial'), findsOneWidget);
    expect(find.text('Expert'), findsOneWidget);
    final first = parseCase(casePacks['tutorial']!.first);
    await tester.tap(find.text(first.title));
    await tester.pumpAndSettle();
    expect(find.byType(CaseGrid), findsOneWidget);
    expect(find.textContaining('alone with the murderer'), findsOneWidget);
  });

  testWidgets('a solved case shows a green tick in the list', (tester) async {
    final first = parseCase(casePacks['tutorial']!.first);
    await tester.pumpWidget(const DetectiveSudokuApp());
    expect(find.byIcon(Icons.check_circle), findsNothing);
    Progress.markSolved(first.id);
    await tester.pump();
    final tick = tester.widget<Icon>(find.byIcon(Icons.check_circle));
    expect(tick.color, Colors.green);
    expect(tick.semanticLabel, 'Solved');
  });

  testWidgets('the menu explains the game and switches to cat mode', (
    tester,
  ) async {
    await tester.pumpWidget(const DetectiveSudokuApp());
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How to play'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Read.'), findsOneWidget);
    expect(find.textContaining('is the murderer'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cat mode'));
    await tester.pumpAndSettle();
    expect(Progress.mode.value, Mode.cat);
    final first = parseCase(casePacks['tutorial']!.first);
    await tester.tap(find.text(first.title));
    await tester.pumpAndSettle();
    expect(find.textContaining('The missing kitten'), findsOneWidget);
    expect(find.textContaining('murderer'), findsNothing);
  });

  testWidgets('GEN-037 the button under a pack makes and opens a new case', (
    tester,
  ) async {
    final normal = RandomCases.inBackground;
    addTearDown(() => RandomCases.inBackground = normal);
    RandomCases.inBackground = (tier) async => RandomCases.make(tier, 7);
    await tester.pumpWidget(const DetectiveSudokuApp());
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
    expect(find.byType(CaseGrid), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
  });

  testWidgets('statements are a checklist: tick, cross, one more with +', (
    tester,
  ) async {
    final c = await open(tester, 'tutorial');
    final answer = c.solution!;
    final anna = c.people[0];
    expect(inCard(anna.id, Icons.check_circle), findsNothing);
    expect(inCard(anna.id, Icons.cancel), findsNothing);

    // On the right square every statement of hers gets a tick.
    await tapCell(tester, c, answer[0]);
    expect(inCard(anna.id, Icons.check_circle), findsWidgets);
    expect(inCard(anna.id, Icons.cancel), findsNothing);
    expect(find.textContaining('${anna.name}  ·  '), findsOneWidget);

    // Tapping her on the grid lifts her, even with someone else selected.
    await tapPerson(tester, c.people[1].id);
    await tapCell(tester, c, answer[0]);
    expect(find.textContaining('${anna.name}  ·  '), findsNothing);
    expect(inCard(anna.id, Icons.check_circle), findsNothing);

    // On a square that breaks her first statement there is a red cross.
    final first = c.clues.firstWhere((Clue x) => x.subject == 0) as Is;
    final wrong = c.cells.indexWhere(
      (x) => c.canOccupy(x.index) && !first.test.test(c, x.index),
    );
    await tapPerson(tester, anna.id);
    await tapCell(tester, c, wrong);
    expect(inCard(anna.id, Icons.cancel), findsWidgets);

    // The + shows one more true statement of hers.
    final extra = c.extras.firstWhere((Clue x) => x.subject == 0);
    final sentence = find.descendant(
      of: card(anna.id),
      matching: find.text(plain(describeClue(c, extra))),
    );
    expect(sentence, findsNothing);
    await tester.ensureVisible(card(anna.id));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: card(anna.id),
        matching: find.byTooltip('One more statement'),
      ),
    );
    await tester.pumpAndSettle();
    expect(sentence, findsOneWidget);
    expect(Progress.extrasShown(c.id, c.people.length)[0], 1);
  });

  testWidgets('a placed card is greyed and the next person is selected', (
    tester,
  ) async {
    final c = await open(tester, 'easy');
    double opacityOf(int p) => tester
        .widget<Opacity>(
          find.ancestor(
            of: card(c.people[p].id),
            matching: find.byType(Opacity),
          ),
        )
        .opacity;
    expect(opacityOf(0), 1);
    await tapCell(tester, c, c.solution![0]);
    expect(opacityOf(0), lessThan(1));
    expect(opacityOf(1), 1);
    // The second suspect is now the one a tap places.
    await tapCell(tester, c, c.solution![1]);
    expect(find.textContaining('${c.people[1].name}  ·  '), findsOneWidget);
  });

  testWidgets('a hint can be closed', (tester) async {
    await open(tester, 'easy');
    await tester.tap(find.byTooltip('Hint'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Look at'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Look at'), findsNothing);
    expect(find.byTooltip('Close'), findsNothing);
  });

  for (final tier in <String>['tutorial', 'easy', 'hard']) {
    testWidgets('a $tier case can be played to "Case solved"', (tester) async {
      // The first hard case with two grids.
      final index = tier == 'hard'
          ? casePacks[tier]!.indexWhere(
              (String t) => parseCase(t).grids.length == 2,
            )
          : 0;
      final c = await open(tester, tier, index);
      expect(find.text('Case solved'), findsNothing);

      // A blocked square is refused with a message.
      final blocked = c.cells.indexWhere((x) => !c.canOccupy(x.index));
      if (blocked >= 0) {
        await tapCell(tester, c, blocked);
        expect(find.text('Nobody can stand there.'), findsOneWidget);
      }

      // Put the first person on a wrong square, then ask for a hint.
      final answer = c.solution!;
      await tapPerson(tester, c.people[0].id);
      await tapCell(tester, c, answer[1]);
      await tester.tap(find.byTooltip('Hint'));
      await tester.pumpAndSettle();
      expect(find.textContaining('was not on'), findsOneWidget);
      await tester.tap(find.byTooltip('Start again'));
      await tester.pumpAndSettle();

      // A hint first says who to look at, then on a second tap the square.
      await tester.tap(find.byTooltip('Hint'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Look at'), findsOneWidget);
      expect(find.textContaining('Tap the hint again'), findsOneWidget);
      await tester.tap(find.byTooltip('Hint'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Tap the hint again'), findsNothing);
      expect(find.textContaining(RegExp(r' was on [A-L]\d')), findsOneWidget);

      for (var p = 0; p < c.people.length; p++) {
        await tapPerson(tester, c.people[p].id);
        await tapCell(tester, c, answer[p]);
      }
      expect(find.text('Case solved'), findsOneWidget);
      expect(find.textContaining('is the murderer'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsNothing);
      expect(Progress.solved.value, contains(c.id));
    });
  }

  testWidgets('cat mode tells the same case as a missing kitten', (
    tester,
  ) async {
    Progress.setMode(Mode.cat);
    final c = await open(tester, 'tutorial');
    for (var p = 0; p < c.people.length; p++) {
      await tapPerson(tester, c.people[p].id);
      await tapCell(tester, c, c.solution![p]);
    }
    expect(find.text('Case solved'), findsOneWidget);
    expect(find.textContaining('was hiding the kitten'), findsOneWidget);
    expect(find.textContaining('murderer'), findsNothing);
  });
}
