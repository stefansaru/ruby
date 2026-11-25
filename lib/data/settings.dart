/// The settings a case can take place in: plain place names, plain area
/// names, and a small set of objects split into ones a person can be on
/// and ones that block a square. Hand-written; see docs/Settings.md.
///
/// The generator builds scenes from this list and the art list in
/// docs/Art.md is derived from it, so a new object here is a new sprite.
library;

class AreaSpec {
  const AreaSpec(this.name, this.kinds, {this.indoor = true});
  final String name;

  /// The codes of the objects that belong in this area. An object is only
  /// ever placed in an area that lists it (GEN-029): a boat on the Lake,
  /// never in the Pines.
  final String kinds;

  /// Indoor areas can have a window on an outer wall.
  final bool indoor;

  bool allows(KindSpec kind) => kinds.contains(kind.code);
}

class KindSpec {
  const KindSpec(this.code, this.name, {required this.sit, this.wide = false});

  /// One lower-case letter, unique within its setting.
  final String code;
  final String name;

  /// A person can be on it; otherwise it blocks its square.
  final bool sit;

  /// Drawn across two squares (a bed, a car, a boat).
  final bool wide;
}

class SettingDef {
  const SettingDef(
    this.id,
    this.name,
    this.gridNames,
    this.areas,
    this.kinds,
    this.titles,
  );
  final String id;
  final String name;

  /// The names of the two grids when a case is split in two.
  final List<String> gridNames;
  final List<AreaSpec> areas;
  final List<KindSpec> kinds;

  /// Things that belong to this place, for case titles ("The Last
  /// Ticket"). No word appears in two settings (GEN-033).
  final List<String> titles;
}

