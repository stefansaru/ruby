/// English wording for clues. The text is built from the same clue object
/// the engine checks, with one fixed sentence per clue type, so a sentence
/// always means exactly what [Clue.holds] tests.
///
/// Wording rules (docs/GameRules.md): columns are lettered and rows are
/// numbered, never "the right column"; directions are "above", "below",
/// "left" and "right", never compass points. `**` marks the key words the
/// view draws bold.
library;

import 'atoms.dart';
import 'clue.dart';
import 'logic_solver.dart';
import 'model.dart';

String _a(String noun) =>
    '${'aeiou'.contains(noun[0].toLowerCase()) ? 'an' : 'a'} **$noun**';

String _trait(String trait) => trait.endsWith('s') ? '**$trait**' : _a(trait);

String _list(List<String> items, String joiner) => items.length == 1
    ? items.first
    : '${items.sublist(0, items.length - 1).join(', ')} $joiner ${items.last}';

/// A verb phrase for [t]: "was in the **Kitchen**". [his] is "his"/"her"/
/// "their"; [plural] switches "was" to "were".
String _phrase(
  CaseDef c,
  CellTest t,
  String his, {
  bool neg = false,
  bool plural = false,
}) {
  final was = plural ? 'were' : 'was';
  final be = neg ? '$was **not**' : was;
  // With two grids a row or column number means the speaker's own grid.
  final ofGrid = c.grids.length > 1 ? ' of $his grid' : '';
  switch (t) {
    case Not(:final CellTest inner):
      return _phrase(c, inner, his, neg: !neg, plural: plural);
    case InArea(:final Set<int> areas):
      return '$be in ${_list(<String>[for (final int a in areas) 'the **${c.areas[a].name}**'], 'or')}';
    case OnKind(:final int kind):
      return '$be on ${_a(c.kinds[kind].name)}';
    case BesideKind(:final int kind, :final int? exactly):
      if (exactly == null) return '$be beside ${_a(c.kinds[kind].name)}';
      return neg
          ? 'did **not** have ${_a(c.kinds[kind].name)} on exactly '
                '**$exactly** ${exactly == 1 ? 'side' : 'sides'}'
          : 'had ${_a(c.kinds[kind].name)} on exactly **$exactly** '
                '${exactly == 1 ? 'side' : 'sides'}';
    case FrontOf(:final bool door):
      return '$be in front of ${_a(door ? 'door' : 'window')}';
    case InRow(:final row):
      return '$be in **row ${row + 1}**$ofGrid';
    case InCol(:final col):
      return '$be in **column ${colLabel(col)}**$ofGrid';
    case InGrid(:final grid):
      return '$be on the **${c.grids[grid].label}** grid';
    case OnBorder():
      return '$be on the **edge** of the grid';
    case GridCorner():
      return '$be in a **corner** of the grid';
    case AreaCorner():
      return '$be in a **corner** of $his area';
    case Sees(:final int kind):
      return 'could ${neg ? '**not** ' : ''}**see** ${_a(c.kinds[kind].name)}';
    case LineHas(kind: final int k, :final bool row):
      final line = row ? 'row' : 'column';
      return neg
          ? 'had **no** ${c.kinds[k].name} in $his **$line**'
          : 'had ${_a(c.kinds[k].name)} in $his **$line**';
  }
}

String _who(Selector s, int count) {
  final one = count == 1;
  if (s.gender == Gender.male) return one ? 'man' : 'men';
  if (s.gender == Gender.female) return one ? 'woman' : 'women';
  final base = one ? 'person' : 'people';
  if (s.trait == null) return base;
  return '$base ${s.negate ? 'without' : 'with'} ${_trait(s.trait!)}';
}

String _everyone(Selector s) {
  if (s.gender == Gender.male) return 'Every **man**';
  if (s.gender == Gender.female) return 'Every **woman**';
  if (s.trait == null) return '**Everyone**';
  return 'Everyone **${s.negate ? 'without' : 'with'}** ${_trait(s.trait!)}';
}

