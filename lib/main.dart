import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/progress.dart';
import 'services/store.dart';

/// A playable draft: pick a case, place everyone, find the culprit.
/// Placeholder shapes, no purchase yet (see TODO.md).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Progress.init(await openStore());
  runApp(const DetectiveSudokuApp());
}

/// The device's store, or one in memory when the device refuses: the game
/// must start even if nothing can be saved.
Future<KeyValueStore> openStore({
  Future<KeyValueStore> Function() open = PrefsStore.open,
}) async {
  try {
    return await open();
  } on Object catch (e) {
    debugPrint('progress will not be saved: $e');
    return MemoryStore();
  }
}

class DetectiveSudokuApp extends StatelessWidget {
  const DetectiveSudokuApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Detective Sudoku',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B2335)),
    ),
    home: const HomeScreen(),
  );
}
