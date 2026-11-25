import 'package:flutter/foundation.dart';

import '../engine/case_text.dart';
import '../engine/tier.dart';
import '../gen/gen_campaign.dart';
import '../gen/gen_case.dart';
import '../gen/gen_check.dart';

/// Makes a new case of a tier on the device (GEN-037).
///
/// This is the one file of the app allowed to import the generator
/// (`test/architecture_test.dart`): screens ask here and get case text
/// back, exactly as if it came from a pack.
abstract final class RandomCases {
  /// How many seeds [make] tries before it gives up.
  static const int seedsTried = 40;

  /// The case text for [tier], starting at [seed]. A seed whose draws all
  /// fail a gate, or whose case fails the check every shipped case gets,
  /// is replaced by the next one. Throws a [StateError] when [tries]
  /// seeds in a row give nothing, so a tier that cannot be
  /// made is an error and not an endless wait.
  static String make(Tier tier, int seed, {int tries = seedsTried}) {
    for (var s = seed; s < seed + tries; s++) {
      final made = generateCase(randomConfig(tier, s)).result;
      if (made == null) continue;
      final text = writeCase(made);
      if (checkShipped(text, tier) == null) return text;
    }
    throw StateError('no ${tier.name} case in $tries seeds from $seed');
  }

  /// [make] off the screen's thread, with a seed from the clock.
  /// Replaceable so widget tests need no second isolate.
  static Future<String> Function(Tier tier) inBackground = (Tier tier) =>
      compute(_job, (
        tier.index,
        DateTime.now().microsecondsSinceEpoch & 0x3fffffff,
      ));

  static String _job((int, int) job) => make(Tier.values[job.$1], job.$2);
}
