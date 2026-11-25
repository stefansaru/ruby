/// The case text format: [parseCase] reads it and is also the validator,
/// [writeCase] writes it back. The format is described in docs/Levels.md.
///
/// A case that parses is well formed: every reference resolves, every area is
/// one connected piece, there is exactly one victim, and a stated solution
/// obeys every rule and clue. Nothing malformed can reach the game.
library;

import 'clue.dart';
import 'model.dart';

class CaseFormatException implements Exception {
  CaseFormatException(this.message, [this.line = 0]);
  final String message;
  final int line;
  @override
  String toString() =>
      line > 0 ? 'Case line $line: $message' : 'Case: $message';
}

CaseDef parseCase(String text) => _Parser(text).parse();

class _Parser {
  _Parser(String text) : lines = text.split('\n');

  final List<String> lines;
  int lineNo = 0;

  String id = '';
  String title = '';
  String setting = '';
  bool liar = false;
  bool noTouch = false;
  final List<GridDef> grids = <GridDef>[];
  final List<AreaDef> areas = <AreaDef>[];
  final List<ObjectKind> kinds = <ObjectKind>[];
  final List<Cell> cells = <Cell>[];
  final List<Opening> openings = <Opening>[];
  final List<Person> people = <Person>[];
  final List<Clue> clues = <Clue>[];
  final List<Clue> extras = <Clue>[];
  final List<(int, List<String>)> clueLines = <(int, List<String>)>[];
  final List<(int, List<String>)> extraLines = <(int, List<String>)>[];
  final List<(int, List<String>)> openLines = <(int, List<String>)>[];
  (int, List<String>)? solutionLine;

  Never fail(String message, [int? line]) =>
      throw CaseFormatException(message, line ?? lineNo);

  int number(String s, [String what = 'number']) =>
      int.tryParse(s) ?? fail('expected a $what, got "$s"');

  /// A count of people: never negative.
  int count(String s) {
    final n = number(s, 'count');
    return n >= 0 ? n : fail('a count cannot be negative');
  }

  /// A line that may appear only once.
  void once(String word, bool first) {
    if (!first) fail('"$word" is given twice');
  }

