import 'package:flutter/material.dart';

import '../data/cases.dart';
import '../engine/case_text.dart';
import '../engine/tier.dart';
import '../engine/wording.dart';
import '../services/progress.dart';
import '../services/random_case.dart';
import '../widgets/clue_text.dart';
import 'case_screen.dart';

String _capital(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// The packs, easiest first, and the cases inside each.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// The tiers that have a pack, easiest first.
  final List<Tier> tiers = <Tier>[
    for (final tier in Tier.values)
      if (casePacks.containsKey(tier.name)) tier,
  ];

  /// The tier a random case is being made for. Kept here and not in the
  /// button, which is a list row and is thrown away when scrolled off.
  Tier? making;

  Future<void> _makeRandom(Tier tier) async {
    if (making != null) return;
    setState(() => making = tier);
    String? text;
    try {
      text = await RandomCases.inBackground(tier);
    } on Object catch (e) {
      debugPrint('no random case: $e');
    }
    if (!mounted) return;
    setState(() => making = null);
    if (text == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(noticeNoRandomCase)));
      return;
    }
    final made = text;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CaseScreen(pack: <String>[made], index: 0),
      ),
    );
  }

  void _howToPlay() {
    final steps = howToPlay(Progress.mode.value);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to play'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ClueText('${i + 1}.  ${steps[i]}'),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: tiers.length,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Detective Sudoku'),
        actions: <Widget>[
          ValueListenableBuilder<Mode>(
            valueListenable: Progress.mode,
            builder: (context, mode, _) => PopupMenuButton<String>(
              tooltip: 'Menu',
              onSelected: (choice) {
                if (choice == 'how') {
                  _howToPlay();
                } else {
                  Progress.setMode(
                    choice == Mode.cat.name ? Mode.cat : Mode.detective,
                  );
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                CheckedPopupMenuItem<String>(
                  value: Mode.detective.name,
                  checked: mode == Mode.detective,
                  child: const Text('Detective mode'),
                ),
                CheckedPopupMenuItem<String>(
                  value: Mode.cat.name,
                  checked: mode == Mode.cat,
                  child: const Text('Cat mode'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'how',
                  child: Text('How to play'),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          tabs: <Widget>[
            for (final tier in tiers) Tab(text: _capital(tier.name)),
          ],
        ),
      ),
      body: TabBarView(
        children: <Widget>[
          for (final tier in tiers)
            _PackList(
              tier: tier,
              pack: casePacks[tier.name]!,
              making: making == tier,
              onRandom: making == null ? () => _makeRandom(tier) : null,
            ),
        ],
      ),
    ),
  );
}

class _PackList extends StatelessWidget {
  const _PackList({
    required this.tier,
    required this.pack,
    required this.making,
    required this.onRandom,
  });

  final Tier tier;
  final List<String> pack;

  /// A random case of this tier is being made.
  final bool making;

  /// Null while any random case is being made.
  final VoidCallback? onRandom;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
    valueListenable: Progress.solved,
    builder: (context, solved, _) => ListView.builder(
      // One more row at the bottom: the random case button.
      itemCount: pack.length + 1,
      itemBuilder: (context, i) {
        if (i == pack.length) return _randomButton();
        // Only the header is read here; the case is checked when opened.
        final c = readHeader(pack[i]);
        final size = c.sizes
            .map(((int, int) g) => '${g.$1}x${g.$2}')
            .join(' + ');
        return ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text(c.title),
          subtitle: Text(
            '${_capital(c.setting)}  ·  $size  ·  ${c.people} people',
          ),
          trailing: solved.contains(c.id)
              ? const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  semanticLabel: 'Solved',
                )
              : const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CaseScreen(pack: pack, index: i),
            ),
          ),
        );
      },
    ),
  );

  Widget _randomButton() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    child: FilledButton.tonalIcon(
      key: ValueKey<String>('random-${tier.name}'),
      onPressed: onRandom,
      icon: making
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.casino_outlined),
      label: Text(making ? 'Making a case…' : 'Generate a random case'),
    ),
  );
}
