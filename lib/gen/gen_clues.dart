/// Chooses the clues for a drawn scene: lists every true statement the tier
/// allows, then adds statements until exactly one placement fits, then
/// drops every statement the case does not need.
library;

import 'dart:math';

import '../engine/case_text.dart';
import '../engine/clue.dart';
import '../engine/exact_solver.dart';
import '../engine/model.dart';
import 'gen_config.dart';

/// A clue family, the tier it first appears in and how often it is drawn.
enum Family {
  area(Tier.tutorial, 3),
  on(Tier.tutorial, 3),
  beside(Tier.tutorial, 3),
  rowCol(Tier.tutorial, 1),
  corner(Tier.easy, 1),
  notTest(Tier.normal, 2),
  front(Tier.normal, 2),
  direction(Tier.normal, 3),
  offset(Tier.normal, 2),
  together(Tier.normal, 2),
  alone(Tier.normal, 2),
  border(Tier.normal, 1),
  areaCorner(Tier.normal, 1),
  line(Tier.normal, 2),
  only(Tier.normal, 2),
  aloneWith(Tier.hard, 2),
  others(Tier.hard, 3),
  diagonal(Tier.hard, 2),
  count(Tier.hard, 2),
  besideExactly(Tier.hard, 1),
  eitherArea(Tier.hard, 3),
  apart(Tier.hard, 2),
  grid(Tier.hard, 2),
  samePosition(Tier.hard, 2),
  group(Tier.hard, 2),
  sees(Tier.expert, 3),
  distance(Tier.expert, 2),
  more(Tier.expert, 2);

  const Family(this.since, this.weight);
  final Tier since;
  final int weight;
}

class Candidate {
  Candidate(this.clue, this.family);
  final Clue clue;
  final Family family;
}

