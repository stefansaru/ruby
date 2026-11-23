/// The logic solver: solves a case the way a person does, one named
/// technique at a time, and records every step. It grades difficulty (the
/// hardest technique a case needs) and supplies the explained hints.
///
/// The techniques are listed in docs/Techniques.md, easiest first. The
/// solver always uses the easiest technique that makes progress, so the
/// recorded path is the gentlest one it knows.
library;

import 'atoms.dart';
import 'clue.dart';
import 'model.dart';

enum Technique {
  /// A clue about one person removes the squares it rules out.
  clue(1),

  /// A person has one square left: place them, block their row and column.
  single(1),

  /// A row or column that must hold someone has one person who can be there.
  lastInLine(2),

  /// Every square left for a person lines up with a square: nobody else
  /// can be on it.
  intersection(3),

  /// A clue linking two people: a square is out when the other person has
  /// no square that goes with it.
  pair(3),

  /// Two or three people share as many rows (or columns): nobody else can
  /// be in those lines.
  subset(4),

  /// Counting people in an area or on an object, including the rule that
  /// the victim's area holds exactly two people.
  counting(5),

  /// Suppose a person is on a square and follow it to a contradiction.
  whatIf(8),

  /// One statement is false: test each statement as the lie.
  liarSplit(10);

  const Technique(this.weight);
  final int weight;
}

class LogicStep {
  LogicStep(
    this.technique, {
    this.person,
    this.clue,
    this.placed,
    this.removed = const <(int, int)>[],
  });
  final Technique technique;

  /// The person the step is about, when there is one.
  final int? person;

  /// Index into [CaseDef.clues]; [victimRule] or [noTouchRule] for the
  /// two rules that are not clues.
  final int? clue;

  /// The square the person is placed on, for [Technique.single].
  final int? placed;

  /// (person, square) pairs ruled out by this step.
  final List<(int, int)> removed;
}

class LogicResult {
  LogicResult({
    required this.solved,
    required this.contradiction,
    required this.steps,
    required this.pos,
  });

  /// Everyone is placed and the placement obeys every rule and clue.
  final bool solved;

  /// The clues and placements cannot all be true.
  final bool contradiction;
  final List<LogicStep> steps;

  /// Person to square where decided, otherwise -1.
  final List<int> pos;

  int get score =>
      steps.fold(0, (int sum, LogicStep s) => sum + s.technique.weight);

  Technique get hardest => steps.fold(
    Technique.clue,
    (Technique t, LogicStep s) => s.technique.index > t.index ? s.technique : t,
  );
}

/// Solves [c] by technique. [fixed] holds squares already decided (the
/// player's placements, for a hint). [max] caps the techniques allowed.
LogicResult solveLogic(
  CaseDef c, {
  Technique max = Technique.liarSplit,
  Map<int, int> fixed = const <int, int>{},
}) {
  if (!c.liar) {
    return _Solver(c, c.clues, max, fixed).run();
  }
  final open = List<int>.filled(c.people.length, -1);
  if (max.index < Technique.liarSplit.index) {
    return LogicResult(
      solved: false,
      contradiction: false,
      steps: <LogicStep>[],
      pos: open,
    );
  }
  // One liar: assume each statement in turn is the lie. The case is solved
  // by logic when every assumption but one runs into a contradiction and
  // that one solves.
  LogicResult? winner;
  final steps = <LogicStep>[];
  for (final lie in c.statements) {
    final clues = List<Clue>.of(c.clues);
    clues[lie] = negate(clues[lie]);
    final r = _Solver(c, clues, Technique.whatIf, fixed).run();
    steps.add(
      LogicStep(Technique.liarSplit, person: c.clues[lie].subject, clue: lie),
    );
    if (r.contradiction) continue;
    if (!r.solved || winner != null) {
      return LogicResult(
        solved: false,
        contradiction: false,
        steps: steps,
        pos: open,
      );
    }
    winner = r;
  }
  if (winner == null) {
    return LogicResult(
      solved: false,
      contradiction: true,
      steps: steps,
      pos: open,
    );
  }
  return LogicResult(
    solved: true,
    contradiction: false,
    steps: <LogicStep>[...steps, ...winner.steps],
    pos: winner.pos,
  );
}

