// The sentence a player reads against the clue the engine checks.
//
// The engine can be right about a clue and the sentence still say the
// opposite ("left" for "right", the two areas of "more ... than ..."
// swapped). The other tests cannot see that: they never read English.
//
// Rules explored here:
//   W1  Every sentence names what its clue names: the area, the object,
//       the row number, the column letter, the other person.
//   W2  Direction words match the numbers: above/below, left/right, and
//       how many rows or columns.
//   W3  A sentence says "not" or "no" exactly when its clue is a denial.
//   W4  "He" and "his" for a man, "She" and "her" for a woman.
//   W5  Counts are the clue's counts, and "more in A than in B" keeps
//       its order.
import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/wording.dart';

import '../support/explore.dart';

/// What the case text says the codes stand for, read without the engine.
class Names {
  Names(String text) {
    for (final line in text.split('\n')) {
      final t = line.trim().split(RegExp(r'\s+'));
      switch (t[0]) {
        case 'area':
          area[t[1]] = t.sublist(2).join(' ');
        case 'kind':
          kind[t[1]] = t.sublist(3).join(' ');
        case 'grid':
          grids.add(t[1].replaceAll('_', ' '));
        case 'person' || 'victim':
          person[t[1]] = t[2].replaceAll('_', ' ');
          male[t[1]] = t[3] == 'm';
      }
    }
  }
  final Map<String, String> area = <String, String>{};
  final Map<String, String> kind = <String, String>{};
  final Map<String, String> person = <String, String>{};
  final Map<String, bool> male = <String, bool>{};
  final List<String> grids = <String>[];
}

String _an(String noun) => 'aeiou'.contains(noun[0]) ? 'an $noun' : 'a $noun';

/// The phrases a sentence must contain for the test [t], and whether the
/// test is a denial.
(List<String>, bool) testWords(Names n, List<String> t) {
  if (t[0] == 'not') {
    final (words, denied) = testWords(n, t.sublist(1));
    return (words, !denied);
  }
  switch (t[0]) {
    case 'in':
      return (
        <String>[for (final a in t[1].split('|')) 'the ${n.area[a]}'],
        false,
      );
    case 'on':
      return (<String>['on ${_an(n.kind[t[1]]!)}'], false);
    case 'beside':
      if (t.length == 3) {
        final sides = int.parse(t[2].substring(1));
        return (
          <String>[
            n.kind[t[1]]!,
            'on exactly $sides ${sides == 1 ? 'side' : 'sides'}',
          ],
          false,
        );
      }
      return (<String>['beside ${_an(n.kind[t[1]]!)}'], false);
    case 'front':
      return (<String>['in front of a ${t[1]}'], false);
    case 'row':
      return (<String>['in row ${t[1]}'], false);
    case 'col':
      return (
        <String>['in column ${String.fromCharCode(64 + int.parse(t[1]))}'],
        false,
      );
    case 'grid':
      return (<String>['on the ${t[1].replaceAll('_', ' ')} grid'], false);
    case 'border':
      return (<String>['on the edge of the grid'], false);
    case 'corner':
      return (<String>['in a corner of the grid'], false);
    case 'areacorner':
      return (<String>['in a corner of', 'area'], false);
    case 'sees':
      return (<String>['see ${_an(n.kind[t[1]]!)}'], false);
    case 'line':
      final line = t[1] == 'row' ? ' row' : ' column';
      return (<String>[n.kind[t[2]]!, line], false);
  }
  throw StateError('no words known for "${t.join(' ')}"');
}

bool denies(String sentence) => RegExp(r'\b(not|no)\b').hasMatch(sentence);

