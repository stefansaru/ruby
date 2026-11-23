/// Clues broken into the simple pieces both solvers work with.
///
/// A clue such as "she was alone" is, piece by piece, "she was not in the
/// same area as Ben", "...as Cora", and so on. Working on the pieces lets
/// each solver use a few simple routines instead of one per clue type.
/// The split is exact: the pieces together say what the clue says.
library;

import 'clue.dart';
import 'model.dart';

typedef Between = bool Function(int x, int y);

/// [person] stands on a square passing [test].
class UnaryAtom {
  UnaryAtom(this.person, this.test, this.clue);
  final int person;
  final CellTest test;
  final int clue;
}

/// The squares of [p] and [q] satisfy [ok].
class BinaryAtom {
  BinaryAtom(this.p, this.q, this.ok, this.clue);
  final int p;
  final int q;
  final Between ok;
  final int clue;
}

/// Exactly [n] of [people] stand on a square passing [test].
class CountAtom {
  CountAtom(this.people, this.test, this.n, this.clue);
  final List<int> people;
  final CellTest test;
  final int n;
  final int clue;
}

/// Exactly [n] of [people] are in the same area as [subject].
class OthersAtom {
  OthersAtom(this.subject, this.people, this.n, this.clue);
  final int subject;
  final List<int> people;
  final int n;
  final int clue;
}

/// A clue with no simpler pieces; checked whole.
class GenericAtom {
  GenericAtom(this.what, this.clue);
  final Clue what;
  final int clue;

  /// Full placements already found to satisfy the clue (logic solver).
  final List<List<int>> witnesses = <List<int>>[];
}

/// Clue index used for the rule that the victim's area holds exactly two.
const int victimRule = -1;

/// Clue index used for the no-touch case rule.
const int noTouchRule = -2;

class Atoms {
  /// The pieces of [clues] for case [c], plus the victim rule and, when
  /// the case has it, the no-touch rule. Each piece remembers the index of
  /// the clue it came from.
  Atoms(this.c, List<Clue> clues) {
    for (var i = 0; i < clues.length; i++) {
      _expand(clues[i], i);
    }
    final n = c.people.length;
    others.add(OthersAtom(c.victim, _allBut(c.victim), 1, victimRule));
    if (c.noTouch) {
      for (var p = 0; p < n; p++) {
        for (var q = p + 1; q < n; q++) {
          binary.add(
            BinaryAtom(p, q, (int x, int y) => !c.touching(x, y), noTouchRule),
          );
        }
      }
    }
  }

  final CaseDef c;
  final List<UnaryAtom> unary = <UnaryAtom>[];
  final List<BinaryAtom> binary = <BinaryAtom>[];
  final List<CountAtom> counts = <CountAtom>[];
  final List<OthersAtom> others = <OthersAtom>[];
  final List<GenericAtom> generic = <GenericAtom>[];

  List<int> _allBut(int s) => <int>[
    for (var p = 0; p < c.people.length; p++)
      if (p != s) p,
  ];

  bool _sameArea(int x, int y) => c.cells[x].area == c.cells[y].area;
  bool _differentArea(int x, int y) => c.cells[x].area != c.cells[y].area;

  void _expand(Clue clue, int i) {
    final n = c.people.length;
    switch (clue) {
      case Is(:final subject, :final test):
        unary.add(UnaryAtom(subject, test, i));
      case Rel(:final subject, :final other):
        binary.add(
          BinaryAtom(
            subject,
            other,
            (int x, int y) => clue.between(c, x, y),
            i,
          ),
        );
      case Alone(:final subject):
        for (final q in _allBut(subject)) {
          binary.add(BinaryAtom(subject, q, _differentArea, i));
        }
      case AloneWith(:final subject, others: final company):
        for (final q in _allBut(subject)) {
          binary.add(
            BinaryAtom(
              subject,
              q,
              company.contains(q) ? _sameArea : _differentArea,
              i,
            ),
          );
        }
      case Others(:final subject, :final who, :final count):
        others.add(
          OthersAtom(
            subject,
            <int>[
              for (final q in _allBut(subject))
                if (who.matches(c.people[q])) q,
            ],
            count,
            i,
          ),
        );
      case OnlyOne(:final subject, :final test):
        for (var p = 0; p < n; p++) {
          unary.add(UnaryAtom(p, p == subject ? test : Not(test), i));
        }
      case AllOthers(:final subject, :final test):
        for (var p = 0; p < n; p++) {
          unary.add(UnaryAtom(p, p == subject ? Not(test) : test, i));
        }
      case Count(:final test, :final count):
        counts.add(
          CountAtom(<int>[for (var p = 0; p < n; p++) p], test, count, i),
        );
      case Group(:final who, :final test):
        for (var p = 0; p < n; p++) {
          if (who.matches(c.people[p])) unary.add(UnaryAtom(p, test, i));
        }
      case Negated(:final inner):
        if (inner is Rel) {
          binary.add(
            BinaryAtom(
              inner.subject,
              inner.other,
              (int x, int y) => !inner.between(c, x, y),
              i,
            ),
          );
        } else {
          generic.add(GenericAtom(clue, i));
        }
      case More():
        generic.add(GenericAtom(clue, i));
    }
  }
}
