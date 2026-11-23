/// The shipped case packs as a list of slots. Each slot is a pinned seed
/// and a configuration, so the packs can be rebuilt byte for byte.
library;

import '../data/settings.dart';
import 'gen_config.dart';

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
    _Shape(6, <(int, int)>[(4, 4)]),
  ],
  Tier.easy: <_Shape>[
    _Shape(24, <(int, int)>[(5, 5)]),
    _Shape(24, <(int, int)>[(6, 6)]),
  ],
  Tier.normal: <_Shape>[
    _Shape(24, <(int, int)>[(6, 6)]),
    _Shape(24, <(int, int)>[(7, 7)]),
  ],
  Tier.hard: <_Shape>[
    _Shape(12, <(int, int)>[(7, 7)], traits: true),
    _Shape(12, <(int, int)>[(8, 8)], traits: true),
    _Shape(8, <(int, int)>[(4, 4), (4, 4)]),
    _Shape(8, <(int, int)>[(6, 8)], traits: true),
    _Shape(8, <(int, int)>[(8, 8)], irregular: true),
  ],
  Tier.expert: <_Shape>[
    _Shape(12, <(int, int)>[(8, 8)], traits: true),
    _Shape(8, <(int, int)>[(9, 9)], traits: true),
    _Shape(8, <(int, int)>[(7, 7)], liar: true),
    _Shape(8, <(int, int)>[(8, 8)], noTouch: true),
  ],
};

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
          titleIndex: tier.index * 96 + number - 1,
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
