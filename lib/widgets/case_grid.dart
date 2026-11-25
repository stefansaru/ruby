import 'package:flutter/material.dart';

import '../engine/model.dart';
import '../engine/session.dart';
import '../theme/palette.dart';

/// Walls, and the tabs that carry the area names on them.
const Color _wallColor = Color(0xDD000000);

/// Where the squares of one grid are inside a box: lettered columns along
/// the top, numbered rows down the left, square cells.
class GridGeometry {
  GridGeometry(this.grid, Size size)
    : cell = _min(
        size.width / (grid.cols + 0.6),
        size.height / (grid.rows + 0.6),
      );

  final GridDef grid;
  final double cell;

  static double _min(double a, double b) => a < b ? a : b;

  double get margin => cell * 0.6;
  Size get size => Size(margin + grid.cols * cell, margin + grid.rows * cell);

  Rect rectOf(int row, int col) =>
      Rect.fromLTWH(margin + col * cell, margin + row * cell, cell, cell);

  /// The cell index under [at], or -1.
  int cellAt(Offset at) {
    final col = ((at.dx - margin) / cell).floor();
    final row = ((at.dy - margin) / cell).floor();
    if (at.dx < margin || at.dy < margin) return -1;
    if (row < 0 || col < 0 || row >= grid.rows || col >= grid.cols) return -1;
    return grid.cellAt[row][col];
  }
}

/// One grid of a case, drawn with placeholder shapes until art exists:
/// a colour per area, thick walls, objects as labelled tiles, people as
/// lettered discs. Reports taps on squares.
///
/// A wide object (a bed, a boat) is two squares of one object in the case
/// (`Cell.instance`); this draft draws each square as its own tile.
class CaseGrid extends StatelessWidget {
  const CaseGrid({
    required this.session,
    required this.gridIndex,
    required this.onTapCell,
    super.key,
  });

  final CaseSession session;
  final int gridIndex;
  final ValueChanged<int> onTapCell;

