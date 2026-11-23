// Times the generator: the first slots of each tier, one line per slot.
// Results worth keeping go in docs/Performance.md.
//
//   dart run tool/bench_gen.dart          three slots per shape-less tier
//   dart run tool/bench_gen.dart --n=6

import 'dart:io';

import 'package:ruby/gen/gen_campaign.dart';
import 'package:ruby/gen/gen_case.dart';
import 'package:ruby/gen/gen_config.dart';

void main(List<String> args) {
  var n = 3;
  for (final a in args) {
    if (a.startsWith('--n=')) n = int.tryParse(a.substring(4)) ?? n;
  }
  for (final tier in Tier.values) {
    final slots = campaign(tier);
    // Spread the sample over the pack so every shape is timed.
    final step = slots.length ~/ n == 0 ? 1 : slots.length ~/ n;
    for (var i = 0; i < slots.length; i += step) {
      final cfg = slots[i];
      final watch = Stopwatch()..start();
      final out = generateCase(cfg);
      stdout.writeln(
        '${cfg.id} ${cfg.grids} '
        '${cfg.liar ? 'liar ' : ''}${cfg.noTouch ? 'notouch ' : ''}'
        '${cfg.irregular ? 'irregular ' : ''}'
        '${out.draws} draws ${watch.elapsedMilliseconds} ms '
        '${out.grade?.hardest.name ?? 'NO CASE'}',
      );
    }
  }
}
