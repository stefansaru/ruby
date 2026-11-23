import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/model.dart';

import 'fixtures.dart';

void main() {
  /// The starter case with one line replaced.
  String swap(String from, String to) {
    expect(starterCase, contains(from));
    return starterCase.replaceFirst(from, to);
  }

  Matcher rejects(String part) => throwsA(
    isA<CaseFormatException>().having(
      (CaseFormatException e) => e.message,
      'message',
      contains(part),
    ),
  );

  test('the starter case parses into the model', () {
    final c = parseCase(starterCase);
    expect(c.id, 'test-starter');
    expect(c.title, 'The Quiet Garden');
    expect(c.grids.single.rows, 4);
    expect(c.areas.map((AreaDef a) => a.name), <String>[
      'Garden',
      'Kitchen',
      'Pond',
    ]);
    expect(c.people.map((Person p) => p.name), <String>[
      'Anna',
      'Ben',
      'Cora',
      'Dan',
    ]);
    expect(c.victim, 3);
    expect(c.clues, hasLength(4));
    expect(c.cellLabel(c.solution![0]), 'B2');
  });

  test('GEN-009 writing a parsed case gives the same text back', () {
    final text = writeCase(parseCase(starterCase));
    expect(writeCase(parseCase(text)), text);
    final full = board(<String>[
      'rule notouch',
      'clue A is not beside t x2',
      'clue A is front window',
      'clue A is areacorner',
      'clue B is sees e',
      'clue B is line col c',
      'clue B offset D -3 *',
      'clue C alonewith B',
      'clue C others !hat 1',
      'clue D only in H|K',
      'clue * count 2 on c',
      'clue * more G K',
      'clue * group hat not border',
    ]);
    expect(writeCase(parseCase(writeCase(full))), writeCase(full));
  });

  group('GEN-006 the parser is the validator', () {
    test('unknown names are refused', () {
      expect(
        () => parseCase(swap('clue A is on c', 'clue A is on z')),
        rejects('unknown kind'),
      );
      expect(
        () => parseCase(swap('clue C is in P', 'clue C is in Z')),
        rejects('unknown area'),
      );
      expect(
        () => parseCase(swap('clue A is on c', 'clue Z is on c')),
        rejects('unknown person'),
      );
      expect(
        () => parseCase(swap('G.. Gc. K.. Kt.', 'G.. Gc. K.. Xt.')),
        rejects('unknown area'),
      );
      expect(
        () => parseCase(swap('clue A is on c', 'clue A hops c')),
        rejects('unknown clue'),
      );
      expect(
        () => parseCase(swap('setting home', 'colour blue')),
        rejects('unknown line'),
      );
    });

    test('a broken grid is refused', () {
      expect(
        () => parseCase(swap('G.. Gc. K.. Kt.', 'G.. Gc. K..')),
        rejects('expected 4 squares'),
      );
      expect(
        () => parseCase(swap('G.. Gc. K.. Kt.', 'G.. Gc K.. Kt.')),
        rejects('three characters'),
      );
      // The Pond would be in two pieces.
      expect(
        () => parseCase(swap('Gr. G.. G.. K..', 'Gr. G.. G.. P..')),
        rejects('more than one piece'),
      );
    });

    test('a person cannot be on a blocking object', () {
      expect(
        () => parseCase(swap('clue A is on c', 'clue A is on t')),
        rejects('nobody can be on'),
      );
    });

    test('exactly one victim', () {
      expect(
        () => parseCase(swap('victim D Dan m', 'person D Dan m')),
        rejects('exactly one victim'),
      );
      expect(
        () => parseCase(swap('person C Cora f', 'victim C Cora f')),
        rejects('exactly one victim'),
      );
    });

    test('ids are not reused', () {
      expect(
        () => parseCase(swap('person B Ben m', 'person A Ben m')),
        rejects('defined twice'),
      );
      expect(
        () => parseCase(swap('area K Kitchen', 'area G Kitchen')),
        rejects('defined twice'),
      );
    });

    test('the cast must fit and openings must be on walls', () {
      expect(() => board(<String>['person F Finn m']), rejects('cannot fit'));
      // The middle of the Kitchen has no wall to its north.
      expect(
        () => board(<String>['open Home 2 2 N door']),
        rejects('on a wall'),
      );
      expect(() => board(<String>['open Home 9 9 N door']), rejects('outside'));
    });

    test('numbers out of range and stray words are refused', () {
      expect(() => board(<String>['clue A is row 9']), rejects('no row 9'));
      expect(() => board(<String>['clue A is col 0']), rejects('no column 0'));
      expect(() => board(<String>['clue A alone again']), rejects('too many'));
      expect(() => board(<String>['clue A with B C']), rejects('too many'));
    });

    test('impossible relations are refused', () {
      expect(() => board(<String>['clue A dir A -1 0']), rejects('themselves'));
      expect(() => board(<String>['clue A dir B 0 0']), rejects('not both 0'));
      expect(
        () => board(<String>['clue A offset B 0 *']),
        rejects('impossible'),
      );
      expect(
        () => board(<String>['clue * group cape border']),
        rejects('nobody has the trait'),
      );
    });
  });

  test('GEN-007 a stated solution that breaks the case is refused', () {
    // Ben on a square that is not beside the table.
    expect(
      () => parseCase(swap('B=1:1:4', 'B=1:1:3')),
      rejects('solution is wrong'),
    );
    // Two people in one row.
    expect(
      () => parseCase(swap('C=1:3:1', 'C=1:2:1')),
      rejects('solution is wrong'),
    );
    expect(() => parseCase(swap(' D=1:4:3', '')), rejects('place everyone'));
  });

  test('GEN-008 the victim gives no statement', () {
    expect(
      () => parseCase(swap('clue A is on c', 'clue D is in K')),
      rejects('victim gives no statement'),
    );
  });

  test('GEN-011 a liar case needs statements to choose from', () {
    expect(
      () => board(<String>['rule liar', 'clue A is in K']),
      rejects('at least two statements'),
    );
  });
}
