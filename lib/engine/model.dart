/// The case model: grids, areas, objects, people. Pure Dart, no Flutter.
///
/// Coordinates are 0-based here. Players and the case text format see
/// 1-based rows (1 at the top) and lettered columns (A on the left).
library;

import 'clue.dart';

enum Gender { male, female }

enum Side { north, east, south, west }

/// A person in a case. Exactly one person per case is the victim.
class Person {
  const Person({
    required this.id,
    required this.name,
    required this.gender,
    this.traits = const <String>{},
    this.isVictim = false,
  });

  /// One character, unique in the case; what a token shows.
  final String id;
  final String name;
  final Gender gender;
  final Set<String> traits;
  final bool isVictim;
}

/// A kind of object ("chair", "tree"). A person can stand on a square
/// holding an object only when [canOccupy] is true.
class ObjectKind {
  const ObjectKind(this.code, this.name, {required this.canOccupy});
  final String code;
  final String name;
  final bool canOccupy;
}

class AreaDef {
  const AreaDef(this.code, this.name);
  final String code;
  final String name;
}

/// One usable square. Squares cut out of an irregular grid do not exist.
class Cell {
  const Cell({
    required this.index,
    required this.grid,
    required this.row,
    required this.col,
    required this.area,
    required this.kind,
    required this.instance,
  });
  final int index;
  final int grid;
  final int row;
  final int col;
  final int area;

  /// Index into [CaseDef.kinds], or -1 for bare floor.
  final int kind;

  /// Squares of the same kind and instance that touch are one drawn object.
  final String instance;
}

/// A door or window on one side of a square.
class Opening {
  const Opening(this.cell, this.side, {required this.isDoor});
  final int cell;
  final Side side;
  final bool isDoor;
}

/// "C" for the third column: columns are lettered, rows are numbered.
String colLabel(int col) => String.fromCharCode(65 + col);

/// Ids of cases made on request begin with this; shipped ids never do.
const String randomIdPrefix = 'random-';

bool isRandomId(String caseId) => caseId.startsWith(randomIdPrefix);

class GridDef {
  const GridDef(this.name, this.rows, this.cols, this.cellAt);

  /// As stored in the case text: one word, `_` for a space.
  final String name;
  final int rows;
  final int cols;

  /// The name as a player reads it.
  String get label => name.replaceAll('_', ' ');

  /// One person per row and column: the shorter side.
  int get capacity => rows < cols ? rows : cols;

  /// `[row][col]` to cell index, -1 where the grid has no square.
  final List<List<int>> cellAt;
}

/// A complete case: the scene, the cast, the clues and the certified answer.
class CaseDef {
  CaseDef({
    required this.id,
    required this.title,
    required this.setting,
    required this.grids,
    required this.areas,
    required this.kinds,
    required this.cells,
    required this.openings,
    required this.people,
    required this.clues,
    this.extras = const <Clue>[],
    this.liar = false,
    this.noTouch = false,
    this.solution,
  }) {
    _neighbor = List<List<int>>.generate(cells.length, (int i) {
      final c = cells[i];
      final g = grids[c.grid];
      int at(int r, int k) =>
          (r < 0 || k < 0 || r >= g.rows || k >= g.cols) ? -1 : g.cellAt[r][k];
      return <int>[
        at(c.row - 1, c.col),
        at(c.row, c.col + 1),
        at(c.row + 1, c.col),
        at(c.row, c.col - 1),
      ];
    });
  }

  final String id;
  final String title;
  final String setting;
  final List<GridDef> grids;
  final List<AreaDef> areas;
  final List<ObjectKind> kinds;
  final List<Cell> cells;
  final List<Opening> openings;
  final List<Person> people;
  final List<Clue> clues;

  /// Extra true statements a player can ask for (GEN-035). The case is
  /// complete without them: the solvers and the rules never read them.
  final List<Clue> extras;

  /// Case rule: exactly one personal statement is false.
  final bool liar;

  /// Case rule: no two people touch, not even diagonally.
  final bool noTouch;

  /// Person index to cell index.
  final List<int>? solution;

  late final List<List<int>> _neighbor;

  int get victim => people.indexWhere((Person p) => p.isVictim);

  /// How many people the grids can hold.
  int get capacity => grids.fold(0, (int sum, GridDef g) => sum + g.capacity);

