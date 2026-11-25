import 'package:flutter/material.dart';

/// Placeholder colours until the art exists (docs/Art.md).

const List<Color> _areas = <Color>[
  Color(0xFFF6D8AE),
  Color(0xFFBFE3C0),
  Color(0xFFBCD9F2),
  Color(0xFFF3C6CF),
  Color(0xFFE2D4F0),
  Color(0xFFF5EBA8),
  Color(0xFFCFE8E4),
  Color(0xFFE6D2BE),
];

const List<Color> _people = <Color>[
  Color(0xFFD1495B),
  Color(0xFF2E7DAF),
  Color(0xFF3E8E5A),
  Color(0xFFB8621B),
  Color(0xFF7A4EA3),
  Color(0xFF00838F),
  Color(0xFFAD1457),
  Color(0xFF5C6BC0),
  Color(0xFF6D4C41),
  Color(0xFF558B2F),
  Color(0xFFC2185B),
  Color(0xFF455A64),
];

Color areaColor(int area) => _areas[area % _areas.length];

Color personColor(int person) => _people[person % _people.length];