/// Checks one sentence against its notation; returns what is wrong.
List<String> faults(Names n, String notation, String sentence) {
  final out = <String>[];
  void must(String phrase) {
    if (!sentence.contains(phrase)) out.add('lacks "$phrase"');
  }

  void mustNot(String word) {
    if (RegExp('\\b$word\\b').hasMatch(sentence)) out.add('says "$word"');
  }

  void denial(bool expected) {
    if (denies(sentence) != expected) {
      out.add(expected ? 'does not deny' : 'denies');
    }
  }

  void test(List<String> t) {
    final (words, denied) = testWords(n, t);
    words.forEach(must);
    denial(denied);
  }

  final t = notation.split(' ');
  if (t[0] == '*') {
    switch (t[1]) {
      case 'count':
        final count = int.parse(t[2]);
        must('Exactly $count ${count == 1 ? 'person' : 'people'}');
        test(t.sublist(3));
      case 'more':
        // The order is the meaning.
        must(
          'More people were in the ${n.area[t[2]]} than in the ${n.area[t[3]]}',
        );
      case 'group':
        must(switch (t[2]) {
          'm' => 'Every man',
          'f' => 'Every woman',
          'any' => 'Everyone',
          _ => t[2].startsWith('!') ? 'Everyone without' : 'Everyone with',
        });
        if (t[2].length > 1 && t[2] != 'any') must(t[2].replaceFirst('!', ''));
        test(t.sublist(3));
    }
    return out;
  }

  // W4
  final he = n.male[t[0]]!;
  switch (t[1]) {
    case 'allothers':
      must('Everyone except ${he ? 'him' : 'her'} ');
    default:
      if (!sentence.startsWith(he ? 'He ' : 'She ')) {
        out.add('starts with the wrong pronoun');
      }
  }
  mustNot(he ? 'her' : 'his');
  mustNot(he ? 'She' : 'He');

  String other() => n.person[t[2]]!;
  switch (t[1]) {
    case 'is':
      test(t.sublist(2));
    case 'only':
      must('the only person who');
      test(t.sublist(2));
    case 'allothers':
      test(t.sublist(2));
    case 'dir':
      must(other());
      final a = int.parse(t[3]);
      final b = int.parse(t[4]);
      for (final (word, wanted) in <(String, bool)>[
        ('above', a == -1),
        ('below', a == 1),
        ('left', b == -1),
        ('right', b == 1),
      ]) {
        if (wanted) {
          must(word);
        } else {
          mustNot(word);
        }
      }
      denial(false);
    case 'offset':
      must(other());
      must('exactly');
      if (t[3] != '*') {
        final a = int.parse(t[3]);
        must(
          '${a.abs()} ${a.abs() == 1 ? 'row' : 'rows'} ${a < 0 ? 'above' : 'below'}',
        );
        mustNot(a < 0 ? 'below' : 'above');
      } else {
        mustNot('above');
        mustNot('below');
      }
      if (t[4] != '*') {
        final b = int.parse(t[4]);
        must(
          '${b.abs()} ${b.abs() == 1 ? 'column' : 'columns'} to the '
          '${b < 0 ? 'left' : 'right'}',
        );
        mustNot(b < 0 ? 'right' : 'left');
      } else {
        mustNot('left');
        mustNot('right');
      }
    case 'diag':
      must(other());
      must('same diagonal');
    case 'dist':
      final steps = int.parse(t[3]);
      must(other());
      must('exactly $steps ${steps == 1 ? 'step' : 'steps'} from');
    case 'with':
      must(other());
      must('in the same area as');
      denial(false);
    case 'notwith':
      must(other());
      must('not in the same area as');
    case 'samegrid':
      must(other());
      must('on the same grid as');
    case 'samepos':
      must(other());
      must('same position');
      must('another grid');
    case 'alone':
      must('alone in');
      mustNot('with');
    case 'alonewith':
      must('alone with');
      for (final id in t.sublist(2)) {
        must(n.person[id]!);
      }
      // Nobody is named who is not in the clue.
      for (final entry in n.person.entries) {
        if (!t.sublist(2).contains(entry.key) && entry.key != t[0]) {
          mustNot(entry.value);
        }
      }
    case 'others':
      final count = int.parse(t[3]);
      must(count == 0 ? 'had no other' : 'had exactly $count other');
      final one = count <= 1;
      must(switch (t[2]) {
        'm' => one ? 'man' : 'men',
        'f' => one ? 'woman' : 'women',
        _ => one ? 'person' : 'people',
      });
      if (t[2].startsWith('!')) {
        must('without');
        must(t[2].substring(1));
      } else if (t[2].length > 1 && t[2] != 'any') {
        must('with ');
        mustNot('without');
        must(t[2]);
      }
    default:
      out.add('no words known for "${t[1]}"');
  }
  return out;
}

