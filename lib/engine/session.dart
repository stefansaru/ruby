/// One play-through of a case: where the player has put people so far,
/// who is selected, what a tap does, which placements clash, how each
/// statement stands, whether the case is solved, and what a hint would
/// say. Pure Dart; the screen only draws what this reports.
library;

import 'atoms.dart';
import 'clue.dart';
import 'logic_solver.dart';
import 'model.dart';

/// What the placements so far say about one statement: nothing yet, it
/// fits, or it cannot be true as things stand.
enum ClueMark { open, met, broken }

/// What a tap on a square did.
enum TapOutcome {
  /// The selected person now stands on the square.
  placed,

  /// The person standing there was lifted off and is now selected.
  lifted,

  /// The square cannot hold a person; nothing changed.
  refused,

  /// The case is solved; the board no longer changes.
  ignored,
}

/// What to tell a player who asks for help.
class Hint {
  const Hint(
    this.person,
    this.cell, {
    required this.wrong,
    this.because = const <LogicStep>[],
    this.lie,
  });
  final int person;
  final int cell;

  /// The solver's steps that ruled out squares for [person], in order:
  /// why only [cell] is left. Empty for a wrong placement.
  final List<LogicStep> because;

  /// True: the person is on [cell] and was not there. False: the person
  /// can now be worked out and belongs on [cell].
  final bool wrong;

  /// In a liar case, the index of the false statement the steps rest on
  /// ([LogicResult.lie]).
  final int? lie;
}

class CaseSession {
  CaseSession(this.c)
    : assert(c.solution != null, 'a played case has a certified solution'),
      pos = List<int>.filled(c.people.length, -1);

  final CaseDef c;

  /// Person to square, -1 while not placed.
  final List<int> pos;

  /// The person the next tap on an empty square places.
  int get selected => _selected;
  int _selected = 0;

  // The pieces of each statement, made once: [markOf] runs on every frame.
  final Map<Clue, Atoms> _pieces = Map<Clue, Atoms>.identity();

  // The last hint and the placements it was worked out for.
  Hint? _hint;
  String? _hintFor;

  /// The person standing on [cell], or -1.
  int personAt(int cell) => cell < 0 ? -1 : pos.indexOf(cell);

  void select(int person) {
    RangeError.checkValidIndex(person, pos, 'person');
    _selected = person;
  }

  /// The next person to place: suspects in order, the victim last
  /// (GEN-031). -1 when everyone is placed.
  int get nextWaiting {
    for (var p = 0; p < pos.length; p++) {
      if (p != c.victim && pos[p] < 0) return p;
    }
    return pos[c.victim] < 0 ? c.victim : -1;
  }

  /// A tap on [cell]. A person standing there is lifted and selected,
  /// whoever was selected: nobody is ever replaced by a tap. Otherwise
  /// the selected person is put there and the next waiting person is
  /// selected. Once the case is solved taps change nothing.
  TapOutcome tap(int cell) {
    if (complete && solved) return TapOutcome.ignored;
    final there = personAt(cell);
    if (there >= 0) {
      remove(there);
      _selected = there;
      return TapOutcome.lifted;
    }
    if (!place(_selected, cell)) return TapOutcome.refused;
    final next = nextWaiting;
    if (next >= 0) _selected = next;
    return TapOutcome.placed;
  }

  /// Puts [person] on [cell]. Refused (returns false) when the square
  /// cannot hold a person or someone else is standing on it: nobody is
  /// ever pushed off by a placement. Clashes with other people are
  /// allowed and reported by [conflicts], so the player can see a mistake
  /// instead of being stopped by it.
  bool place(int person, int cell) {
    if (cell < 0 || cell >= c.cells.length || !c.canOccupy(cell)) return false;
    final there = personAt(cell);
    if (there >= 0 && there != person) return false;
    pos[person] = cell;
    return true;
  }

  void remove(int person) => pos[person] = -1;

  /// Back to an empty board, the first suspect selected.
  void clear() {
    pos.fillRange(0, pos.length, -1);
    _selected = nextWaiting;
  }

  /// The extra statements of [person], in the order they are revealed.
  List<Clue> extrasOf(int person) => <Clue>[
    for (final Clue x in c.extras)
      if (x.subject == person) x,
  ];

  /// What [person]'s card shows: their statements, then the first [shown]
  /// of their extras. Empty for the victim, who says nothing.
  List<Clue> statementsOf(int person, {int shown = 0}) => <Clue>[
    for (final Clue x in c.clues)
      if (x.subject == person) x,
    ...extrasOf(person).take(shown < 0 ? 0 : shown),
  ];

