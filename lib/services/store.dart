import 'package:shared_preferences/shared_preferences.dart';

/// Where the app keeps the little it remembers: text by key. Behind an
/// interface so the screens and tests never touch the phone's storage
/// directly.
abstract class KeyValueStore {
  String? read(String key);
  Future<void> write(String key, String value);
}

/// Forgets everything when the app closes. The default, and what tests use.
class MemoryStore implements KeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  String? read(String key) => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

/// Kept on the device.
class PrefsStore implements KeyValueStore {
  PrefsStore._(this._prefs);
  final SharedPreferences _prefs;

  static Future<PrefsStore> open() async =>
      PrefsStore._(await SharedPreferences.getInstance());

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
}
