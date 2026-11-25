# Settings

Written 2026-11-24. A setting is the place a case happens in. It supplies the area names,
the objects and (later) the art. The list lives in `lib/data/settings.dart`, hand-written;
the generator builds scenes from it and the art list in `docs/Art.md` is derived from it.
This file mirrors that list. If the two differ, the code is right and this file is stale.

## The naming rule

**Short everyday words a ten-year-old knows; one word where possible.** Kitchen, Pond, chair,
tree. Not "Foreman's Office", "Kopje" or "jerrycan".

*Why:*

- A clue is read many times while solving. "She was beside a shelf in the Hall" has to be
  taken in at a glance.
- Plain words translate cleanly, and the game is meant to be translated.
- A plain word matches a plain picture. At phone size a "chair" tile is recognisable; a
  "transformer" tile is not.
- The puzzle books in this genre lean on exotic locations for flavour and pay for it in
  legend boxes explaining each new object. We would rather need no legend.

Two more rules follow from how clues are worded:

- **Object names are singular nouns that take "a" or "an"** ("a chair", "an umbrella"),
  because the sentence builder writes "beside a ...". A plural-looking name would read
  wrongly.
- **Within a setting, every object has its own one-letter code**, used in the case format.

## Which object goes where

**Each area lists the objects that belong in it, and an object is only ever placed in an
area that lists it** (GEN-029, 2026-11-24). A boat is on the Lake, the Sea or a Pond; a car
is in the Garage or on the Street; a bed is in a bedroom.

*Why:* the first build only knew "inside" and "outside", so a boat could land in the Pines
or on the Path. A scene that makes no sense makes the clues about it feel arbitrary.

| Column | Meaning |
|---|---|
| Objects that belong there | The only objects the generator may put in that area. |
| Can be on it | Yes: a person can stand on its square ("on a chair"). No: it blocks its square; people stand beside it. |
| Squares | 1, or 2 for a wide object. A wide object is drawn across two touching squares of one area when there is room, otherwise on one. |

A scene does not use every object: each area gets at most two kinds from its own list.
*Why:* a scene with many kinds of object is hard to read.

When a case has two grids, the grids take the setting's two grid names.

The tables below are written from `lib/data/settings.dart`; `test/data/mapping_test.dart`
checks the list itself and every shipped case against it.

## Titles

**A case title is "The", an adjective and one of its setting's title words** ("The Last
Ticket" on the Train). Each setting has twelve words and no word is in two settings
(GEN-033, 2026-11-25). *Why:* titles used to come from one list for every place, so a train
case could be "The Muddy Matchbox".

## The settings

### Home — grids: Downstairs, Upstairs

Title words: Teacup, Key, Slipper, Doorbell, Curtain, Saucepan, Cushion, Doormat, Armchair, Teapot, Photograph, Blanket.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Kitchen | yes | chair, table, shelf, plant |
| Bedroom | yes | bed, rug, chair, shelf |
| Bathroom | yes | rug, shelf, plant |
| Living Room | yes | chair, rug, table, plant |
| Hall | yes | rug, shelf, plant |
| Garden | no | tree, plant, chair, table |
| Garage | yes | car, shelf |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| chair | c | yes | 1 |
| bed | b | yes | 2 |
| rug | r | yes | 1 |
| table | t | no | 1 |
| shelf | s | no | 1 |
| plant | p | no | 1 |
| tree | e | no | 1 |
| car | a | yes | 2 |

### Beach — grids: North Beach, South Beach

Title words: Sandcastle, Seashell, Sunhat, Lighthouse, Tide, Deckchair, Lifebelt, Flip-Flop, Bucket, Crab, Postcard, Parasol.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Sand | no | towel, sunbed, umbrella, palm |
| Sea | no | boat, rock |
| Pier | no | chair, table |
| Cafe | yes | chair, table |
| Dunes | no | towel, palm, rock |
| Rocks | no | rock, towel |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| towel | w | yes | 1 |
| boat | b | yes | 2 |
| sunbed | d | yes | 1 |
| umbrella | u | no | 1 |
| palm | p | no | 1 |
| rock | k | no | 1 |
| chair | c | yes | 1 |
| table | t | no | 1 |

### Forest — grids: East Woods, West Woods

