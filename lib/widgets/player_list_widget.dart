import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerListWidget extends StatelessWidget {
  final List<Player> players;
  final int currentIndex;

  const PlayerListWidget(
      {super.key, required this.players, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(players.length, (i) {
        final player = players[i];
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? player.color.withOpacity(0.25)
                : const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? player.color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: player.color,
                radius: 18,
                child: Text(player.initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${player.drinksConsumed} 🍺',
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: player.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('TURNO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      }),
    );
  }
}
