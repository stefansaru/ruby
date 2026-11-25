import 'package:flutter/material.dart';

import '../engine/case_text.dart';
import '../engine/model.dart';
import '../engine/session.dart';
import '../engine/wording.dart';
import '../services/progress.dart';
import '../theme/palette.dart';
import '../widgets/case_grid.dart';
import '../widgets/clue_text.dart';

/// Plays one pack: shows case [index] and moves on to the next when asked.
///
/// The screen decides nothing about the game. What a tap does, who is
/// next, how a statement stands and what a hint says all come from
/// [CaseSession] and the wording; this file lays them out.
class CaseScreen extends StatefulWidget {
  const CaseScreen({required this.pack, required this.index, super.key})
    : assert(index >= 0 && index < pack.length, 'no such case in the pack');

  /// The cases of one tier, in the text format.
  final List<String> pack;
  final int index;

  @override
  State<CaseScreen> createState() => _CaseScreenState();
}

class _CaseScreenState extends State<CaseScreen> {
  late final CaseSession session = CaseSession(
    parseCase(widget.pack[widget.index]),
  );
  late final List<GlobalKey> cardKeys = <GlobalKey>[
    for (final _ in c.people) GlobalKey(),
  ];

  /// How many extra statements each person has open.
  late final List<int> extrasShown = Progress.extrasShown(
    c.id,
    c.people.length,
  );

  String? message;

  /// True while [message] is a hint that has not yet named its square: a
  /// second tap on the hint button then adds the square.
  bool hintWaiting = false;

  CaseDef get c => session.c;
  Mode get mode => Progress.mode.value;