/// Every statement that is true in [pos] and allowed in [tier].
List<Candidate> listCandidates(CaseDef c, List<int> pos, Tier tier) {
  final out = <Candidate>[];
  void add(Family f, Clue clue) {
    if (f.since.index <= tier.index && clue.holds(c, pos)) {
      out.add(Candidate(clue, f));
    }
  }

  final n = c.people.length;
  final victim = c.victim;
  final victimArea = c.cells[pos[victim]].area;
  final multi = c.grids.length > 1;
  final hasDoor = c.openings.any((Opening o) => o.isDoor);
  final hasWindow = c.openings.any((Opening o) => !o.isDoor);
  final traits = <String>{for (final Person p in c.people) ...p.traits};
  final selectors = <Selector>[
    const Selector.any(),
    const Selector.gender(Gender.male),
    const Selector.gender(Gender.female),
    for (final String t in traits) Selector.trait(t),
  ];

  for (var p = 0; p < n; p++) {
    if (p == victim) continue;
    final cell = c.cells[pos[p]];
    add(Family.area, Is(p, InArea(<int>{cell.area})));
    for (var a = 0; a < c.areas.length; a++) {
      if (a == cell.area) continue;
      // Listed in area order, so the true one is not always first.
      add(
        Family.eitherArea,
        Is(
          p,
          InArea(a < cell.area ? <int>{a, cell.area} : <int>{cell.area, a}),
        ),
      );
      add(Family.notTest, Is(p, Not(InArea(<int>{a}))));
    }
    for (var k = 0; k < c.kinds.length; k++) {
      if (c.kinds[k].canOccupy) {
        add(Family.on, Is(p, OnKind(k)));
        add(Family.notTest, Is(p, Not(OnKind(k))));
        add(Family.only, OnlyOne(p, OnKind(k)));
      }
      add(Family.beside, Is(p, BesideKind(k)));
      add(Family.notTest, Is(p, Not(BesideKind(k))));
      add(Family.besideExactly, Is(p, BesideKind(k, exactly: 2)));
      add(Family.only, OnlyOne(p, BesideKind(k)));
      add(Family.line, Is(p, LineHas(k, row: true)));
      add(Family.line, Is(p, LineHas(k, row: false)));
      add(Family.sees, Is(p, Sees(k)));
      add(Family.sees, Is(p, Not(Sees(k))));
    }
    add(Family.rowCol, Is(p, InRow(cell.row)));
    add(Family.rowCol, Is(p, InCol(cell.col)));
    add(Family.corner, Is(p, const GridCorner()));
    add(Family.border, Is(p, const OnBorder()));
    add(Family.border, Is(p, const Not(OnBorder())));
    add(Family.areaCorner, Is(p, const AreaCorner()));
    if (hasDoor) add(Family.front, Is(p, const FrontOf(door: true)));
    if (hasWindow) add(Family.front, Is(p, const FrontOf(door: false)));
    if (multi) add(Family.grid, Is(p, InGrid(cell.grid)));

    // Statements about company never mention the victim's area: they
    // would name the murderer outright.
    if (cell.area != victimArea) {
      add(Family.alone, Alone(p));
      final company = <int>[
        for (var q = 0; q < n; q++)
          if (q != p && c.cells[pos[q]].area == cell.area) q,
      ];
      if (company.isNotEmpty && company.length <= 2) {
        add(Family.aloneWith, AloneWith(p, company));
      }
      for (final who in selectors) {
        for (var count = 0; count <= 3; count++) {
          if (count == 0 && who.gender == null) continue;
          add(Family.others, Others(p, who, count));
        }
      }
    }

    for (var q = 0; q < n; q++) {
      if (q == p || q == victim) continue;
      final other = c.cells[pos[q]];
      if (cell.area != victimArea) {
        add(Family.together, Rel(p, q, RelKind.sameArea));
      }
      add(Family.apart, Rel(p, q, RelKind.notSameArea));
      if (multi) {
        add(Family.grid, Rel(p, q, RelKind.sameGrid));
        add(Family.samePosition, Rel(p, q, RelKind.samePosition));
      }
      if (cell.grid != other.grid) continue;
      final dr = cell.row - other.row;
      final dc = cell.col - other.col;
      add(Family.direction, Rel(p, q, RelKind.direction, a: dr.sign, b: 0));
      add(Family.direction, Rel(p, q, RelKind.direction, a: 0, b: dc.sign));
      add(
        Family.direction,
        Rel(p, q, RelKind.direction, a: dr.sign, b: dc.sign),
      );
      if (dr.abs() <= 3) add(Family.offset, Rel(p, q, RelKind.offset, a: dr));
      if (dc.abs() <= 3) add(Family.offset, Rel(p, q, RelKind.offset, b: dc));
      add(Family.diagonal, Rel(p, q, RelKind.diagonal));
      add(Family.distance, Rel(p, q, RelKind.distance, a: dr.abs() + dc.abs()));
    }
  }

  // General clues.
  for (var k = 0; k < c.kinds.length; k++) {
    if (!c.kinds[k].canOccupy) continue;
    final on = pos.where((int x) => c.cells[x].kind == k).length;
    add(Family.count, Count(OnKind(k), on));
  }
  for (var a = 0; a < c.areas.length; a++) {
    if (a == victimArea) continue;
    for (var b = 0; b < c.areas.length; b++) {
      if (b != a && b != victimArea) add(Family.more, More(a, b));
    }
  }
  for (final who in selectors.skip(1)) {
    final members = c.people.where(who.matches).length;
    if (members < 2 || members > n - 2) continue;
    add(Family.group, Group(who, const OnBorder()));
    add(Family.group, Group(who, const Not(OnBorder())));
    for (var k = 0; k < c.kinds.length; k++) {
      if (c.kinds[k].canOccupy) add(Family.group, Group(who, OnKind(k)));
      add(Family.group, Group(who, BesideKind(k)));
    }
  }
  return out;
}

/// A false statement for the liar: something that would be true on
/// another square.
Candidate? _drawLie(CaseDef c, List<int> pos, int liar, Random rnd) {
  final cell = c.cells[pos[liar]];
  final lies = <Candidate>[
    for (var a = 0; a < c.areas.length; a++)
      if (a != cell.area) Candidate(Is(liar, InArea(<int>{a})), Family.area),
    for (var k = 0; k < c.kinds.length; k++) ...<Candidate>[
      if (c.kinds[k].canOccupy && cell.kind != k)
        Candidate(Is(liar, OnKind(k)), Family.on),
      if (!BesideKind(k).test(c, cell.index))
        Candidate(Is(liar, BesideKind(k)), Family.beside),
    ],
  ];
  return lies.isEmpty ? null : lies[rnd.nextInt(lies.length)];
}