  @override
  Widget build(BuildContext context) {
    final grid = session.c.grids[gridIndex];
    return AspectRatio(
      aspectRatio: (grid.cols + 0.6) / (grid.rows + 0.6),
      child: LayoutBuilder(
        builder: (context, box) {
          final geometry = GridGeometry(grid, box.biggest);
          return GestureDetector(
            onTapUp: (details) {
              final cell = geometry.cellAt(details.localPosition);
              if (cell >= 0) onTapCell(cell);
            },
            child: CustomPaint(
              size: box.biggest,
              painter: _GridPainter(
                session,
                gridIndex,
                geometry,
                session.selected,
                List<int>.of(session.pos),
                Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(
    this.session,
    this.gridIndex,
    this.g,
    this.selected,
    this.pos,
    this.ink,
  );

  final CaseSession session;
  final int gridIndex;
  final GridGeometry g;
  final int selected;
  final List<int> pos;
  final Color ink;

  void _text(
    Canvas canvas,
    String text,
    Offset centre,
    double size,
    Color color, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter
      ..paint(canvas, centre - Offset(painter.width / 2, painter.height / 2))
      ..dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = session.c;
    final grid = g.grid;
    final cell = g.cell;
    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black26;
    final wall = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.09
      ..strokeCap = StrokeCap.square
      ..color = _wallColor;

    for (var k = 0; k < grid.cols; k++) {
      _text(
        canvas,
        colLabel(k),
        Offset(g.margin + (k + 0.5) * cell, g.margin * 0.5),
        cell * 0.3,
        ink,
        bold: true,
      );
    }
    for (var r = 0; r < grid.rows; r++) {
      _text(
        canvas,
        '${r + 1}',
        Offset(g.margin * 0.5, g.margin + (r + 0.5) * cell),
        cell * 0.3,
        ink,
        bold: true,
      );
    }

    // Floors and objects.
    for (final x in c.cells) {
      if (x.grid != gridIndex) continue;
      final rect = g.rectOf(x.row, x.col);
      canvas
        ..drawRect(rect, Paint()..color = areaColor(x.area))
        ..drawRect(rect, thin);
      if (x.kind < 0) continue;
      final kind = c.kinds[x.kind];
      // The top strip of a square is kept free for the area name.
      final tile = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          rect.left + cell * 0.1,
          rect.top + cell * 0.2,
          rect.right - cell * 0.1,
          rect.bottom - cell * 0.05,
        ),
        Radius.circular(cell * (kind.canOccupy ? 0.22 : 0.04)),
      );
      if (kind.canOccupy) {
        // Something a person can be on: a light outlined tile.
        canvas
          ..drawRRect(tile, Paint()..color = Colors.white70)
          ..drawRRect(
            tile,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = Colors.black54,
          );
      } else {
        // Something that blocks the square: a dark solid tile.
        canvas.drawRRect(tile, Paint()..color = const Color(0xFF5D5348));
      }
      final name = kind.name.length > 7 ? kind.name.substring(0, 7) : kind.name;
      _text(
        canvas,
        name,
        rect.center + Offset(0, kind.canOccupy ? cell * 0.3 : cell * 0.07),
        cell * 0.19,
        kind.canOccupy ? Colors.black87 : Colors.white,
      );
    }

    // Walls, then doors and windows on them.
    for (final x in c.cells) {
      if (x.grid != gridIndex) continue;
      final rect = g.rectOf(x.row, x.col);
      for (final side in Side.values) {
        if (!c.isWall(x.index, side)) continue;
        final (a, b) = _edge(rect, side);
        canvas.drawLine(a, b, wall);
      }
    }
    for (final o in c.openings) {
      final x = c.cells[o.cell];
      if (x.grid != gridIndex) continue;
      final (a, b) = _edge(g.rectOf(x.row, x.col), o.side);
      canvas.drawLine(
        Offset.lerp(a, b, 0.25)!,
        Offset.lerp(a, b, 0.75)!,
        Paint()
          ..strokeWidth = cell * 0.13
          ..strokeCap = StrokeCap.round
          ..color = o.isDoor
              ? const Color(0xFFB7791F)
              : const Color(0xFF7CC4EE),
      );
    }

    _areaNames(canvas);

    // A cross on every empty square in the row or column of someone
    // already placed: nobody else can go there.
    final cross = Paint()
      ..strokeWidth = cell * 0.05
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x99B3261E);
    for (final index in session.crossedOut) {
      final x = c.cells[index];
      if (x.grid != gridIndex) continue;
      final r = g.rectOf(x.row, x.col).deflate(cell * 0.36);
      canvas
        ..drawLine(r.topLeft, r.bottomRight, cross)
        ..drawLine(r.topRight, r.bottomLeft, cross);
    }

    // People.
    final clashing = session.conflicts;
    for (var p = 0; p < pos.length; p++) {
      if (pos[p] < 0) continue;
      final x = c.cells[pos[p]];
      if (x.grid != gridIndex) continue;
      final centre = g.rectOf(x.row, x.col).center + Offset(0, cell * 0.06);
      final person = c.people[p];
      canvas.drawCircle(
        centre,
        cell * 0.3,
        Paint()..color = person.isVictim ? Colors.black87 : personColor(p),
      );
      if (clashing.contains(p) || p == selected) {
        canvas.drawCircle(
          centre,
          cell * 0.34,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = cell * 0.07
            ..color = clashing.contains(p) ? Colors.red : Colors.white,
        );
      }
      _text(canvas, person.id, centre, cell * 0.36, Colors.white, bold: true);
    }
  }

  /// Writes each area's name on a tab in the colour of the wall, hanging
  /// from its longest stretch of top wall, or from its longest stretch of
  /// left wall when that gives the name more room.
  void _areaNames(Canvas canvas) {
    final c = session.c;
    final grid = g.grid;
    final cell = g.cell;
    for (var a = 0; a < c.areas.length; a++) {
      bool mine(int r, int k) =>
          r >= 0 &&
          k >= 0 &&
          r < grid.rows &&
          k < grid.cols &&
          grid.cellAt[r][k] >= 0 &&
          c.cells[grid.cellAt[r][k]].area == a;
      // (row, column, length) of the longest run along a wall.
      var across = (0, 0, 0);
      var down = (0, 0, 0);
      for (var r = 0; r < grid.rows; r++) {
        var run = 0;
        for (var k = 0; k < grid.cols; k++) {
          run = mine(r, k) && !mine(r - 1, k) ? run + 1 : 0;
          if (run > across.$3) across = (r, k - run + 1, run);
        }
      }
      for (var k = 0; k < grid.cols; k++) {
        var run = 0;
        for (var r = 0; r < grid.rows; r++) {
          run = mine(r, k) && !mine(r, k - 1) ? run + 1 : 0;
          if (run > down.$3) down = (r - run + 1, k, run);
        }
      }
      if (across.$3 == 0) continue; // The area is on another grid.
      final painter = TextPainter(
        text: TextSpan(
          text: c.areas[a].name,
          style: TextStyle(
            fontSize: cell * 0.15,
            height: 1,
            fontWeight: FontWeight.w700,
            // The tab is the colour of the wall; the name stands out on it.
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      // The name sits on a tab that hangs from the wall: as wide as the
      // name at the wall, cut slanted at its far end.
      final height = cell * 0.2;
      final pad = cell * 0.07;
      final slant = height * 0.7;
      double room(int squares) => squares * cell - 2 * pad - slant;
      // Turn the name only when it does not fit across and fits better down.
      final turned = painter.width > room(across.$3) && down.$3 > across.$3;
      final space = room(turned ? down.$3 : across.$3);
      final scale = painter.width > space ? space / painter.width : 1.0;
      final width = painter.width * scale + 2 * pad;
      canvas.save();
      // Move to where the tab meets the wall, x running along the wall.
      if (turned) {
        final top = g.rectOf(down.$1, down.$2);
        canvas
          ..translate(top.left, top.top + down.$3 * cell)
          ..rotate(-1.5707963267948966);
      } else {
        final first = g.rectOf(across.$1, across.$2);
        canvas.translate(first.left, first.top);
      }
      canvas
        ..drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(width + slant, 0)
            ..lineTo(width, height)
            ..lineTo(0, height)
            ..close(),
          Paint()..color = _wallColor,
        )
        ..translate(pad, (height - painter.height * scale) / 2)
        ..scale(scale);
      painter
        ..paint(canvas, Offset.zero)
        ..dispose();
      canvas.restore();
    }
  }

  (Offset, Offset) _edge(Rect r, Side side) => switch (side) {
    Side.north => (r.topLeft, r.topRight),
    Side.east => (r.topRight, r.bottomRight),
    Side.south => (r.bottomLeft, r.bottomRight),
    Side.west => (r.topLeft, r.bottomLeft),
  };

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.selected != selected ||
      old.ink != ink ||
      old.g.cell != g.cell ||
      old.session != session ||
      !_same(old.pos, pos);

  static bool _same(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return a.length == b.length;
  }
}