/// The sentence shown to the player for [clue].
String describeClue(CaseDef c, Clue clue) {
  String name(int p) => '**${c.people[p].name}**';
  final s = clue.subject;
  final male = s != null && c.people[s].gender == Gender.male;
  final he = male ? 'He' : 'She';
  final his = male ? 'his' : 'her';
  final him = male ? 'him' : 'her';
  String steps(int n, String unit) => '$n $unit${n == 1 ? '' : 's'}';
  switch (clue) {
    case Is(:final CellTest test):
      return '$he ${_phrase(c, test, his)}.';
    case Rel(
      :final int other,
      :final RelKind kind,
      :final int? a,
      :final int? b,
    ):
      final o = name(other);
      switch (kind) {
        case RelKind.direction:
          final v = a == -1 ? '**above**' : '**below**';
          final h = b == -1 ? '**left**' : '**right**';
          if (b == 0) return '$he was in a row $v $o.';
          if (a == 0) return '$he was in a column to the $h of $o.';
          return '$he was $v and to the $h of $o.';
        case RelKind.offset:
          final rows = a == null
              ? ''
              : '**${steps(a.abs(), 'row')} ${a < 0 ? 'above' : 'below'}**';
          final cols = b == null
              ? ''
              : '**${steps(b.abs(), 'column')} to the '
                    '${b < 0 ? 'left' : 'right'}** of';
          if (b == null) return '$he was exactly $rows $o.';
          if (a == null) return '$he was exactly $cols $o.';
          return '$he was exactly $rows and $cols $o.';
        case RelKind.diagonal:
          return '$he was on the same **diagonal** as $o.';
        case RelKind.sameArea:
          return '$he was in the **same area** as $o.';
        case RelKind.notSameArea:
          return '$he was **not** in the same area as $o.';
        case RelKind.sameGrid:
          return '$he was on the **same grid** as $o.';
        case RelKind.samePosition:
          return '$he was in the **same position** as $o, on another grid.';
        case RelKind.distance:
          return '$he was exactly **${steps(a!, 'step')}** from $o '
              '(rows plus columns).';
      }
    case Alone():
      return '$he was **alone** in $his area.';
    case AloneWith(:final List<int> others):
      return '$he was **alone with** '
          '${_list(others.map(name).toList(), 'and')} in $his area.';
    case Others(:final Selector who, :final int count):
      return count == 0
          ? '$he had **no** other ${_who(who, 1)} in $his area.'
          : '$he had exactly **$count** other ${_who(who, count)} '
                'in $his area.';
    case OnlyOne(:final CellTest test):
      return '$he was the **only** person who ${_phrase(c, test, 'their')}.';
    case AllOthers(:final CellTest test):
      return '**Everyone except** $him ${_phrase(c, test, 'their')}.';
    case Count(:final CellTest test, :final int count):
      return 'Exactly **$count** ${count == 1 ? 'person' : 'people'} '
          '${_phrase(c, test, 'their', plural: count != 1)}.';
    case More(:final int more, :final int fewer):
      return '**More** people were in the **${c.areas[more].name}** '
          'than in the **${c.areas[fewer].name}**.';
    case Group(:final Selector who, :final CellTest test):
      return '${_everyone(who)} ${_phrase(c, test, 'their')}.';
    case Negated(:final Clue inner):
      return 'This is **false**: ${describeClue(c, inner)}';
  }
}

/// The story the same case is told as. Only words change with the mode:
/// the rules, the clues and the answer are the same (docs/features/Modes.md).
enum Mode {
  /// A victim and a murderer.
  detective,

  /// A missing kitten and the cat who was hiding it.
  cat,
}

/// The line on the victim's card.
String describeVictim(CaseDef c, [Mode mode = Mode.detective]) {
  final v = c.people[c.victim];
  final she = v.gender == Gender.male ? 'He' : 'She';
  return switch (mode) {
    Mode.detective => '**The victim.** $she was alone with the murderer.',
    Mode.cat => '**The missing kitten.** $she was hiding with exactly one cat.',
  };
}

/// The line shown when the case is solved; [pos] is the answer.
String describeSolved(CaseDef c, List<int> pos, [Mode mode = Mode.detective]) {
  final culprit = c.people[c.murdererIn(pos)].name;
  final victim = c.people[c.victim].name;
  final area = c.areas[c.cells[pos[c.victim]].area].name;
  return switch (mode) {
    Mode.detective =>
      '**$culprit** was alone with $victim in the **$area**. '
          '$culprit is the murderer.',
    Mode.cat =>
      '**$culprit** was the only cat with $victim in the **$area**. '
          '$culprit was hiding the kitten.',
  };
}

/// The game in three steps, for the "How to play" sheet.
List<String> howToPlay([Mode mode = Mode.detective]) {
  final (who, last, answer) = switch (mode) {
    Mode.detective => (
      'suspect',
      'the **victim**',
      'The one person in the same area as the victim is the **murderer**.',
    ),
    Mode.cat => (
      'cat',
      'the **missing kitten**',
      'The one cat in the same area as the kitten was **hiding** it.',
    ),
  };
  final read =
      '**Read.** Every $who says where they were. Every statement is true '
      'unless the case says one is false.';
  final place =
      '**Place.** Put each $who on a square. There is **one** in every row '
      'and every column, never two. A dark object blocks its square; a '
      'light one can be stood on.';
  final find =
      '**Find.** Nothing is said about $last: they are on the square that '
      'is left. $answer';
  return <String>[read, place, find];
}

/// Short notices of the case screen. Kept here with the other player-facing
/// words so that none is written in a screen.
const String noticeBlocked = 'Nobody can stand there.';
const String noticeMisfit =
    'Everyone is placed, but something does not fit yet.';
const String noticeSolved = 'This case is solved.';
const String noticeNoRandomCase = 'No case could be made. Please try again.';

/// A wrong placement, named by a hint.
String describeWrong(CaseDef c, int person, int cell) =>
    '**${c.people[person].name}** was not on **${c.placeLabel(cell)}**.';

/// A case rule as a line above the statements.
String describeRuleLine(String rule) => 'Rule: $rule';

