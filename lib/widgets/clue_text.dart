import 'package:flutter/material.dart';

/// A sentence from the engine's wording, with `**key words**` drawn bold.
class ClueText extends StatelessWidget {
  const ClueText(this.text, {this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
        ],
      ),
      style: style,
    );
  }
}
