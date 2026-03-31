import 'package:flutter/material.dart';

import '../game_logic/game_controller.dart';
import '../models/game_mode.dart';
import '../models/game_setup.dart';
import '../models/game_state.dart';
import '../models/game_summary.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../services/game_storage.dart';
import '../theme/game_palette.dart';
import '../widgets/active_rules_widget.dart';
import '../widgets/board_widget.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/dice_widget.dart';
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
  bool _processingTurn = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    if (widget.savedGame != null) {
      _controller.restore(widget.savedGame!.state, widget.savedGame!.tiles);
    } else {
      _controller.initialize(widget.players!, widget.gameMode!, widget.setup!);
      // Set starting player from spinner result
      if (widget.startingPlayerIndex > 0 && widget.startingPlayerIndex < widget.players!.length) {
        _controller.state.currentPlayerIndex = widget.startingPlayerIndex;
      }
      _persistState();
    }
  }

  GamePalette get _palette => paletteFor(_controller.state.gameMode);

  Future<void> _persistState() {
    return _storage.saveGame(state: _controller.state, tiles: _controller.tiles);
  }

  Future<void> _animatePath(List<int> path) async {
    for (final position in path) {
      if (!mounted) return;
      setState(() => _controller.setCurrentPlayerPosition(position));
      await _persistState();
      await Future.delayed(const Duration(milliseconds: 180));
    }
  }

  Future<void> _onRoll() async {
    if (_processingTurn) return;
    final roll = _controller.rollDice();
    if (roll == null) return;

    _processingTurn = true;
    final player = _controller.state.currentPlayer;
    final path = _controller.movementPathForRoll(roll);
    await _animatePath(path);

    if (!mounted) return;
    if (_controller.state.isGameOver) {
      await _showGameOver(player);
      _processingTurn = false;
      return;
    }

    if (_controller.currentTile.type == TileType.rule) {
      _showRuleInput(player);
      _processingTurn = false;
      return;
    }

    await _handleTileResolution();
    _processingTurn = false;
  }

  Future<void> _handleTileResolution() async {
    var result = _controller.resolveCurrentTile();

    if (result.requiresTargetSelection) {
      final target = await _showSwapPicker();
      if (target != null) {
        setState(() {
          result = _controller.resolveCurrentTile(selectedPlayer: target);
        });
        await _persistState();
      }
    }

    if (result.movementDelta != 0) {
      final extraPath = _controller.movementPathFromCurrent(result.movementDelta);
      await _animatePath(extraPath);
      if (_controller.state.isGameOver) {
        await _showGameOver(_controller.state.currentPlayer);
        return;
      }
    }

    if (!mounted) return;
    await _persistState();

    if (result.shouldRollAgain) {
      // Show modal first, then allow the same player to roll again
      await EventModal.show(
        context,
        playerName: _controller.state.currentPlayer.name,
        tile: _controller.currentTile,
        detail: result.summary,
        isRollAgain: true,
        onNext: () {
          setState(() => _controller.resetForReroll());
          _persistState();
        },
      );
      return;
    }

    await EventModal.show(
      context,
      playerName: _controller.state.currentPlayer.name,
      tile: _controller.currentTile,
      detail: result.summary,
      onNext: () {
        setState(() => _controller.nextTurn());
        _persistState();
      },
    );
  }

  Future<Player?> _showSwapPicker() async {
    final current = _controller.state.currentPlayer;
    final others = _controller.state.players.where((player) => player != current).toList();
    return showDialog<Player>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _palette.panel,
        title: const Text('Intercambiar posición', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: others
              .map(
                (player) => ListTile(
                  leading: CircleAvatar(backgroundColor: player.color),
                  title: Text(player.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('Casilla ${player.position + 1}', style: const TextStyle(color: Colors.white54)),
                  onTap: () => Navigator.of(context).pop(player),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showRuleInput(Player player) {
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
          setState(() => _controller.nextTurn());
          await _persistState();
        },
      ),
    );
  }

  Future<void> _showGameOver(Player winner) async {
    setState(() => _showConfetti = true);
    await _storage.addCompletedGame(
      GameSummary(
        winnerName: winner.name,
        turnCount: _controller.state.turnCount,
        boardLength: _controller.state.setup.boardLength,
        modeLabel: _controller.state.gameMode.label,
        totalDrinks: _controller.state.players.fold(0, (sum, player) => sum + player.drinksConsumed),
        finishedAt: DateTime.now(),
      ),
    );
    await _storage.clearSavedGame();

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverModal(
        playerName: winner.name,
        activeRules: _controller.state.activeRules,
        ranking: _controller.rankings(),
        highlights: _controller.state.logEntries.take(3).toList(),
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

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final current = state.currentPlayer;

    return Stack(
      children: [
        _buildScaffold(state, current),
        if (_showConfetti) ConfettiOverlay(active: _showConfetti),
      ],
    );
  }

  Widget _buildScaffold(GameState state, Player current) {
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
                Text(
                  '${state.gameMode.label} · ${state.setup.boardLength} casillas',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Image.asset('assets/images/logo.png', width: 44, height: 44),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showDrinksModal,
            tooltip: 'Tragos',
            icon: const Text('🍺', style: TextStyle(fontSize: 22)),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _turnHeader(current),
              ),
              SizedBox(
                height: 330,
                child: BoardWidget(
                  tiles: _controller.tiles,
                  players: state.players,
                  focusedPosition: current.position,
                  accentColor: _palette.accent,
                ),
              ),
              if (state.activeRules.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ActiveRulesWidget(rules: state.activeRules),
                ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                        children: [
                          ...state.players.map((player) => _playerRow(player, player == current)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 132,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DiceWidget(
                              value: state.lastDiceRoll,
                              canRoll: !state.waitingForNextTurn,
                              onRoll: _onRoll,
                              glowColor: _palette.accent,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'D6 fijo',
                              style: TextStyle(color: _palette.accentSoft, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _turnHeader(Player current) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _palette.panel.withOpacity(0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _palette.accent.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: current.color,
            backgroundImage: current.avatarBytes != null ? MemoryImage(current.avatarBytes!) : null,
            child: current.avatarBytes == null
                ? Text(current.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(current.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Turno ${_controller.state.turnCount + 1} · Casilla ${current.position + 1}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _palette.accent.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('En juego', style: TextStyle(color: _palette.accentSoft, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _playerRow(Player player, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? player.color.withOpacity(0.22) : _palette.panel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isActive ? player.color : Colors.white10, width: 1.4),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: player.color,
            backgroundImage: player.avatarBytes != null ? MemoryImage(player.avatarBytes!) : null,
            child: player.avatarBytes == null
                ? Text(player.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Casilla ${player.position + 1} · ${player.drinksConsumed} tragos', style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          _drinkButton(Icons.remove, () async {
            setState(() => _controller.adjustDrinks(player, -1));
            await _persistState();
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('${player.drinksConsumed}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          _drinkButton(Icons.add, () async {
            setState(() => _controller.adjustDrinks(player, 1));
            await _persistState();
          }),
        ],
      ),
    );
  }

  Widget _drinkButton(IconData icon, Future<void> Function() onTap) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: Colors.white70),
      ),
    );
  }

  void _showDrinksModal() {
    final players = _controller.state.players;
    final sorted = List<Player>.from(players)
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
              const Text(
                'TRAGOS POR JUGADOR',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
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
                            ? Text(player.initials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: player.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: player.color),
                        ),
                        child: Text(
                          '${player.drinksConsumed} 🍺',
                          style: TextStyle(color: player.color, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
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
}