void main() {
  test('GEN-041 W1 to W5 every shipped sentence says what its clue means', () {
    final kinds = <String>{};
    var read = 0;
    for (final s in shipped()) {
      final names = Names(s.text);
      final clues = <(String, String)>[
        for (var i = 0; i < s.c.clues.length; i++)
          (s.oracle.clueLines[i], describeClue(s.c, s.c.clues[i])),
        for (var i = 0; i < s.c.extras.length; i++)
          (s.oracle.extraLines[i], describeClue(s.c, s.c.extras[i])),
      ];
      for (final (notation, sentence) in clues) {
        final plain = sentence.replaceAll('**', '');
        // The two-grid tail "of her grid" is checked on its own below.
        expect(
          faults(names, notation, plain),
          isEmpty,
          reason: '$s: "$notation" reads "$plain"',
        );
        // One sentence, ending in a full stop, with balanced bold marks.
        expect(plain, endsWith('.'), reason: '$s');
        expect('**'.allMatches(sentence).length.isEven, isTrue, reason: '$s');
        final t = notation.split(' ');
        kinds.add(t[0] == '*' ? '* ${t[1]}' : t[1]);
        read++;
      }
    }
    expect(read, greaterThan(4000));
    // Every family the generator draws was read.
    expect(
      kinds,
      containsAll(<String>[
        'is',
        'dir',
        'offset',
        'diag',
        'dist',
        'with',
        'notwith',
        'alone',
        'alonewith',
        'others',
        'only',
        'samegrid',
        'samepos',
        '* count',
        '* more',
        '* group',
      ]),
    );
  });

  test('GEN-041 W1 on two grids a row or column says "of her grid"', () {
    var seen = 0;
    for (final s in shipped()) {
      if (s.c.grids.length < 2) continue;
      for (var i = 0; i < s.c.clues.length; i++) {
        final notation = s.oracle.clueLines[i];
        if (!RegExp(r' is (not )?(row|col) \d').hasMatch(notation)) continue;
        final plain = describeClue(s.c, s.c.clues[i]).replaceAll('**', '');
        expect(plain, matches(RegExp(r'of (his|her) grid\.$')), reason: '$s');
        seen++;
      }
    }
    expect(seen, greaterThan(0));
  });

  test('GEN-041 the checker itself notices a wrong sentence', () {
    // A guard on the test: each of these must be reported.
    final n = Names('''
area K Kitchen
area G Garden
kind c sit chair
kind t block table
person A Anna f
person B Ben m
victim V Vera f
''');
    void wrong(String notation, String sentence) => expect(
      faults(n, notation, sentence),
      isNotEmpty,
      reason: '"$sentence" was accepted for "$notation"',
    );
    void right(String notation, String sentence) => expect(
      faults(n, notation, sentence),
      isEmpty,
      reason: '"$sentence" was refused for "$notation"',
    );
    right('A dir B -1 0', 'She was in a row above Ben.');
    wrong('A dir B -1 0', 'She was in a row below Ben.');
    wrong('A dir B 1 0', 'She was in a row above Ben.');
    right('A dir B 0 -1', 'She was in a column to the left of Ben.');
    wrong('A dir B 0 1', 'She was in a column to the left of Ben.');
    wrong('A dir B -1 -1', 'She was above and to the right of Ben.');
    right('B offset A 2 *', 'He was exactly 2 rows below Anna.');
    wrong('B offset A -2 *', 'He was exactly 2 rows below Anna.');
    wrong('B offset A 2 *', 'He was exactly 1 row below Anna.');
    wrong('B offset A * 1', 'He was exactly 1 column to the left of Anna.');
    right('A is in K', 'She was in the Kitchen.');
    wrong('A is in K', 'She was in the Garden.');
    wrong('A is in K', 'She was not in the Kitchen.');
    wrong('A is not in K', 'She was in the Kitchen.');
    wrong('A is in K', 'He was in the Kitchen.');
    wrong('B is in K', 'She was in the Kitchen.');
    right('A is col 3', 'She was in column C.');
    wrong('A is col 3', 'She was in column B.');
    wrong('A is row 3', 'She was in row 2.');
    wrong('A is on c', 'She was beside a chair.');
    wrong('A is beside t', 'She was beside a chair.');
    right('* more K G', 'More people were in the Kitchen than in the Garden.');
    wrong('* more G K', 'More people were in the Kitchen than in the Garden.');
    wrong('* count 2 on c', 'Exactly 3 people were on a chair.');
    right('A others m 0', 'She had no other man in her area.');
    wrong('A others m 1', 'She had no other man in her area.');
    wrong('A others f 2', 'She had exactly 2 other men in her area.');
    wrong('A with B', 'She was not in the same area as Ben.');
    wrong('A notwith B', 'She was in the same area as Ben.');
    wrong('A alonewith B', 'She was alone with Ben and Vera in her area.');
    wrong(
      'A dist B 3',
      'She was exactly 2 steps from Ben (rows plus columns).',
    );
    wrong('A alone', 'She was alone with Ben in her area.');
  });
}
