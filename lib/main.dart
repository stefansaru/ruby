import 'package:flutter/material.dart';

/// Placeholder shell. The playable game is not built yet (see TODO.md);
/// this round delivers the engine, the generator and the case packs.
void main() => runApp(const DetectiveSudokuApp());

class DetectiveSudokuApp extends StatelessWidget {
  const DetectiveSudokuApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    title: 'Detective Sudoku',
    home: Scaffold(body: Center(child: Text('Detective Sudoku'))),
  );
}
