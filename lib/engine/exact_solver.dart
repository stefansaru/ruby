/// The exact solver: finds every placement that obeys the rules and clues.
/// It answers one question for the generator and the tests: does this case
/// have exactly one solution? It does not explain anything; the logic solver
/// (logic_solver.dart) does that.
library;

import 'atoms.dart';
import 'clue.dart';
import 'model.dart';

/// Up to [limit] distinct solutions of [c]. A case is valid when the result
/// has exactly one entry with `limit: 2`.
List<List<int>> solveExact(CaseDef c, {int limit = 2}) {
  final found = <List<int>>[];
  if (!c.liar) {
    _search(c, c.clues, limit, found);
    return found;
  }
  // One liar: try each statement as the false one. A placement breaks
  // exactly one statement under exactly one of these hypotheses, so the
  // hypotheses never produce the same solution twice.
  for (final lie in c.statements) {
    final clues = List<Clue>.of(c.clues);
    clues[lie] = negate(clues[lie]);
    _search(c, clues, limit, found);
    if (found.length >= limit) break;
  }
  return found;
}

void _search(CaseDef c, List<Clue> clues, int limit, List<List<int>> found) {
  final n = c.people.length;
  final atoms = Atoms(c, clues);

  // Squares each person could stand on, from the pieces about them alone.
  final start = List<List<int>>.generate(n, (int p) {
    final tests = <CellTest>[
      for (final u in atoms.unary)
        if (u.person == p) u.test,
    ];
    return <int>[
      for (var x = 0; x < c.cells.length; x++)
        if (c.canOccupy(x) && tests.every((CellTest t) => t.test(c, x))) x,
    ];
  });

  // The pieces linking each pair of people, seen from either side.
  final links = List<List<List<Between>>>.generate(
    n,
    (_) => List<List<Between>>.generate(n, (_) => <Between>[]),
  );
  for (final b in atoms.binary) {
    links[b.p][b.q].add(b.ok);
    links[b.q][b.p].add((int y, int x) => b.ok(x, y));
  }

  final pos = List<int>.filled(n, -1);

  /// False as soon as a counting piece can no longer come out right;
  /// with everyone placed, true only when every piece holds.
  bool countsPossible(bool complete) {
    for (final a in atoms.counts) {
      var yes = 0;
      for (final p in a.people) {
        if (pos[p] >= 0 && a.test.test(c, pos[p])) yes++;
      }
      if (yes > a.n || (complete && yes != a.n)) return false;
    }
    for (final a in atoms.others) {
      if (pos[a.subject] < 0) continue;
      final area = c.cells[pos[a.subject]].area;
      var yes = 0;
      for (final p in a.people) {
        if (pos[p] >= 0 && c.cells[pos[p]].area == area) yes++;
      }
      if (yes > a.n || (complete && yes != a.n)) return false;
    }
    if (complete) {
      for (final g in atoms.generic) {
        if (!g.what.holds(c, pos)) return false;
      }
    }
    return true;
  }

  void place(int placed, List<List<int>> live) {
    if (found.length >= limit) return;
    if (placed == n) {
      if (countsPossible(true)) found.add(List<int>.of(pos));
      return;
    }
    // The person with the fewest squares left goes next.
    var p = -1;
    for (var q = 0; q < n; q++) {
      if (pos[q] < 0 && (p < 0 || live[q].length < live[p].length)) p = q;
    }
    for (final x in live[p]) {
      pos[p] = x;
      if (countsPossible(false)) {
        final next = List<List<int>>.of(live);
        var dead = false;
        for (var q = 0; q < n && !dead; q++) {
          if (pos[q] >= 0) continue;
          final rules = links[p][q];
          next[q] = <int>[
            for (final y in live[q])
              if (!c.conflict(x, y) && rules.every((Between ok) => ok(x, y))) y,
          ];
          dead = next[q].isEmpty;
        }
        if (!dead) place(placed + 1, next);
      }
      pos[p] = -1;
      if (found.length >= limit) return;
    }
  }

  if (start.every((List<int> s) => s.isNotEmpty)) place(0, start);
}
