import 'package:flutter/material.dart';

import '../models/active_rule.dart';
import '../models/player.dart';

class GameOverModal extends StatefulWidget {
  final List<Player> ranking;
  final List<ActiveRule> activeRules;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameOverModal({
    super.key,
    required this.ranking,
    required this.activeRules,
    required this.onRestart,
    required this.onHome,
  });

  @override
  State<GameOverModal> createState() => _GameOverModalState();
}

class _GameOverModalState extends State<GameOverModal> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late List<AnimationController> _rowControllers;
  late Animation<double> _headerScale;

  static const List<String> _medals = ['🥇', '🥈', '🥉'];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerScale = CurvedAnimation(parent: _headerController, curve: Curves.elasticOut);
    _rowControllers = List.generate(
      widget.ranking.length,
      (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 420)),
    );
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    _headerController.forward();
    for (var i = 0; i < _rowControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      _rowControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    for (final c in _rowControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topDrinker = widget.ranking.isNotEmpty ? widget.ranking.first : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(18),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0B36), Color(0xFF47206C), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaleTransition(
                scale: _headerScale,
                child: Column(
                  children: [
                    const Center(child: Text('🌙', style: TextStyle(fontSize: 60))),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'FIN DE LA NOCHE',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (topDrinker != null)
                      Center(
                        child: Text(
                          '${topDrinker.name} se lleva el premio a la resistencia 🏆',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Tabla de tragos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 10),
              ...widget.ranking.asMap().entries.map((entry) {
                final rank = entry.key;
                final player = entry.value;
                final medal = rank < _medals.length ? _medals[rank] : '  ${rank + 1}.';
                final controller = _rowControllers[rank];
                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(-0.6, 0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic)),
                  child: FadeTransition(
                    opacity: controller,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: rank == 0 ? Colors.white.withOpacity(0.12) : Colors.black26,
                        borderRadius: BorderRadius.circular(14),
                        border: rank == 0
                            ? Border.all(color: const Color(0xFFFFD700).withOpacity(0.6), width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(medal, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: player.color,
                            backgroundImage: player.avatarBytes != null ? MemoryImage(player.avatarBytes!) : null,
                            child: player.avatarBytes == null
                                ? Text(player.initials,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: rank == 0 ? FontWeight.w900 : FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: player.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: player.color.withOpacity(0.6)),
                            ),
                            child: Text(
                              '${player.drinksConsumed} 🍺',
                              style: TextStyle(color: player.color, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (widget.activeRules.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Reglas activas al cierre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 10),
                ...widget.activeRules.map(
                  (rule) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(' ${rule.text} (por ${rule.createdBy})', style: const TextStyle(color: Colors.white70)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5E35B1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Nueva partida', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: widget.onHome,
                  child: const Text('Volver al inicio', style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
