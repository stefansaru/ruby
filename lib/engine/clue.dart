/// Clue types. Every clue has one exact meaning, given by [Clue.holds];
/// the wording shown to the player is derived from the same object
/// (see wording.dart), so the text and the check cannot drift apart.
library;

import 'model.dart';

/// A yes/no question about one square: "is it in the Kitchen?".
sealed class CellTest {
  const CellTest();
  bool test(CaseDef c, int cell);
}

class InArea extends CellTest {
  const InArea(this.areas);
  final Set<int> areas;
  @override
  bool test(CaseDef c, int cell) => areas.contains(c.cells[cell].area);
}

class OnKind extends CellTest {
  const OnKind(this.kind);
  final int kind;
  @override
  bool test(CaseDef c, int cell) => c.cells[cell].kind == kind;
}

/// Beside = directly above, below, left or right, and in the same area.
class BesideKind extends CellTest {
  const BesideKind(this.kind, {this.exactly});
  final int kind;
  final int? exactly;

  int count(CaseDef c, int cell) {
    var n = 0;
    for (final s in Side.values) {
      final o = c.neighbor(cell, s);
      if (o >= 0 &&
          c.cells[o].area == c.cells[cell].area &&
          c.cells[o].kind == kind) {
        n++;
      }
    }
    return n;
  }

  @override
  bool test(CaseDef c, int cell) {
    final n = count(c, cell);
    return exactly == null ? n > 0 : n == exactly;
  }
}

/// In front of a door or window: on either side of it.
class FrontOf extends CellTest {
  const FrontOf({required this.door});
  final bool door;
  @override
  bool test(CaseDef c, int cell) {
    for (final s in Side.values) {
      final o = c.openingAt(cell, s);
      if (o != null && o.isDoor == door) return true;
    }
    return false;
  }
}

class InRow extends CellTest {
  const InRow(this.row);
  final int row;
  @override
  bool test(CaseDef c, int cell) => c.cells[cell].row == row;
}

class InCol extends CellTest {
  const InCol(this.col);
  final int col;
  @override
  bool test(CaseDef c, int cell) => c.cells[cell].col == col;
}

class InGrid extends CellTest {
  const InGrid(this.grid);
  final int grid;
  @override
  bool test(CaseDef c, int cell) => c.cells[cell].grid == grid;
}

/// On the outline of the grid.
class OnBorder extends CellTest {
  const OnBorder();
  @override
  bool test(CaseDef c, int cell) =>
      Side.values.any((Side s) => c.neighbor(cell, s) < 0);
}

/// A corner of the grid: two outline sides that meet.
class GridCorner extends CellTest {
  const GridCorner();
  @override
  bool test(CaseDef c, int cell) {
    bool out(Side s) => c.neighbor(cell, s) < 0;
    return (out(Side.north) || out(Side.south)) &&
        (out(Side.west) || out(Side.east));
  }
}

/// A corner of its area: two walls that meet.
class AreaCorner extends CellTest {
  const AreaCorner();
  @override
  bool test(CaseDef c, int cell) {
    bool wall(Side s) => c.isWall(cell, s);
    return (wall(Side.north) || wall(Side.south)) &&
        (wall(Side.west) || wall(Side.east));
  }
}

/// Could see an object of this kind: looking straight along the row or
/// column, the first object met is of this kind. Walls stop the view unless
/// they have a door or window; any object stops the view behind it.
class Sees extends CellTest {
  const Sees(this.kind);
  final int kind;
  @override
  bool test(CaseDef c, int cell) {
    for (final s in Side.values) {
      var at = cell;
      while (true) {
        final next = c.neighbor(at, s);
        if (next < 0) break;
        if (c.isWall(at, s) && c.openingAt(at, s) == null) break;
        final k = c.cells[next].kind;
        if (k == kind) return true;
        if (k >= 0) break;
        at = next;
      }
    }
    return false;
  }
}

/// An object of this kind is somewhere in the same row (or column).
class LineHas extends CellTest {
  const LineHas(this.kind, {required this.row});
  final int kind;
  final bool row;
  @override
  bool test(CaseDef c, int cell) {
    final me = c.cells[cell];
    for (final o in c.cells) {
      if (o.grid != me.grid || o.kind != kind || o.index == cell) continue;
      if (row ? o.row == me.row : o.col == me.col) return true;
    }
    return false;
  }
}

class Not extends CellTest {
  const Not(this.inner);
  final CellTest inner;
  @override
  bool test(CaseDef c, int cell) => !inner.test(c, cell);
}

/// Which people a counting clue talks about.
class Selector {
  const Selector.any() : gender = null, trait = null, negate = false;
  const Selector.gender(Gender this.gender) : trait = null, negate = false;
  const Selector.trait(String this.trait, {this.negate = false})
    : gender = null;

  final Gender? gender;
  final String? trait;
  final bool negate;

  bool matches(Person p) {
    if (gender != null) return p.gender == gender;
    if (trait != null) return p.traits.contains(trait) != negate;
    return true;
  }
}

/// How two people stand relative to each other.
enum RelKind {
  /// Direction: [Rel.a] is the row sign, [Rel.b] the column sign
  /// (-1 above/left, 1 below/right, 0 any). Same grid.
  direction,

  /// Exact offset: subject row - other row == a, column likewise;
  /// null leaves that axis free. Same grid.
  offset,
  diagonal,
  sameArea,
  notSameArea,
  sameGrid,

  /// Same row and column, on different grids.
  samePosition,

  /// Exactly [Rel.a] steps apart, counting rows plus columns. Same grid.
  distance,
}

sealed class Clue {
  const Clue();