Title words: Acorn, Mushroom, Owl, Trail, Fern, Pinecone, Moss, Birdhouse, Hollow, Footprint, Axe, Birdsong.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Clearing | no | log, rock, bush |
| Pines | no | tree, bush, log, rock |
| Lake | no | boat, rock |
| Cabin | yes | chair, table, rug |
| Path | no | log, rock, bush |
| Cave | yes | rock, log |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| tree | e | no | 1 |
| bush | u | no | 1 |
| rock | k | no | 1 |
| log | l | yes | 1 |
| boat | b | yes | 2 |
| chair | c | yes | 1 |
| table | t | no | 1 |
| rug | r | yes | 1 |

### City — grids: Old Town, New Town

Title words: Taxi, Newspaper, Tram, Alley, Rooftop, Briefcase, Pigeon, Signpost, Receipt, Umbrella, Pavement, Clocktower.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Street | no | car, lamp, bin |
| Shop | yes | shelf, table, bin |
| Cafe | yes | table, chair, bin |
| Square | no | bench, lamp, tree, bin |
| Bank | yes | table, chair, shelf |
| Park | no | bench, tree, bin, lamp |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| car | a | yes | 2 |
| bench | n | yes | 1 |
| lamp | m | no | 1 |
| tree | e | no | 1 |
| shelf | s | no | 1 |
| table | t | no | 1 |
| chair | c | yes | 1 |
| bin | i | no | 1 |

### Farm — grids: Farmyard, Fields

Title words: Scarecrow, Pitchfork, Rooster, Haystack, Milk Pail, Horseshoe, Wheelbarrow, Fence, Egg Basket, Weathervane, Gate, Harvest.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Barn | yes | hay bale, tractor, cow, pig |
| Field | no | hay bale, tractor, cow |
| Yard | no | tractor, pig, hay bale |
| House | yes | chair, table, bed |
| Pond | no | rock |
| Orchard | no | tree, hay bale |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| hay bale | h | yes | 1 |
| tractor | a | yes | 2 |
| cow | o | no | 1 |
| pig | g | no | 1 |
| tree | e | no | 1 |
| chair | c | yes | 1 |
| table | t | no | 1 |
| bed | b | yes | 2 |
| rock | k | no | 1 |

### School — grids: Ground Floor, First Floor

Title words: Blackboard, Satchel, Ruler, Homework, Bell, Notebook, Chalk, Report Card, Lunchbox, Pencil, Register, Eraser.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Classroom | yes | desk, chair, shelf, bin |
| Library | yes | shelf, table, chair, desk |
| Gym | yes | mat, bench |
| Hall | yes | bench, bin, shelf |
| Canteen | yes | table, chair, bin |
| Yard | no | bench, tree, bin |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| desk | d | no | 1 |
| chair | c | yes | 1 |
| shelf | s | no | 1 |
| mat | m | yes | 1 |
| bench | n | yes | 1 |
| tree | e | no | 1 |
| table | t | no | 1 |
| bin | i | no | 1 |

### Train — grids: Front Cars, Rear Cars

Title words: Ticket, Luggage, Whistle, Timetable, Platform, Lantern, Carriage, Compartment, Signal, Tunnel, Berth, Luggage Rack.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Engine | yes | seat, shelf |
| First Class | yes | seat, table, rug, suitcase |
| Second Class | yes | seat, shelf, suitcase |
| Dining Car | yes | seat, table, rug |
| Sleeper | yes | bed, rug, suitcase |
| Luggage Car | yes | trunk, shelf, suitcase |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| seat | c | yes | 1 |
| bed | b | yes | 2 |
| table | t | no | 1 |
| trunk | k | no | 1 |
| rug | r | yes | 1 |
| shelf | s | no | 1 |
| suitcase | l | no | 1 |

### Ship — grids: Upper Deck, Lower Deck

Title words: Anchor, Porthole, Compass, Logbook, Lifebuoy, Rope, Gangway, Chart, Hammock, Spyglass, Sail, Cargo.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Deck | no | chair, lifeboat, barrel, crate |
| Bridge | yes | chair, table |
| Cabin | yes | bed, rug, chair, table |
| Galley | yes | table, barrel, chair |
| Hold | yes | crate, barrel |
| Bow | no | chair, barrel |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| chair | c | yes | 1 |
| bed | b | yes | 2 |
| crate | k | no | 1 |
| barrel | l | no | 1 |
| lifeboat | a | yes | 2 |
| table | t | no | 1 |
| rug | r | yes | 1 |

### Camp — grids: Lakeside, Hillside

