/// Hand-written cases used across the engine tests.
library;

import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/model.dart';

/// A 4x4 starter case: three suspects and the victim, three areas.
const String starterCase = '''
case test-starter
title The Quiet Garden
setting home
area G Garden
area K Kitchen
area P Pond
kind c sit chair
kind t block table
kind r block tree
grid Home 4 4
Gr. G.. G.. K..
G.. Gc. K.. Kt.
P.. G.. K.. K..
Pr. P.. P.. K..
person A Anna f
person B Ben m
person C Cora f
victim D Dan m
clue A is on c
clue B is beside t
clue C is in P
clue C is beside r
solution A=1:2:2 B=1:1:4 C=1:3:1 D=1:4:3
''';

/// A 5x5 board with a door, a window and five people, without clues.
/// Tests add clue lines with [board].
const String _board = '''
case test-board
title Clue Board
setting home
area K Kitchen
area G Garden
area H Hall
kind c sit chair
kind t block table
kind e block tree
grid Home 5 5
K.. K.. Kt. G.. Ge.
Kc. K.. K.. G.. G..
H.. H.. H.. G.. Gc.
H.. Ht. H.. G.. G..
H.. H.. Hc. G.. Ge.
open Home 2 3 E door
open Home 1 1 N window
person A Anna f hat
person B Ben m
person C Cora f hat
person D Dan m glasses
victim E Eva f
''';

/// The board with extra lines (clues, rules, a solution) appended.
CaseDef board([List<String> lines = const <String>[]]) =>
    parseCase('$_board${lines.join('\n')}\n');

/// The square at a 1-based row and column of the first grid.
int at(CaseDef c, int row, int col) => c.grids.first.cellAt[row - 1][col - 1];

/// Anna on the Kitchen chair, Ben and Cora in the Garden, Dan with the
/// victim Eva in the Hall. Dan is the murderer.
List<int> boardPlacement(CaseDef c) => <int>[
  at(c, 2, 1),
  at(c, 1, 4),
  at(c, 3, 5),
  at(c, 4, 3),
  at(c, 5, 2),
];
