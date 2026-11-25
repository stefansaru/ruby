// The layer rules, checked on the source files themselves (GEN-023).
// Each layer has a list of what it MAY import; anything else fails.
//
//   lib/engine/   pure Dart, stands alone: imports only its own files
//   lib/gen/      dart:math, the engine, the data, its own files
//   lib/data/     imports only its own files
//   lib/services/ never a screen or a widget; one file, random_case.dart,
//                 is the app's only door to the generator
//   lib/widgets/  never a screen or a service
//   lib/screens/  never the generator, by import or by name
//   tool/         dart:io and the package; the only place that reads
//                 arguments and files
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> dartFiles(String dir) =>
    Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();

List<String> imports(File f) => <String>[
  for (final line in f.readAsLinesSync())
    if (line.startsWith('import ') || line.startsWith('export '))
      line.split(RegExp('[\'"]'))[1],
];

String name(File f) => f.path.replaceAll(r'\', '/');

/// A file in the same folder: no scheme and no path.
bool sibling(String i) => !i.contains(':') && !i.contains('/');

/// An import that reaches the generator, however it is spelled.
bool reachesGen(String i) =>
    RegExp('(^|/)gen/').hasMatch(i) || i.startsWith('package:ruby/gen');

const String door = 'lib/services/random_case.dart';

void main() {
  test('the folders this test guards exist and are not empty', () {
    for (final dir in <String>[
      'lib/engine',
      'lib/gen',
      'lib/data',
      'lib/services',
      'lib/screens',
      'lib/widgets',
      'tool',
    ]) {
      expect(dartFiles(dir), isNotEmpty, reason: dir);
    }
  });

  test('GEN-023 the engine imports nothing but itself', () {
    for (final f in dartFiles('lib/engine')) {
      for (final i in imports(f)) {
        expect(sibling(i), isTrue, reason: '${name(f)} imports $i');
      }
    }
  });

  test('GEN-023 the generator imports only dart:math, engine and data', () {
    for (final f in dartFiles('lib/gen')) {
      for (final i in imports(f)) {
        final allowed =
            i == 'dart:math' ||
            sibling(i) ||
            i.startsWith('../engine/') ||
            i.startsWith('../data/');
        expect(allowed, isTrue, reason: '${name(f)} imports $i');
      }
    }
  });

  test('GEN-023 data files import only data files', () {
    for (final f in dartFiles('lib/data')) {
      for (final i in imports(f)) {
        expect(sibling(i), isTrue, reason: '${name(f)} imports $i');
      }
    }
  });

  test('GEN-023 only one service of the app reaches the generator', () {
    final app = dartFiles('lib')
        .where((File f) => !name(f).startsWith('lib/gen/') && name(f) != door)
        .toList();
    expect(app, isNotEmpty);
    for (final f in app) {
      for (final i in imports(f)) {
        expect(reachesGen(i), isFalse, reason: '${name(f)} imports $i');
      }
    }
    final doorFile = File(door);
    expect(imports(doorFile).where(reachesGen), isNotEmpty);
    // The door hands out case text, not the generator: it re-exports nothing.
    expect(
      doorFile.readAsLinesSync().where((String l) => l.startsWith('export ')),
      isEmpty,
    );
  });

  test('GEN-023 screens and widgets never name the generator', () {
    for (final f in <File>[
      ...dartFiles('lib/screens'),
      ...dartFiles('lib/widgets'),
    ]) {
      final text = f.readAsStringSync();
      for (final word in <String>[
        'generateCase',
        'randomConfig',
        'GenConfig',
        'checkShipped',
        'campaign(',
      ]) {
        expect(text, isNot(contains(word)), reason: '${name(f)}: $word');
      }
    }
  });

  test('GEN-023 the app layers point one way', () {
    void never(String dir, List<String> folders) {
      for (final f in dartFiles(dir)) {
        for (final i in imports(f)) {
          for (final folder in folders) {
            expect(
              i.contains('$folder/'),
              isFalse,
              reason: '${name(f)} imports $i',
            );
          }
        }
      }
    }

    never('lib/services', <String>['screens', 'widgets']);
    never('lib/widgets', <String>['screens', 'services']);
    never('lib/theme', <String>['screens', 'services', 'widgets', 'engine']);
  });

  test('GEN-023 nothing in lib reads files or uses parts', () {
    for (final f in dartFiles('lib')) {
      for (final i in imports(f)) {
        expect(i, isNot('dart:io'), reason: name(f));
        expect(i, isNot('dart:html'), reason: name(f));
        expect(i, isNot('dart:mirrors'), reason: name(f));
      }
      expect(
        f.readAsLinesSync().where((String l) => l.startsWith('part ')),
        isEmpty,
        reason: name(f),
      );
    }
  });

  test('GEN-023 tools import only dart:io and the package', () {
    for (final f in dartFiles('tool')) {
      for (final i in imports(f)) {
        expect(
          i == 'dart:io' || i.startsWith('package:ruby/'),
          isTrue,
          reason: '${name(f)} imports $i',
        );
      }
    }
  });

  test('GEN-016 the engine and the generator have no clock and no '
      'unseeded chance', () {
    for (final f in <File>[
      ...dartFiles('lib/engine'),
      ...dartFiles('lib/gen'),
    ]) {
      final text = f.readAsStringSync();
      for (final word in <String>['DateTime', 'Stopwatch', 'Random()']) {
        expect(text, isNot(contains(word)), reason: '${name(f)}: $word');
      }
    }
  });

  test('GEN-022 a generated file says so, and only generated files do', () {
    for (final f in dartFiles('lib')) {
      final generated = RegExp(r'lib/data/cases_\w+\.dart$').hasMatch(name(f));
      final says = f.readAsStringSync().startsWith('// GENERATED by ');
      expect(says, generated, reason: name(f));
    }
  });

  test('no hand-written source file grows past 2000 lines', () {
    for (final dir in <String>['lib', 'tool', 'test']) {
      for (final f in dartFiles(dir)) {
        if (RegExp(r'lib/data/cases_\w+\.dart$').hasMatch(name(f))) continue;
        expect(f.readAsLinesSync().length, lessThan(2000), reason: name(f));
      }
    }
  });
}
