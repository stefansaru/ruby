// A second witness for the rules.
//
// This file re-implements what a case means: the placement rules and the
// meaning of every clue. It is written from docs/GameRules.md (sections 2
// to 5) and reads the case text itself. It shares no code with lib/engine:
// no CaseDef, no Clue, no Atoms, no solver. Where the engine and this file
// disagree, one of them is wrong, and the tests that compare them fail.
//
// Keep it that way: never import anything from package:ruby here, and
// never "fix" a disagreement by copying the engine's logic into this file.
// Go back to the rules document and decide which side misread it.

/// A square: grid, row and column, all counted from 0.
typedef Sq = (int g, int r, int c);

class OraclePerson {
  OraclePerson(
    this.id,
    this.name,
    this.male,
    this.traits, {
    required this.victim,
  });
  final String id;
  final String name;
  final bool male;
  final Set<String> traits;
  final bool victim;
}

class OracleSquare {
  OracleSquare(this.area, this.kind);
  final String area;

  /// The kind code of the object on the square, or null for bare floor.
  final String? kind;
}

typedef Truth = bool Function(Map<String, Sq> pos);

class Oracle {
  Oracle(String text) {
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final t = line.split(RegExp(r'\s+'));
      switch (t[0]) {
        case 'rule':
          if (t[1] == 'liar') liar = true;
          if (t[1] == 'notouch') noTouch = true;
        case 'kind':
          sit[t[1]] = t[2] == 'sit';
        case 'grid':
          final rows = int.parse(t[2]);
          final cols = int.parse(t[3]);
          final grid = <List<OracleSquare?>>[];
          for (var r = 0; r < rows; r++) {
            final cells = lines[i + 1 + r].trim().split(RegExp(r'\s+'));
            OracleSquare? read(String s) => s == '---'
                ? null
                : OracleSquare(s[0], s[1] == '.' ? null : s[1]);
            grid.add(cells.take(cols).map(read).toList());
          }
          gridNames.add(t[1]);
          grids.add(grid);
          i += rows;
        case 'open':
          final g = gridNames.indexOf(t[1]);
          final r = int.parse(t[2]) - 1;
          final k = int.parse(t[3]) - 1;
          final (dr, dk) = _step[t[4]]!;
          // An opening belongs to both squares it joins.
          openings.add(((g, r, k), (g, r + dr, k + dk), t[5] == 'door'));
        case 'person' || 'victim':
          people.add(
            OraclePerson(
              t[1],
              t[2],
              t[3] == 'm',
              t.length > 4 ? t[4].split(',').toSet() : <String>{},
              victim: t[0] == 'victim',
            ),
          );
        case 'clue':
          clueLines.add(t.sublist(1).join(' '));
        case 'extra':
          extraLines.add(t.sublist(1).join(' '));
        case 'solution':
          solution = <String, Sq>{
            for (final part in t.sublist(1))
              part.split('=')[0]: _at(part.split('=')[1]),
          };
      }
    }
    clues = <Truth>[for (final c in clueLines) meaning(c)];
    extras = <Truth>[for (final c in extraLines) meaning(c)];
  }

  static const Map<String, (int, int)> _step = <String, (int, int)>{
    'N': (-1, 0),
    'E': (0, 1),
    'S': (1, 0),
    'W': (0, -1),
  };

  static Sq _at(String s) {
    final n = s.split(':').map(int.parse).toList();
    return (n[0] - 1, n[1] - 1, n[2] - 1);
  }

  bool liar = false;
  bool noTouch = false;
  final Map<String, bool> sit = <String, bool>{};
  final List<String> gridNames = <String>[];
  final List<List<List<OracleSquare?>>> grids = <List<List<OracleSquare?>>>[];
  final List<(Sq, Sq, bool)> openings = <(Sq, Sq, bool)>[];
  final List<OraclePerson> people = <OraclePerson>[];
  final List<String> clueLines = <String>[];
  final List<String> extraLines = <String>[];
  late final List<Truth> clues;
  late final List<Truth> extras;
  Map<String, Sq>? solution;

  OraclePerson get victim => people.firstWhere((OraclePerson p) => p.victim);

  // ------------------------------------------------------------ the scene

  OracleSquare? at(Sq s) {
    final (g, r, k) = s;
    if (g < 0 || g >= grids.length) return null;
    if (r < 0 || r >= grids[g].length) return null;
    if (k < 0 || k >= grids[g][r].length) return null;
    return grids[g][r][k];
  }

  Sq _next(Sq s, (int, int) d) => (s.$1, s.$2 + d.$1, s.$3 + d.$2);

  /// Every square of the scene.
  Iterable<Sq> get squares sync* {
    for (var g = 0; g < grids.length; g++) {
      for (var r = 0; r < grids[g].length; r++) {
        for (var k = 0; k < grids[g][r].length; k++) {
          if (grids[g][r][k] != null) yield (g, r, k);
        }
      }
    }
  }

  /// "A bare square can hold a person"; so can an object one can be on.
  bool canHold(Sq s) {
    final x = at(s);
    if (x == null) return false;
    return x.kind == null || sit[x.kind]!;
  }

  String area(Sq s) => at(s)!.area;

  /// The outline of the grid, also around a cut corner.
  bool _outline(Sq s, (int, int) d) => at(_next(s, d)) == null;

  /// "A wall is the outline of the grid or the border between two areas."
  bool _wall(Sq s, (int, int) d) =>
      _outline(s, d) || at(_next(s, d))!.area != at(s)!.area;

  bool _opening(Sq s, (int, int) d, {bool? door}) {
    final n = _next(s, d);
    return openings.any(
      ((Sq, Sq, bool) o) =>
          (door == null || o.$3 == door) &&
          ((o.$1 == s && o.$2 == n) || (o.$1 == n && o.$2 == s)),
    );
  }

  static const List<(int, int)> _up = <(int, int)>[(-1, 0)];
  static const List<(int, int)> _down = <(int, int)>[(1, 0)];
  static const List<(int, int)> _left = <(int, int)>[(0, -1)];
  static const List<(int, int)> _right = <(int, int)>[(0, 1)];
  static const List<(int, int)> _four = <(int, int)>[
    (-1, 0),
    (1, 0),
    (0, -1),
    (0, 1),
  ];

  // ------------------------------------------------- tests on one square

  /// The meaning of a test such as `not beside t x2`, as a question about
  /// one square.
  bool Function(Sq) squareTest(List<String> t) {
    switch (t[0]) {
      case 'not':
        final inner = squareTest(t.sublist(1));
        return (Sq s) => !inner(s);
      case 'in':
        final codes = t[1].split('|').toSet();
        return (Sq s) => codes.contains(area(s));
      case 'on':
        // "The person's own square holds that object."
        return (Sq s) => at(s)!.kind == t[1];
      case 'beside':
        // "Directly above, below, left or right of the person's square
        // and in the same area. Diagonals do not count."
        int count(Sq s) => _four.where(((int, int) d) {
          final n = at(_next(s, d));
          return n != null && n.area == area(s) && n.kind == t[1];
        }).length;
        if (t.length == 3) {
          final exactly = int.parse(t[2].substring(1));
          return (Sq s) => count(s) == exactly;
        }
        return (Sq s) => count(s) > 0;
      case 'front':
        // "The door or window is on one side of the person's square."
        final door = t[1] == 'door';
        return (Sq s) =>
            _four.any(((int, int) d) => _opening(s, d, door: door));
      case 'row':
        final row = int.parse(t[1]) - 1;
        return (Sq s) => s.$2 == row;
      case 'col':
        final col = int.parse(t[1]) - 1;
        return (Sq s) => s.$3 == col;
      case 'grid':
        final grid = gridNames.indexOf(t[1]);
        return (Sq s) => s.$1 == grid;
      case 'border':
        // "At least one side on the outline of its grid."
        return (Sq s) => _four.any(((int, int) d) => _outline(s, d));
      case 'corner':
        // "An outline side above or below it and an outline side left or
        // right of it."
        return (Sq s) =>
            (_outline(s, _up.single) || _outline(s, _down.single)) &&
            (_outline(s, _left.single) || _outline(s, _right.single));
      case 'areacorner':
        // "Same, with walls."
        return (Sq s) =>
            (_wall(s, _up.single) || _wall(s, _down.single)) &&
            (_wall(s, _left.single) || _wall(s, _right.single));
      case 'sees':
        // "Looking straight up, down, left or right, the first object met
        // is of that kind. Any object stops the view behind it. A wall
        // stops the view unless it has a door or window at that point.
        // The object on the person's own square does not count."
        return (Sq s) => _four.any(((int, int) d) {
          var here = s;
          while (true) {
            if (_outline(here, d)) return false;
            if (_wall(here, d) && !_opening(here, d)) return false;
            here = _next(here, d);
            final kind = at(here)!.kind;
            if (kind != null) return kind == t[1];
          }
        });
      case 'line':
        // "Some other square of the same row (column) of the same grid
        // holds that object. Walls and distance do not matter."
        final row = t[1] == 'row';
        return (Sq s) => squares.any(
          (Sq o) =>
              o != s &&
              o.$1 == s.$1 &&
              (row ? o.$2 == s.$2 : o.$3 == s.$3) &&
              at(o)!.kind == t[2],
        );
    }
    throw StateError('the oracle does not know the test "${t.join(' ')}"');
  }

  bool Function(OraclePerson) _who(String s) {
    if (s == 'any') return (OraclePerson p) => true;
    if (s == 'm') return (OraclePerson p) => p.male;
    if (s == 'f') return (OraclePerson p) => !p.male;
    if (s.startsWith('!')) {
      return (OraclePerson p) => !p.traits.contains(s.substring(1));
    }
    return (OraclePerson p) => p.traits.contains(s);
  }

  // ---------------------------------------------------------------- clues

  /// The meaning of a clue in the notation of the case format (the words
  /// after `clue`), as a question about where everybody stands.
  Truth meaning(String notation) {
    final t = notation.split(' ');
    if (t[0] == '*') {
      switch (t[1]) {
        case 'count':
          // "Exactly N people ...", the victim included.
          final n = int.parse(t[2]);
          final test = squareTest(t.sublist(3));
          return (Map<String, Sq> pos) => pos.values.where(test).length == n;
        case 'more':
          return (Map<String, Sq> pos) =>
              pos.values.where((Sq s) => area(s) == t[2]).length >
              pos.values.where((Sq s) => area(s) == t[3]).length;
        case 'group':
          final who = _who(t[2]);
          final test = squareTest(t.sublist(3));
          return (Map<String, Sq> pos) =>
              people.where(who).every((OraclePerson p) => test(pos[p.id]!));
      }
      throw StateError('the oracle does not know "$notation"');
    }
    final me = t[0];
    Iterable<String> everyoneElse() =>
        people.map((OraclePerson p) => p.id).where((String id) => id != me);
    switch (t[1]) {
      case 'is':
        final test = squareTest(t.sublist(2));
        return (Map<String, Sq> pos) => test(pos[me]!);
      case 'only':
        // "True of the speaker and false of everybody else, the victim
        // included."
        final test = squareTest(t.sublist(2));
        return (Map<String, Sq> pos) =>
            test(pos[me]!) &&
            everyoneElse().every((String o) => !test(pos[o]!));
      case 'allothers':
        // "True of everybody else and false of the speaker."
        final test = squareTest(t.sublist(2));
        return (Map<String, Sq> pos) =>
            !test(pos[me]!) &&
            everyoneElse().every((String o) => test(pos[o]!));
      case 'alone':
        // "Nobody else was in the person's area, not even the victim."
        return (Map<String, Sq> pos) =>
            everyoneElse().every((String o) => area(pos[o]!) != area(pos[me]!));
      case 'alonewith':
        // "The person's area held exactly the person and the people named."
        final named = t.sublist(2).toSet();
        return (Map<String, Sq> pos) => everyoneElse().every(
          (String o) => (area(pos[o]!) == area(pos[me]!)) == named.contains(o),
        );
      case 'others':
        // "Counting everyone except the speaker, exactly N of that
        // description were in the speaker's area."
        final who = _who(t[2]);
        final n = int.parse(t[3]);
        return (Map<String, Sq> pos) =>
            people
                .where(
                  (OraclePerson p) =>
                      p.id != me &&
                      who(p) &&
                      area(pos[p.id]!) == area(pos[me]!),
                )
                .length ==
            n;
    }
    // What is left relates the speaker to one other person.
    final you = t[2];
    bool sameGrid(Map<String, Sq> pos) => pos[me]!.$1 == pos[you]!.$1;
    int rows(Map<String, Sq> pos) => pos[me]!.$2 - pos[you]!.$2;
    int cols(Map<String, Sq> pos) => pos[me]!.$3 - pos[you]!.$3;
    switch (t[1]) {
      case 'dir':
        // "Above": a row with a smaller number. "Left": an earlier letter.
        // 0 leaves that axis free.
        final a = int.parse(t[3]);
        final b = int.parse(t[4]);
        return (Map<String, Sq> pos) =>
            sameGrid(pos) &&
            (a == 0 || (a < 0 ? rows(pos) < 0 : rows(pos) > 0)) &&
            (b == 0 || (b < 0 ? cols(pos) < 0 : cols(pos) > 0));
      case 'offset':
        // "Row number differs by exactly N in that direction."
        final a = t[3] == '*' ? null : int.parse(t[3]);
        final b = t[4] == '*' ? null : int.parse(t[4]);
        return (Map<String, Sq> pos) =>
            sameGrid(pos) &&
            (a == null || rows(pos) == a) &&
            (b == null || cols(pos) == b);
      case 'diag':
        // "As many rows apart as columns apart."
        return (Map<String, Sq> pos) =>
            sameGrid(pos) && rows(pos).abs() == cols(pos).abs();
      case 'dist':
        // "Rows apart plus columns apart equals N."
        final n = int.parse(t[3]);
        return (Map<String, Sq> pos) =>
            sameGrid(pos) && rows(pos).abs() + cols(pos).abs() == n;
      case 'with':
        return (Map<String, Sq> pos) => area(pos[me]!) == area(pos[you]!);
      case 'notwith':
        return (Map<String, Sq> pos) => area(pos[me]!) != area(pos[you]!);
      case 'samegrid':
        return sameGrid;
      case 'samepos':
        // "Same row number and same column letter, on different grids."
        return (Map<String, Sq> pos) =>
            !sameGrid(pos) && rows(pos) == 0 && cols(pos) == 0;
    }
    throw StateError('the oracle does not know "$notation"');
  }

  // ---------------------------------------------------------------- rules

  /// The placement rules alone (GameRules section 2), or the first one
  /// broken. Does not look at the clues.
  String? rulesBroken(Map<String, Sq> pos) {
    final ids = pos.keys.toList();
    for (final id in ids) {
      if (!canHold(pos[id]!)) return '$id is on a square nobody can be on';
    }
    for (var i = 0; i < ids.length; i++) {
      for (var j = 0; j < i; j++) {
        final (g, r, k) = pos[ids[i]]!;
        final (h, s, l) = pos[ids[j]]!;
        if (g != h) continue;
        if (r == s || k == l) return '${ids[i]} and ${ids[j]} share a line';
        if (noTouch && (r - s).abs() <= 1 && (k - l).abs() <= 1) {
          return '${ids[i]} and ${ids[j]} touch';
        }
      }
    }
    // "The victim's area holds exactly two people."
    final where = area(pos[victim.id]!);
    final there = pos.values.where((Sq s) => area(s) == where).length;
    if (there != 2) return 'the victim is with ${there - 1} people, not one';
    return null;
  }

  /// Null when [pos] is an answer to the case: the rules hold and every
  /// clue is true, or, in a liar case, exactly one statement is false and
  /// every general clue is true.
  String? wrong(Map<String, Sq> pos) {
    final rule = rulesBroken(pos);
    if (rule != null) return rule;
    var falseStatements = 0;
    for (var i = 0; i < clues.length; i++) {
      if (clues[i](pos)) continue;
      final general = clueLines[i].startsWith('*');
      if (!liar || general) return 'false: ${clueLines[i]}';
      falseStatements++;
    }
    if (liar && falseStatements != 1) {
      return '$falseStatements statements are false, not one';
    }
    return null;
  }

  /// The murderer of [pos]: the one other person in the victim's area.
  String murderer(Map<String, Sq> pos) => people
      .firstWhere(
        (OraclePerson p) =>
            !p.victim && area(pos[p.id]!) == area(pos[victim.id]!),
      )
      .id;

  /// Every answer to the case, found the slow, sure way: every way of
  /// putting everybody on a square that keeps one per row and column is
  /// tried against the rules and the clues. No cleverness, so nothing to
  /// get wrong. [limit] stops the search early.
  List<Map<String, Sq>> everyAnswer({int limit = 3}) {
    final free = squares.where(canHold).toList();
    final out = <Map<String, Sq>>[];
    final pos = <String, Sq>{};
    void put(int who) {
      if (out.length >= limit) return;
      if (who == people.length) {
        if (wrong(pos) == null) out.add(Map<String, Sq>.of(pos));
        return;
      }
      for (final s in free) {
        final clash = pos.values.any(
          (Sq o) => o.$1 == s.$1 && (o.$2 == s.$2 || o.$3 == s.$3),
        );
        if (clash) continue;
        pos[people[who].id] = s;
        put(who + 1);
        pos.remove(people[who].id);
      }
    }

    put(0);
    return out;
  }
}