Title words: Marshmallow, Sleeping Bag, Torch, Rucksack, Tent Peg, Kettle, Flask, Songbook, Paddle, Guy Rope, Firewood, Billycan.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Fire Ring | no | campfire, log, rock, chair |
| Tents | no | tent, chair |
| Lake | no | canoe, rock |
| Woods | no | tree, log, rock |
| Field | no | tent, chair, table |
| Kitchen | yes | table, chair |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| tent | n | yes | 1 |
| log | l | yes | 1 |
| canoe | b | yes | 2 |
| tree | e | no | 1 |
| campfire | f | no | 1 |
| rock | k | no | 1 |
| table | t | no | 1 |
| chair | c | yes | 1 |

### Hotel — grids: Ground Floor, First Floor

Title words: Room Key, Luggage Cart, Suite, Guestbook, Trolley, Towel, Minibar, Revolving Door, Elevator, Wake-Up Call, Pillow, Reservation.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Lobby | yes | sofa, desk, plant, chair |
| Room 1 | yes | bed, chair, desk |
| Room 2 | yes | bed, chair, desk |
| Bar | yes | chair, table, sofa |
| Pool | no | sunbed, plant |
| Kitchen | yes | table, chair |
| Garden | no | tree, plant, chair |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| bed | b | yes | 2 |
| chair | c | yes | 1 |
| sofa | o | yes | 2 |
| table | t | no | 1 |
| plant | p | no | 1 |
| desk | d | no | 1 |
| sunbed | u | yes | 1 |
| tree | e | no | 1 |

### Park — grids: North Park, South Park

Title words: Picnic, Kite, Duck, Bandstand, Ice Cream, Squirrel, Frisbee, Watering Can, Birdbath, Sundial, Carousel, Balloon.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Lawn | no | tree, bench, bush |
| Playground | no | swing, bench |
| Pond | no | boat |
| Path | no | bench, bush |
| Rose Garden | no | bush, fountain, bench |
| Cafe | yes | table, chair |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| bench | n | yes | 1 |
| tree | e | no | 1 |
| bush | u | no | 1 |
| fountain | f | no | 1 |
| swing | w | yes | 1 |
| boat | b | yes | 2 |
| table | t | no | 1 |
| chair | c | yes | 1 |

### Museum — grids: Ground Floor, First Floor

Title words: Painting, Fossil, Mummy, Catalogue, Exhibit, Audio Guide, Portrait, Relic, Display Case, Ticket Stub, Mask, Sculpture.

| Area | Indoor | Objects that belong there |
|---|---|---|
| Hall | yes | bench, statue, plant |
| Gallery | yes | bench, vase, statue |
| Dino Room | yes | skeleton, bench |
| Gift Shop | yes | shelf, vase |
| Cafe | yes | chair, table, plant |
| Garden | no | bench, statue, plant |

| Object | Code | Can be on it | Squares |
|---|---|---|---|
| bench | n | yes | 1 |
| statue | u | no | 1 |
| vase | v | no | 1 |
| skeleton | o | no | 1 |
| shelf | s | no | 1 |
| chair | c | yes | 1 |
| table | t | no | 1 |
| plant | p | no | 1 |

## Known rough edges (2026-11-24)

- The areas of a two-grid case are dealt to the grids at random, so "Upstairs" can receive
  the Garden (TODO 7).
- "Room 1" and "Room 2" break the one-word rule and sit next to row numbers in clues; they
  are candidates for renaming (Suite, Attic).
- An object that blocks must be a real obstacle. The Train's lamp was not, so it is a
  suitcase since 2026-11-25; the City's lamp is a lamp post and stays.
- A Pond on the Farm only has a rock, and the Pier only a chair and a table: plain, but
  nothing there is out of place. More objects mean more sprites.

## Adding a setting

1. Add a `SettingDef` to `lib/data/settings.dart`: id, name, two grid names, at least six
   areas (a two-grid case needs areas for both grids), and objects with unique one-letter
   codes. Include at least three objects a person can be on (two-square ones count) and three
   that block (the Museum has two to be on, bench and chair: the one exception,
   2026-11-25), and make
   sure both indoor and outdoor areas (if the setting has both) have objects that fit them.
2. Check the names against the naming rule above.
3. Add the setting to this file and its sprites to `docs/Art.md`.
4. Regenerate the packs (`docs/Levels.md`). Settings rotate through the slots by position in
   the list (slot number modulo the number of settings), so **adding, removing or reordering
   a setting moves most slots to a different place and changes most cases**. That is
   acceptable before release and a content change after it.
