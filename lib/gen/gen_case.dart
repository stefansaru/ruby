/// Generates one case and judges it. A case ships only after passing every
/// gate below, in this order; the funnel counts how far each draw got, so a
/// slot that keeps failing shows where.
library;

import 'dart:math';

import '../engine/case_text.dart';
import '../engine/clue.dart';
import '../engine/exact_solver.dart';
import '../engine/logic_solver.dart';
import '../engine/model.dart';
import 'gen_clues.dart';
import 'gen_config.dart';
import 'gen_scene.dart';

enum Gate {
  /// A scene with a rule-abiding placement was drawn.
  scene,

  /// A clue list leaves exactly one placement.
  unique,

  /// The written case parses back to the same case.
  wellFormed,

  /// The logic solver solves it: no guessing needed.
  logic,

  /// The hardest technique needed belongs to the requested tier.
  tier,

  /// The clues are a mix, not one sentence repeated.
  variety,
}

class GenOutcome {
  GenOutcome(
    this.result,
    this.grade,
    this.funnel,
    this.draws, [
    this.families = const <Family>[],
  ]);

  /// The accepted case, or null when the slot ran out of attempts.
  final CaseDef? result;
  final LogicResult? grade;

  /// The family of each clue of the accepted case, in clue order.
  final List<Family> families;

  /// How many draws passed each gate.
  final Map<Gate, int> funnel;
  final int draws;
}

/// Same config, same case: everything random comes from [GenConfig.seed].
GenOutcome generateCase(GenConfig cfg) {
  final rnd = Random(cfg.seed);
  final funnel = <Gate, int>{for (final Gate g in Gate.values) g: 0};
  void pass(Gate g) => funnel[g] = funnel[g]! + 1;

  for (var draw = 1; draw <= cfg.attempts; draw++) {
    final scene = drawScene(cfg, rnd);
    if (scene == null) continue;
    pass(Gate.scene);

    final chosen = chooseClues(scene, cfg, rnd);
    if (chosen == null) continue;
    final c = scene.copyWith(
      clues: <Clue>[for (final Candidate x in chosen) x.clue],
      liar: cfg.liar,
    );
    final found = solveExact(c);
    if (found.length != 1 || c.check(found.first) != null) continue;
    pass(Gate.unique);

    final text = writeCase(c);
    final CaseDef back;
    try {
      back = parseCase(text);
    } on CaseFormatException {
      continue;
    }
    if (writeCase(back) != text) continue;
    pass(Gate.wellFormed);

    final grade = solveLogic(back);
    if (!grade.solved) continue;
    pass(Gate.logic);

    final hardest = grade.hardest;
    if (!cfg.tier.accepts(hardest)) continue;
    pass(Gate.tier);

    final families = <Family>{for (final Candidate x in chosen) x.family};
    final most = families
        .map((Family f) => chosen.where((Candidate x) => x.family == f).length)
        .reduce(max);
    final wanted = cfg.tier.index >= Tier.normal.index ? 3 : 2;
    if (families.length < wanted || most * 10 > chosen.length * 6) continue;
    pass(Gate.variety);

    return GenOutcome(back, grade, funnel, draw, <Family>[
      for (final Candidate x in chosen) x.family,
    ]);
  }
  return GenOutcome(null, null, funnel, cfg.attempts);
}
