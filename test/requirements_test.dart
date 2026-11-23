// Keeps the GEN register (docs/requirements/gen/) and the tests in step:
// every requirement is cited by a test, and every id a test cites exists.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final id = RegExp(r'GEN-\d{3}');
  final register = Directory('docs/requirements/gen');

  Set<String> registered() => <String>{
    for (final f in register.listSync().whereType<File>())
      if (id.hasMatch(f.uri.pathSegments.last))
        id.firstMatch(f.uri.pathSegments.last)!.group(0)!,
  };

  Set<String> cited() => <String>{
    for (final f
        in Directory('test')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (File f) =>
                  f.path.endsWith('_test.dart') &&
                  !f.path.endsWith('requirements_test.dart'),
            ))
      for (final m in id.allMatches(f.readAsStringSync())) m.group(0)!,
  };

  test('the register is there', () {
    expect(register.existsSync(), isTrue);
    expect(registered().length, greaterThan(20));
    expect(File('docs/requirements/gen/_TEMPLATE.md').existsSync(), isTrue);
  });

  test('every GEN requirement is cited by at least one test', () {
    expect(registered().difference(cited()), isEmpty);
  });

  test('every GEN id cited by a test is in the register', () {
    expect(cited().difference(registered()), isEmpty);
  });

  test('every requirement file has the four headings and its own id', () {
    for (final f in register.listSync().whereType<File>()) {
      final file = f.uri.pathSegments.last;
      if (!id.hasMatch(file)) continue;
      final text = f.readAsStringSync();
      expect(
        text,
        startsWith('# ${id.firstMatch(file)!.group(0)}'),
        reason: file,
      );
      for (final heading in <String>[
        '## Requirement',
        '## Why',
        '## How it is enforced',
        '## Covered by',
      ]) {
        expect(text, contains(heading), reason: file);
      }
      expect(text, contains('**Status:**'), reason: file);
    }
  });

  test('the index lists every requirement', () {
    final index = File('docs/requirements/gen/README.md').readAsStringSync();
    for (final r in registered()) {
      expect(index, contains(r));
    }
  });
}