class _Stop implements Exception {}

class _Solver {
  _Solver(this.c, this.clues, this.max, Map<int, int> fixed)
    : n = c.people.length,
      atoms = Atoms(c, clues) {
    cand = List<Set<int>>.generate(
      n,
      (int p) => fixed.containsKey(p)
          ? <int>{fixed[p]!}
          : <int>{
              for (var x = 0; x < c.cells.length; x++)
                if (c.canOccupy(x)) x,
            },
    );
    done = List<bool>.filled(n, false);
    _findFullLines();
  }

  final CaseDef c;
  final List<Clue> clues;
  final Technique max;
  final int n;
  final Atoms atoms;
  late List<Set<int>> cand;
  late List<bool> done;

  /// (grid, isRow, index) of every line that must hold a person.
  final List<(int, bool, int)> fullLines = <(int, bool, int)>[];
  final List<LogicStep> steps = <LogicStep>[];

  /// When the people exactly fill the grids, every row of a grid with as
  /// many people as rows holds someone (and likewise columns).
  void _findFullLines() {
    var capacity = 0;
    for (final g in c.grids) {
      capacity += g.rows < g.cols ? g.rows : g.cols;
    }
    if (capacity != n) return;
    for (var g = 0; g < c.grids.length; g++) {
      final d = c.grids[g];
      if (d.rows <= d.cols) {
        for (var r = 0; r < d.rows; r++) {
          fullLines.add((g, true, r));
        }
      }
      if (d.cols <= d.rows) {
        for (var k = 0; k < d.cols; k++) {
          fullLines.add((g, false, k));
        }
      }
    }
  }

  LogicResult run() {
    var contradiction = false;
    try {
      _propagate(max);
    } on _Stop {
      contradiction = true;
    }
    final pos = <int>[
      for (final s in cand)
        if (s.length == 1) s.first else -1,
    ];
    var solved = !contradiction && !pos.contains(-1);
    // A capped run may not have used every clue; the answer still has to
    // obey all of them before it is called solved.
    if (solved && !_obeys(pos)) solved = false;
    return LogicResult(
      solved: solved,
      contradiction: contradiction,
      steps: steps,
      pos: pos,
    );
  }

  bool _obeys(List<int> pos) {
    for (var p = 0; p < n; p++) {
      for (var q = 0; q < p; q++) {
        if (c.conflict(pos[p], pos[q])) return false;
        if (c.noTouch && c.touching(pos[p], pos[q])) return false;
      }
    }
    return c.murdererIn(pos) >= 0 &&
        clues.every((Clue clue) => clue.holds(c, pos));
  }

  void _propagate(Technique limit) {
    bool allowed(Technique t) => limit.index >= t.index;
    final order = <bool Function()>[
      _single,
      _clues,
      if (allowed(Technique.lastInLine)) _lastInLine,
      if (allowed(Technique.intersection)) _intersection,
      if (allowed(Technique.pair)) _pairs,
      if (allowed(Technique.subset)) _subsets,
      if (allowed(Technique.counting)) _counting,
      if (allowed(Technique.counting)) _generic,
      if (allowed(Technique.whatIf)) _whatIf,
    ];
    var progress = true;
    while (progress) {
      progress = false;
      for (final technique in order) {
        if (technique()) {
          progress = true;
          break;
        }
      }
    }
  }

  /// Removes the squares of [p] failing [keep]; throws when none are left.
  List<(int, int)> _filter(int p, bool Function(int x) keep) {
    final out = <(int, int)>[];
    for (final x in cand[p].toList(growable: false)) {
      if (!keep(x)) {
        cand[p].remove(x);
        out.add((p, x));
      }
    }
    if (cand[p].isEmpty) throw _Stop();
    return out;
  }

  bool _add(
    Technique t,
    List<(int, int)> removed, {
    int? person,
    int? clue,
    int? placed,
  }) {
    if (removed.isEmpty && placed == null) return false;
    steps.add(
      LogicStep(
        t,
        person: person,
        clue: clue,
        placed: placed,
        removed: removed,
      ),
    );
    return true;
  }

