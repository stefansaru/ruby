/// Draws a scene (grids, areas, objects, doors and windows), a cast and a
/// placement that obeys the rules. No clues yet; gen_clues.dart adds them.
library;

import 'dart:math';

import '../data/settings.dart';
import '../engine/clue.dart';
import '../engine/model.dart';
import 'gen_config.dart';

const List<(String, String)> _names = <(String, String)>[
  ('Anna', 'Adam'), ('Bea', 'Ben'), ('Cora', 'Carl'), ('Dana', 'Dan'),
  ('Eva', 'Eli'), ('Faye', 'Finn'), ('Gina', 'Gus'), ('Hana', 'Hugo'),
  ('Ida', 'Ivan'), ('Jade', 'Jack'), ('Kira', 'Karl'), ('Lena', 'Leo'),
  ('Mia', 'Max'), ('Nora', 'Ned'), ('Olga', 'Otto'), ('Pia', 'Paul'),
  ('Rosa', 'Rex'), ('Sara', 'Sam'), ('Tina', 'Tom'), ('Uma', 'Uri'),
  ('Wanda', 'Will'), ('Zoe', 'Zak'), //
];

const List<String> _adjectives = <String>[
  'Quiet', 'Missing', 'Broken', 'Late', 'Cold', 'Silent', 'Crooked', 'Last',
  'Lost', 'Velvet', 'Hidden', 'Empty', 'Second', 'Locked', 'Borrowed',
  'Open', 'Wrong', 'Spare', 'Muddy', 'Torn', 'Early', 'Blue', 'Sleepy',
  'Odd', //
];

const List<String> _nouns = <String>[
  'Teacup', 'Key', 'Letter', 'Umbrella', 'Glove', 'Ticket', 'Candle',
  'Button', 'Clock', 'Ribbon', 'Lantern', 'Map', 'Whistle', 'Scarf',
  'Coin', 'Window', 'Footprint', 'Postcard', 'Spoon', 'Bell', 'Hat',
  'Suitcase', 'Notebook', 'Matchbox', //
];

/// How many different titles [titleFor] can make.
const int titleCount = 24 * 24;

/// "The Quiet Teacup": a title from two plain words. Each [index] below
/// [titleCount] gives a different title, so a pack never repeats one.
String titleFor(int index) {
  final i = index % titleCount;
  final adjective = i % _adjectives.length;
  final noun = (i ~/ _adjectives.length + 5 * adjective) % _nouns.length;
  return 'The ${_adjectives[adjective]} ${_nouns[noun]}';
}