  /// How [clue] stands against the placements so far (GEN-036). A
  /// statement stays open while its speaker is not placed, and while it
  /// depends on someone who is not placed yet; it is broken as soon as
  /// the people already placed contradict it.
  ClueMark markOf(Clue clue) {
    final speaker = clue.subject;
    if (speaker != null && pos[speaker] < 0) return ClueMark.open;
    if (complete) {
      return clue.holds(c, pos) ? ClueMark.met : ClueMark.broken;
    }
    final pieces = _pieces.putIfAbsent(
      clue,
      () => Atoms(c, <Clue>[clue], rules: false),
    );
    var waiting = false;
    for (final a in pieces.unary) {
      if (pos[a.person] < 0) {
        waiting = true;
      } else if (!a.test.test(c, pos[a.person])) {
        return ClueMark.broken;
      }
    }
    for (final a in pieces.binary) {
      if (pos[a.p] < 0 || pos[a.q] < 0) {
        waiting = true;
      } else if (!a.ok(pos[a.p], pos[a.q])) {
        return ClueMark.broken;
      }
    }
    // Counts need everyone on the grid.
    final counted =
        pieces.counts.isNotEmpty ||
        pieces.generic.isNotEmpty ||
        pieces.others.isNotEmpty;
    return waiting || counted ? ClueMark.open : ClueMark.met;
  }

  /// How the rule "the victim was alone with one person" stands.
  ClueMark get victimMark {
    final v = c.victim;
    if (pos[v] < 0) return ClueMark.open;
    final area = c.cells[pos[v]].area;
    var company = 0;
    for (var p = 0; p < pos.length; p++) {
      if (p != v && pos[p] >= 0 && c.cells[pos[p]].area == area) company++;
    }
    if (company > 1) return ClueMark.broken;
    if (!complete) return ClueMark.open;
    return company == 1 ? ClueMark.met : ClueMark.broken;
  }

  /// Everyone who shares a row or column with someone else, or touches
  /// someone in a no-touch case.
  Set<int> get conflicts {
    final out = <int>{};
    for (var p = 0; p < pos.length; p++) {
      if (pos[p] < 0) continue;
      for (var q = 0; q < p; q++) {
        if (pos[q] < 0) continue;
        if (c.clash(pos[p], pos[q])) {
          out
            ..add(p)
            ..add(q);
        }
      }
    }
    return out;
  }

  /// The empty squares nobody can be put on any more: those in the row or
  /// column of someone already placed (and, in a no-touch case, those
  /// touching them). The view marks them with a cross.
  Set<int> get crossedOut {
    final placed = <int>[
      for (final x in pos)
        if (x >= 0) x,
    ];
    return <int>{
      for (var x = 0; x < c.cells.length; x++)
        if (c.canOccupy(x) &&
            !placed.contains(x) &&
            placed.any((int y) => c.clash(x, y)))
          x,
    };
  }

  bool get complete => !pos.contains(-1);

  /// Everyone is where the certified solution puts them. A shipped case
  /// has one solution, so this is the same as "obeys every clue".
  bool get solved {
    final answer = c.solution!;
    for (var p = 0; p < pos.length; p++) {
      if (pos[p] != answer[p]) return false;
    }
    return true;
  }

  /// The murderer of the certified solution.
  int get murderer => c.murdererIn(c.solution!);

  /// A wrong placement if there is one, otherwise the next person the
  /// logic solver can place from here, with the steps that explain it.
  /// The victim comes last (GEN-031). Null when the case is solved.
  ///
  /// The answer is worked out once per board: asking again without
  /// moving anyone returns the same hint without solving again.
  Hint? hint() {
    final board = pos.join(',');
    if (_hintFor != board) {
      _hint = _workOutHint();
      _hintFor = board;
    }
    return _hint;
  }

  Hint? _workOutHint() {
    final answer = c.solution!;
    for (var p = 0; p < pos.length; p++) {
      if (pos[p] >= 0 && pos[p] != answer[p]) {
        return Hint(p, pos[p], wrong: true);
      }
    }
    if (complete) return null;
    // Everything placed is right, so the solver may build on it.
    final fixed = <int, int>{
      for (var p = 0; p < pos.length; p++)
        if (pos[p] >= 0) p: pos[p],
    };
    final solving = solveLogic(c, fixed: fixed);
    final steps = solving.steps;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final p = step.person;
      final square = step.placed;
      if (step.technique != Technique.single ||
          p == null ||
          square == null ||
          pos[p] >= 0) {
        continue;
      }
      return Hint(
        p,
        // The solver's own square, not a look-up of the stored answer.
        square,
        wrong: false,
        lie: solving.lie,
        because: <LogicStep>[
          for (final LogicStep s in steps.sublist(0, i))
            if (s.removed.any(((int, int) r) => r.$1 == p)) s,
        ],
      );
    }
    // The solver cannot go on from here. That never happens in a shipped
    // case (GEN-014); for any other case, name the next person from the
    // stated answer so the player is not left without help.
    final p = nextWaiting;
    return Hint(p, answer[p], wrong: false);
  }
}
