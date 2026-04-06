import 'package:flutter/material.dart';

import '../game_logic/game_controller.dart';
import '../models/game_mode.dart';
import '../models/game_setup.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../services/game_storage.dart';
import '../theme/game_palette.dart';
import '../widgets/active_rules_widget.dart';
import '../widgets/event_modal.dart';
import '../widgets/game_over_modal.dart';
import '../widgets/rule_input_modal.dart';
import 'setup_screen.dart';

class GameScreen extends StatefulWidget {
  final List<Player>? players;
  final GameMode? gameMode;
  final GameSetup? setup;
  final SavedGameData? savedGame;
  final int startingPlayerIndex;

  const GameScreen({
    super.key,
    this.players,
    this.gameMode,
    this.setup,
    this.savedGame,
    this.startingPlayerIndex = 0,
  });

  bool get isRestored => savedGame != null;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  final GameStorage _storage = GameStorage();
  bool _canDraw = true;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    if (widget.savedGame != null) {
      _controller.restore(widget.savedGame!.state);
    } else {
      _controller.initialize(widget.players!, widget.gameMode!, widget.setup!);
      if (widget.startingPlayerIndex > 0 &&
          widget.startingPlayerIndex < widget.players!.length) {
        _controller.state.currentPlayerIndex = widget.startingPlayerIndex;
      }
      _persistState();
    }
  }

  GamePalette get _palette => paletteFor(_controller.state.gameMode);

  Future<void> _persistState() {
    return _storage.saveGame(state: _controller.state);
  }

  Future<void> _onDrawCard() async {
    if (!_canDraw) return;
    setState(() => _canDraw = false);

    final card = _controller.drawCard();

    if (card.type == TileType.rule) {
      _showRuleInput(_controller.state.currentPlayer, card);
      return;
    }

    await _resolveCard(card);
  }

  Future<void> _resolveCard(Tile card) async {
    var result = _controller.resolveCard(card);

    if (result.requiresTargetSelection) {
      final target = await _showSwapPicker();
      if (target != null) {
        result = _controller.resolveCard(card, selectedPlayer: target);
      } else {
        // Cancelled — advance turn normally
        setState(() {
          _controller.nextTurn();
          _canDraw = true;
        });
        await _persistState();
        return;
      }
    }

    if (!mounted) return;

    await EventModal.show(
      context,
      playerName: _controller.state.currentPlayer.name,
      tile: card,
      detail: result.summary,
      isRollAgain: result.shouldDrawAgain,
      onNext: () async {
        if (result.shouldDrawAgain) {
          setState(() => _canDraw = true);
        } else {
          setState(() {
            _controller.nextTurn();
            _canDraw = true;
          });
        }
        await _persistState();
      },
    );
  }

  Future<Player?> _showSwapPicker() async {
    final current = _controller.state.currentPlayer;
    final others = _controller.state.players.where((p) => p != current).toList();
    return showDialog<Player>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _palette.panel,
        title: const Text('¿Con quién intercambias tragos?', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: others
              .map((p) => ListTile(
                    leading: CircleAvatar(backgroundColor: p.color),
                    title: Text(p.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('${p.drinksConsumed} 🍺', style: const TextStyle(color: Colors.white54)),
                    onTap: () => Navigator.of(context).pop(p),
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showRuleInput(Player player, Tile card) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RuleInputModal(
        playerName: player.name,
        playerColor: player.color,
        onSave: (text) async {
          if (text != '(Sin regla)') {
            _controller.addRule(text, player.name);
          }
          setState(() {
            _controller.nextTurn();
            _canDraw = true;
          });
          await _persistState();
        },
      ),
    );
  }

  void _showEndGameConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _palette.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Terminar la partida?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Se mostrará el resumen de la noche.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: TextStyle(color: _palette.accentSoft)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEndGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _palette.accent, foregroundColor: Colors.white),
            child: const Text('Terminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEndGame() async {
    await _storage.clearSavedGame();
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverModal(
        ranking: _controller.rankings(),
        activeRules: _controller.state.activeRules,
        onRestart: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SetupScreen()),
          );
        },
        onHome: () {
          Navigator.of(context).pop();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  void _showDrinksModal() {
    final sorted = List<Player>.from(_controller.state.players)
      ..sort((a, b) => b.drinksConsumed.compareTo(a.drinksConsumed));

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _palette.panel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _palette.accent.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍺', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              const Text('TRAGOS POR JUGADOR',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              ...sorted.asMap().entries.map((entry) {
                final rank = entry.key;
                final player = entry.value;
                final medal = rank == 0 ? '🥇' : rank == 1 ? '🥈' : rank == 2 ? '🥉' : '  ';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: player.color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Text(medal, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: player.color,
                        radius: 16,
                        backgroundImage: player.avatarBytes != null ? MemoryImage(player.avatarBytes!) : null,
                        child: player.avatarBytes == null
                            ? Text(player.initials,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      // Manual adjust buttons
                      _drinkButton(Icons.remove, () {
                        setState(() => _controller.adjustDrinks(player, -1));
                        _persistState();
                        Navigator.of(context).pop();
                        _showDrinksModal();
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('${player.drinksConsumed} 🍺',
                            style: TextStyle(color: player.color, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      _drinkButton(Icons.add, () {
                        setState(() => _controller.adjustDrinks(player, 1));
                        _persistState();
                        Navigator.of(context).pop();
                        _showDrinksModal();
                      }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar', style: TextStyle(color: _palette.accentSoft, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drinkButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final current = state.currentPlayer;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _palette.background,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Broncola', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Text(state.gameMode.label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
            const SizedBox(width: 8),
            Image.asset('assets/images/logo.png', width: 40, height: 40),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showDrinksModal,
            tooltip: 'Tragos',
            icon: const Text('🍺', style: TextStyle(fontSize: 22)),
          ),
          IconButton(
            onPressed: _showEndGameConfirm,
            tooltip: 'Terminar partida',
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.white70),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _palette.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Current player header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _turnHeader(current, state),
              ),

              // Draw area — takes most of the screen
              Expanded(
                child: Center(
                  child: _drawCardArea(current),
                ),
              ),

              // Active rules
              if (state.activeRules.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ActiveRulesWidget(rules: state.activeRules),
                ),

              // Player strip at bottom
              _playerStrip(state),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _turnHeader(Player current, GameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _palette.panel.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _palette.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: current.color,
            backgroundImage: current.avatarBytes != null ? MemoryImage(current.avatarBytes!) : null,
            child: current.avatarBytes == null
                ? Text(current.initials,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(current.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Turno ${state.turnCount + 1}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _palette.accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${current.drinksConsumed} 🍺',
              style: TextStyle(color: _palette.accentSoft, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawCardArea(Player current) {
    return GestureDetector(
      onTap: _canDraw ? _onDrawCard : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _canDraw
                ? [_palette.accent.withOpacity(0.28), _palette.accent.withOpacity(0.08)]
                : [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _canDraw ? _palette.accent : Colors.white24,
            width: _canDraw ? 2 : 1,
          ),
          boxShadow: _canDraw
              ? [BoxShadow(color: _palette.accent.withOpacity(0.25), blurRadius: 24, spreadRadius: 2)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _canDraw ? '🃏' : '⏳',
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 20),
            Text(
              _canDraw ? 'ROBAR CARTA' : 'EN JUEGO...',
              style: TextStyle(
                color: _canDraw ? _palette.accentSoft : Colors.white38,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 2.5,
              ),
            ),
            if (_canDraw) ...[
              const SizedBox(height: 8),
              Text(
                'Toca para robar',
                style: TextStyle(color: _palette.accentSoft.withOpacity(0.55), fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _playerStrip(GameState state) {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: state.players
            .map((p) => _playerChip(p, p == state.currentPlayer))
            .toList(),
      ),
    );
  }

  Widget _playerChip(Player player, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: isActive ? player.color.withOpacity(0.22) : _palette.panel.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? player.color : Colors.white12, width: isActive ? 1.5 : 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: player.color,
                backgroundImage: player.avatarBytes != null ? MemoryImage(player.avatarBytes!) : null,
                child: player.avatarBytes == null
                    ? Text(player.initials,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 7),
              Text(player.name,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _chipDrinkButton(Icons.remove, () {
                setState(() => _controller.adjustDrinks(player, -1));
                _persistState();
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${player.drinksConsumed} 🍺',
                    style: TextStyle(
                        color: isActive ? Colors.white : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              _chipDrinkButton(Icons.add, () {
                setState(() => _controller.adjustDrinks(player, 1));
                _persistState();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipDrinkButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: Colors.white70),
      ),
    );
  }
}
