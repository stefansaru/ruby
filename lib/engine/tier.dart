import 'logic_solver.dart';

/// The difficulty ladder. A case belongs to a tier by the hardest technique
/// the logic solver needs for it (docs/Levels.md), not by its size.
enum Tier {
  tutorial(Technique.clue, Technique.single),
  easy(Technique.clue, Technique.single),
  normal(Technique.lastInLine, Technique.pair),
  hard(Technique.subset, Technique.counting),
  expert(Technique.whatIf, Technique.liarSplit);

  const Tier(this.easiest, this.hardest);

  /// The hardest technique a case of this tier needs lies in this range.
  final Technique easiest;
  final Technique hardest;

  bool accepts(Technique t) =>
      t.index >= easiest.index && t.index <= hardest.index;
}
