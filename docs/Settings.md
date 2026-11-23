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

## What an object entry says

| Column | Meaning |
|---|---|
| Can be on it | Yes: a person can stand on its square ("on a chair"). No: it blocks its square; people stand beside it. |
| Where | inside: only in indoor areas. outside: only in outdoor areas. anywhere: both. |
| Squares | 1, or 2 for a wide object. A wide object is drawn across two touching squares of one area when there is room, otherwise on one. |

A scene does not use every object of its setting: the generator picks two or three objects
you can be on and two or three that block, then places them only in areas where they belong.
*Why:* a scene with eight kinds of object is hard to read; four to six is plenty for clues.

When a case has two grids, the grids take the setting's two grid names.

## The settings

### Home — grids: Downstairs, Upstairs

Areas: Kitchen, Bedroom, Bathroom, Living Room, Hall, Garage (indoor); Garden (outdoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| chair | c | yes | inside | 1 |
| bed | b | yes | inside | 2 |
| rug | r | yes | inside | 1 |
| table | t | no | inside | 1 |
| shelf | s | no | inside | 1 |
| plant | p | no | anywhere | 1 |
| tree | e | no | outside | 1 |
| car | a | yes | anywhere | 2 |

### Beach — grids: North Beach, South Beach

Areas: Sand, Sea, Pier, Dunes, Rocks (outdoor); Cafe (indoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| towel | w | yes | outside | 1 |
| boat | b | yes | outside | 2 |
| sunbed | d | yes | outside | 1 |
| umbrella | u | no | outside | 1 |
| palm | p | no | outside | 1 |
| rock | k | no | outside | 1 |
| chair | c | yes | inside | 1 |
| table | t | no | inside | 1 |

### Forest — grids: East Woods, West Woods

Areas: Clearing, Pines, Lake, Path (outdoor); Cabin, Cave (indoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| tree | e | no | outside | 1 |
| bush | u | no | outside | 1 |
| rock | k | no | anywhere | 1 |
| log | l | yes | outside | 1 |
| boat | b | yes | outside | 2 |
| chair | c | yes | inside | 1 |
| table | t | no | inside | 1 |
| rug | r | yes | inside | 1 |

### City — grids: Old Town, New Town

Areas: Street, Square, Park (outdoor); Shop, Cafe, Bank (indoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| car | a | yes | outside | 2 |
| bench | n | yes | outside | 1 |
| lamp | m | no | outside | 1 |
| tree | e | no | outside | 1 |
| shelf | s | no | inside | 1 |
| table | t | no | inside | 1 |
| chair | c | yes | inside | 1 |
| bin | i | no | anywhere | 1 |

### Farm — grids: Farmyard, Fields

Areas: Field, Yard, Pond, Orchard (outdoor); Barn, House (indoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| hay bale | h | yes | anywhere | 1 |
| tractor | a | yes | outside | 2 |
| cow | o | no | outside | 1 |
| pig | g | no | outside | 1 |
| tree | e | no | outside | 1 |
| chair | c | yes | inside | 1 |
| table | t | no | inside | 1 |
| bed | b | yes | inside | 2 |

### School — grids: Ground Floor, First Floor

Areas: Classroom, Library, Gym, Hall, Canteen (indoor); Yard (outdoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| desk | d | no | inside | 1 |
| chair | c | yes | inside | 1 |
| shelf | s | no | inside | 1 |
| mat | m | yes | inside | 1 |
| bench | n | yes | anywhere | 1 |
| tree | e | no | outside | 1 |
| table | t | no | inside | 1 |
| bin | i | no | anywhere | 1 |

### Train — grids: Front Cars, Rear Cars

Areas (all indoor): Engine, First Class, Second Class, Dining Car, Sleeper, Luggage Car.

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| seat | c | yes | inside | 1 |
| bed | b | yes | inside | 2 |
| table | t | no | inside | 1 |
| trunk | k | no | inside | 1 |
| rug | r | yes | inside | 1 |
| shelf | s | no | inside | 1 |
| lamp | l | no | inside | 1 |

### Ship — grids: Upper Deck, Lower Deck

Areas: Deck, Bow (outdoor); Bridge, Cabin, Galley, Hold (indoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| chair | c | yes | anywhere | 1 |
| bed | b | yes | inside | 2 |
| crate | k | no | anywhere | 1 |
| barrel | l | no | anywhere | 1 |
| lifeboat | a | yes | outside | 2 |
| table | t | no | inside | 1 |
| rug | r | yes | inside | 1 |

### Camp — grids: Lakeside, Hillside

Areas: Fire Ring, Tents, Lake, Woods, Field (outdoor); Kitchen (indoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| tent | n | yes | outside | 1 |
| log | l | yes | outside | 1 |
| canoe | b | yes | outside | 2 |
| tree | e | no | outside | 1 |
| campfire | f | no | outside | 1 |
| rock | k | no | outside | 1 |
| table | t | no | anywhere | 1 |
| chair | c | yes | anywhere | 1 |

### Hotel — grids: Ground Floor, First Floor

Areas: Lobby, Room 1, Room 2, Bar, Kitchen (indoor); Pool, Garden (outdoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| bed | b | yes | inside | 2 |
| chair | c | yes | inside | 1 |
| sofa | o | yes | inside | 2 |
| table | t | no | inside | 1 |
| plant | p | no | anywhere | 1 |
| desk | d | no | inside | 1 |
| sunbed | u | yes | outside | 1 |
| tree | e | no | outside | 1 |

### Park — grids: North Park, South Park

Areas: Lawn, Playground, Pond, Path, Rose Garden (outdoor); Cafe (indoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| bench | n | yes | outside | 1 |
| tree | e | no | outside | 1 |
| bush | u | no | outside | 1 |
| fountain | f | no | outside | 1 |
| swing | w | yes | outside | 1 |
| boat | b | yes | outside | 2 |
| table | t | no | inside | 1 |
| chair | c | yes | inside | 1 |

### Museum — grids: Ground Floor, First Floor

Areas: Hall, Gallery, Dino Room, Gift Shop, Cafe (indoor); Garden (outdoor).

| Object | Code | Can be on it | Where | Squares |
|---|---|---|---|---|
| bench | n | yes | anywhere | 1 |
| statue | u | no | anywhere | 1 |
| vase | v | no | inside | 1 |
| skeleton | o | no | inside | 1 |
| shelf | s | no | inside | 1 |
| chair | c | yes | inside | 1 |
| table | t | no | inside | 1 |
| plant | p | no | anywhere | 1 |

## Known rough edges (2026-11-24)

- Some pairings the "where" rule allows read oddly: a boat can land in the Dunes or on the
  Path because both are outdoor; a rock in a Cave is fine but a rock in a Cabin is also
  allowed. Fixing this needs a finer rule than inside/outside (for example a list of areas
  per object). Listed in TODO.
- The areas of a two-grid case are dealt to the grids at random, so "Upstairs" can receive
  the Garden. Same fix.
- "Room 1" and "Room 2" break the one-word rule and sit next to row numbers in clues; they
  are candidates for renaming (Suite, Attic).

## Adding a setting

1. Add a `SettingDef` to `lib/data/settings.dart`: id, name, two grid names, at least six
   areas (a two-grid case needs areas for both grids), and objects with unique one-letter
   codes. Include at least three objects a person can be on and three that block, and make
   sure both indoor and outdoor areas (if the setting has both) have objects that fit them.
2. Check the names against the naming rule above.
3. Add the setting to this file and its sprites to `docs/Art.md`.
4. Regenerate the packs (`docs/Levels.md`). Settings rotate through the slots by position in
   the list (slot number modulo the number of settings), so **adding, removing or reordering
   a setting moves most slots to a different place and changes most cases**. That is
   acceptable before release and a content change after it.
