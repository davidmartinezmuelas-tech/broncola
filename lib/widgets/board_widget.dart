import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/content_pack.dart';
import '../models/player.dart';
import '../models/tile.dart';

class BoardWidget extends StatefulWidget {
  final List<Tile> tiles;
  final List<Player> players;
  final int focusedPosition;
  final Color accentColor;

  const BoardWidget({
    super.key,
    required this.tiles,
    required this.players,
    required this.focusedPosition,
    required this.accentColor,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  final ScrollController _scrollController = ScrollController();

  static const int _columns = 5;
  static const double _tileSize = 54.0;
  static const double _gap = 8.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocused(animate: false));
  }

  @override
  void didUpdateWidget(BoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedPosition != widget.focusedPosition) {
      _scrollToFocused(animate: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _rows => (widget.tiles.length / _columns).ceil();

  List<Offset> get _path => _buildSnakePath(_columns, _rows);

  void _scrollToFocused({required bool animate}) {
    if (!_scrollController.hasClients) return;
    final path = _path;
    if (widget.focusedPosition >= path.length) return;

    final focusedOffset = path[widget.focusedPosition];
    final tileY = _gap + focusedOffset.dy * (_tileSize + _gap);
    final viewHeight = _scrollController.position.viewportDimension;
    final target = (tileY - viewHeight / 2 + _tileSize / 2)
        .clamp(0.0, _scrollController.position.maxScrollExtent);

    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  static List<Offset> _buildSnakePath(int columns, int rows) {
    final path = <Offset>[];
    for (int row = rows - 1; row >= 0; row--) {
      final isEvenStripe = (rows - 1 - row).isEven;
      if (isEvenStripe) {
        for (int col = 0; col < columns; col++) {
          path.add(Offset(col.toDouble(), row.toDouble()));
        }
      } else {
        for (int col = columns - 1; col >= 0; col--) {
          path.add(Offset(col.toDouble(), row.toDouble()));
        }
      }
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final path = _path;
    final width = _columns * _tileSize + (_columns + 1) * _gap;
    final height = rows * _tileSize + (rows + 1) * _gap;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: const Color(0x22000000),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(width, height),
                    painter: _PathPainter(
                      path: path,
                      tileCount: widget.tiles.length,
                      tileSize: _tileSize,
                      gap: _gap,
                    ),
                  ),
                  for (int i = 0; i < widget.tiles.length; i++)
                    _TileCell(
                      tile: widget.tiles[i],
                      index: i,
                      offset: path[i],
                      tileSize: _tileSize,
                      gap: _gap,
                      focused: i == widget.focusedPosition,
                      players: const [],
                      accentColor: widget.accentColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TileCell extends StatelessWidget {
  final Tile tile;
  final int index;
  final Offset offset;
  final double tileSize;
  final double gap;
  final bool focused;
  final List<Player> players;
  final Color accentColor;

  const _TileCell({
    required this.tile,
    required this.index,
    required this.offset,
    required this.tileSize,
    required this.gap,
    required this.focused,
    required this.players,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final config = _configFor(tile.type, isCustom: tile.isCustom);
    return Positioned(
      left: gap + offset.dx * (tileSize + gap),
      top: gap + offset.dy * (tileSize + gap),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          color: config.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: focused ? accentColor : config.border,
            width: focused ? 2.2 : 1.2,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tile.pack != ContentPack.base ? tile.pack.emoji : config.emoji, style: const TextStyle(fontSize: 18)),
            if (tile.isCustom)
              const Text('TUYA', style: TextStyle(color: Color(0xFFD4E157), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5))
            else
              Text(
                '${index + 1}',
                style: TextStyle(
                  color: config.border,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (players.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: players
                    .take(3)
                    .map((p) => _PlayerDot(color: p.color, avatarBytes: p.avatarBytes))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PlayerDot extends StatelessWidget {
  final Color color;
  final Uint8List? avatarBytes;

  const _PlayerDot({required this.color, required this.avatarBytes});

  @override
  Widget build(BuildContext context) {
    if (avatarBytes != null) {
      return CircleAvatar(radius: 7, backgroundImage: MemoryImage(avatarBytes!));
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PathPainter extends CustomPainter {
  final List<Offset> path;
  final int tileCount;
  final double tileSize;
  final double gap;

  const _PathPainter({
    required this.path,
    required this.tileCount,
    required this.tileSize,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < math.min(tileCount - 1, path.length - 1); i++) {
      canvas.drawLine(_center(path[i]), _center(path[i + 1]), paint);
    }
  }

  Offset _center(Offset point) {
    final dx = gap + point.dx * (tileSize + gap) + tileSize / 2;
    final dy = gap + point.dy * (tileSize + gap) + tileSize / 2;
    return Offset(dx, dy);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) =>
      oldDelegate.tileCount != tileCount;
}

// ─────────────────────────────────────────────────────────────────────────────

class _TileStyle {
  final Color background;
  final Color border;
  final String emoji;

  const _TileStyle({required this.background, required this.border, required this.emoji});
}

_TileStyle _configFor(TileType type, {bool isCustom = false}) {
  if (isCustom) {
    return const _TileStyle(background: Color(0xFF1A2410), border: Color(0xFFD4E157), emoji: '⭐');
  }
  switch (type) {
    case TileType.drink:
      return const _TileStyle(background: Color(0xFF10253A), border: Color(0xFF42A5F5), emoji: '🍺');
    case TileType.groupDrink:
      return const _TileStyle(background: Color(0xFF27133B), border: Color(0xFFAB47BC), emoji: '🥂');
    case TileType.social:
      return const _TileStyle(background: Color(0xFF0E2A28), border: Color(0xFF26A69A), emoji: '🎭');
    case TileType.rule:
      return const _TileStyle(background: Color(0xFF37210B), border: Color(0xFFFFA726), emoji: '📜');
    case TileType.chaos:
      return const _TileStyle(background: Color(0xFF321012), border: Color(0xFFEF5350), emoji: '💥');
    case TileType.special:
      return const _TileStyle(background: Color(0xFF1D1736), border: Color(0xFF7E57C2), emoji: '✨');
    case TileType.wildcard:
      return const _TileStyle(background: Color(0xFF1A2A10), border: Color(0xFF66BB6A), emoji: '🃏');
    case TileType.finale:
      return const _TileStyle(background: Color(0xFF2A1353), border: Color(0xFFD1C4E9), emoji: '🏁');
  }
}
