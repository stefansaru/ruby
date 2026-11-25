/// Which doors and windows a case needs on its map (GEN-034).
library;

import 'clue.dart';
import 'model.dart';

/// The doors and windows of [c] that [clues] need: doors when a clue says
/// "in front of a door", windows likewise, and all of them when a clue is
/// about what someone can see, because openings let people see through
/// walls. Everything else is left off the map.
///
/// Both switches list every type and have no default, so a new clue or
/// test cannot be added without deciding here whether it reads openings.
List<Opening> usedOpenings(CaseDef c, List<Clue> clues) {
  var doors = false;
  var windows = false;
  var sight = false;
  void look(CellTest t) {
    switch (t) {
      case Not(:final CellTest inner):
        look(inner);
      case FrontOf(:final bool door):
        if (door) {
          doors = true;
        } else {
          windows = true;
        }
      case Sees():
        sight = true;
      case InArea() ||
          OnKind() ||
          BesideKind() ||
          InRow() ||
          InCol() ||
          InGrid() ||
          OnBorder() ||
          GridCorner() ||
          AreaCorner() ||
          LineHas():
        break;
    }
  }

  void read(Clue clue) {
    switch (clue) {
      case Is(:final CellTest test) ||
          OnlyOne(:final CellTest test) ||
          AllOthers(:final CellTest test) ||
          Count(:final CellTest test) ||
          Group(:final CellTest test):
        look(test);
      case Negated(:final Clue inner):
        read(inner);
      case Rel() || Alone() || AloneWith() || Others() || More():
        break;
    }
  }

  clues.forEach(read);
  return <Opening>[
    for (final Opening o in c.openings)
      if (sight || (o.isDoor ? doors : windows)) o,
  ];
}
