import 'package:flutter/foundation.dart';

import '../engine/model.dart' show isRandomId;
import '../engine/wording.dart';
import 'store.dart';

/// What the player has done and chosen: solved cases, the mode, and how
/// many extra statements they have opened in each case. Saved through a
/// [KeyValueStore]; in memory until [init] is given a real one.
///
/// One per app, reached statically: the screens listen to [solved] and
/// [mode]. Tests call [init] with a fresh [MemoryStore] before each test.
abstract final class Progress {
  static KeyValueStore _store = MemoryStore();

  static final ValueNotifier<Set<String>> solved = ValueNotifier<Set<String>>(
    <String>{},
  );

  static final ValueNotifier<Mode> mode = ValueNotifier<Mode>(Mode.detective);

  /// Reads what was saved. Called once at start, and by tests to start
  /// from nothing. Anything unreadable is taken as "nothing saved".
  static void init(KeyValueStore store) {
    _store = store;
    final ids = store.read('solved') ?? '';
    solved.value = <String>{
      for (final id in ids.split(','))
        if (id.isNotEmpty) id,
    };
    mode.value = store.read('mode') == Mode.cat.name
        ? Mode.cat
        : Mode.detective;
  }

  /// Saving must never break play: a failed write is dropped, and what
  /// the player did stays true until the app closes.
  static Future<void> _save(String key, String value) async {
    try {
      await _store.write(key, value);
    } on Object catch (e) {
      debugPrint('could not save $key: $e');
    }
  }

  /// Cases made on request have no place in the list, so no tick.
  static void markSolved(String caseId) {
    if (isRandomId(caseId) || solved.value.contains(caseId)) return;
    solved.value = <String>{...solved.value, caseId};
    _save('solved', solved.value.join(','));
  }

  static void setMode(Mode value) {
    mode.value = value;
    _save('mode', value.name);
  }

  /// How many extra statements each person of [caseId] has open: one
  /// number per person, never negative, whatever was saved.
  static List<int> extrasShown(String caseId, int people) {
    final saved = (_store.read('extras.$caseId') ?? '').split(',');
    int at(int p) {
      final n = p < saved.length ? int.tryParse(saved[p]) ?? 0 : 0;
      return n < 0 ? 0 : n;
    }

    return List<int>.generate(people, at);
  }

  static void setExtrasShown(String caseId, List<int> shown) {
    if (isRandomId(caseId)) return;
    _save('extras.$caseId', shown.join(','));
  }
}
