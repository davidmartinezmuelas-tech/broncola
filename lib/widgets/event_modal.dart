import 'package:flutter/material.dart';

import '../models/tile.dart';

class EventModal extends StatelessWidget {
  final String playerName;
  final Tile tile;
  final String detail;
  final VoidCallback onNext;
  final bool isRollAgain;

  const EventModal({
    super.key,
    required this.playerName,
    required this.tile,
    required this.detail,
    required this.onNext,
    this.isRollAgain = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String playerName,
    required Tile tile,
    required String detail,
    required VoidCallback onNext,
    bool isRollAgain = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EventModal(
        playerName: playerName,
        tile: tile,
        detail: detail,
        onNext: onNext,
        isRollAgain: isRollAgain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _tileConfig(tile.type, isCustom: tile.isCustom);
    final category = tile.category == null ? null : _categoryLabel(tile.category!);
    final trimmedDetail = detail.trim();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [config.colorDark, config.colorLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: config.colorDark.withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(config.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(config.label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            if (category != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(999)),
                child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
            const SizedBox(height: 14),
            Text(playerName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text(tile.text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.35)),
                  if (trimmedDetail.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(trimmedDetail, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.35)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNext();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: config.colorDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(isRollAgain ? '🃏  Robar otra carta' : 'Siguiente turno', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(TileCategory category) {
    switch (category) {
      case TileCategory.truth:
        return 'Verdad';
      case TileCategory.dare:
        return 'Reto';
      case TileCategory.neverHaveIEver:
        return 'Nunca nunca';
      case TileCategory.actOut:
        return 'Imitación / actuación';
      case TileCategory.whoIsMostLikely:
        return '¿Quién es más probable?';
      case TileCategory.custom:
        return 'Casilla personalizada';
    }
  }
}

class _TileConfig {
  final String emoji;
  final String label;
  final Color colorDark;
  final Color colorLight;

  const _TileConfig({required this.emoji, required this.label, required this.colorDark, required this.colorLight});
}

_TileConfig _tileConfig(TileType type, {bool isCustom = false}) {
  if (isCustom) {
    return const _TileConfig(emoji: '⭐', label: 'CASILLA ESPECIAL', colorDark: Color(0xFF33691E), colorLight: Color(0xFF7CB342));
  }
  switch (type) {
    case TileType.drink:
      return const _TileConfig(emoji: '🍺', label: 'BEBE', colorDark: Color(0xFF1565C0), colorLight: Color(0xFF1E88E5));
    case TileType.groupDrink:
      return const _TileConfig(emoji: '🥂', label: 'BEBEN VARIOS', colorDark: Color(0xFF6A1B9A), colorLight: Color(0xFF8E24AA));
    case TileType.social:
      return const _TileConfig(emoji: '🎭', label: 'SOCIAL', colorDark: Color(0xFF00695C), colorLight: Color(0xFF00897B));
    case TileType.rule:
      return const _TileConfig(emoji: '📜', label: 'NUEVA REGLA', colorDark: Color(0xFFE65100), colorLight: Color(0xFFF57C00));
    case TileType.chaos:
      return const _TileConfig(emoji: '💥', label: 'CAOS', colorDark: Color(0xFFB71C1C), colorLight: Color(0xFFE53935));
    case TileType.special:
      return const _TileConfig(emoji: '✨', label: 'ESPECIAL', colorDark: Color(0xFF4527A0), colorLight: Color(0xFF7E57C2));
    case TileType.wildcard:
      return const _TileConfig(emoji: '🃏', label: 'COMODÍN', colorDark: Color(0xFF1B5E20), colorLight: Color(0xFF388E3C));
    case TileType.finale:
      return const _TileConfig(emoji: '🎉', label: 'FINAL', colorDark: Color(0xFF1A0050), colorLight: Color(0xFF7C3AED));
  }
}