  CaseDef parse() {
    var i = 0;
    while (i < lines.length) {
      lineNo = i + 1;
      final line = lines[i].trim();
      i++;
      if (line.isEmpty || line.startsWith('#')) continue;
      final t = line.split(RegExp(r'\s+'));
      final rest = t.length > 1
          ? line.substring(line.indexOf(t[1], t[0].length)).trim()
          : '';
      switch (t[0]) {
        case 'case':
          once('case', id.isEmpty);
          id = rest;
        case 'title':
          once('title', title.isEmpty);
          title = rest;
        case 'setting':
          once('setting', setting.isEmpty);
          setting = rest;
        case 'rule':
          if (rest == 'liar') {
            liar = true;
          } else if (rest == 'notouch') {
            noTouch = true;
          } else {
            fail('unknown rule "$rest"');
          }
        case 'area':
          if (t.length < 3 || t[1].length != 1) fail('area <code> <name>');
          if (areas.any((AreaDef a) => a.code == t[1])) {
            fail('area ${t[1]} is defined twice');
          }
          areas.add(AreaDef(t[1], t.sublist(2).join(' ')));
        case 'kind':
          if (t.length < 4 || t[1].length != 1) {
            fail('kind <code> sit|block <name>');
          }
          if (t[2] != 'sit' && t[2] != 'block') fail('kind is sit or block');
          if (kinds.any((ObjectKind k) => k.code == t[1])) {
            fail('kind ${t[1]} is defined twice');
          }
          kinds.add(
            ObjectKind(t[1], t.sublist(3).join(' '), canOccupy: t[2] == 'sit'),
          );
        case 'grid':
          if (t.length != 4) fail('grid <name> <rows> <cols>');
          final rows = number(t[2], 'row count');
          final cols = number(t[3], 'column count');
          if (rows < 1 || cols < 1 || rows > 26 || cols > 26) {
            fail('grid size out of range');
          }
          if (i + rows > lines.length) fail('grid ${t[1]} is cut short');
          _grid(t[1], rows, cols, lines.sublist(i, i + rows), i);
          i += rows;
        case 'open':
          openLines.add((lineNo, t));
        case 'person' || 'victim':
          if (t.length < 4 || t.length > 5 || t[1].length != 1) {
            fail('${t[0]} <id> <name> m|f [traits]');
          }
          if (t[3] != 'm' && t[3] != 'f') fail('gender is m or f');
          if (people.any((Person p) => p.id == t[1])) {
            fail('person ${t[1]} is defined twice');
          }
          final name = t[2].replaceAll('_', ' ');
          if (people.any((Person p) => p.name == name)) {
            fail('two people are called $name');
          }
          final traits = t.length > 4 ? t[4].split(',').toSet() : <String>{};
          for (final trait in traits) {
            // These words already mean something where a trait is named.
            if (trait.isEmpty ||
                trait.startsWith('!') ||
                const <String>{'m', 'f', 'any'}.contains(trait)) {
              fail('"$trait" cannot be a trait');
            }
          }
          people.add(
            Person(
              id: t[1],
              name: name,
              gender: t[3] == 'm' ? Gender.male : Gender.female,
              traits: traits,
              isVictim: t[0] == 'victim',
            ),
          );
        case 'clue':
          clueLines.add((lineNo, t.sublist(1)));
        case 'extra':
          extraLines.add((lineNo, t.sublist(1)));
        case 'solution':
          once('solution', solutionLine == null);
          solutionLine = (lineNo, t.sublist(1));
        default:
          fail('unknown line "${t[0]}"');
      }
    }
    lineNo = 0;
    if (id.isEmpty) fail('missing "case <id>"');
    if (setting.isEmpty) fail('missing "setting <id>"');
    if (grids.isEmpty) fail('no grid');
    if (people.where((Person p) => p.isVictim).length != 1) {
      fail('a case has exactly one victim');
    }
    if (people.length < 2) fail('a case needs the victim and a suspect');
    _checkAreas();
    for (final (int n, List<String> t) in openLines) {
      lineNo = n;
      _opening(t);
    }
    for (final (int n, List<String> t) in clueLines) {
      lineNo = n;
      final clue = _clue(t);
      if (clue.subject != null && people[clue.subject!].isVictim) {
        fail('the victim gives no statement');
      }
      clues.add(clue);
    }
    for (final (int n, List<String> t) in extraLines) {
      lineNo = n;
      final clue = _clue(t);
      final who = clue.subject;
      if (who == null) fail('an extra statement needs a speaker');
      if (people[who].isVictim) fail('the victim gives no statement');
      extras.add(clue);
    }
    List<int>? solution;
    if (solutionLine != null) {
      lineNo = solutionLine!.$1;
      solution = _solution(solutionLine!.$2);
    }
    final c = CaseDef(
      id: id,
      title: title,
      setting: setting,
      grids: grids,
      areas: areas,
      kinds: kinds,
      cells: cells,
      openings: openings,
      people: people,
      clues: clues,
      extras: extras,
      liar: liar,
      noTouch: noTouch,
      solution: solution,
    );
    if (people.length > c.capacity) {
      fail('${people.length} people cannot fit: the grids hold ${c.capacity}');
    }
    for (final o in openings) {
      if (!c.isWall(o.cell, o.side)) {
        fail('a door or window must be on a wall (${c.cellLabel(o.cell)})');
      }
    }
    if (liar && c.statements.length < 2) {
      fail('a liar case needs at least two statements');
    }
    if (solution != null) {
      final wrong = c.check(solution);
      if (wrong != null) fail('the stated solution is wrong: $wrong');
      for (final extra in extras) {
        if (!extra.holds(c, solution)) {
          fail('an extra statement is false: ${clueNotation(c, extra)}');
        }
      }
    } else if (extras.isNotEmpty) {
      fail('extra statements need a stated solution to be checked against');
    }
    return c;
  }

  void _grid(String name, int rows, int cols, List<String> body, int first) {
    if (grids.any((GridDef g) => g.name == name)) {
      fail('grid $name is defined twice');
    }
    final cellAt = <List<int>>[];
    for (var r = 0; r < rows; r++) {
      lineNo = first + r + 1;
      final t = body[r].trim().split(RegExp(r'\s+'));
      if (t.length != cols) fail('expected $cols squares, got ${t.length}');
      final row = <int>[];
      for (var k = 0; k < cols; k++) {
        final s = t[k];
        if (s.length != 3) fail('square "$s" must be three characters');
        if (s == '---') {
          row.add(-1);
          continue;
        }
        final area = areas.indexWhere((AreaDef a) => a.code == s[0]);
        if (area < 0) fail('square "$s": unknown area ${s[0]}');
        var kind = -1;
        if (s[1] != '.') {
          kind = kinds.indexWhere((ObjectKind o) => o.code == s[1]);
          if (kind < 0) fail('square "$s": unknown kind ${s[1]}');
        } else if (s[2] != '.') {
          fail('square "$s": an instance needs an object');
        }
        row.add(cells.length);
        cells.add(
          Cell(
            index: cells.length,
            grid: grids.length,
            row: r,
            col: k,
            area: area,
            kind: kind,
            instance: s[2],
          ),
        );
      }
      cellAt.add(row);
    }
    grids.add(GridDef(name, rows, cols, cellAt));
  }