  bool _clues() {
    for (final u in atoms.unary) {
      final out = _filter(u.person, (int x) => u.test.test(c, x));
      if (_add(Technique.clue, out, person: u.person, clue: u.clue)) {
        return true;
      }
    }
    return false;
  }

  bool _single() {
    for (var p = 0; p < n; p++) {
      if (done[p] || cand[p].length != 1) continue;
      done[p] = true;
      final x = cand[p].first;
      final out = <(int, int)>[];
      for (var q = 0; q < n; q++) {
        if (q != p) out.addAll(_filter(q, (int y) => !c.conflict(x, y)));
      }
      return _add(Technique.single, out, person: p, placed: x);
    }
    return false;
  }

  bool _inLine((int, bool, int) line, int x) {
    final cell = c.cells[x];
    return cell.grid == line.$1 && (line.$2 ? cell.row : cell.col) == line.$3;
  }

  bool _lastInLine() {
    for (final line in fullLines) {
      var holder = -1;
      var holders = 0;
      for (var p = 0; p < n; p++) {
        if (cand[p].any((int x) => _inLine(line, x))) {
          holder = p;
          holders++;
        }
      }
      if (holders == 0) throw _Stop();
      if (holders != 1) continue;
      final out = _filter(holder, (int x) => _inLine(line, x));
      if (_add(Technique.lastInLine, out, person: holder)) return true;
    }
    return false;
  }

  bool _intersection() {
    for (var p = 0; p < n; p++) {
      if (done[p]) continue;
      final out = <(int, int)>[];
      for (var q = 0; q < n; q++) {
        if (q == p) continue;
        out.addAll(
          _filter(q, (int x) => !cand[p].every((int y) => c.conflict(x, y))),
        );
      }
      if (_add(Technique.intersection, out, person: p)) return true;
    }
    return false;
  }

  bool _pairs() {
    for (final b in atoms.binary) {
      final out = <(int, int)>[
        ..._filter(
          b.p,
          (int x) => cand[b.q].any((int y) => !c.conflict(x, y) && b.ok(x, y)),
        ),
        ..._filter(
          b.q,
          (int y) => cand[b.p].any((int x) => !c.conflict(x, y) && b.ok(x, y)),
        ),
      ];
      if (_add(Technique.pair, out, person: b.p, clue: b.clue)) return true;
    }
    return false;
  }

  bool _subsets() {
    final open = <int>[
      for (var p = 0; p < n; p++)
        if (!done[p]) p,
    ];
    bool tryGroup(List<int> group) {
      final grid = c.cells[cand[group.first].first].grid;
      final rows = <int>{};
      final cols = <int>{};
      for (final p in group) {
        for (final x in cand[p]) {
          final cell = c.cells[x];
          if (cell.grid != grid) return false;
          rows.add(cell.row);
          cols.add(cell.col);
        }
      }
      if (rows.length < group.length || cols.length < group.length) {
        throw _Stop();
      }
      final out = <(int, int)>[];
      for (var q = 0; q < n; q++) {
        if (group.contains(q)) continue;
        out.addAll(
          _filter(q, (int x) {
            final cell = c.cells[x];
            if (cell.grid != grid) return true;
            if (rows.length == group.length && rows.contains(cell.row)) {
              return false;
            }
            if (cols.length == group.length && cols.contains(cell.col)) {
              return false;
            }
            return true;
          }),
        );
      }
      return _add(Technique.subset, out, person: group.first);
    }

    for (var i = 0; i < open.length; i++) {
      for (var j = i + 1; j < open.length; j++) {
        if (tryGroup(<int>[open[i], open[j]])) return true;
        for (var k = j + 1; k < open.length; k++) {
          if (tryGroup(<int>[open[i], open[j], open[k]])) return true;
        }
      }
    }
    return false;
  }