const List<SettingDef> settings = <SettingDef>[
  SettingDef(
    'home',
    'Home',
    <String>['Downstairs', 'Upstairs'],
    <AreaSpec>[
      AreaSpec('Kitchen', 'ctsp'),
      AreaSpec('Bedroom', 'brcs'),
      AreaSpec('Bathroom', 'rsp'),
      AreaSpec('Living Room', 'crtp'),
      AreaSpec('Hall', 'rsp'),
      AreaSpec('Garden', 'epct', indoor: false),
      AreaSpec('Garage', 'as'),
    ],
    <KindSpec>[
      KindSpec('c', 'chair', sit: true),
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('r', 'rug', sit: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('p', 'plant', sit: false),
      KindSpec('e', 'tree', sit: false),
      KindSpec('a', 'car', sit: true, wide: true),
    ],
    <String>[
      'Teacup',
      'Key',
      'Slipper',
      'Doorbell',
      'Curtain',
      'Saucepan',
      'Cushion',
      'Doormat',
      'Armchair',
      'Teapot',
      'Photograph',
      'Blanket',
    ],
  ),
  SettingDef(
    'beach',
    'Beach',
    <String>['North Beach', 'South Beach'],
    <AreaSpec>[
      AreaSpec('Sand', 'wdup', indoor: false),
      AreaSpec('Sea', 'bk', indoor: false),
      AreaSpec('Pier', 'ct', indoor: false),
      AreaSpec('Cafe', 'ct'),
      AreaSpec('Dunes', 'wpk', indoor: false),
      AreaSpec('Rocks', 'kw', indoor: false),
    ],
    <KindSpec>[
      KindSpec('w', 'towel', sit: true),
      KindSpec('b', 'boat', sit: true, wide: true),
      KindSpec('d', 'sunbed', sit: true),
      KindSpec('u', 'umbrella', sit: false),
      KindSpec('p', 'palm', sit: false),
      KindSpec('k', 'rock', sit: false),
      KindSpec('c', 'chair', sit: true),
      KindSpec('t', 'table', sit: false),
    ],
    <String>[
      'Sandcastle',
      'Seashell',
      'Sunhat',
      'Lighthouse',
      'Tide',
      'Deckchair',
      'Lifebelt',
      'Flip-Flop',
      'Bucket',
      'Crab',
      'Postcard',
      'Parasol',
    ],
  ),
  SettingDef(
    'forest',
    'Forest',
    <String>['East Woods', 'West Woods'],
    <AreaSpec>[
      AreaSpec('Clearing', 'lku', indoor: false),
      AreaSpec('Pines', 'eulk', indoor: false),
      AreaSpec('Lake', 'bk', indoor: false),
      AreaSpec('Cabin', 'ctr'),
      AreaSpec('Path', 'lku', indoor: false),
      AreaSpec('Cave', 'kl'),
    ],
    <KindSpec>[
      KindSpec('e', 'tree', sit: false),
      KindSpec('u', 'bush', sit: false),
      KindSpec('k', 'rock', sit: false),
      KindSpec('l', 'log', sit: true),
      KindSpec('b', 'boat', sit: true, wide: true),
      KindSpec('c', 'chair', sit: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('r', 'rug', sit: true),
    ],
    <String>[
      'Acorn',
      'Mushroom',
      'Owl',
      'Trail',
      'Fern',
      'Pinecone',
      'Moss',
      'Birdhouse',
      'Hollow',
      'Footprint',
      'Axe',
      'Birdsong',
    ],
  ),
  SettingDef(
    'city',
    'City',
    <String>['Old Town', 'New Town'],
    <AreaSpec>[
      AreaSpec('Street', 'ami', indoor: false),
      AreaSpec('Shop', 'sti'),
      AreaSpec('Cafe', 'tci'),
      AreaSpec('Square', 'nmei', indoor: false),
      AreaSpec('Bank', 'tcs'),
      AreaSpec('Park', 'neim', indoor: false),
    ],
    <KindSpec>[
      KindSpec('a', 'car', sit: true, wide: true),
      KindSpec('n', 'bench', sit: true),
      KindSpec('m', 'lamp', sit: false),
      KindSpec('e', 'tree', sit: false),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('t', 'table', sit: false),
      KindSpec('c', 'chair', sit: true),
      KindSpec('i', 'bin', sit: false),
    ],
    <String>[
      'Taxi',
      'Newspaper',
      'Tram',
      'Alley',
      'Rooftop',
      'Briefcase',
      'Pigeon',
      'Signpost',
      'Receipt',
      'Umbrella',
      'Pavement',
      'Clocktower',
    ],
  ),
  SettingDef(
    'farm',
    'Farm',
    <String>['Farmyard', 'Fields'],
    <AreaSpec>[
      AreaSpec('Barn', 'haog'),
      AreaSpec('Field', 'hao', indoor: false),
      AreaSpec('Yard', 'agh', indoor: false),
      AreaSpec('House', 'ctb'),
      AreaSpec('Pond', 'k', indoor: false),
      AreaSpec('Orchard', 'eh', indoor: false),
    ],
    <KindSpec>[
      KindSpec('h', 'hay bale', sit: true),
      KindSpec('a', 'tractor', sit: true, wide: true),
      KindSpec('o', 'cow', sit: false),
      KindSpec('g', 'pig', sit: false),
      KindSpec('e', 'tree', sit: false),
      KindSpec('c', 'chair', sit: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('k', 'rock', sit: false),
    ],
    <String>[
      'Scarecrow',
      'Pitchfork',
      'Rooster',
      'Haystack',
      'Milk Pail',
      'Horseshoe',
      'Wheelbarrow',
      'Fence',
      'Egg Basket',
      'Weathervane',
      'Gate',
      'Harvest',
    ],
  ),
  SettingDef(
    'school',
    'School',
    <String>['Ground Floor', 'First Floor'],
    <AreaSpec>[
      AreaSpec('Classroom', 'dcsi'),
      AreaSpec('Library', 'stcd'),
      AreaSpec('Gym', 'mn'),
      AreaSpec('Hall', 'nis'),
      AreaSpec('Canteen', 'tci'),
      AreaSpec('Yard', 'nei', indoor: false),
    ],
    <KindSpec>[
      KindSpec('d', 'desk', sit: false),
      KindSpec('c', 'chair', sit: true),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('m', 'mat', sit: true),
      KindSpec('n', 'bench', sit: true),
      KindSpec('e', 'tree', sit: false),
      KindSpec('t', 'table', sit: false),
      KindSpec('i', 'bin', sit: false),
    ],
    <String>[
      'Blackboard',
      'Satchel',
      'Ruler',
      'Homework',
      'Bell',
      'Notebook',
      'Chalk',
      'Report Card',
      'Lunchbox',
      'Pencil',
      'Register',
      'Eraser',
    ],
  ),
  SettingDef(
    'train',
    'Train',
    <String>['Front Cars', 'Rear Cars'],
    <AreaSpec>[
      AreaSpec('Engine', 'cs'),
      AreaSpec('First Class', 'ctrl'),
      AreaSpec('Second Class', 'csl'),
      AreaSpec('Dining Car', 'ctr'),
      AreaSpec('Sleeper', 'brl'),
      AreaSpec('Luggage Car', 'ksl'),
    ],
    <KindSpec>[
      KindSpec('c', 'seat', sit: true),
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('k', 'trunk', sit: false),
      KindSpec('r', 'rug', sit: true),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('l', 'suitcase', sit: false),
    ],
    <String>[
      'Ticket',
      'Luggage',
      'Whistle',
      'Timetable',
      'Platform',
      'Lantern',
      'Carriage',
      'Compartment',
      'Signal',
      'Tunnel',
      'Berth',
      'Luggage Rack',
    ],
  ),
  SettingDef(
    'ship',
    'Ship',
    <String>['Upper Deck', 'Lower Deck'],
    <AreaSpec>[
      AreaSpec('Deck', 'calk', indoor: false),
      AreaSpec('Bridge', 'ct'),
      AreaSpec('Cabin', 'brct'),
      AreaSpec('Galley', 'tlc'),
      AreaSpec('Hold', 'kl'),
      AreaSpec('Bow', 'cl', indoor: false),
    ],
    <KindSpec>[
      KindSpec('c', 'chair', sit: true),
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('k', 'crate', sit: false),
      KindSpec('l', 'barrel', sit: false),
      KindSpec('a', 'lifeboat', sit: true, wide: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('r', 'rug', sit: true),
    ],
    <String>[
      'Anchor',
      'Porthole',
      'Compass',
      'Logbook',
      'Lifebuoy',
      'Rope',
      'Gangway',
      'Chart',
      'Hammock',
      'Spyglass',
      'Sail',
      'Cargo',
    ],
  ),
  SettingDef(
    'camp',
    'Camp',
    <String>['Lakeside', 'Hillside'],
    <AreaSpec>[
      AreaSpec('Fire Ring', 'flkc', indoor: false),
      AreaSpec('Tents', 'nc', indoor: false),
      AreaSpec('Lake', 'bk', indoor: false),
      AreaSpec('Woods', 'elk', indoor: false),
      AreaSpec('Field', 'nct', indoor: false),
      AreaSpec('Kitchen', 'tc'),
    ],
    <KindSpec>[
      KindSpec('n', 'tent', sit: true),
      KindSpec('l', 'log', sit: true),
      KindSpec('b', 'canoe', sit: true, wide: true),
      KindSpec('e', 'tree', sit: false),
      KindSpec('f', 'campfire', sit: false),
      KindSpec('k', 'rock', sit: false),
      KindSpec('t', 'table', sit: false),
      KindSpec('c', 'chair', sit: true),
    ],
    <String>[
      'Marshmallow',
      'Sleeping Bag',
      'Torch',
      'Rucksack',
      'Tent Peg',
      'Kettle',
      'Flask',
      'Songbook',
      'Paddle',
      'Guy Rope',
      'Firewood',
      'Billycan',
    ],
  ),
  SettingDef(
    'hotel',
    'Hotel',
    <String>['Ground Floor', 'First Floor'],
    <AreaSpec>[
      AreaSpec('Lobby', 'odpc'),
      AreaSpec('Room 1', 'bcd'),
      AreaSpec('Room 2', 'bcd'),
      AreaSpec('Bar', 'cto'),
      AreaSpec('Pool', 'up', indoor: false),
      AreaSpec('Kitchen', 'tc'),
      AreaSpec('Garden', 'epc', indoor: false),
    ],
    <KindSpec>[
      KindSpec('b', 'bed', sit: true, wide: true),
      KindSpec('c', 'chair', sit: true),
      KindSpec('o', 'sofa', sit: true, wide: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('p', 'plant', sit: false),
      KindSpec('d', 'desk', sit: false),
      KindSpec('u', 'sunbed', sit: true),
      KindSpec('e', 'tree', sit: false),
    ],
    <String>[
      'Room Key',
      'Luggage Cart',
      'Suite',
      'Guestbook',
      'Trolley',
      'Towel',
      'Minibar',
      'Revolving Door',
      'Elevator',
      'Wake-Up Call',
      'Pillow',
      'Reservation',
    ],
  ),
  SettingDef(
    'park',
    'Park',
    <String>['North Park', 'South Park'],
    <AreaSpec>[
      AreaSpec('Lawn', 'enu', indoor: false),
      AreaSpec('Playground', 'wn', indoor: false),
      AreaSpec('Pond', 'b', indoor: false),
      AreaSpec('Path', 'nu', indoor: false),
      AreaSpec('Rose Garden', 'ufn', indoor: false),
      AreaSpec('Cafe', 'tc'),
    ],
    <KindSpec>[
      KindSpec('n', 'bench', sit: true),
      KindSpec('e', 'tree', sit: false),
      KindSpec('u', 'bush', sit: false),
      KindSpec('f', 'fountain', sit: false),
      KindSpec('w', 'swing', sit: true),
      KindSpec('b', 'boat', sit: true, wide: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('c', 'chair', sit: true),
    ],
    <String>[
      'Picnic',
      'Kite',
      'Duck',
      'Bandstand',
      'Ice Cream',
      'Squirrel',
      'Frisbee',
      'Watering Can',
      'Birdbath',
      'Sundial',
      'Carousel',
      'Balloon',
    ],
  ),
  SettingDef(
    'museum',
    'Museum',
    <String>['Ground Floor', 'First Floor'],
    <AreaSpec>[
      AreaSpec('Hall', 'nup'),
      AreaSpec('Gallery', 'nvu'),
      AreaSpec('Dino Room', 'on'),
      AreaSpec('Gift Shop', 'sv'),
      AreaSpec('Cafe', 'ctp'),
      AreaSpec('Garden', 'nup', indoor: false),
    ],
    <KindSpec>[
      KindSpec('n', 'bench', sit: true),
      KindSpec('u', 'statue', sit: false),
      KindSpec('v', 'vase', sit: false),
      KindSpec('o', 'skeleton', sit: false),
      KindSpec('s', 'shelf', sit: false),
      KindSpec('c', 'chair', sit: true),
      KindSpec('t', 'table', sit: false),
      KindSpec('p', 'plant', sit: false),
    ],
    <String>[
      'Painting',
      'Fossil',
      'Mummy',
      'Catalogue',
      'Exhibit',
      'Audio Guide',
      'Portrait',
      'Relic',
      'Display Case',
      'Ticket Stub',
      'Mask',
      'Sculpture',
    ],
  ),
];