  /// The people fill the grids, so every row of a grid that is not taller
  /// than wide holds someone, and every column of one not wider than tall.
  bool get isFull => people.length == capacity;

  /// The same scene and cast with different clues or rules.
  CaseDef copyWith({
    List<Clue>? clues,
    List<Clue>? extras,
    List<Opening>? openings,
    bool? liar,
    bool? noTouch,
    List<int>? solution,
    String? id,
    String? title,
  }) => CaseDef(
    id: id ?? this.id,
    title: title ?? this.title,
    setting: setting,
    grids: grids,
    areas: areas,
    kinds: kinds,
    cells: cells,
    openings: openings ?? this.openings,
    people: people,
    clues: clues ?? this.clues,
    extras: extras ?? this.extras,
    liar: liar ?? this.liar,
    noTouch: noTouch ?? this.noTouch,
    solution: solution ?? this.solution,
  );

  /// The square on [side] of [cell], or -1 at the outline.
  int neighbor(int cell, Side side) => _neighbor[cell][side.index];

  bool canOccupy(int cell) {
    final k = cells[cell].kind;
    return k < 0 || kinds[k].canOccupy;
  }

  /// True when two people could not both stand on these squares.
  bool conflict(int a, int b) {
    if (a == b) return true;
    final x = cells[a];
    final y = cells[b];
    return x.grid == y.grid && (x.row == y.row || x.col == y.col);
  }

  /// True when two people on these squares break a placement rule of this
  /// case: the same row or column, or touching in a no-touch case.
  bool clash(int a, int b) => conflict(a, b) || (noTouch && touching(a, b));

  bool touching(int a, int b) {
    final x = cells[a];
    final y = cells[b];
    return x.grid == y.grid &&
        (x.row - y.row).abs() <= 1 &&
        (x.col - y.col).abs() <= 1;
  }

  /// A wall: the outline of the grid or the border between two areas.
  bool isWall(int cell, Side side) {
    final n = neighbor(cell, side);
    return n < 0 || cells[n].area != cells[cell].area;
  }

  /// The opening on this side of this square, seen from either side.
  Opening? openingAt(int cell, Side side) {
    final n = neighbor(cell, side);
    final back = Side.values[(side.index + 2) % 4];
    for (final o in openings) {
      if (o.cell == cell && o.side == side) return o;
      if (n >= 0 && o.cell == n && o.side == back) return o;
    }
    return null;
  }

  /// The murderer in [pos]: the one other person in the victim's area,
  /// or -1 when the victim is alone or has more than one companion.
  int murdererIn(List<int> pos) {
    final v = victim;
    final area = cells[pos[v]].area;
    var found = -1;
    for (var p = 0; p < people.length; p++) {
      if (p == v || cells[pos[p]].area != area) continue;
      if (found >= 0) return -1;
      found = p;
    }
    return found;
  }

  /// The statements a liar could have made: every clue with a speaker.
  List<int> get statements => <int>[
    for (int i = 0; i < clues.length; i++)
      if (clues[i].subject != null) i,
  ];

  /// Checks the placement rules and every clue against a full placement.
  /// Returns null when it is a valid answer, otherwise the reason it is not.
  String? check(List<int> pos) {
    for (var p = 0; p < people.length; p++) {
      if (!canOccupy(pos[p])) return '${people[p].name} is on a blocked square';
      for (var q = 0; q < p; q++) {
        if (conflict(pos[p], pos[q])) {
          return '${people[p].name} and ${people[q].name} share a line';
        }
        if (noTouch && touching(pos[p], pos[q])) {
          return '${people[p].name} and ${people[q].name} touch';
        }
      }
    }
    if (murdererIn(pos) < 0) return 'the victim is not alone with one person';
    var broken = 0;
    for (final clue in clues) {
      if (clue.holds(this, pos)) continue;
      if (!liar || clue.subject == null) return 'a clue is broken';
      broken++;
    }
    if (liar && broken != 1) return 'exactly one statement must be false';
    return null;
  }

  /// "B3", and with two grids "B3 (Upper Deck)": both grids have a B3.
  String placeLabel(int cell) => grids.length > 1
      ? '${cellLabel(cell)} (${grids[cells[cell].grid].label})'
      : cellLabel(cell);

  /// "B3": lettered column, numbered row.
  String cellLabel(int cell) {
    final c = cells[cell];
    return '${colLabel(c.col)}${c.row + 1}';
  }
}