  /// Brings the selected person's card into view once the frame is built.
  void _showSelected() {
    final person = session.selected;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final card = cardKeys[person].currentContext;
      if (card == null || !card.mounted) return;
      Scrollable.ensureVisible(
        card,
        alignment: 0.05,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  void _clearMessage() {
    message = null;
    hintWaiting = false;
  }

  void _tapCell(int cell) {
    setState(() {
      _clearMessage();
      switch (session.tap(cell)) {
        case TapOutcome.ignored:
          return;
        case TapOutcome.refused:
          message = noticeBlocked;
          return;
        case TapOutcome.lifted:
        case TapOutcome.placed:
          _showSelected();
      }
      if (!session.complete) return;
      if (session.solved) {
        Progress.markSolved(c.id);
      } else {
        message = noticeMisfit;
      }
    });
  }

  void _hint() {
    final hint = session.hint();
    setState(() {
      if (hint == null) {
        message = noticeSolved;
        hintWaiting = false;
        return;
      }
      session.select(hint.person);
      _showSelected();
      if (hint.wrong) {
        message = describeWrong(c, hint.person, hint.cell);
        hintWaiting = false;
        return;
      }
      // First tap: who can be worked out and why. Second tap: the square.
      final withSquare = hintWaiting;
      hintWaiting = !withSquare;
      message = describeHint(
        c,
        hint.person,
        hint.because,
        square: withSquare ? hint.cell : null,
        mode: mode,
        lie: hint.lie,
      ).join('\n');
    });
  }

  void _restart() {
    setState(() {
      session.clear();
      _clearMessage();
      _showSelected();
    });
  }

  @override
  Widget build(BuildContext context) {
    final grids = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var g = 0; g < c.grids.length; g++)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (c.grids.length > 1)
                  Text(
                    c.grids[g].label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                // Flexible: the grid also shrinks to the height it is
                // given, so a wide or short screen never clips its rows.
                Flexible(
                  child: CaseGrid(
                    key: ValueKey<String>('grid-$g'),
                    session: session,
                    gridIndex: g,
                    onTapCell: _tapCell,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    // Messages stay pinned above the list so they are never scrolled away.
    final notices = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (session.complete && session.solved) _solvedCard(context),
          if (message != null) _messageCard(context),
        ],
      ),
    );
    final list = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final rule in describeRules(c))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: ClueText(describeRuleLine(rule)),
            ),
          for (final clue in c.clues)
            if (clue.subject == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: _statement(describeClue(c, clue), session.markOf(clue)),
              ),
          for (var p = 0; p < c.people.length; p++) _personCard(context, p),
        ],
      ),
    );

    final cards = Column(
      children: <Widget>[
        // A long hint scrolls inside its share of the screen, so it can
        // never push the statements off it.
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.3,
          ),
          child: SingleChildScrollView(child: notices),
        ),
        Expanded(child: list),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(c.title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Hint',
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _hint,
          ),
          IconButton(
            tooltip: 'Start again',
            icon: const Icon(Icons.restart_alt),
            onPressed: _restart,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth > box.maxHeight) {
              return Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: grids,
                      ),
                    ),
                  ),
                  Expanded(flex: 2, child: cards),
                ],
              );
            }
            return Column(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: box.maxHeight * 0.58),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: grids,
                  ),
                ),
                Expanded(child: cards),
              ],
            );
          },
        ),
      ),
    );
  }

  /// A hint or a notice, with a button to put it away.
  Widget _messageCard(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClueText(message!, key: const ValueKey<String>('message')),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close),
            onPressed: () => setState(_clearMessage),
          ),
        ],
      ),
    ),
  );

  /// One line of a checklist: a tick when the placements fit the
  /// statement, a cross when they contradict it, an empty ring until then.
  Widget _statement(String text, ClueMark mark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 1, right: 6),
          child: switch (mark) {
            ClueMark.met => const Icon(
              Icons.check_circle,
              size: 18,
              color: Colors.green,
              semanticLabel: 'Fits',
            ),
            ClueMark.broken => const Icon(
              Icons.cancel,
              size: 18,
              color: Colors.red,
              semanticLabel: 'Does not fit',
            ),
            ClueMark.open => const Icon(
              Icons.radio_button_unchecked,
              size: 18,
              color: Colors.black38,
            ),
          },
        ),
        Expanded(child: ClueText(text)),
      ],
    ),
  );

  Widget _personCard(BuildContext context, int p) {
    final person = c.people[p];
    final placed = session.pos[p] >= 0;
    final isSelected = p == session.selected;
    final traits = person.traits.isEmpty
        ? ''
        : ' (${person.traits.join(', ')})';
    final where = placed ? '  ·  ${c.placeLabel(session.pos[p])}' : '';
    return Opacity(
      key: cardKeys[p],
      // A placed person's card steps back; the ticks stay readable.
      opacity: placed && !isSelected ? 0.55 : 1,
      child: Card(
        key: ValueKey<String>('person-${person.id}'),
        color: placed ? Theme.of(context).colorScheme.surfaceDim : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            width: isSelected ? 3 : 1,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.black26,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() {
            session.select(p);
            _clearMessage();
          }),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: person.isVictim
                      ? Colors.black87
                      : personColor(p),
                  child: Text(
                    person.id,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${person.name}$traits$where',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (person.isVictim)
                        _statement(describeVictim(c, mode), session.victimMark)
                      else
                        for (final clue in session.statementsOf(
                          p,
                          shown: extrasShown[p],
                        ))
                          _statement(
                            describeClue(c, clue),
                            session.markOf(clue),
                          ),
                    ],
                  ),
                ),
                if (extrasShown[p] < session.extrasOf(p).length)
                  IconButton(
                    tooltip: 'One more statement',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() {
                      extrasShown[p]++;
                      Progress.setExtrasShown(c.id, extrasShown);
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _solvedCard(BuildContext context) {
    final hasNext = widget.index + 1 < widget.pack.length;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Case solved', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            ClueText(describeSolved(c, c.solution!, mode)),
            const SizedBox(height: 8),
            Wrap(
              children: <Widget>[
                if (hasNext)
                  FilledButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => CaseScreen(
                          pack: widget.pack,
                          index: widget.index + 1,
                        ),
                      ),
                    ),
                    child: const Text('Next case'),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to the list'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