  /// Every area is used, lies on one grid and is one connected piece.
  void _checkAreas() {
    for (var a = 0; a < areas.length; a++) {
      final mine = cells.where((Cell c) => c.area == a).toList(growable: false);
      if (mine.isEmpty) fail('area ${areas[a].code} has no squares');
      if (mine.any((Cell c) => c.grid != mine.first.grid)) {
        fail('area ${areas[a].code} is spread over two grids');
      }
      final g = grids[mine.first.grid];
      final seen = <int>{mine.first.index};
      final todo = <Cell>[mine.first];
      while (todo.isNotEmpty) {
        final c = todo.removeLast();
        for (final (int dr, int dc) in const <(int, int)>[
          (-1, 0),
          (1, 0),
          (0, -1),
          (0, 1),
        ]) {
          final r = c.row + dr;
          final k = c.col + dc;
          if (r < 0 || k < 0 || r >= g.rows || k >= g.cols) continue;
          final n = g.cellAt[r][k];
          if (n >= 0 && cells[n].area == a && seen.add(n)) todo.add(cells[n]);
        }
      }
      if (seen.length != mine.length) {
        fail('area ${areas[a].code} is in more than one piece');
      }
    }
  }

  int _gridIndex(String name) {
    final g = grids.indexWhere((GridDef d) => d.name == name);
    return g >= 0 ? g : fail('unknown grid "$name"');
  }

  int _cell(int grid, int row, int col) {
    final g = grids[grid];
    if (row < 1 || col < 1 || row > g.rows || col > g.cols) {
      fail('square $row,$col is outside grid ${g.name}');
    }
    final c = g.cellAt[row - 1][col - 1];
    return c >= 0 ? c : fail('there is no square at $row,$col');
  }

  void _opening(List<String> t) {
    if (t.length != 6) fail('open <grid> <row> <col> N|E|S|W door|window');
    final cell = _cell(_gridIndex(t[1]), number(t[2]), number(t[3]));
    final side = 'NESW'.indexOf(t[4]);
    if (side < 0 || t[4].length != 1) fail('side is N, E, S or W');
    if (t[5] != 'door' && t[5] != 'window') fail('door or window');
    final opening = Opening(cell, Side.values[side], isDoor: t[5] == 'door');
    if (openings.any(
      (Opening o) => o.cell == opening.cell && o.side == opening.side,
    )) {
      fail('two openings on the same side of one square');
    }
    openings.add(opening);
  }

  int _person(String s) {
    final p = people.indexWhere((Person x) => x.id == s);
    return p >= 0 ? p : fail('unknown person "$s"');
  }

  int _area(String s) {
    final a = areas.indexWhere((AreaDef x) => x.code == s);
    return a >= 0 ? a : fail('unknown area "$s"');
  }

  int _kind(String s) {
    final k = kinds.indexWhere((ObjectKind x) => x.code == s);
    return k >= 0 ? k : fail('unknown kind "$s"');
  }

  /// A 1-based row or column number that exists on some grid, 0-based.
  int _line(String s, {required bool rows}) {
    final n = number(s);
    final most = grids.fold(
      0,
      (int m, GridDef g) =>
          m > (rows ? g.rows : g.cols) ? m : (rows ? g.rows : g.cols),
    );
    if (n < 1 || n > most) fail('no ${rows ? 'row' : 'column'} $n');
    return n - 1;
  }

  Selector _selector(String s) {
    if (s == 'any') return const Selector.any();
    if (s == 'm') return const Selector.gender(Gender.male);
    if (s == 'f') return const Selector.gender(Gender.female);
    final neg = s.startsWith('!');
    final trait = neg ? s.substring(1) : s;
    if (!people.any((Person p) => p.traits.contains(trait))) {
      fail('nobody has the trait "$trait"');
    }
    return Selector.trait(trait, negate: neg);
  }