/// A scene, a cast and a rule-abiding placement, or null when this draw
/// did not work out (the caller draws again).
CaseDef? drawScene(GenConfig cfg, Random rnd) {
  final setting = settings.firstWhere((SettingDef s) => s.id == cfg.setting);
  final areaPool = List<AreaSpec>.of(setting.areas)..shuffle(rnd);
  final sits = setting.kinds.where((KindSpec k) => k.sit).toList()
    ..shuffle(rnd);
  final blocks = setting.kinds.where((KindSpec k) => !k.sit).toList()
    ..shuffle(rnd);
  final kindSpecs = <KindSpec>[
    ...sits.take(2 + rnd.nextInt(2)),
    ...blocks.take(2 + rnd.nextInt(2)),
  ];

  final grids = <GridDef>[];
  final areas = <AreaDef>[];
  final areaSpecs = <AreaSpec>[];
  final cells = <Cell>[];
  final usedKinds = <KindSpec>[];
  var nextInstance = 0;

  for (var g = 0; g < cfg.grids.length; g++) {
    final (rows, cols) = cfg.grids[g];
    // Shape: true where the grid has a square.
    final has = List<List<bool>>.generate(
      rows,
      (_) => List<bool>.filled(cols, true),
    );
    if (cfg.irregular) {
      final corners = <int>[0, 1, 2, 3]..shuffle(rnd);
      for (final corner in corners.take(2)) {
        final cut = 1 + rnd.nextInt(2);
        for (var r = 0; r < cut; r++) {
          for (var k = 0; k < cut - r; k++) {
            final rr = corner < 2 ? r : rows - 1 - r;
            final kk = corner.isEven ? k : cols - 1 - k;
            has[rr][kk] = false;
          }
        }
      }
    }
    final count = has.fold(
      0,
      (int n, List<bool> row) => n + row.where((bool b) => b).length,
    );

    // Areas: seeds grown one square at a time until the grid is full.
    final left = areaPool.length - areaSpecs.length;
    final share = cfg.grids.length == 1 ? left : left ~/ (2 - g);
    final wanted = max(2, min(share, sqrt(count).round() - 1));
    final areaOf = List<List<int>>.generate(
      rows,
      (_) => List<int>.filled(cols, -1),
    );
    final free = <(int, int)>[
      for (var r = 0; r < rows; r++)
        for (var k = 0; k < cols; k++)
          if (has[r][k]) (r, k),
    ]..shuffle(rnd);
    final first = areas.length;
    for (var a = 0; a < wanted; a++) {
      final (r, k) = free[a];
      areaOf[r][k] = first + a;
      final spec = areaPool[areaSpecs.length];
      areaSpecs.add(spec);
      areas.add(AreaDef(String.fromCharCode(65 + areas.length), spec.name));
    }
    var filled = wanted;
    while (filled < count) {
      final frontier = <(int, int, int)>[];
      for (var r = 0; r < rows; r++) {
        for (var k = 0; k < cols; k++) {
          if (!has[r][k] || areaOf[r][k] >= 0) continue;
          for (final (dr, dc) in const <(int, int)>[
            (-1, 0),
            (1, 0),
            (0, -1),
            (0, 1),
          ]) {
            final rr = r + dr;
            final kk = k + dc;
            if (rr < 0 || kk < 0 || rr >= rows || kk >= cols) continue;
            if (areaOf[rr][kk] >= 0) frontier.add((r, k, areaOf[rr][kk]));
          }
        }
      }
      if (frontier.isEmpty) return null; // The cut split the grid.
      final (r, k, a) = frontier[rnd.nextInt(frontier.length)];
      areaOf[r][k] = a;
      filled++;
    }
    final sizes = List<int>.filled(wanted, 0);
    for (final row in areaOf) {
      for (final a in row) {
        if (a >= 0) sizes[a - first]++;
      }
    }
    if (sizes.any((int s) => s < 2 || s > count * 0.5)) return null;

    // Objects: about a quarter of each area.
    final kindAt = List<List<int>>.generate(
      rows,
      (_) => List<int>.filled(cols, -1),
    );
    final instanceAt = List<List<String>>.generate(
      rows,
      (_) => List<String>.filled(cols, '.'),
    );
    for (var a = 0; a < wanted; a++) {
      final spec = areaSpecs[first + a];
      final fits = kindSpecs
          .where(
            (KindSpec k) =>
                k.where == Where.anywhere ||
                (k.where == Where.inside) == spec.indoor,
          )
          .toList();
      if (fits.isEmpty) continue;
      final mine = <(int, int)>[
        for (var r = 0; r < rows; r++)
          for (var k = 0; k < cols; k++)
            if (areaOf[r][k] == first + a) (r, k),
      ]..shuffle(rnd);
      final target = (mine.length * (0.2 + rnd.nextDouble() * 0.15)).round();
      var placed = 0;
      for (final (r, k) in mine) {
        if (placed >= max(1, target)) break;
        if (kindAt[r][k] >= 0) continue;
        final kind = fits[rnd.nextInt(fits.length)];
        var index = usedKinds.indexOf(kind);
        if (index < 0) {
          index = usedKinds.length;
          usedKinds.add(kind);
        }
        kindAt[r][k] = index;
        placed++;
        if (!kind.wide) continue;
        // A wide object takes a second square beside the first.
        for (final (dr, dc) in const <(int, int)>[(0, 1), (1, 0)]) {
          final rr = r + dr;
          final kk = k + dc;
          if (rr >= rows || kk >= cols) continue;
          if (areaOf[rr][kk] != first + a || kindAt[rr][kk] >= 0) continue;
          final tag =
              '123456789abcdefghijklmnopqrstuvwxyz'[nextInstance++ % 35];
          kindAt[rr][kk] = index;
          instanceAt[r][k] = tag;
          instanceAt[rr][kk] = tag;
          placed++;
          break;
        }
      }
    }

    final cellAt = List<List<int>>.generate(
      rows,
      (_) => List<int>.filled(cols, -1),
    );
    for (var r = 0; r < rows; r++) {
      for (var k = 0; k < cols; k++) {
        if (!has[r][k]) continue;
        cellAt[r][k] = cells.length;
        cells.add(
          Cell(
            index: cells.length,
            grid: g,
            row: r,
            col: k,
            area: areaOf[r][k],
            kind: kindAt[r][k],
            instance: instanceAt[r][k],
          ),
        );
      }
    }
    final name = cfg.grids.length == 1
        ? setting.name
        : setting.gridNames[g].replaceAll(' ', '_');
    grids.add(GridDef(name, rows, cols, cellAt));
  }

  final kinds = <ObjectKind>[
    for (final KindSpec k in usedKinds)
      ObjectKind(k.code, k.name, canOccupy: k.sit),
  ];

  // Cast: suspects A, B, C... and a victim with a later initial.
  final n = cfg.people;
  final victimName = n - 1 + rnd.nextInt(_names.length - n + 1);
  final people = <Person>[
    for (var p = 0; p < n; p++)
      () {
        final male = rnd.nextBool();
        final (her, his) = _names[p == n - 1 ? victimName : p];
        final name = male ? his : her;
        return Person(
          id: name[0],
          name: name,
          gender: male ? Gender.male : Gender.female,
          traits: <String>{
            if (cfg.traits && rnd.nextInt(100) < 40) 'hat',
            if (cfg.traits && rnd.nextInt(100) < 30) 'glasses',
          },
          isVictim: p == n - 1,
        );
      }(),
  ];

  final scene = CaseDef(
    id: cfg.id,
    title: titleFor(cfg.titleIndex),
    setting: cfg.setting,
    grids: grids,
    areas: areas,
    kinds: kinds,
    cells: cells,
    openings: const <Opening>[],
    people: people,
    clues: const <Clue>[],
    noTouch: cfg.noTouch,
  );
  final openings = _drawOpenings(scene, areaSpecs, rnd);
  final solution = _drawPlacement(scene, rnd);
  if (solution == null) return null;
  return CaseDef(
    id: scene.id,
    title: scene.title,
    setting: scene.setting,
    grids: grids,
    areas: areas,
    kinds: kinds,
    cells: cells,
    openings: openings,
    people: people,
    clues: const <Clue>[],
    noTouch: cfg.noTouch,
    solution: solution,
  );
}