  /// The person who makes the statement; null for a general clue.
  int? get subject;

  bool holds(CaseDef c, List<int> pos);
}

/// "[subject] was ...": a statement about the square the subject stood on.
class Is extends Clue {
  const Is(this.subject, this.test);
  @override
  final int subject;
  final CellTest test;
  @override
  bool holds(CaseDef c, List<int> pos) => test.test(c, pos[subject]);
}

class Rel extends Clue {
  const Rel(this.subject, this.other, this.kind, {this.a, this.b});
  @override
  final int subject;
  final int other;
  final RelKind kind;
  final int? a;
  final int? b;

  /// The relation between a square for the subject and one for the other.
  bool between(CaseDef c, int x, int y) {
    final s = c.cells[x];
    final o = c.cells[y];
    final same = s.grid == o.grid;
    final dr = s.row - o.row;
    final dc = s.col - o.col;
    switch (kind) {
      case RelKind.direction:
        return same && (a == 0 || dr.sign == a) && (b == 0 || dc.sign == b);
      case RelKind.offset:
        return same && (a == null || dr == a) && (b == null || dc == b);
      case RelKind.diagonal:
        return same && dr != 0 && dr.abs() == dc.abs();
      case RelKind.sameArea:
        return s.area == o.area;
      case RelKind.notSameArea:
        return s.area != o.area;
      case RelKind.sameGrid:
        return same;
      case RelKind.samePosition:
        return !same && dr == 0 && dc == 0;
      case RelKind.distance:
        return same && dr.abs() + dc.abs() == a;
    }
  }

  @override
  bool holds(CaseDef c, List<int> pos) => between(c, pos[subject], pos[other]);
}

/// Nobody else was in the subject's area, not even the victim.
class Alone extends Clue {
  const Alone(this.subject);
  @override
  final int subject;
  @override
  bool holds(CaseDef c, List<int> pos) {
    final area = c.cells[pos[subject]].area;
    for (var p = 0; p < pos.length; p++) {
      if (p != subject && c.cells[pos[p]].area == area) return false;
    }
    return true;
  }
}

/// Exactly the subject and [others] were in the subject's area.
class AloneWith extends Clue {
  const AloneWith(this.subject, this.others);
  @override
  final int subject;
  final List<int> others;
  @override
  bool holds(CaseDef c, List<int> pos) {
    final area = c.cells[pos[subject]].area;
    for (var p = 0; p < pos.length; p++) {
      if (p == subject) continue;
      if ((c.cells[pos[p]].area == area) != others.contains(p)) return false;
    }
    return true;
  }
}

/// Exactly [count] other people matching [who] were in the subject's area.
class Others extends Clue {
  const Others(this.subject, this.who, this.count);
  @override
  final int subject;
  final Selector who;
  final int count;
  @override
  bool holds(CaseDef c, List<int> pos) {
    final area = c.cells[pos[subject]].area;
    var n = 0;
    for (var p = 0; p < pos.length; p++) {
      if (p != subject &&
          who.matches(c.people[p]) &&
          c.cells[pos[p]].area == area) {
        n++;
      }
    }
    return n == count;
  }
}

/// The subject was the only person for whom [test] is true.
class OnlyOne extends Clue {
  const OnlyOne(this.subject, this.test);
  @override
  final int subject;
  final CellTest test;
  @override
  bool holds(CaseDef c, List<int> pos) {
    for (var p = 0; p < pos.length; p++) {
      if (test.test(c, pos[p]) != (p == subject)) return false;
    }
    return true;
  }
}

/// [test] is true for everyone except the subject.
class AllOthers extends Clue {
  const AllOthers(this.subject, this.test);
  @override
  final int subject;
  final CellTest test;
  @override
  bool holds(CaseDef c, List<int> pos) {
    for (var p = 0; p < pos.length; p++) {
      if (test.test(c, pos[p]) == (p == subject)) return false;
    }
    return true;
  }
}

/// General clue: exactly [count] people satisfy [test].
class Count extends Clue {
  const Count(this.test, this.count);
  final CellTest test;
  final int count;
  @override
  int? get subject => null;
  @override
  bool holds(CaseDef c, List<int> pos) =>
      pos.where((int x) => test.test(c, x)).length == count;
}

/// General clue: more people were in area [more] than in area [fewer].
class More extends Clue {
  const More(this.more, this.fewer);
  final int more;
  final int fewer;
  @override
  int? get subject => null;
  @override
  bool holds(CaseDef c, List<int> pos) {
    var n = 0;
    for (final x in pos) {
      final area = c.cells[x].area;
      if (area == more) n++;
      if (area == fewer) n--;
    }
    return n > 0;
  }
}

/// General clue: [test] is true for every person matching [who].
class Group extends Clue {
  const Group(this.who, this.test);
  final Selector who;
  final CellTest test;
  @override
  int? get subject => null;
  @override
  bool holds(CaseDef c, List<int> pos) {
    for (var p = 0; p < pos.length; p++) {
      if (who.matches(c.people[p]) && !test.test(c, pos[p])) return false;
    }
    return true;
  }
}

/// A statement known to be false; used when a case has one liar.
class Negated extends Clue {
  const Negated(this.inner);
  final Clue inner;
  @override
  int? get subject => inner.subject;
  @override
  bool holds(CaseDef c, List<int> pos) => !inner.holds(c, pos);
}

/// The opposite of [clue], kept as simple as possible.
Clue negate(Clue clue) => switch (clue) {
  Is(:final int subject, :final CellTest test) => Is(
    subject,
    test is Not ? test.inner : Not(test),
  ),
  Negated(:final Clue inner) => inner,
  _ => Negated(clue),
};
