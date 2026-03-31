import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../models/game_setup.dart';
import '../models/player.dart';
import '../theme/game_palette.dart';
import 'game_screen.dart';

class SpinScreen extends StatefulWidget {
  final List<Player> players;
  final GameMode gameMode;
  final GameSetup setup;

  const SpinScreen({
    super.key,
    required this.players,
    required this.gameMode,
    required this.setup,
  });

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scrollAnim;

  bool _spinning = false;
  bool _done = false;
  int _winnerIndex = 0;

  // How many "slots" to cycle visually
  static const int _slotsVisible = 3;

  // Current fractional index in the player list (for display)
  double _currentIndex = 0;
  Timer? _ticker;
  double _speed = 0;

  GamePalette get _palette => paletteFor(widget.gameMode);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scrollAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_spinning) return;
    setState(() {
      _spinning = true;
      _done = false;
    });

    _winnerIndex = Random().nextInt(widget.players.length);
    final n = widget.players.length;

    // Total ticks: spin full rounds + land on winner
    const totalDuration = Duration(milliseconds: 2800);
    final startSpeed = 0.18; // index per tick
    final stopAfter = totalDuration.inMilliseconds;
    var elapsed = 0;
    const tickMs = 40;

    // Start fast, decelerate
    _speed = startSpeed;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      elapsed += tickMs;
      final progress = (elapsed / stopAfter).clamp(0.0, 1.0);
      // Ease out speed
      _speed = startSpeed * (1 - Curves.easeIn.transform(progress));

      setState(() => _currentIndex = (_currentIndex + _speed) % n);

      if (elapsed >= stopAfter) {
        timer.cancel();
        // Snap to winner
        final snapped = _winnerIndex.toDouble();
        setState(() {
          _currentIndex = snapped;
          _spinning = false;
          _done = true;
        });
        _controller.forward(from: 0);
      }
    });
  }

  void _proceed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          players: widget.players,
          gameMode: widget.gameMode,
          setup: widget.setup,
          startingPlayerIndex: _winnerIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.players.length;
    final displayIndex = _currentIndex.round() % n;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _palette.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Text(
                  'RULETA DE INICIO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gira para saber quién empieza',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const Spacer(),
                // Slot reel
                Center(
                  child: Container(
                    width: 280,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _palette.accent, width: 2),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _buildReel(n, displayIndex),
                  ),
                ),
                const Spacer(),
                if (_done) ...[
                  ScaleTransition(
                    scale: _scrollAnim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: _palette.accent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _palette.accent, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          const Text('EMPIEZA', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 2, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: widget.players[_winnerIndex].color,
                                backgroundImage: widget.players[_winnerIndex].avatarBytes != null
                                    ? MemoryImage(widget.players[_winnerIndex].avatarBytes!)
                                    : null,
                                child: widget.players[_winnerIndex].avatarBytes == null
                                    ? Text(widget.players[_winnerIndex].initials,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.players[_winnerIndex].name,
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _proceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _palette.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Empezar partida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _spinning ? null : _startSpin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _spinning ? Colors.white12 : _palette.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _spinning ? 'Girando...' : '🎰  Girar ruleta',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReel(int n, int displayIndex) {
    // Show 3 items: prev, current, next
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slotsVisible, (slot) {
        final offset = slot - 1; // -1, 0, 1
        final idx = ((displayIndex + offset) % n + n) % n;
        final player = widget.players[idx];
        final isCentre = offset == 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: isCentre
              ? BoxDecoration(
                  color: _palette.accent.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _palette.accent, width: 1.5),
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: isCentre ? 22 : 16,
                backgroundColor: player.color,
                backgroundImage: player.avatarBytes != null ? MemoryImage(player.avatarBytes!) : null,
                child: player.avatarBytes == null
                    ? Text(player.initials,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isCentre ? 14 : 11))
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                player.name,
                style: TextStyle(
                  color: isCentre ? Colors.white : Colors.white38,
                  fontSize: isCentre ? 18 : 14,
                  fontWeight: isCentre ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