  CellTest _test(List<String> t) {
    if (t.isEmpty) fail('missing test');
    void need(int n) {
      if (t.length != n) fail('bad test "${t.join(' ')}"');
    }

    switch (t[0]) {
      case 'not':
        return Not(_test(t.sublist(1)));
      case 'in':
        need(2);
        return InArea(t[1].split('|').map(_area).toSet());
      case 'on':
        need(2);
        final k = _kind(t[1]);
        if (!kinds[k].canOccupy) fail('nobody can be on a ${kinds[k].name}');
        return OnKind(k);
      case 'beside':
        if (t.length == 3 && t[2].startsWith('x')) {
          final sides = number(t[2].substring(1));
          if (sides < 1 || sides > 4) fail('a square has 1 to 4 sides');
          return BesideKind(_kind(t[1]), exactly: sides);
        }
        need(2);
        return BesideKind(_kind(t[1]));
      case 'front':
        need(2);
        if (t[1] != 'door' && t[1] != 'window') fail('front door|window');
        return FrontOf(door: t[1] == 'door');
      case 'row':
        need(2);
        return InRow(_line(t[1], rows: true));
      case 'col':
        need(2);
        return InCol(_line(t[1], rows: false));
      case 'grid':
        need(2);
        return InGrid(_gridIndex(t[1]));
      case 'border':
        need(1);
        return const OnBorder();
      case 'corner':
        need(1);
        return const GridCorner();
      case 'areacorner':
        need(1);
        return const AreaCorner();
      case 'sees':
        need(2);
        return Sees(_kind(t[1]));
      case 'line':
        need(3);
        if (t[1] != 'row' && t[1] != 'col') fail('line row|col <kind>');
        return LineHas(_kind(t[2]), row: t[1] == 'row');
      default:
        fail('unknown test "${t[0]}"');
    }
  }

  Clue _clue(List<String> t) {
    if (t.length < 2) fail('clue <person|*> <what>');
    if (t[0] == '*') {
      switch (t[1]) {
        case 'count':
          if (t.length < 4) fail('count <n> <test>');
          return Count(_test(t.sublist(3)), count(t[2]));
        case 'more':
          if (t.length != 4) fail('more <area> <area>');
          return More(_area(t[2]), _area(t[3]));
        case 'group':
          if (t.length < 4) fail('group <who> <test>');
          return Group(_selector(t[2]), _test(t.sublist(3)));
        default:
          fail('unknown general clue "${t[1]}"');
      }
    }
    final s = _person(t[0]);
    int other() {
      if (t.length < 3) fail('${t[1]} needs another person');
      final o = _person(t[2]);
      if (o == s) fail('a clue cannot relate a person to themselves');
      return o;
    }

    int? axis(String v) => v == '*' ? null : number(v);
    void exact(int n) {
      if (t.length != n) fail('too many words in "${t.join(' ')}"');
    }

    switch (t[1]) {
      case 'is':
        return Is(s, _test(t.sublist(2)));
      case 'dir':
        if (t.length != 5) fail('dir <person> <rows> <cols>');
        final a = number(t[3]);
        final b = number(t[4]);
        if (a.abs() > 1 || b.abs() > 1 || (a == 0 && b == 0)) {
          fail('dir takes -1, 0 or 1, not both 0');
        }
        return Rel(s, other(), RelKind.direction, a: a, b: b);
      case 'offset':
        if (t.length != 5) fail('offset <person> <rows|*> <cols|*>');
        final a = axis(t[3]);
        final b = axis(t[4]);
        if (a == null && b == null) fail('offset needs a row or a column');
        if (a == 0 || b == 0) fail('an offset of 0 is impossible');
        return Rel(s, other(), RelKind.offset, a: a, b: b);
      case 'diag':
        exact(3);
        return Rel(s, other(), RelKind.diagonal);
      case 'with':
        exact(3);
        return Rel(s, other(), RelKind.sameArea);
      case 'notwith':
        exact(3);
        return Rel(s, other(), RelKind.notSameArea);
      case 'samegrid':
        exact(3);
        return Rel(s, other(), RelKind.sameGrid);
      case 'samepos':
        exact(3);
        return Rel(s, other(), RelKind.samePosition);
      case 'dist':
        if (t.length != 4) fail('dist <person> <steps>');
        final steps = number(t[3]);
        // Never the same row or column, so never fewer than two steps.
        if (steps < 2) fail('two people are at least 2 steps apart');
        return Rel(s, other(), RelKind.distance, a: steps);
      case 'alone':
        exact(2);
        return Alone(s);
      case 'alonewith':
        if (t.length < 3) fail('alonewith <person>...');
        final list = t.sublist(2).map(_person).toList();
        if (list.contains(s)) fail('alonewith lists the other people');
        if (list.toSet().length != list.length) {
          fail('alonewith names someone twice');
        }
        return AloneWith(s, list);
      case 'others':
        if (t.length != 4) fail('others <who> <n>');
        return Others(s, _selector(t[2]), count(t[3]));
      case 'only':
        return OnlyOne(s, _test(t.sublist(2)));
      case 'allothers':
        return AllOthers(s, _test(t.sublist(2)));
      default:
        fail('unknown clue "${t[1]}"');
    }
  }

