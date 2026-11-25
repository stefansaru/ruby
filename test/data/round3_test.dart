// Titles from the setting (GEN-033), no unused doors or windows (GEN-034),
// extra statements (GEN-035), checklist marks (GEN-036) and cases made on
// request (GEN-037), checked on every shipped case.
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/data/cases.dart';
import 'package:ruby/data/settings.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/exact_solver.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/openings.dart';
import 'package:ruby/engine/session.dart';
import 'package:ruby/engine/wording.dart';
import 'package:ruby/gen/gen_campaign.dart';
import 'package:ruby/gen/gen_check.dart';
import 'package:ruby/gen/gen_clues.dart';
import 'package:ruby/gen/gen_config.dart';
import 'package:ruby/services/progress.dart';
import 'package:ruby/services/random_case.dart';
import 'package:ruby/services/store.dart';

Iterable<CaseDef> shipped([int? perTier]) sync* {
  for (final tier in Tier.values) {
    final pack = casePacks[tier.name]!;
    for (final text in perTier == null ? pack : pack.take(perTier)) {
      yield parseCase(text);
    }
  }
}

void main() {
  test('the four packs the owner asked for hold a hundred cases each', () {
    for (final tier in <String>['tutorial', 'easy', 'normal', 'hard']) {
      expect(casePacks[tier], hasLength(100), reason: tier);
    }
  });

  group('titles', () {
    test('GEN-033 every title ends in a word of its own setting', () {
      final titles = <String>{};
      for (final c in shipped()) {
        final setting = settings.firstWhere(
          (SettingDef s) => s.id == c.setting,
        );
        expect(c.title, startsWith('The '), reason: c.id);
        expect(
          setting.titles.any((String noun) => c.title.endsWith(' $noun')),
          isTrue,
          reason: '${c.id}: "${c.title}" is not about the ${setting.name}',
        );
        expect(titles.add(c.title), isTrue, reason: 'repeated: ${c.title}');
      }
    });
  });

  group('doors and windows', () {
    test('GEN-034 none is on a map unless a clue uses it', () {
      var withOpenings = 0;
      for (final c in shipped()) {
        expect(
          usedOpenings(c, c.clues),
          hasLength(c.openings.length),
          reason: c.id,
        );
        if (c.openings.isNotEmpty) withOpenings++;
      }
      // The clue family still exists: some cases do have them.
      expect(withOpenings, greaterThan(0));
    });

    test('GEN-034 tutorial and easy cases have none', () {
      for (final tier in <String>['tutorial', 'easy']) {
        for (final text in casePacks[tier]!) {
          expect(parseCase(text).openings, isEmpty);
        }
      }
    });

    test('GEN-034 a door nobody mentions is not shipped', () {
      final text = casePacks['tutorial']!.first;
      final c = parseCase(text);
      final cell = c.cells.firstWhere((Cell x) {
        final east = c.neighbor(x.index, Side.east);
        return east >= 0 && c.cells[east].area != x.area;
      });
      final door =
          'open ${c.grids[cell.grid].name} ${cell.row + 1} ${cell.col + 1} '
          'E door\n';
      final withDoor = text.replaceFirst('person ', '${door}person ');
      expect(parseCase(withDoor).openings, hasLength(1));
      expect(checkShipped(withDoor, Tier.tutorial), contains('in no clue'));
    });
  });

  group('extra statements', () {
    test('GEN-035 extras are true, new, spoken by a suspect, and top each '
        'suspect up to three statements', () {
      var suspects = 0;
      var full = 0;
      for (final c in shipped()) {
        final said = <String>{for (final x in c.clues) clueNotation(c, x)};
        for (final x in c.extras) {
          expect(x.subject, isNotNull, reason: c.id);
          expect(x.subject, isNot(c.victim), reason: c.id);
          expect(x.holds(c, c.solution!), isTrue, reason: c.id);
          expect(said.add(clueNotation(c, x)), isTrue, reason: c.id);
        }
        for (var p = 0; p < c.people.length; p++) {
          if (p == c.victim) continue;
          final needed = c.clues.where((Clue x) => x.subject == p).length;
          final extra = c.extras.where((Clue x) => x.subject == p).length;
          if (extra > 0) {
            expect(
              needed + extra,
              lessThanOrEqualTo(statementsPerSuspect),
              reason: c.id,
            );
          }
          suspects++;
          if (needed + extra >= statementsPerSuspect) full++;
        }
      }
      // A few suspects in small scenes have nothing more to say.
      expect(full / suspects, greaterThan(0.9));
    });

    test('GEN-035 extras never speak of company in the area of the victim', () {
      for (final c in shipped()) {
        final pos = c.solution!;
        final victimArea = c.cells[pos[c.victim]].area;
        for (final x in c.extras) {
          final company =
              x is Alone ||
              x is AloneWith ||
              x is Others ||
              (x is Rel && x.kind == RelKind.sameArea);
          if (company) {
            expect(
              c.cells[pos[x.subject!]].area,
              isNot(victimArea),
              reason: c.id,
            );
          }
        }
      }
    });

    test('GEN-035 the case is the same puzzle without its extras', () {
      for (final c in shipped(8)) {
        final bare = c.copyWith(extras: const <Clue>[]);
        expect(solveExact(bare), <List<int>>[c.solution!], reason: c.id);
        expect(writeCase(c), contains('\nextra '), reason: c.id);
        expect(writeCase(bare), isNot(contains('\nextra ')), reason: c.id);
        expect(writeCase(parseCase(writeCase(c))), writeCase(c));
      }
    });

    test(
      'GEN-035 a false extra, or one without a speaker, cannot be built',
      () {
        final text = casePacks['tutorial']!.first;
        final c = parseCase(text);
        final elsewhere = c.areas.indexWhere(
          (AreaDef a) => a != c.areas[c.cells[c.solution![0]].area],
        );
        final id = c.people[0].id;
        String withLine(String line) =>
            text.replaceFirst('solution ', '$line\nsolution ');
        expect(
          () =>
              parseCase(withLine('extra $id is in ${c.areas[elsewhere].code}')),
          throwsA(isA<CaseFormatException>()),
        );
        expect(
          () => parseCase(withLine('extra * count 0 on ${c.kinds.first.code}')),
          throwsA(isA<CaseFormatException>()),
        );
        expect(
          () => parseCase(withLine('extra ${c.people[c.victim].id} is row 1')),
          throwsA(isA<CaseFormatException>()),
        );
      },
    );
  });

  group('checklist marks', () {
    test('GEN-036 on the finished answer every true statement is ticked', () {
      for (final c in shipped(12)) {
        final s = CaseSession(c);
        for (var p = 0; p < c.people.length; p++) {
          s.place(p, c.solution![p]);
        }
        final marks = <ClueMark>[for (final x in c.clues) s.markOf(x)];
        if (c.liar) {
          expect(
            marks.where((ClueMark m) => m == ClueMark.broken),
            hasLength(1),
            reason: c.id,
          );
        } else {
          expect(marks, everyElement(ClueMark.met), reason: c.id);
        }
        for (final x in c.extras) {
          expect(s.markOf(x), ClueMark.met, reason: c.id);
        }
        expect(s.victimMark, ClueMark.met, reason: c.id);
      }
    });

    test('GEN-036 a mark given early never changes while placements stay', () {
      for (final c in shipped(12)) {
        if (c.liar) continue;
        final s = CaseSession(c);
        final all = <Clue>[...c.clues, ...c.extras];
        for (var p = 0; p < c.people.length; p++) {
          for (final x in all) {
            // Correct placements never show a cross.
            expect(s.markOf(x), isNot(ClueMark.broken), reason: c.id);
            // A statement waits for its speaker.
            if (x.subject != null && s.pos[x.subject!] < 0) {
              expect(s.markOf(x), ClueMark.open, reason: c.id);
            }
          }
          expect(s.victimMark, isNot(ClueMark.broken), reason: c.id);
          s.place(p, c.solution![p]);
        }
      }
    });

    test('GEN-036 a placement that contradicts a statement gets a cross', () {
      for (final c in shipped(12)) {
        final s = CaseSession(c);
        for (final x in c.clues.whereType<Is>()) {
          final wrong = c.cells.indexWhere(
            (Cell y) => c.canOccupy(y.index) && !x.test.test(c, y.index),
          );
          if (wrong < 0) continue;
          s
            ..clear()
            ..place(x.subject, wrong);
          expect(s.markOf(x), ClueMark.broken, reason: c.id);
        }
      }
    });

    test('GEN-036 the victim with two companions is crossed at once', () {
      final c = shipped(1).first;
      final s = CaseSession(c);
      final pos = c.solution!;
      final area = c.cells[pos[c.victim]].area;
      final inArea = <int>[
        for (final x in c.cells)
          if (x.area == area && c.canOccupy(x.index)) x.index,
      ];
      if (inArea.length < 3) return;
      s
        ..place(c.victim, inArea[0])
        ..place(0, inArea[1]);
      expect(s.victimMark, ClueMark.open);
      s.place(1, inArea[2]);
      expect(s.victimMark, ClueMark.broken);
    });
  });

  group('cases made on request', () {
    test('GEN-037 the same seed gives the same config and case', () {
      for (final tier in Tier.values) {
        final a = randomConfig(tier, 41);
        final b = randomConfig(tier, 41);
        expect(a.id, 'random-${tier.name}-41');
        expect(a.setting, b.setting);
        expect(a.grids, b.grids);
        expect(a.titleIndex, b.titleIndex);
      }
      expect(RandomCases.make(Tier.easy, 41), RandomCases.make(Tier.easy, 41));
      expect(
        RandomCases.make(Tier.easy, 41),
        isNot(RandomCases.make(Tier.easy, 42)),
      );
    });

    test(
      'GEN-037 a random case of every tier is as sound as a shipped one',
      () {
        final shippedTitles = <String>{for (final c in shipped()) c.title};
        for (final tier in Tier.values) {
          for (final seed in <int>[3, 1234567]) {
            final text = RandomCases.make(tier, seed);
            expect(
              checkShipped(text, tier),
              isNull,
              reason: '${tier.name} $seed',
            );
            final c = parseCase(text);
            expect(c.id, startsWith('random-${tier.name}-'));
            expect(shippedTitles, isNot(contains(c.title)));
          }
        }
      },
    );
  });

  group('what the app remembers', () {
    test('solved cases, the mode and opened extras survive a restart', () {
      final store = MemoryStore();
      Progress.init(store);
      expect(Progress.solved.value, isEmpty);
      Progress.markSolved('easy-003');
      Progress.markSolved('random-easy-9');
      Progress.setExtrasShown('easy-003', <int>[1, 0, 2]);
      expect(Progress.mode.value.name, 'detective');
      Progress.setMode(Mode.cat);

      Progress.init(store);
      expect(Progress.solved.value, <String>{'easy-003'});
      expect(Progress.mode.value, Mode.cat);
      expect(Progress.extrasShown('easy-003', 4), <int>[1, 0, 2, 0]);
      expect(Progress.extrasShown('easy-004', 2), <int>[0, 0]);
      Progress.init(MemoryStore());
    });
  });
}
