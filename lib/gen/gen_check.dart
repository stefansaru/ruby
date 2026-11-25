/// The honest check of a shipped case, independent of how it was made:
/// it starts from the text in the pack and trusts nothing else. The data
/// tests and `tool/check_cases.dart` both run it over every case.
library;

import '../data/settings.dart';
import '../engine/case_text.dart';
import '../engine/clue.dart';
import '../engine/exact_solver.dart';
import '../engine/logic_solver.dart';
import '../engine/model.dart';
import '../engine/openings.dart';
import 'gen_config.dart';

/// Null when [text] is a sound case of [tier], otherwise what is wrong.
String? checkShipped(String text, Tier tier) {
  final CaseDef c;
  try {
    c = parseCase(text);
  } on CaseFormatException catch (e) {
    return e.toString();
  }
  final answer = c.solution;
  if (answer == null) return 'no certified solution';

  final misplaced = misplacedObject(c);
  if (misplaced != null) return misplaced;
  final victim = c.people[c.victim];
  if (c.victim != c.people.length - 1) return 'the victim is not listed last';
  if (victim.id != 'V' || !victim.name.startsWith('V')) {
    return 'the victim ${victim.name} does not begin with V';
  }

  if (usedOpenings(c, c.clues).length != c.openings.length) {
    return 'a door or window is on the map but in no clue';
  }
  final said = <String>{};
  for (final clue in <Clue>[...c.clues, ...c.extras]) {
    if (!said.add(clueNotation(c, clue))) return 'a statement is repeated';
  }

  // Every suspect speaks.
  for (var p = 0; p < c.people.length; p++) {
    if (p == c.victim) continue;
    if (!c.clues.any((Clue clue) => clue.subject == p)) {
      return '${c.people[p].name} says nothing';
    }
  }

  // Exactly one solution, and it is the certified one.
  final found = solveExact(c);
  if (found.length != 1) return 'has ${found.length} solutions, not one';
  if (found.single.join(',') != answer.join(',')) {
    return 'the certified solution is not the one the solver finds';
  }

  // Solved by logic alone, landing on the same answer, in the right tier.
  final grade = solveLogic(c);
  if (!grade.solved) return 'the logic solver cannot finish it';
  if (grade.pos.join(',') != answer.join(',')) {
    return 'the logic solver reaches a different answer';
  }
  if (!tier.accepts(grade.hardest)) {
    return 'needs ${grade.hardest.name}, outside the ${tier.name} tier';
  }
  final placements = <int>[
    for (final LogicStep s in grade.steps)
      if (s.technique == Technique.single) s.person!,
  ];
  if (placements.isEmpty || placements.last != c.victim) {
    return 'the victim is not the last person placed';
  }

  // Nothing said can be left out.
  for (var i = 0; i < c.clues.length; i++) {
    final s = c.clues[i].subject;
    if (s != null &&
        c.clues.where((Clue clue) => clue.subject == s).length == 1) {
      continue; // A suspect's only statement always stays.
    }
    final without = List<Clue>.of(c.clues)..removeAt(i);
    final rest = solveExact(c.copyWith(clues: without));
    if (rest.length == 1 && rest.single.join(',') == answer.join(',')) {
      return 'clue ${i + 1} is not needed';
    }
  }
  return null;
}

/// Null when every object of [c] stands in an area its setting lists it
/// for (docs/Settings.md), otherwise the first one that does not.
String? misplacedObject(CaseDef c) {
  final index = settings.indexWhere((SettingDef s) => s.id == c.setting);
  if (index < 0) return 'unknown setting ${c.setting}';
  final setting = settings[index];
  for (final cell in c.cells) {
    if (cell.kind < 0) continue;
    final kind = c.kinds[cell.kind];
    final area = c.areas[cell.area];
    final allowed = setting.areas.any(
      (AreaSpec a) =>
          a.name == area.name &&
          setting.kinds.any(
            (KindSpec k) =>
                k.code == kind.code && k.name == kind.name && a.allows(k),
          ),
    );
    if (!allowed) {
      return 'a ${kind.name} does not belong in the ${area.name} '
          '(${c.cellLabel(cell.index)})';
    }
  }
  return null;
}