  /// Exactly [target] of [people] pass [test]: when enough certainly do,
  /// the rest cannot; when only just enough still can, they all must.
  List<(int, int)> _exactly(
    List<int> people,
    bool Function(int x) test,
    int target,
  ) {
    var sure = 0;
    var possible = 0;
    for (final p in people) {
      if (cand[p].every(test)) sure++;
      if (cand[p].any(test)) possible++;
    }
    if (sure > target || possible < target) throw _Stop();
    final out = <(int, int)>[];
    if (sure == target) {
      for (final p in people) {
        if (!cand[p].every(test)) out.addAll(_filter(p, (int x) => !test(x)));
      }
    } else if (possible == target) {
      for (final p in people) {
        if (cand[p].any(test)) out.addAll(_filter(p, test));
      }
    }
    return out;
  }

  bool _counting() {
    for (final a in atoms.counts) {
      final out = _exactly(a.people, (int x) => a.test.test(c, x), a.n);
      if (_add(Technique.counting, out, clue: a.clue)) return true;
    }
    for (final a in atoms.others) {
      // An area is out for the subject when the right number of the
      // others can no longer be there.
      final out = _filter(a.subject, (int x) {
        final area = c.cells[x].area;
        bool inArea(int y) => c.cells[y].area == area;
        var sure = 0;
        var possible = 0;
        for (final p in a.people) {
          final free = <int>[
            for (final y in cand[p])
              if (!c.conflict(x, y)) y,
          ];
          if (free.isNotEmpty && free.every(inArea)) sure++;
          if (free.any(inArea)) possible++;
        }
        return sure <= a.n && possible >= a.n;
      });
      final areas = <int>{for (final x in cand[a.subject]) c.cells[x].area};
      if (areas.length == 1) {
        out.addAll(
          _exactly(a.people, (int y) => c.cells[y].area == areas.first, a.n),
        );
      }
      if (_add(Technique.counting, out, person: a.subject, clue: a.clue)) {
        return true;
      }
    }
    return false;
  }

  /// Clues with no technique of their own: a square stays only while some
  /// full placement using it satisfies the clue.
  bool _generic() {
    for (final g in atoms.generic) {
      final out = <(int, int)>[];
      for (var p = 0; p < n; p++) {
        out.addAll(_filter(p, (int x) => _supported(g, p, x)));
      }
      if (_add(Technique.counting, out, clue: g.clue)) return true;
    }
    return false;
  }

  bool _supported(GenericAtom g, int person, int square) {
    for (final w in g.witnesses) {
      if (w[person] != square) continue;
      var live = true;
      for (var q = 0; q < n && live; q++) {
        live = cand[q].contains(w[q]);
      }
      if (live) return true;
    }
    final order = <int>[
      for (var p = 0; p < n; p++)
        if (p != person) p,
    ]..sort((int a, int b) => cand[a].length.compareTo(cand[b].length));
    final pos = List<int>.filled(n, -1);
    pos[person] = square;
    var budget = 20000;
    var found = false;
    bool place(int depth) {
      if (budget-- <= 0) return true; // Undecided: keep the square.
      if (depth == order.length) {
        if (!g.what.holds(c, pos)) return false;
        found = true;
        return true;
      }
      final p = order[depth];
      next:
      for (final x in cand[p]) {
        for (var q = 0; q < n; q++) {
          if (pos[q] >= 0 && c.conflict(x, pos[q])) continue next;
        }
        pos[p] = x;
        if (place(depth + 1)) return true;
        pos[p] = -1;
      }
      return false;
    }

    final keep = place(0);
    if (found) g.witnesses.add(List<int>.of(pos));
    return keep;
  }

  bool _whatIf() {
    for (var size = 2; size <= 3; size++) {
      for (var p = 0; p < n; p++) {
        if (cand[p].length != size) continue;
        for (final x in cand[p].toList(growable: false)) {
          final savedCand = cand;
          final savedDone = done;
          final savedSteps = steps.length;
          cand = <Set<int>>[for (final s in savedCand) Set<int>.of(s)];
          cand[p] = <int>{x};
          done = List<bool>.of(savedDone);
          var dead = false;
          try {
            _propagate(Technique.counting);
          } on _Stop {
            dead = true;
          }
          cand = savedCand;
          done = savedDone;
          steps.removeRange(savedSteps, steps.length);
          if (dead) {
            cand[p].remove(x);
            return _add(Technique.whatIf, <(int, int)>[(p, x)], person: p);
          }
        }
      }
    }
    return false;
  }
}
