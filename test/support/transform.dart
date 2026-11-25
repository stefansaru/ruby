// Turns a case over: left to right, or top to bottom. The mirrored case
// is the same puzzle seen in a mirror, so it must have exactly one answer,
// the mirror of the original one. A rule that treats left and right (or
// above and below) differently by mistake cannot survive both.
//
// Works on the case text, so it does not lean on the engine's model.

/// The text of [text] mirrored: columns reversed when [columns], rows
/// reversed otherwise.
String mirrored(String text, {required bool columns}) {
  final lines = text.trimRight().split('\n');
  final sizes = <String, (int, int)>{};
  final order = <String>[];
  final out = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final t = line.trim().split(RegExp(r'\s+'));
    switch (t[0]) {
      case 'grid':
        final rows = int.parse(t[2]);
        final cols = int.parse(t[3]);
        sizes[t[1]] = (rows, cols);
        order.add(t[1]);
        out.add(line);
        final body = lines.sublist(i + 1, i + 1 + rows);
        if (columns) {
          out.addAll(<String>[
            for (final row in body)
              row.trim().split(RegExp(r'\s+')).reversed.join(' '),
          ]);
        } else {
          out.addAll(body.reversed);
        }
        i += rows;
      case 'open':
        final (rows, cols) = sizes[t[1]]!;
        final row = int.parse(t[2]);
        final col = int.parse(t[3]);
        const across = <String, String>{'E': 'W', 'W': 'E'};
        const down = <String, String>{'N': 'S', 'S': 'N'};
        out.add(
          columns
              ? 'open ${t[1]} $row ${cols + 1 - col} ${across[t[4]] ?? t[4]} ${t[5]}'
              : 'open ${t[1]} ${rows + 1 - row} $col ${down[t[4]] ?? t[4]} ${t[5]}',
        );
      case 'clue' || 'extra':
        // Row and column numbers mean the speaker's own grid; the grids
        // of a case are the same size, so the first one serves.
        final (rows, cols) = sizes[order.first]!;
        out.add(_clue(t, rows, cols, columns: columns));
      case 'solution':
        out.add(
          <String>[
            'solution',
            for (final part in t.sublist(1))
              () {
                final kv = part.split('=');
                final n = kv[1].split(':').map(int.parse).toList();
                final (rows, cols) = sizes[order[n[0] - 1]]!;
                return columns
                    ? '${kv[0]}=${n[0]}:${n[1]}:${cols + 1 - n[2]}'
                    : '${kv[0]}=${n[0]}:${rows + 1 - n[1]}:${n[2]}';
              }(),
          ].join(' '),
        );
      default:
        out.add(line);
    }
  }
  return '${out.join('\n')}\n';
}

String _clue(List<String> t, int rows, int cols, {required bool columns}) {
  final w = List<String>.of(t);
  String flip(String n) => n == '*' ? n : '${-int.parse(n)}';
  if (w.length > 2 && (w[2] == 'dir' || w[2] == 'offset')) {
    // dir/offset <other> <rows> <cols>
    final axis = columns ? 5 : 4;
    w[axis] = flip(w[axis]);
    return w.join(' ');
  }
  // A test may sit anywhere in the line: "is col 2", "only not row 3",
  // "* count 2 col 1". "line row t" names an object, not a number.
  final word = columns ? 'col' : 'row';
  final size = columns ? cols : rows;
  for (var i = 0; i + 1 < w.length; i++) {
    final n = int.tryParse(w[i + 1]);
    if (w[i] == word && n != null && (i == 0 || w[i - 1] != 'line')) {
      w[i + 1] = '${size + 1 - n}';
    }
  }
  return w.join(' ');
}