/// A door between some neighbouring areas, a window on some outer walls
/// of indoor areas.
List<Opening> _drawOpenings(CaseDef c, List<AreaSpec> specs, Random rnd) {
  final doors = <(int, int), List<Opening>>{};
  final windows = <int, List<Opening>>{};
  for (final cell in c.cells) {
    for (final side in Side.values) {
      final other = c.neighbor(cell.index, side);
      if (other < 0) {
        if (specs[cell.area].indoor) {
          windows
              .putIfAbsent(cell.area, () => <Opening>[])
              .add(Opening(cell.index, side, isDoor: false));
        }
      } else if (c.cells[other].area > cell.area) {
        doors
            .putIfAbsent((cell.area, c.cells[other].area), () => <Opening>[])
            .add(Opening(cell.index, side, isDoor: true));
      }
    }
  }
  return <Opening>[
    for (final List<Opening> list in doors.values)
      if (rnd.nextInt(100) < 45) list[rnd.nextInt(list.length)],
    for (final List<Opening> list in windows.values)
      if (rnd.nextInt(100) < 45) list[rnd.nextInt(list.length)],
  ];
}

/// One person per row and column on squares that can hold a person, the
/// victim alone with exactly one suspect.
List<int>? _drawPlacement(CaseDef c, Random rnd) {
  final n = c.people.length;
  for (var attempt = 0; attempt < 300; attempt++) {
    final who = List<int>.generate(n, (int p) => p)..shuffle(rnd);
    final pos = List<int>.filled(n, -1);
    var next = 0;
    var ok = true;
    for (var g = 0; g < c.grids.length && ok; g++) {
      final d = c.grids[g];
      final byRow = d.rows <= d.cols;
      final lines = byRow ? d.rows : d.cols;
      final across = byRow ? d.cols : d.rows;
      final taken = List<bool>.filled(across, false);
      final chosen = List<int>.filled(lines, -1);
      bool fill(int line) {
        if (line == lines) return true;
        final order = List<int>.generate(across, (int i) => i)..shuffle(rnd);
        for (final i in order) {
          if (taken[i]) continue;
          final cell = byRow ? d.cellAt[line][i] : d.cellAt[i][line];
          if (cell < 0 || !c.canOccupy(cell)) continue;
          taken[i] = true;
          chosen[line] = cell;
          if (fill(line + 1)) return true;
          taken[i] = false;
        }
        return false;
      }

      ok = fill(0);
      for (var line = 0; line < lines && ok; line++) {
        pos[who[next++]] = chosen[line];
      }
    }
    if (!ok) return null; // No placement fits this scene at all.
    if (c.murdererIn(pos) < 0) continue;
    if (c.noTouch) {
      var touch = false;
      for (var p = 0; p < n && !touch; p++) {
        for (var q = 0; q < p && !touch; q++) {
          touch = c.touching(pos[p], pos[q]);
        }
      }
      if (touch) continue;
    }
    return pos;
  }
  return null;
}