  List<int> _solution(List<String> t) {
    final pos = List<int>.filled(people.length, -1);
    for (final part in t) {
      final kv = part.split('=');
      final at = kv.length == 2 ? kv[1].split(':') : <String>[];
      if (at.length != 3) fail('solution entry is <id>=<grid>:<row>:<col>');
      final g = number(at[0]);
      if (g < 1 || g > grids.length) fail('solution: no grid $g');
      final who = _person(kv[0]);
      if (pos[who] >= 0) fail('the solution places ${kv[0]} twice');
      pos[who] = _cell(g - 1, number(at[1]), number(at[2]));
    }
    if (pos.contains(-1)) fail('the solution must place everyone');
    return pos;
  }
}

/// What a list of cases needs to know about one, read without checking
/// the whole case (the list would otherwise parse and verify every row).
class CaseHeader {
  const CaseHeader({
    required this.id,
    required this.title,
    required this.setting,
    required this.sizes,
    required this.people,
  });
  final String id;
  final String title;
  final String setting;

  /// (rows, columns) of each grid.
  final List<(int, int)> sizes;
  final int people;
}

/// The header of a case in the text format. Trusts the text: use
/// [parseCase] to check it. Missing parts come back empty, never thrown.
CaseHeader readHeader(String text) {
  var id = '';
  var title = '';
  var setting = '';
  var people = 0;
  final sizes = <(int, int)>[];
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    final space = line.indexOf(' ');
    if (space < 0) continue;
    final rest = line.substring(space + 1).trim();
    switch (line.substring(0, space)) {
      case 'case':
        id = rest;
      case 'title':
        title = rest;
      case 'setting':
        setting = rest;
      case 'grid':
        final t = rest.split(RegExp(r'\s+'));
        final rows = t.length == 3 ? int.tryParse(t[1]) : null;
        final cols = t.length == 3 ? int.tryParse(t[2]) : null;
        if (rows != null && cols != null) sizes.add((rows, cols));
      case 'person' || 'victim':
        people++;
    }
  }
  return CaseHeader(
    id: id,
    title: title,
    setting: setting,
    sizes: sizes,
    people: people,
  );
}

// ---------------------------------------------------------------- writing

String _testText(CaseDef c, CellTest t) => switch (t) {
  Not(:final CellTest inner) => 'not ${_testText(c, inner)}',
  InArea(:final Set<int> areas) =>
    'in ${areas.map((int a) => c.areas[a].code).join('|')}',
  OnKind(:final int kind) => 'on ${c.kinds[kind].code}',
  BesideKind(:final int kind, :final int? exactly) =>
    'beside ${c.kinds[kind].code}${exactly == null ? '' : ' x$exactly'}',
  FrontOf(:final bool door) => 'front ${door ? 'door' : 'window'}',
  InRow(:final int row) => 'row ${row + 1}',
  InCol(:final int col) => 'col ${col + 1}',
  InGrid(:final int grid) => 'grid ${c.grids[grid].name}',
  OnBorder() => 'border',
  GridCorner() => 'corner',
  AreaCorner() => 'areacorner',
  Sees(:final int kind) => 'sees ${c.kinds[kind].code}',
  LineHas(:final int kind, :final bool row) =>
    'line ${row ? 'row' : 'col'} ${c.kinds[kind].code}',
};

