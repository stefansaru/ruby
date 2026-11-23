import 'package:flutter_test/flutter_test.dart';
import 'package:ruby/engine/wording.dart';

import 'fixtures.dart';

void main() {
  String say(String line) {
    final c = board(<String>['clue $line']);
    return describeClue(c, c.clues.single);
  }

  test('GEN-024 one fixed sentence per clue', () {
    expect(say('A is in K'), 'She was in the **Kitchen**.');
    expect(say('A is in K|G'), 'She was in the **Kitchen** or the **Garden**.');
    expect(say('B is not in H'), 'He was **not** in the **Hall**.');
    expect(say('A is on c'), 'She was on a **chair**.');
    expect(say('B is beside e'), 'He was beside a **tree**.');
    expect(say('B is not beside t'), 'He was **not** beside a **table**.');
    expect(
      say('B is beside e x2'),
      'He had a **tree** on exactly **2** sides.',
    );
    expect(say('A is front window'), 'She was in front of a **window**.');
    expect(say('A is front door'), 'She was in front of a **door**.');
    expect(say('A is grid Home'), 'She was on the **Home** grid.');
    expect(say('A samegrid B'), 'She was on the **same grid** as **Ben**.');
    expect(
      say('A samepos B'),
      'She was in the **same position** as **Ben**, on another grid.',
    );
    expect(say('B is border'), 'He was on the **edge** of the grid.');
    expect(say('A is corner'), 'She was in a **corner** of the grid.');
    expect(say('A is areacorner'), 'She was in a **corner** of her area.');
    expect(say('B is sees e'), 'He could **see** a **tree**.');
    expect(say('B is not sees e'), 'He could **not** **see** a **tree**.');
    expect(say('A is line row t'), 'She had a **table** in her **row**.');
    expect(say('A alone'), 'She was **alone** in her area.');
    expect(say('B alonewith C'), 'He was **alone with** **Cora** in his area.');
    expect(
      say('B others f 1'),
      'He had exactly **1** other woman in his area.',
    );
    expect(say('B others m 0'), 'He had **no** other man in his area.');
    expect(
      say('B others hat 2'),
      'He had exactly **2** other people with a **hat** in his area.',
    );
    expect(
      say('A only on c'),
      'She was the **only** person who was on a **chair**.',
    );
    expect(
      say('D allothers border'),
      '**Everyone except** him was on the **edge** of the grid.',
    );
    expect(say('* count 2 on c'), 'Exactly **2** people were on a **chair**.');
    expect(say('* count 1 on c'), 'Exactly **1** person was on a **chair**.');
    expect(
      say('* more G K'),
      '**More** people were in the **Garden** than in the **Kitchen**.',
    );
    expect(
      say('* group hat on c'),
      'Everyone **with** a **hat** was on a **chair**.',
    );
    expect(
      say('* group f not border'),
      'Every **woman** was **not** on the **edge** of the grid.',
    );
  });

  test('GEN-024 rows are numbered, columns lettered, no compass words', () {
    expect(say('B is row 1'), 'He was in **row 1**.');
    expect(say('B is col 4'), 'He was in **column D**.');
    expect(say('A dir C -1 0'), 'She was in a row **above** **Cora**.');
    expect(say('A dir C 1 0'), 'She was in a row **below** **Cora**.');
    expect(
      say('A dir C 0 -1'),
      'She was in a column to the **left** of **Cora**.',
    );
    expect(
      say('A dir C -1 1'),
      'She was **above** and to the **right** of **Cora**.',
    );
    expect(say('B offset D -3 *'), 'He was exactly **3 rows above** **Dan**.');
    expect(
      say('B offset D * 1'),
      'He was exactly **1 column to the right** of **Dan**.',
    );
    expect(
      say('B offset D 2 -1'),
      'He was exactly **2 rows below** and **1 column to the left** of '
      '**Dan**.',
    );
    expect(say('A diag D'), 'She was on the same **diagonal** as **Dan**.');
    expect(
      say('A dist B 4'),
      'She was exactly **4 steps** from **Ben** (rows plus columns).',
    );
    expect(say('B with C'), 'He was in the **same area** as **Cora**.');
    expect(say('B notwith A'), 'He was **not** in the same area as **Anna**.');
    for (final line in <String>[
      'A dir C -1 0',
      'A dir C 1 1',
      'B offset D 2 *',
    ]) {
      expect(say(line), isNot(matches(RegExp('north|south|east|west'))));
    }
  });

  test('the victim card and the case rules', () {
    final c = board(<String>['rule notouch']);
    expect(
      describeVictim(c),
      '**The victim.** She was alone with the murderer.',
    );
    expect(describeRules(c).single, contains('not even diagonally'));
    expect(describeRules(board()), isEmpty);
  });
}
