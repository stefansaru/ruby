// The object-to-area mapping (GEN-029), the victim's name (GEN-030) and the
// victim being placed last (GEN-031), checked on the settings list and on
// every shipped case.
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/data/cases.dart';
import 'package:ruby/data/settings.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/logic_solver.dart';
import 'package:ruby/engine/session.dart';
import 'package:ruby/gen/gen_check.dart';
import 'package:ruby/gen/gen_config.dart';

/// The areas of any setting that list the object called [name].
Set<String> areasOf(String name) => <String>{
  for (final s in settings)
    for (final k in s.kinds)
      if (k.name == name)
        for (final a in s.areas)
          if (a.allows(k)) a.name,
};

void main() {
  group('settings', () {
    test('GEN-029 every area lists only objects of its own setting', () {
      for (final s in settings) {
        final codes = <String>{for (final k in s.kinds) k.code};
        expect(codes.length, s.kinds.length, reason: '${s.id}: codes repeat');
        for (final a in s.areas) {
          expect(a.kinds, isNotEmpty, reason: '${s.id} ${a.name}');
          for (final code in a.kinds.split('')) {
            expect(codes, contains(code), reason: '${s.id} ${a.name}');
          }
          expect(
            a.kinds.split('').toSet().length,
            a.kinds.length,
            reason: '${s.id} ${a.name}: an object is listed twice',
          );
        }
      }
    });

    test('GEN-029 every object belongs in at least one area', () {
      for (final s in settings) {
        for (final k in s.kinds) {
          expect(
            s.areas.any((AreaSpec a) => a.allows(k)),
            isTrue,
            reason: '${s.id}: ${k.name} has no area',
          );
        }
      }
    });

    test('GEN-029 boats are on water, cars on roads, beds indoors', () {
      const water = <String>{'Lake', 'Sea', 'Pond'};
      expect(water.containsAll(areasOf('boat')), isTrue);
      expect(water.containsAll(areasOf('canoe')), isTrue);
      expect(areasOf('lifeboat'), <String>{'Deck'});
      expect(areasOf('car'), <String>{'Garage', 'Street'});
      expect(areasOf('campfire'), <String>{'Fire Ring'});
      expect(areasOf('swing'), <String>{'Playground'});
      expect(areasOf('skeleton'), <String>{'Dino Room'});
      // A lamp only blocks a square where it is a lamp post (input/problem5).
      expect(areasOf('lamp'), <String>{'Street', 'Square', 'Park'});
      expect(areasOf('suitcase'), isNotEmpty);
      for (final s in settings) {
        for (final a in s.areas) {
          for (final k in s.kinds.where(a.allows)) {
            // Furniture stays indoors; trees stay outdoors.
            if (const <String>{
              'bed',
              'sofa',
              'shelf',
              'desk',
            }.contains(k.name)) {
              expect(a.indoor, isTrue, reason: '${k.name} in ${a.name}');
            }
            if (const <String>{'tree', 'bush', 'palm'}.contains(k.name)) {
              expect(a.indoor, isFalse, reason: '${k.name} in ${a.name}');
            }
          }
        }
      }
    });

    test('GEN-029 the report from the phone: no boat in the Pines', () {
      final forest = settings.firstWhere((SettingDef s) => s.id == 'forest');
      final boat = forest.kinds.firstWhere((KindSpec k) => k.name == 'boat');
      for (final area in <String>['Pines', 'Clearing', 'Path', 'Cave']) {
        final spec = forest.areas.firstWhere((AreaSpec a) => a.name == area);
        expect(spec.allows(boat), isFalse, reason: area);
      }
    });
  });

  group('shipped cases', () {
    test('GEN-029 every object stands in an area that lists it', () {
      for (final tier in Tier.values) {
        for (final text in casePacks[tier.name]!) {
          final c = parseCase(text);
          expect(misplacedObject(c), isNull, reason: c.id);
        }
      }
    });

    test('GEN-029 a misplaced object is reported with its square', () {
      const text = '''
case test-misplaced
title The Stray Boat
setting forest
area P Pines
area L Lake
kind b sit boat
grid Forest 3 3
Pb. P.. L..
P.. P.. L..
P.. L.. L..
person A Anna f
person B Ben m
victim V Vera f
clue A is on b
clue B is in L
solution A=1:1:1 B=1:3:2 V=1:2:3
''';
      expect(
        misplacedObject(parseCase(text)),
        'a boat does not belong in the Pines (A1)',
      );
      expect(checkShipped(text, Tier.tutorial), contains('does not belong'));
    });

    test('GEN-030 the victim is listed last and begins with V', () {
      for (final tier in Tier.values) {
        for (final text in casePacks[tier.name]!) {
          final c = parseCase(text);
          final victim = c.people[c.victim];
          expect(c.victim, c.people.length - 1, reason: c.id);
          expect(victim.id, 'V', reason: c.id);
          expect(victim.name, startsWith('V'), reason: c.id);
          for (final p in c.people) {
            if (!p.isVictim) expect(p.id, isNot('V'), reason: c.id);
          }
        }
      }
    });

    test('GEN-030 a victim with another initial is not shipped', () {
      final text = casePacks['tutorial']!.first;
      final c = parseCase(text);
      final name = c.people[c.victim].name;
      final renamed = text
          .replaceAll('victim V $name', 'victim W Will')
          .replaceAll(' V=', ' W=');
      expect(renamed, isNot(text));
      expect(checkShipped(renamed, Tier.tutorial), contains('begin with V'));
    });

    test('GEN-031 the solver places the victim after every suspect', () {
      for (final tier in Tier.values) {
        for (final text in casePacks[tier.name]!) {
          final c = parseCase(text);
          final placed = <int>[
            for (final s in solveLogic(c).steps)
              if (s.technique == Technique.single) s.person!,
          ];
          expect(placed.last, c.victim, reason: c.id);
          expect(
            placed.where((int p) => p == c.victim).length,
            1,
            reason: c.id,
          );
        }
      }
    });

    test('GEN-031 hints never name the victim before the last suspect', () {
      for (final tier in Tier.values) {
        for (final text in casePacks[tier.name]!.take(6)) {
          final c = parseCase(text);
          final s = CaseSession(c);
          for (var i = 0; i < c.people.length; i++) {
            final h = s.hint()!;
            expect(
              h.person == c.victim,
              i == c.people.length - 1,
              reason: c.id,
            );
            s.place(h.person, h.cell);
          }
          expect(s.solved, isTrue, reason: c.id);
        }
      }
    });

    test('GEN-032 tutorial and easy cases need a statement and the people '
        'already placed, nothing more', () {
      for (final tier in <Tier>[Tier.tutorial, Tier.easy]) {
        for (final text in casePacks[tier.name]!) {
          final c = parseCase(text);
          final grade = solveLogic(c, max: Technique.single);
          expect(grade.solved, isTrue, reason: c.id);
          for (final s in grade.steps) {
            expect(
              s.technique == Technique.clue || s.technique == Technique.single,
              isTrue,
              reason: c.id,
            );
          }
        }
      }
    });
  });
}
