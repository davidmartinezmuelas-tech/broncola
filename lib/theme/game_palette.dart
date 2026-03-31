import 'package:flutter/material.dart';
import '../models/game_mode.dart';

class GamePalette {
  final Color accent;
  final Color accentSoft;
  final Color background;
  final Color panel;
  final List<Color> gradient;

  const GamePalette({
    required this.accent,
    required this.accentSoft,
    required this.background,
    required this.panel,
    required this.gradient,
  });
}

GamePalette paletteFor(GameMode mode) {
  switch (mode) {
    case GameMode.light:
      return const GamePalette(
        accent: Color(0xFF26A69A),
        accentSoft: Color(0xFF80CBC4),
        background: Color(0xFF08141A),
        panel: Color(0xFF12232C),
        gradient: [Color(0xFF08141A), Color(0xFF11323A), Color(0xFF0D1F24)],
      );
    case GameMode.spicy:
      return const GamePalette(
        accent: Color(0xFFFF7A45),
        accentSoft: Color(0xFFFFB088),
        background: Color(0xFF1B0F0A),
        panel: Color(0xFF2A1712),
        gradient: [Color(0xFF1B0F0A), Color(0xFF492018), Color(0xFF2B140E)],
      );
    case GameMode.wild:
      return const GamePalette(
        accent: Color(0xFFE53935),
        accentSoft: Color(0xFFEF9A9A),
        background: Color(0xFF140707),
        panel: Color(0xFF261111),
        gradient: [Color(0xFF140707), Color(0xFF351010), Color(0xFF1E0909)],
      );
  }
}
