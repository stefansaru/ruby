import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/data/settings.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/clue.dart';
import 'package:ruby/engine/exact_solver.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/openings.dart';
import 'package:ruby/engine/wording.dart';
import 'package:ruby/gen/gen_campaign.dart';
import 'package:ruby/gen/gen_case.dart';
import 'package:ruby/gen/gen_check.dart';
import 'package:ruby/gen/gen_clues.dart';
import 'package:ruby/gen/gen_config.dart';
import 'package:ruby/gen/gen_scene.dart';

GenConfig config({
  Tier tier = Tier.easy,
  List<(int, int)> grids = const <(int, int)>[(5, 5)],
  int seed = 11,
  bool irregular = false,
  bool liar = false,
  bool noTouch = false,
  bool traits = false,
  String setting = 'home',
  int attempts = 400,
}) => GenConfig(
  id: 'test-001',
  tier: tier,
  setting: setting,
  grids: grids,
  seed: seed,
  irregular: irregular,
  liar: liar,
  noTouch: noTouch,
  traits: traits,
  attempts: attempts,
);

void main() {
  test('GEN-016 the same config gives the same case', () {
    for (final tier in <Tier>[Tier.easy, Tier.normal]) {
      final a = generateCase(config(tier: tier, grids: <(int, int)>[(6, 6)]));
      final b = generateCase(config(tier: tier, grids: <(int, int)>[(6, 6)]));
      expect(a.result, isNotNull);
      expect(writeCase(a.result!), writeCase(b.result!));
      expect(a.draws, b.draws);
      final other = generateCase(
        config(tier: tier, grids: <(int, int)>[(6, 6)], seed: 12),
      );
      expect(writeCase(other.result!), isNot(writeCase(a.result!)));
    }
  });

  group('GEN-017 a config that makes no sense is refused by field', () {
    Matcher refuses(String field) => throwsA(
      isA<ArgumentError>().having((ArgumentError e) => e.name, 'name', field),
    );
    test('setting, grids, attempts, liar', () {
      expect(() => config(setting: 'moon'), refuses('setting'));
      expect(() => config(grids: <(int, int)>[]), refuses('grids'));
      expect(() => config(grids: <(int, int)>[(2, 5)]), refuses('grids'));
      expect(() => config(grids: <(int, int)>[(13, 13)]), refuses('grids'));
      expect(
        () => config(grids: <(int, int)>[(4, 4), (4, 4), (4, 4)]),
        refuses('grids'),
      );
      expect(() => config(attempts: 0), refuses('attempts'));
      expect(() => config(liar: true), refuses('liar'));
      expect(
        () => GenConfig(
          id: '',
          tier: Tier.easy,
          setting: 'home',
          grids: <(int, int)>[(5, 5)],
          seed: 1,
        ),
        refuses('id'),
      );
    });
  });

  test('GEN-018 the funnel narrows gate by gate and ends in one case', () {
    final out = generateCase(
      config(tier: Tier.normal, grids: <(int, int)>[(6, 6)]),
    );
    expect(out.result, isNotNull);
    final counts = <int>[for (final g in Gate.values) out.funnel[g]!];
    for (var i = 1; i < counts.length; i++) {
      expect(
        counts[i],
        lessThanOrEqualTo(counts[i - 1]),
        reason: Gate.values[i].name,
      );
    }
    expect(counts.last, 1);
    expect(counts.first, lessThanOrEqualTo(out.draws));
  });

  test('GEN-025 an accepted case mixes clue families', () {
    for (final tier in <Tier>[Tier.easy, Tier.normal, Tier.hard]) {
      final out = generateCase(config(tier: tier, grids: <(int, int)>[(6, 6)]));
      final families = out.families;
      expect(families, hasLength(out.result!.clues.length));
      final kinds = families.toSet();
      expect(
        kinds.length,
        greaterThanOrEqualTo(tier.index >= Tier.normal.index ? 3 : 2),
      );
      for (final f in kinds) {
        final share = families.where((Family x) => x == f).length;
        expect(share * 10, lessThanOrEqualTo(families.length * 6));
      }
    }
  });

  test('GEN-018 a slot that cannot be filled says so', () {
    // Tutorial-grade logic on a 9x9 scene does not happen in three draws.
    final out = generateCase(
      config(tier: Tier.tutorial, grids: <(int, int)>[(9, 9)], attempts: 3),
    );
    expect(out.result, isNull);
    expect(out.draws, 3);
    expect(out.funnel[Gate.variety], 0);
  });

  group('scenes', () {
    test('GEN-001 GEN-002 GEN-003 a drawn placement obeys the rules', () {
      for (var seed = 0; seed < 40; seed++) {
        final cfg = config(
          grids: seed.isEven
              ? <(int, int)>[(6, 6)]
              : <(int, int)>[(4, 4), (4, 4)],
          irregular: seed % 3 == 0 && seed.isEven,
          noTouch: seed % 5 == 0 && seed.isEven,
          seed: seed,
        );
        final scene = drawScene(cfg, Random(seed));
        if (scene == null) continue;
        expect(scene.check(scene.solution!), isNull, reason: 'seed $seed');
        expect(scene.people.length, cfg.people);
        expect(scene.people.where((Person p) => p.isVictim), hasLength(1));
        expect(
          scene.people.map((Person p) => p.id).toSet(),
          hasLength(cfg.people),
          reason: 'tokens must differ',
        );
        // A scene on its own parses as a case.
        expect(parseCase(writeCase(scene)).cells.length, scene.cells.length);
      }
    });

    test('GEN-027 a grid that is not square leaves rows or columns empty', () {
      final cfg = config(tier: Tier.hard, grids: <(int, int)>[(6, 8)]);
      expect(cfg.people, 6);
      final out = generateCase(cfg);
      expect(out.result, isNotNull);
      final c = out.result!;
      expect(c.people, hasLength(6));
      expect(describeRules(c), contains('**2** columns stay empty.'));
      final rows = c.solution!.map((int x) => c.cells[x].row).toSet();
      expect(rows, hasLength(6), reason: 'every row holds someone');
    });

    test('irregular grids lose squares at the corners', () {
      CaseDef? scene;
      for (var seed = 0; scene == null; seed++) {
        scene = drawScene(
          config(grids: <(int, int)>[(8, 8)], irregular: true),
          Random(seed),
        );
      }
      expect(scene.cells.length, lessThan(64));
      expect(writeCase(scene), contains('---'));
    });

    test('GEN-033 titles differ for every index and every setting', () {
      final titles = <String>{
        for (final s in settings)
          for (var i = 0; i < titleCount; i++) titleFor(s, i),
      };
      expect(titles, hasLength(titleCount * settings.length));
    });

    test('GEN-033 no title word belongs to two settings', () {
      final nouns = <String>[for (final s in settings) ...s.titles];
      expect(nouns.toSet(), hasLength(nouns.length));
      for (final s in settings) {
        expect(s.titles, hasLength(12), reason: s.id);
      }
    });
  });

  group('clues', () {
    CaseDef scene(Tier tier, int seed, {bool traits = false}) {
      CaseDef? s;
      for (var k = seed; s == null; k++) {
        s = drawScene(
          config(
            tier: tier,
            grids: <(int, int)>[(6, 6)],
            traits: traits,
            seed: k,
          ),
          Random(k),
        );
      }
      return s;
    }

    test('GEN-004 every candidate statement is true of the placement', () {
      final s = scene(Tier.expert, 3, traits: true);
      final list = listCandidates(s, s.solution!, Tier.expert);
      expect(list, isNotEmpty);
      for (final x in list) {
        expect(
          x.clue.holds(s, s.solution!),
          isTrue,
          reason: clueNotation(s, x.clue),
        );
      }
    });

    test('GEN-015 a tier only draws the clue families it has reached', () {
      final s = scene(Tier.expert, 5, traits: true);
      for (final tier in Tier.values) {
        for (final x in listCandidates(s, s.solution!, tier)) {
          expect(x.family.since.index, lessThanOrEqualTo(tier.index));
        }
      }
      final easy = listCandidates(s, s.solution!, Tier.easy);
      expect(easy.every((Candidate x) => x.clue is Is), isTrue);
    });

    test('GEN-021 no statement names the victim or the victim area', () {
      for (var seed = 0; seed < 12; seed++) {
        final s = scene(Tier.expert, seed * 7, traits: true);
        final pos = s.solution!;
        final victimArea = s.cells[pos[s.victim]].area;
        for (final x in listCandidates(s, pos, Tier.expert)) {
          final clue = x.clue;
          expect(clue.subject, isNot(s.victim));
          if (clue is Rel) expect(clue.other, isNot(s.victim));
          if (clue is AloneWith) expect(clue.others, isNot(contains(s.victim)));
          if (clue is Alone || clue is AloneWith || clue is Others) {
            expect(s.cells[pos[clue.subject!]].area, isNot(victimArea));
          }
          if (clue is More) {
            expect(clue.more, isNot(victimArea));
            expect(clue.fewer, isNot(victimArea));
          }
        }
      }
    });

    test('an either-or area clue does not put the true area first', () {
      // The two areas are listed in area order whichever one is true.
      final s = scene(Tier.hard, 9);
      final pos = s.solution!;
      var trueSecond = 0;
      for (final x in listCandidates(s, pos, Tier.hard)) {
        final clue = x.clue;
        if (clue is! Is || clue.test is! InArea) continue;
        final areas = (clue.test as InArea).areas.toList();
        if (areas.length != 2) continue;
        expect(areas[0], lessThan(areas[1]));
        if (areas[1] == s.cells[pos[clue.subject]].area) trueSecond++;
      }
      expect(trueSecond, greaterThan(0));
    });

    test('GEN-019 GEN-020 chosen clues are unique, complete and needed', () {
      for (final tier in <Tier>[Tier.easy, Tier.normal, Tier.hard]) {
        final cfg = config(tier: tier, grids: <(int, int)>[(6, 6)]);
        final rnd = Random(21);
        List<Candidate>? chosen;
        CaseDef? s;
        while (chosen == null) {
          s = drawScene(cfg, rnd);
          if (s != null) chosen = chooseClues(s, cfg, rnd);
        }
        final clues = <Clue>[for (final x in chosen) x.clue];
        final c = s!.copyWith(clues: clues, openings: usedOpenings(s, clues));
        final found = solveExact(c);
        expect(found, hasLength(1));
        expect(found.single, c.solution);
        // The same checks the shipped packs get, minus the tier.
        final wrong = checkShipped(writeCase(c), tier);
        expect(
          wrong == null || wrong.contains('tier') || wrong.contains('logic'),
          isTrue,
          reason: wrong,
        );
      }
    });

    test('GEN-011 a generated liar case has exactly one false statement', () {
      final out = generateCase(
        config(tier: Tier.expert, grids: <(int, int)>[(6, 6)], liar: true),
      );
      expect(out.result, isNotNull);
      final c = out.result!;
      expect(c.liar, isTrue);
      final lies = c.statements
          .where((int i) => !c.clues[i].holds(c, c.solution!))
          .toList();
      expect(lies, hasLength(1));
      expect(describeRules(c).join(), contains('false'));
    });
  });

  group('campaign', () {
    test('GEN-028 every pack has unique ids, titles and seeds', () {
      final ids = <String>{};
      final seeds = <int>{};
      final titles = <String>{};
      var total = 0;
      for (final tier in Tier.values) {
        final slots = campaign(tier);
        expect(slots, isNotEmpty);
        for (final cfg in slots) {
          total++;
          ids.add(cfg.id);
          seeds.add(cfg.seed);
          titles.add('${cfg.setting} ${cfg.titleIndex}');
          expect(cfg.tier, tier);
          expect(cfg.id, startsWith('${tier.name}-'));
          expect(cfg.titleIndex, lessThan(titleCount));
        }
      }
      expect(ids, hasLength(total));
      expect(seeds, hasLength(total));
      expect(titles, hasLength(total));
    });

    test('GEN-033 a tier too large for its share of titles is refused', () {
      expect(titleRound(1), 0);
      expect(titleRound(settings.length), 0);
      expect(titleRound(settings.length + 1), 1);
      expect(() => titleRound(10 * settings.length + 1), throwsStateError);
      for (final tier in Tier.values) {
        for (final cfg in campaign(tier)) {
          // The shipped slots leave the rest of the titles to random cases.
          expect(cfg.titleIndex, lessThan(Tier.values.length * 10));
          expect(
            randomConfig(tier, cfg.seed).titleIndex,
            greaterThanOrEqualTo(Tier.values.length * 10),
          );
        }
      }
    });

    test('GEN-028 every pack beyond the tutorial visits every setting', () {
      for (final tier in Tier.values.skip(1)) {
        final visited = <String>{for (final cfg in campaign(tier)) cfg.setting};
        expect(visited, hasLength(12), reason: tier.name);
      }
    });
  });
}
