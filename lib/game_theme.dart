import 'dart:math';

import 'package:flutter/material.dart';

/// Colours shared across the game UI.
class GamePalette {
  GamePalette._();

  static const backgroundTop = Color(0xFF2A1A5E);
  static const backgroundBottom = Color(0xFF0E0824);

  static const tray = Color(0xFF3B2F80);
  static const trayDeep = Color(0xFF2A2163);
  static const trayEdge = Color(0xFF170F3D);
  static const socketTop = Color(0xFF1A1340);
  static const socketBottom = Color(0xFF261C57);

  static const panel = Color(0xFF4A3AA0);
  static const panelEdge = Color(0xFF241A5C);

  static const gold = Color(0xFFFFC93C);
  static const textMuted = Color(0xFFB9AEF0);
}

const Map<int, Color> _tileColors = {
  2: Color(0xFF5AC8FA),
  4: Color(0xFF3D8BF0),
  8: Color(0xFF2BC4A8),
  16: Color(0xFF55CC55),
  32: Color(0xFFA8CC2A),
  64: Color(0xFFFFB627),
  128: Color(0xFFFF8F2E),
  256: Color(0xFFFF5E3A),
  512: Color(0xFFF0406E),
  1024: Color(0xFFCB45D6),
  2048: Color(0xFFFFCC00),
};

Color tileColorFor(int value) => _tileColors[value] ?? const Color(0xFF8E5CFF);

/// How strongly a tile glows, from 0 (128 and below) to 1 (2048 and up).
double tileGlowFor(int value) {
  if (value < 128) return 0;
  return ((log(value) / ln2 - 6) / 5).clamp(0.0, 1.0);
}

/// Darkens [color] by reducing its HSL lightness by [amount] (0..1).
Color shade(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

/// Lightens [color] by increasing its HSL lightness by [amount] (0..1).
Color tint(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}