/// The case rules that go beyond the base rules, as sentences.
List<String> describeRules(CaseDef c) {
  final out = <String>[];
  if (c.isFull) {
    for (final g in c.grids) {
      final where = c.grids.length > 1 ? ' in the ${g.label}' : '';
      if (g.rows > g.cols) {
        out.add('**${g.rows - g.cols}** rows$where stay empty.');
      } else if (g.cols > g.rows) {
        out.add('**${g.cols - g.rows}** columns$where stay empty.');
      }
    }
  }
  if (c.noTouch) {
    out.add(
      'No two people were next to each other, **not even '
      'diagonally**.',
    );
  }
  if (c.liar) out.add('Exactly **one** statement is **false**.');
  return out;
}

/// One sentence saying what a solver step shows, for a hint. Draft copy
/// (TODO 24): the owner approves player-facing wording.
///
/// [lie] is [LogicResult.lie]: a step that rests on that statement rests
/// on it being false, and says so.
String describeStep(
  CaseDef c,
  LogicStep s, {
  Mode mode = Mode.detective,
  int? lie,
}) {
  String name(int? p) => p == null ? 'Someone' : '**${c.people[p].name}**';
  // With two grids a row, a column or a square is named with its grid.
  final two = c.grids.length > 1;
  String rule(int? clue) {
    if (clue == null) return '';
    if (clue == victimRule) {
      return switch (mode) {
        Mode.detective =>
          'The victim was alone with the murderer, so that area holds '
              'exactly **two** people.',
        Mode.cat =>
          'The kitten was hiding with one cat, so that area holds exactly '
              '**two**.',
      };
    }
    if (clue == noTouchRule) return 'No two people were next to each other.';
    final what = c.clues[clue];
    final text = describeClue(c, what);
    final who = what.subject;
    if (clue == lie) return "The false statement is ${name(who)}'s: $text";
    return who == null ? 'Clue: $text' : '${name(who)} said: $text';
  }

  switch (s.technique) {
    case Technique.clue:
    case Technique.pair:
    case Technique.counting:
      return rule(s.clue);
    case Technique.single:
      final cell = c.cells[s.placed!];
      return '${name(s.person)} is on **${c.placeLabel(s.placed!)}**, so '
          '**row ${cell.row + 1}** and **column '
          '${colLabel(cell.col)}** ${two ? 'there ' : ''}are taken.';
    case Technique.lastInLine:
      final (grid, isRow, index) = s.line!;
      final where = two ? ' of the ${c.grids[grid].label}' : '';
      final line = isRow
          ? '**Row ${index + 1}**'
          : '**Column ${colLabel(index)}**';
      return '$line$where must hold someone, and only ${name(s.person)} can '
          'still be there.';
    case Technique.intersection:
      return 'Every square left for ${name(s.person)} is in one line, so '
          'nobody else can be in that line.';
    case Technique.subset:
      return 'A few people can only be in as many rows or columns as there '
          'are of them, so nobody else can be in those lines.';
    case Technique.whatIf:
      return 'One square for ${name(s.person)} leads to a dead end, so it '
          'is ruled out.';
    case Technique.liarSplit:
      return 'Exactly one statement is false: try each one as the lie.';
  }
}

/// A hint as short lines (draft copy, TODO 24): who to look at, any step
/// that cannot be read off the grid, and what is left. With [square] the
/// answer for that person is added. [because] is the hint's list of steps.
List<String> describeHint(
  CaseDef c,
  int person,
  List<LogicStep> because, {
  int? square,
  Mode mode = Mode.detective,
  int? lie,
}) {
  final who = c.people[person];
  final name = '**${who.name}**';
  final male = who.gender == Gender.male;
  // A step the player can already see: this person's own statement, or
  // someone standing on the grid (their row and column are crossed out).
  bool onScreen(LogicStep s) {
    if (s.technique == Technique.single) return true;
    final clue = s.clue;
    return s.technique == Technique.clue &&
        clue != null &&
        clue >= 0 &&
        clue != lie &&
        c.clues[clue].subject == person;
  }

  final liar = lie == null ? null : c.clues[lie].subject;
  final more = <String>{
    // The split comes first: everything after it rests on the lie.
    if (lie != null) ...<String>[
      'Try each statement as the false one: only one leaves no dead end.',
      describeStep(c, LogicStep(Technique.clue, clue: lie), lie: lie),
    ],
    for (final LogicStep s in because)
      if (!onScreen(s)) describeStep(c, s, mode: mode, lie: lie),
  }..remove('');
  final String left;
  if (who.isVictim) {
    left =
        'With everyone else placed, **one** square is left for '
        '${male ? 'him' : 'her'}.';
  } else if (person == liar) {
    left = 'With that and the crossed-out squares, **one** square is left.';
  } else {
    left =
        '${male ? 'His' : 'Her'} statements and the crossed-out squares '
        'leave **one** square.';
  }
  return <String>[
    'Look at $name.',
    ...more,
    left,
    if (square == null)
      'Tap the hint again to see the square.'
    else
      '$name was on **${c.placeLabel(square)}**.',
  ];
}