String _selectorText(Selector s) {
  if (s.gender != null) return s.gender == Gender.male ? 'm' : 'f';
  if (s.trait != null) return '${s.negate ? '!' : ''}${s.trait}';
  return 'any';
}

/// One clue in the text format, without the leading "clue".
String clueNotation(CaseDef c, Clue clue) {
  String id(int p) => c.people[p].id;
  switch (clue) {
    case Is(:final int subject, :final CellTest test):
      return '${id(subject)} is ${_testText(c, test)}';
    case Rel(:final int subject, :final int other, :final RelKind kind):
      final s = id(subject);
      final o = id(other);
      return switch (kind) {
        RelKind.direction => '$s dir $o ${clue.a} ${clue.b}',
        RelKind.offset => '$s offset $o ${clue.a ?? '*'} ${clue.b ?? '*'}',
        RelKind.diagonal => '$s diag $o',
        RelKind.sameArea => '$s with $o',
        RelKind.notSameArea => '$s notwith $o',
        RelKind.sameGrid => '$s samegrid $o',
        RelKind.samePosition => '$s samepos $o',
        RelKind.distance => '$s dist $o ${clue.a}',
      };
    case Alone(:final int subject):
      return '${id(subject)} alone';
    case AloneWith(:final int subject, :final List<int> others):
      return '${id(subject)} alonewith ${others.map(id).join(' ')}';
    case Others(:final int subject, :final Selector who, :final int count):
      return '${id(subject)} others ${_selectorText(who)} $count';
    case OnlyOne(:final int subject, :final CellTest test):
      return '${id(subject)} only ${_testText(c, test)}';
    case AllOthers(:final int subject, :final CellTest test):
      return '${id(subject)} allothers ${_testText(c, test)}';
    case Count(:final CellTest test, :final int count):
      return '* count $count ${_testText(c, test)}';
    case More(:final int more, :final int fewer):
      return '* more ${c.areas[more].code} ${c.areas[fewer].code}';
    case Group(:final Selector who, :final CellTest test):
      return '* group ${_selectorText(who)} ${_testText(c, test)}';
    case Negated():
      throw ArgumentError('a negated clue is never stored');
  }
}

String _place(CaseDef c, int person, int cell) {
  final x = c.cells[cell];
  return '${c.people[person].id}=${x.grid + 1}:${x.row + 1}:${x.col + 1}';
}

String writeCase(CaseDef c) {
  final b = StringBuffer()
    ..writeln('case ${c.id}')
    ..writeln('title ${c.title}')
    ..writeln('setting ${c.setting}');
  if (c.liar) b.writeln('rule liar');
  if (c.noTouch) b.writeln('rule notouch');
  for (final a in c.areas) {
    b.writeln('area ${a.code} ${a.name}');
  }
  for (final k in c.kinds) {
    b.writeln('kind ${k.code} ${k.canOccupy ? 'sit' : 'block'} ${k.name}');
  }
  for (final g in c.grids) {
    b.writeln('grid ${g.name} ${g.rows} ${g.cols}');
    for (final row in g.cellAt) {
      b.writeln(
        row
            .map((int i) {
              if (i < 0) return '---';
              final x = c.cells[i];
              return c.areas[x.area].code +
                  (x.kind < 0 ? '.' : c.kinds[x.kind].code) +
                  x.instance;
            })
            .join(' '),
      );
    }
  }
  for (final o in c.openings) {
    final x = c.cells[o.cell];
    b.writeln(
      'open ${c.grids[x.grid].name} ${x.row + 1} ${x.col + 1} '
      '${'NESW'[o.side.index]} ${o.isDoor ? 'door' : 'window'}',
    );
  }
  for (final p in c.people) {
    final traits = p.traits.isEmpty ? '' : ' ${p.traits.join(',')}';
    b.writeln(
      '${p.isVictim ? 'victim' : 'person'} ${p.id} '
      '${p.name.replaceAll(' ', '_')} '
      '${p.gender == Gender.male ? 'm' : 'f'}$traits',
    );
  }
  for (final clue in c.clues) {
    b.writeln('clue ${clueNotation(c, clue)}');
  }
  for (final extra in c.extras) {
    b.writeln('extra ${clueNotation(c, extra)}');
  }
  final s = c.solution;
  if (s != null) {
    b.writeln(
      'solution ${<String>[for (int p = 0; p < s.length; p++) _place(c, p, s[p])].join(' ')}',
    );
  }
  return b.toString();
}