/// The clues for [scene], or null when no list makes it unique.
/// The scene's stated solution is the one that stays.
List<Candidate>? chooseClues(CaseDef scene, GenConfig cfg, Random rnd) {
  final c = scene;
  final pos = c.solution!;
  final n = c.people.length;
  final pool = listCandidates(c, pos, cfg.tier)..shuffle(rnd);
  final perPerson = cfg.tier.index >= Tier.hard.index ? 3 : 2;
  final chosen = <Candidate>[];
  final used = <String>{};

  int speaks(int p) =>
      chosen.where((Candidate x) => x.clue.subject == p).length;
  bool allowed(Candidate x) {
    if (used.contains(clueNotation(c, x.clue))) return false;
    final s = x.clue.subject;
    if (s == null) {
      return chosen.where((Candidate y) => y.clue.subject == null).length < 2;
    }
    if (speaks(s) >= perPerson) return false;
    // A row and a column together would simply name the square.
    return x.family != Family.rowCol ||
        !chosen.any(
          (Candidate y) => y.clue.subject == s && y.family == Family.rowCol,
        );
  }

  void take(Candidate x) {
    chosen.add(x);
    used.add(clueNotation(c, x.clue));
  }

  Candidate? draw(List<Candidate> from, int Function(Candidate) weight) {
    var total = 0;
    for (final x in from) {
      total += weight(x);
    }
    if (total == 0) return null;
    var roll = rnd.nextInt(total);
    for (final x in from) {
      roll -= weight(x);
      if (roll < 0) return x;
    }
    return null;
  }

  // The liar's false statement goes in first.
  if (cfg.liar) {
    final lie = _drawLie(c, pos, rnd.nextInt(n - 1), rnd);
    if (lie == null) return null;
    take(lie);
  }
  // Everyone says one thing.
  for (var p = 0; p < n; p++) {
    if (p == c.victim || speaks(p) > 0) continue;
    final x = draw(
      pool.where((Candidate x) => x.clue.subject == p && allowed(x)).toList(),
      (Candidate x) => x.family.weight,
    );
    if (x == null) return null;
    take(x);
  }

  CaseDef withClues(List<Candidate> list) => c.copyWith(
    clues: <Clue>[for (final Candidate x in list) x.clue],
    liar: cfg.liar,
  );
  bool same(List<int> a) {
    for (var p = 0; p < n; p++) {
      if (a[p] != pos[p]) return false;
    }
    return true;
  }

  // Add the statement that rules out most of the other placements, until
  // none is left.
  for (var round = 0; round < 40; round++) {
    final found = solveExact(withClues(chosen), limit: 40);
    final rivals = found.where((List<int> a) => !same(a)).toList();
    if (found.length < 40 && found.length == rivals.length) {
      return null; // The answer itself was ruled out.
    }
    if (rivals.isEmpty) break;
    if (round == 39) return null;
    final open = pool.where(allowed).toList();
    final kills = <Candidate, int>{
      for (final Candidate x in open)
        x: rivals.where((List<int> a) => !x.clue.holds(c, a)).length,
    };
    final x = draw(open, (Candidate x) {
      final k = kills[x]!;
      return k * k * x.family.weight;
    });
    if (x == null) return null;
    take(x);
  }

  // Drop what is not needed, keeping one statement per suspect.
  for (final x in List<Candidate>.of(chosen)..shuffle(rnd)) {
    final s = x.clue.subject;
    if (s != null && speaks(s) <= 1) continue;
    final without = List<Candidate>.of(chosen)..remove(x);
    final found = solveExact(withClues(without));
    if (found.length == 1 && same(found.first)) chosen.remove(x);
  }

  // Suspects in order, general clues last.
  final ordered = List<Candidate>.of(chosen);
  int key(Candidate x) => x.clue.subject ?? n;
  final index = <Candidate, int>{
    for (var i = 0; i < ordered.length; i++) ordered[i]: i,
  };
  ordered.sort((Candidate a, Candidate b) {
    final byPerson = key(a).compareTo(key(b));
    return byPerson != 0 ? byPerson : index[a]!.compareTo(index[b]!);
  });
  return ordered;
}
