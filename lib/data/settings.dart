/// The settings a case can take place in: plain place names, plain area
/// names, and a small set of objects split into ones a person can be on
/// and ones that block a square. Hand-written; see docs/Settings.md.
///
/// The generator builds scenes from this list and the art list in
/// docs/Art.md is derived from it, so a new object here is a new sprite.
library;

enum Where { inside, outside, anywhere }

class AreaSpec {
  const AreaSpec(this.name, {this.indoor = true});
  final String name;
  final bool indoor;
}

class KindSpec {
  const KindSpec(
    this.code,
    this.name, {
    required this.sit,
    this.where = Where.inside,
    this.wide = false,
  });

  /// One lower-case letter, unique within its setting.
  final String code;
  final String name;

  /// A person can be on it; otherwise it blocks its square.
  final bool sit;
  final Where where;

  /// Drawn across two squares (a bed, a car, a boat).
  final bool wide;
}

class SettingDef {
  const SettingDef(this.id, this.name, this.gridNames, this.areas, this.kinds);
  final String id;
  final String name;

  /// The names of the two grids when a case is split in two.
  final List<String> gridNames;
  final List<AreaSpec> areas;
  final List<KindSpec> kinds;
}

const _out = Where.outside;
const _any = Where.anywhere;

const List<SettingDef> settings = <SettingDef>[
  SettingDef(
    'home',
    'Home',
    <String>['Downstairs', 'Upstairs'],
    <AreaSpec>[
      AreaSpec('Kitchen'),
      AreaSpec('Bedroom'),
      AreaSpec('Bathroom'),
      AreaSpec('Living Room'),
      AreaSpec('Hall'),
      AreaSpec('Garden', indoor: false),
      AreaSpec('Garage'),
    ],
    <KindSpec>[
      KindSpec('c', 'chair', sit: true),
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('r', 'rug', sit: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('p', 'plant', sit: false, where: _any),
      KindSpec('e', 'tree', sit: false, where: _out),
      KindSpec('a', 'car', sit: true, where: _any, wide: true),
    ],
  ),
  SettingDef(
    'beach',
    'Beach',
    <String>['North Beach', 'South Beach'],
    <AreaSpec>[
      AreaSpec('Sand', indoor: false),
      AreaSpec('Sea', indoor: false),
      AreaSpec('Pier', indoor: false),
      AreaSpec('Cafe'),
      AreaSpec('Dunes', indoor: false),
      AreaSpec('Rocks', indoor: false),
    ],
    <KindSpec>[
      KindSpec('w', 'towel', sit: true, where: _out),
      KindSpec('b', 'boat', sit: true, where: _out, wide: true),
      KindSpec('d', 'sunbed', sit: true, where: _out),
      KindSpec('u', 'umbrella', sit: false, where: _out),
      KindSpec('p', 'palm', sit: false, where: _out),
      KindSpec('k', 'rock', sit: false, where: _out),
      KindSpec('c', 'chair', sit: true),
      KindSpec('t', 'table', sit: false),
    ],
  ),
  SettingDef(
    'forest',
    'Forest',
    <String>['East Woods', 'West Woods'],
    <AreaSpec>[
      AreaSpec('Clearing', indoor: false),
      AreaSpec('Pines', indoor: false),
      AreaSpec('Lake', indoor: false),
      AreaSpec('Cabin'),
      AreaSpec('Path', indoor: false),
      AreaSpec('Cave'),
    ],
    <KindSpec>[
      KindSpec('e', 'tree', sit: false, where: _out),
      KindSpec('u', 'bush', sit: false, where: _out),
      KindSpec('k', 'rock', sit: false, where: _any),
      KindSpec('l', 'log', sit: true, where: _out),
      KindSpec('b', 'boat', sit: true, where: _out, wide: true),
      KindSpec('c', 'chair', sit: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('r', 'rug', sit: true),
    ],
  ),
  SettingDef(
    'city',
    'City',
    <String>['Old Town', 'New Town'],
    <AreaSpec>[
      AreaSpec('Street', indoor: false),
      AreaSpec('Shop'),
      AreaSpec('Cafe'),
      AreaSpec('Square', indoor: false),
      AreaSpec('Bank'),
      AreaSpec('Park', indoor: false),
    ],
    <KindSpec>[
      KindSpec('a', 'car', sit: true, where: _out, wide: true),
      KindSpec('n', 'bench', sit: true, where: _out),
      KindSpec('m', 'lamp', sit: false, where: _out),
      KindSpec('e', 'tree', sit: false, where: _out),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('t', 'table', sit: false),
      KindSpec('c', 'chair', sit: true),
      KindSpec('i', 'bin', sit: false, where: _any),
    ],
  ),
  SettingDef(
    'farm',
    'Farm',
    <String>['Farmyard', 'Fields'],
    <AreaSpec>[
      AreaSpec('Barn'),
      AreaSpec('Field', indoor: false),
      AreaSpec('Yard', indoor: false),
      AreaSpec('House'),
      AreaSpec('Pond', indoor: false),
      AreaSpec('Orchard', indoor: false),
    ],
    <KindSpec>[
      KindSpec('h', 'hay bale', sit: true, where: _any),
      KindSpec('a', 'tractor', sit: true, where: _out, wide: true),
      KindSpec('o', 'cow', sit: false, where: _out),
      KindSpec('g', 'pig', sit: false, where: _out),
      KindSpec('e', 'tree', sit: false, where: _out),
      KindSpec('c', 'chair', sit: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('b', 'bed', sit: true, wide: true),
    ],
  ),
  SettingDef(
    'school',
    'School',
    <String>['Ground Floor', 'First Floor'],
    <AreaSpec>[
      AreaSpec('Classroom'),
      AreaSpec('Library'),
      AreaSpec('Gym'),
      AreaSpec('Hall'),
      AreaSpec('Canteen'),
      AreaSpec('Yard', indoor: false),
    ],
    <KindSpec>[
      KindSpec('d', 'desk', sit: false),
      KindSpec('c', 'chair', sit: true),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('m', 'mat', sit: true),
      KindSpec('n', 'bench', sit: true, where: _any),
      KindSpec('e', 'tree', sit: false, where: _out),
      KindSpec('t', 'table', sit: false),
      KindSpec('i', 'bin', sit: false, where: _any),
    ],
  ),
  SettingDef(
    'train',
    'Train',
    <String>['Front Cars', 'Rear Cars'],
    <AreaSpec>[
      AreaSpec('Engine'),
      AreaSpec('First Class'),
      AreaSpec('Second Class'),
      AreaSpec('Dining Car'),
      AreaSpec('Sleeper'),
      AreaSpec('Luggage Car'),
    ],
    <KindSpec>[
      KindSpec('c', 'seat', sit: true),
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('k', 'trunk', sit: false),
      KindSpec('r', 'rug', sit: true),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('l', 'lamp', sit: false),
    ],
  ),
  SettingDef(
    'ship',
    'Ship',
    <String>['Upper Deck', 'Lower Deck'],
    <AreaSpec>[
      AreaSpec('Deck', indoor: false),
      AreaSpec('Bridge'),
      AreaSpec('Cabin'),
      AreaSpec('Galley'),
      AreaSpec('Hold'),
      AreaSpec('Bow', indoor: false),
    ],
    <KindSpec>[
      KindSpec('c', 'chair', sit: true, where: _any),
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('k', 'crate', sit: false, where: _any),
      KindSpec('l', 'barrel', sit: false, where: _any),
      KindSpec('a', 'lifeboat', sit: true, where: _out, wide: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('r', 'rug', sit: true),
    ],
  ),
  SettingDef(
    'camp',
    'Camp',
    <String>['Lakeside', 'Hillside'],
    <AreaSpec>[
      AreaSpec('Fire Ring', indoor: false),
      AreaSpec('Tents', indoor: false),
      AreaSpec('Lake', indoor: false),
      AreaSpec('Woods', indoor: false),
      AreaSpec('Field', indoor: false),
      AreaSpec('Kitchen'),
    ],
    <KindSpec>[
      KindSpec('n', 'tent', sit: true, where: _out),
      KindSpec('l', 'log', sit: true, where: _out),
      KindSpec('b', 'canoe', sit: true, where: _out, wide: true),
      KindSpec('e', 'tree', sit: false, where: _out),
      KindSpec('f', 'campfire', sit: false, where: _out),
      KindSpec('k', 'rock', sit: false, where: _out),
      KindSpec('t', 'table', sit: false, where: _any),
      KindSpec('c', 'chair', sit: true, where: _any),
    ],
  ),
  SettingDef(
    'hotel',
    'Hotel',
    <String>['Ground Floor', 'First Floor'],
    <AreaSpec>[
      AreaSpec('Lobby'),
      AreaSpec('Room 1'),
      AreaSpec('Room 2'),
      AreaSpec('Bar'),
      AreaSpec('Pool', indoor: false),
      AreaSpec('Kitchen'),
      AreaSpec('Garden', indoor: false),
    ],
    <KindSpec>[
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('c', 'chair', sit: true),
      KindSpec('o', 'sofa', sit: true, wide: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('p', 'plant', sit: false, where: _any),
      KindSpec('d', 'desk', sit: false),
      KindSpec('u', 'sunbed', sit: true, where: _out),
      KindSpec('e', 'tree', sit: false, where: _out),
    ],
  ),
  SettingDef(
    'park',
    'Park',
    <String>['North Park', 'South Park'],
    <AreaSpec>[
      AreaSpec('Lawn', indoor: false),
      AreaSpec('Playground', indoor: false),
      AreaSpec('Pond', indoor: false),
      AreaSpec('Path', indoor: false),
      AreaSpec('Rose Garden', indoor: false),
      AreaSpec('Cafe'),
    ],
    <KindSpec>[
      KindSpec('n', 'bench', sit: true, where: _out),
      KindSpec('e', 'tree', sit: false, where: _out),
      KindSpec('u', 'bush', sit: false, where: _out),
      KindSpec('f', 'fountain', sit: false, where: _out),
      KindSpec('w', 'swing', sit: true, where: _out),
      KindSpec('b', 'boat', sit: true, where: _out, wide: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('c', 'chair', sit: true),
    ],
  ),
  SettingDef(
    'museum',
    'Museum',
    <String>['Ground Floor', 'First Floor'],
    <AreaSpec>[
      AreaSpec('Hall'),
      AreaSpec('Gallery'),
      AreaSpec('Dino Room'),
      AreaSpec('Gift Shop'),
      AreaSpec('Cafe'),
      AreaSpec('Garden', indoor: false),
    ],
    <KindSpec>[
      KindSpec('n', 'bench', sit: true, where: _any),
      KindSpec('u', 'statue', sit: false, where: _any),
      KindSpec('v', 'vase', sit: false),
      KindSpec('o', 'skeleton', sit: false),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('c', 'chair', sit: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('p', 'plant', sit: false, where: _any),
    ],
  ),
];
