/// What to generate: one [GenConfig] describes one case slot.
library;

import '../data/settings.dart';
import '../engine/logic_solver.dart';

/// The difficulty ladder. A case belongs to a tier by the hardest technique
/// the logic solver needs for it (docs/Levels.md), not by its size.
enum Tier {
  tutorial(Technique.clue, Technique.single),
  easy(Technique.clue, Technique.lastInLine),
  normal(Technique.intersection, Technique.pair),
  hard(Technique.subset, Technique.counting),
  expert(Technique.whatIf, Technique.liarSplit);

  const Tier(this.easiest, this.hardest);

  /// The hardest technique a case of this tier needs lies in this range.
  final Technique easiest;
  final Technique hardest;

  bool accepts(Technique t) =>
      t.index >= easiest.index && t.index <= hardest.index;
}

class GenConfig {
  GenConfig({
    required this.id,
    required this.tier,
    required this.setting,
    required this.grids,
    required this.seed,
    this.titleIndex = 0,
    this.irregular = false,
    this.liar = false,
    this.noTouch = false,
    this.traits = false,
    this.attempts = 400,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'must not be empty');
    if (!settings.any((SettingDef s) => s.id == setting)) {
      throw ArgumentError.value(setting, 'setting', 'unknown setting');
    }
    if (grids.isEmpty || grids.length > 2) {
      throw ArgumentError.value(grids, 'grids', 'one or two grids');
    }
    for (final (int rows, int cols) in grids) {
      if (rows < 3 || cols < 3 || rows > 12 || cols > 12) {
        throw ArgumentError.value(grids, 'grids', 'sides are 3 to 12');
      }
    }
    if (people < 3 || people > 12) {
      throw ArgumentError.value(grids, 'grids', 'must hold 3 to 12 people');
    }
    if (titleIndex < 0) {
      throw ArgumentError.value(
        titleIndex,
        'titleIndex',
        'must not be negative',
      );
    }
    if (attempts < 1) {
      throw ArgumentError.value(attempts, 'attempts', 'must be positive');
    }
    if (liar && tier != Tier.expert) {
      throw ArgumentError.value(liar, 'liar', 'liar cases are expert only');
    }
  }

  final String id;
  final Tier tier;
  final String setting;

  /// (rows, columns) of each grid.
  final List<(int, int)> grids;
  final int seed;

  /// Which title the case gets (see `titleFor`); distinct per slot.
  final int titleIndex;

  /// Cut squares out of the corners.
  final bool irregular;
  final bool liar;
  final bool noTouch;

  /// Give people hats and glasses that clues can refer to.
  final bool traits;

  /// How many scenes to try before giving up on this slot.
  final int attempts;

  /// One person per row and column: each grid holds as many people as its
  /// shorter side.
  int get people => grids.fold(
    0,
    (int sum, (int, int) g) => sum + (g.$1 < g.$2 ? g.$1 : g.$2),
  );
}
