// Sweeps every shipped case through the honest check (lib/gen/gen_check.dart):
// parses, exactly one solution, solved by logic in its tier, no clue to spare.
//
//   dart run tool/check_cases.dart
//
// Exits with 1 when any case fails.

import 'dart:io';

import 'package:ruby/data/cases.dart';
import 'package:ruby/gen/gen_check.dart';
import 'package:ruby/gen/gen_config.dart';

void main() {
  var bad = 0;
  var total = 0;
  for (final tier in Tier.values) {
    final pack = casePacks[tier.name]!;
    final watch = Stopwatch()..start();
    for (var i = 0; i < pack.length; i++) {
      total++;
      final wrong = checkShipped(pack[i], tier);
      if (wrong == null) continue;
      bad++;
      stdout.writeln('  ${tier.name} #${i + 1}: $wrong');
    }
    stdout.writeln(
      '${tier.name}: ${pack.length} cases, ${watch.elapsed.inSeconds}s',
    );
  }
  stdout.writeln(
    bad == 0 ? 'All $total cases are sound.' : '$bad of $total FAILED.',
  );
  if (bad > 0) exitCode = 1;
}
