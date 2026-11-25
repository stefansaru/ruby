// Prints a shipped case the way a player would read it: the grid, the
// cards and, on request, the answer and the solving steps. There is no
// game screen yet, so this is how a case is read and solved on paper.
//
//   dart run tool/show_case.dart easy 3            the third easy case
//   dart run tool/show_case.dart hard 12 --answer  with answer and steps

import 'dart:io';

import 'package:ruby/data/cases.dart';
import 'package:ruby/engine/atoms.dart';
import 'package:ruby/engine/case_text.dart';
import 'package:ruby/engine/logic_solver.dart';
import 'package:ruby/engine/model.dart';
import 'package:ruby/engine/wording.dart';

void main(List<String> args) {
  final pack = args.isEmpty ? null : casePacks[args[0]];
  final number = args.length > 1 ? int.tryParse(args[1]) : null;
  if (pack == null || number == null || number < 1 || number > pack.length) {
    stdout.writeln(
      'usage: show_case <tier> <number> [--answer]\n'
      'tiers: ${casePacks.keys.join(', ')}',
    );
    exitCode = 64;
    return;
  }
  final c = parseCase(pack[number - 1]);
  String plain(String s) => s.replaceAll('**', '');

  stdout
    ..writeln('${c.id}: ${c.title} (${c.setting})')
    ..writeln();
  for (var g = 0; g < c.grids.length; g++) {
    final d = c.grids[g];
    if (c.grids.length > 1) stdout.writeln(d.label);
    stdout.writeln(
      '     ${<String>[for (var k = 0; k < d.cols; k++) colLabel(k).padRight(3)].join(' ')}',
    );
    for (var r = 0; r < d.rows; r++) {
      stdout.writeln(
        '${(r + 1).toString().padLeft(3)}  ${<String>[for (final i in d.cellAt[r])
          if (i < 0) '   ' else c.areas[c.cells[i].area].code + (c.cells[i].kind < 0 ? '.' : c.kinds[c.cells[i].kind].code) + c.cells[i].instance].join(' ')}',
      );
    }
    stdout.writeln();
  }
  stdout.writeln(
    'Areas: ${<String>[for (final a in c.areas) '${a.code} ${a.name}'].join(', ')}',
  );
  stdout.writeln(
    'Objects: ${<String>[for (final k in c.kinds) '${k.code} ${k.name} (${k.canOccupy ? 'can stand on' : 'blocks'})'].join(', ')}',
  );
  for (final o in c.openings) {
    stdout.writeln(
      '${o.isDoor ? 'Door' : 'Window'} on the ${o.side.name} '
      'side of ${c.cellLabel(o.cell)}',
    );
  }
  stdout.writeln();
  for (final rule in describeRules(c)) {
    stdout.writeln('Rule: ${plain(rule)}');
  }
  for (var p = 0; p < c.people.length; p++) {
    final person = c.people[p];
    final traits = person.traits.isEmpty
        ? ''
        : ' (${person.traits.join(', ')})';
    if (person.isVictim) {
      stdout.writeln('${person.name}$traits: ${plain(describeVictim(c))}');
      continue;
    }
    final said = <String>[
      for (final clue in c.clues)
        if (clue.subject == p) plain(describeClue(c, clue)),
    ];
    stdout.writeln('${person.name}$traits: ${said.join(' ')}');
  }
  for (final clue in c.clues) {
    if (clue.subject == null) {
      stdout.writeln('Also: ${plain(describeClue(c, clue))}');
    }
  }
  if (!args.contains('--answer')) return;

  final r = solveLogic(c);
  stdout
    ..writeln()
    ..writeln(
      'Answer: ${<String>[for (var p = 0; p < c.people.length; p++) '${c.people[p].name} ${c.cellLabel(c.solution![p])}'].join(', ')}',
    )
    ..writeln('The murderer is ${c.people[c.murdererIn(c.solution!)].name}.')
    ..writeln('Hardest technique: ${r.hardest.name}, score ${r.score}')
    ..writeln('Steps:');
  for (final s in r.steps) {
    final who = s.person == null ? '' : ' ${c.people[s.person!].name}';
    final clue = s.clue == null
        ? ''
        : s.clue == victimRule
        ? ' [victim rule]'
        : s.clue == noTouchRule
        ? ' [no-touch rule]'
        : s.clue == r.lie
        ? ' [false: ${plain(describeClue(c, c.clues[s.clue!]))}]'
        : ' [${plain(describeClue(c, c.clues[s.clue!]))}]';
    final what = s.placed != null
        ? ' placed on ${c.cellLabel(s.placed!)}'
        : s.removed.isEmpty
        ? ''
        : ' rules out ${s.removed.length} squares';
    stdout.writeln('  ${s.technique.name}:$who$what$clue');
  }
}
