/// The honest check of a shipped case, independent of how it was made:
/// it starts from the text in the pack and trusts nothing else. The data
/// tests and `tool/check_cases.dart` both run it over every case.
library;

import '../engine/case_text.dart';
import '../engine/clue.dart';
import '../engine/exact_solver.dart';
import '../engine/logic_solver.dart';
import '../engine/model.dart';
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

  // Every suspect speaks, and nothing said can be left out.
  for (var p = 0; p < c.people.length; p++) {
    if (p == c.victim) continue;
    if (!c.clues.any((Clue clue) => clue.subject == p)) {
      return '${c.people[p].name} says nothing';
    }
  }
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
