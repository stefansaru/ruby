/// English wording for clues. The text is built from the same clue object
/// the engine checks, with one fixed sentence per clue type, so a sentence
/// always means exactly what [Clue.holds] tests.
///
/// Wording rules (docs/GameRules.md): columns are lettered and rows are
/// numbered, never "the right column"; directions are "above", "below",
/// "left" and "right", never compass points. `**` marks the key words the
/// view draws bold.
library;

import 'clue.dart';
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
      return '$be in **column ${String.fromCharCode(65 + col)}**$ofGrid';
    case InGrid(:final grid):
      return '$be on the **${c.grids[grid].name.replaceAll('_', ' ')}** grid';
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

/// The line on the victim's card.
String describeVictim(CaseDef c) {
  final v = c.people[c.victim];
  return '**The victim.** ${v.gender == Gender.male ? 'He' : 'She'} was '
      'alone with the murderer.';
}

/// The case rules that go beyond the base rules, as sentences.
List<String> describeRules(CaseDef c) {
  final out = <String>[];
  var capacity = 0;
  for (final g in c.grids) {
    capacity += g.rows < g.cols ? g.rows : g.cols;
  }
  if (capacity == c.people.length) {
    for (final g in c.grids) {
      final where = c.grids.length > 1
          ? ' in the ${g.name.replaceAll('_', ' ')}'
          : '';
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
