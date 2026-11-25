// Helpers shared by the exploratory tests in test/explore/.
//
// These tests draw their inputs at random from a fixed seed, so a run is
// repeatable. How much they draw is set by the environment variable
// RUBY_EXPLORE: 1 (the default) keeps them quick enough for the commit
// gates; a larger number makes every test draw that many times more.
//
//   flutter test test/explore                      the quick run
//   RUBY_EXPLORE=20 flutter test test/explore      a deep run (minutes)
//   $env:RUBY_EXPLORE=20; flutter test test/explore    the same, PowerShell
import 'dart:io';
import 'dart:math';

import 'package:ruby/data/cases.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/tier.dart';

import 'oracle.dart';

/// How many times more than the quick run to draw.
final int depth = max(
  1,
  int.tryParse(Platform.environment['RUBY_EXPLORE'] ?? '') ?? 1,
);

/// One shipped case with everything a test needs.
class Shipped {
  Shipped(this.tier, this.text) : c = parseCase(text), oracle = Oracle(text);
  final Tier tier;
  final String text;
  final CaseDef c;
  final Oracle oracle;

  @override
  String toString() => c.id;
}

/// Every shipped case of [tier], or of all tiers.
List<Shipped> shipped([Tier? tier]) => <Shipped>[
  for (final t in Tier.values)
    if (tier == null || t == tier)
      for (final text in casePacks[t.name]!) Shipped(t, text),
];

/// [count] cases spread evenly over [from], so every shape is met.
List<Shipped> spread(List<Shipped> from, int count) {
  if (count >= from.length) return from;
  return <Shipped>[
    for (var i = 0; i < count; i++) from[i * from.length ~/ count],
  ];
}

/// A placement of the engine (person to cell index) as the oracle reads it.
Map<String, Sq> toOracle(CaseDef c, List<int> pos) => <String, Sq>{
  for (var p = 0; p < c.people.length; p++)
    c.people[p].id: (
      c.cells[pos[p]].grid,
      c.cells[pos[p]].row,
      c.cells[pos[p]].col,
    ),
};

/// Everybody on a square that can hold a person, no two on one square.
/// Rows and columns may clash: the point is to try boards that are wrong
/// in every possible way.
List<int> anyPlacement(CaseDef c, Random rnd) {
  final free = <int>[
    for (final x in c.cells)
      if (c.canOccupy(x.index)) x.index,
  ]..shuffle(rnd);
  return free.sublist(0, c.people.length);
}

/// One person per row and column on each grid, squares that can hold a
/// person; the clues and the victim rule are not looked at. Null when the
/// draw got stuck (rare; the caller draws again).
List<int>? lawfulPlacement(CaseDef c, Random rnd) {
  final pos = <int>[];
  for (var p = 0; p < c.people.length; p++) {
    final free = <int>[
      for (final x in c.cells)
        if (c.canOccupy(x.index) &&
            pos.every((int y) => !c.conflict(x.index, y)))
          x.index,
    ];
    if (free.isEmpty) return null;
    pos.add(free[rnd.nextInt(free.length)]);
  }
  return pos;
}
