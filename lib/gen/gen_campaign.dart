/// The shipped case packs as a list of slots. Each slot is a pinned seed
/// and a configuration, so the packs can be rebuilt byte for byte.
library;

import 'dart:math';

import '../data/settings.dart';
import '../engine/model.dart' show randomIdPrefix;
import 'gen_config.dart';
import 'gen_scene.dart' show titleCount;

/// One kind of case inside a tier and how many of it to make.
class _Shape {
  const _Shape(
    this.count,
    this.grids, {
    this.irregular = false,
    this.liar = false,
    this.noTouch = false,
    this.traits = false,
  });
  final int count;
  final List<(int, int)> grids;
  final bool irregular;
  final bool liar;
  final bool noTouch;
  final bool traits;
}

const Map<Tier, List<_Shape>> _plan = <Tier, List<_Shape>>{
  Tier.tutorial: <_Shape>[
    _Shape(100, <(int, int)>[(4, 4)]),
  ],
  Tier.easy: <_Shape>[
    _Shape(50, <(int, int)>[(5, 5)]),
    _Shape(50, <(int, int)>[(6, 6)]),
  ],
  Tier.normal: <_Shape>[
    _Shape(50, <(int, int)>[(6, 6)]),
    _Shape(50, <(int, int)>[(7, 7)]),
  ],
  Tier.hard: <_Shape>[
    _Shape(25, <(int, int)>[(7, 7)], traits: true),
    _Shape(25, <(int, int)>[(8, 8)], traits: true),
    _Shape(17, <(int, int)>[(4, 4), (4, 4)]),
    _Shape(17, <(int, int)>[(6, 8)], traits: true),
    _Shape(16, <(int, int)>[(8, 8)], irregular: true),
  ],
  Tier.expert: <_Shape>[
    _Shape(12, <(int, int)>[(8, 8)], traits: true),
    _Shape(8, <(int, int)>[(9, 9)], traits: true),
    _Shape(8, <(int, int)>[(7, 7)], liar: true),
    _Shape(8, <(int, int)>[(8, 8)], noTouch: true),
  ],
};

/// Title indexes each tier may use per setting; the rest are for
/// [randomConfig].
const int _titlesPerTier = 10;

/// How many times the settings have all had a turn before slot [number].
/// A tier larger than its share of titles would repeat one: refuse it.
int titleRound(int number) {
  final round = (number - 1) ~/ settings.length;
  if (round >= _titlesPerTier) {
    throw StateError(
      'a tier holds at most ${_titlesPerTier * settings.length} cases '
      'before titles repeat',
    );
  }
  return round;
}

/// A fresh case of [tier] made on request (GEN-037): a shape from the
/// tier's plan, a setting and a title drawn from [seed]. Same seed, same
/// config. The id is not a shipped id, so it never gets a solved tick.
GenConfig randomConfig(Tier tier, int seed) {
  final rnd = Random(seed);
  final shapes = _plan[tier]!;
  final shape = shapes[rnd.nextInt(shapes.length)];
  final reserved = Tier.values.length * _titlesPerTier;
  return GenConfig(
    id: '$randomIdPrefix${tier.name}-$seed',
    tier: tier,
    setting: settings[rnd.nextInt(settings.length)].id,
    grids: shape.grids,
    seed: seed,
    titleIndex: reserved + rnd.nextInt(titleCount - reserved),
    irregular: shape.irregular,
    liar: shape.liar,
    noTouch: shape.noTouch,
    traits: shape.traits,
  );
}

/// Every slot of [tier], in pack order. Settings rotate so each pack
/// visits every place.
List<GenConfig> campaign(Tier tier) {
  final out = <GenConfig>[];
  for (final shape in _plan[tier]!) {
    for (var i = 0; i < shape.count; i++) {
      final number = out.length + 1;
      out.add(
        GenConfig(
          id: '${tier.name}-${number.toString().padLeft(3, '0')}',
          tier: tier,
          setting: settings[(number - 1) % settings.length].id,
          grids: shape.grids,
          seed: tier.index * 100000 + number * 7919,
          // Unique within the slot's setting: the settings take turns.
          titleIndex: tier.index * _titlesPerTier + titleRound(number),
          irregular: shape.irregular,
          liar: shape.liar,
          noTouch: shape.noTouch,
          traits: shape.traits,
        ),
      );
    }
  }
  return out;
}
