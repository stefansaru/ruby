// Builds the shipped case packs in lib/data/.
//
//   dart run tool/generate_cases.dart              write every pack
//   dart run tool/generate_cases.dart --only=easy  one tier
//   dart run tool/generate_cases.dart --dry-run    build, compare with the
//                                                  files on disk, write nothing
//   dart run tool/generate_cases.dart --probe=6    first N slots per tier,
//                                                  funnel only, write nothing
//   --verbose                                      one line per slot
//
// All the logic is in lib/gen/; this file only reads arguments and files.

import 'dart:io';

import 'package:ruby/engine/logic_solver.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/gen/gen_campaign.dart';
import 'package:ruby/gen/gen_case.dart';
import 'package:ruby/gen/gen_config.dart';
import 'package:ruby/gen/gen_render.dart';

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final verbose = args.contains('--verbose');
  String? option(String name) {
    for (final a in args) {
      if (a.startsWith('--$name=')) return a.substring(name.length + 3);
    }
    return null;
  }

  final only = option('only');
  final probe = int.tryParse(option('probe') ?? '');
  var failed = false;

  for (final tier in Tier.values) {
    if (only != null && tier.name != only) continue;
    final watch = Stopwatch()..start();
    var slots = campaign(tier);
    if (probe != null) slots = slots.take(probe).toList();
    final cases = <CaseDef>[];
    final funnel = <Gate, int>{for (final Gate g in Gate.values) g: 0};
    final hardest = <Technique, int>{};
    var draws = 0;
    for (final cfg in slots) {
      final slotWatch = Stopwatch()..start();
      final out = generateCase(cfg);
      draws += out.draws;
      if (verbose) {
        stdout.writeln(
          '  ${cfg.id} ${cfg.setting} ${cfg.grids}: '
          '${out.draws} draws, ${slotWatch.elapsedMilliseconds} ms, '
          '${out.grade?.hardest.name}',
        );
      }
      for (final g in Gate.values) {
        funnel[g] = funnel[g]! + out.funnel[g]!;
      }
      if (out.result == null) {
        stdout.writeln('  ${cfg.id}: NO CASE after ${out.draws} draws');
        failed = true;
        continue;
      }
      cases.add(out.result!);
      hardest.update(out.grade!.hardest, (int n) => n + 1, ifAbsent: () => 1);
    }
    stdout
      ..writeln(
        '${tier.name}: ${cases.length}/${slots.length} cases, '
        '$draws draws, ${watch.elapsed.inSeconds}s',
      )
      ..writeln(
        '  funnel: ${<String>[for (final Gate g in Gate.values) '${g.name} ${funnel[g]}'].join(' > ')}',
      )
      ..writeln(
        '  hardest technique: ${<String>[for (final MapEntry<Technique, int> e in hardest.entries) '${e.key.name} ${e.value}'].join(', ')}',
      );
    if (probe != null) continue;

    final file = File('lib/data/${packFileName(tier)}');
    final text = renderPack(tier, cases);
    if (dryRun) {
      final same =
          file.existsSync() &&
          file.readAsStringSync().replaceAll('\r\n', '\n') == text;
      stdout.writeln(
        same ? '  ${file.path}: unchanged' : '  ${file.path}: DIFFERS',
      );
      if (!same) failed = true;
    } else {
      file.writeAsStringSync(text);
      stdout.writeln('  wrote ${file.path}');
    }
  }
  if (failed) exitCode = 1;
}
