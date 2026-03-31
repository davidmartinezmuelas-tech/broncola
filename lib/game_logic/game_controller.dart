import 'dart:math';

import '../models/active_rule.dart';
import '../models/game_log_entry.dart';
import '../models/game_mode.dart';
import '../models/game_setup.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import 'board_builder.dart';

class TileActionResult {
  final String summary;
  final int movementDelta;
  final bool requiresTargetSelection;
  final bool shouldRollAgain;

  const TileActionResult({
    required this.summary,
    this.movementDelta = 0,
    this.requiresTargetSelection = false,
    this.shouldRollAgain = false,
  });
}

class GameController {
  late GameState state;
  late List<Tile> _tiles;
  final Random _random = Random();

  void initialize(List<Player> players, GameMode mode, GameSetup setup) {
    _tiles = BoardBuilder.build(
      mode,
      boardLength: setup.boardLength,
      customTileTexts: setup.customTileTexts,
      selectedPacks: setup.selectedPacks,
    );
    state = GameState(players: players, gameMode: mode, setup: setup);
    state.addLog(
      GameLogEntry(
        title: 'Partida creada',
        detail: '${players.length} jugadores en modo ${mode.label} con ${setup.boardLength} casillas.',
        createdAt: DateTime.now(),
      ),
    );
  }

  void restore(GameState restoredState, List<Tile> restoredTiles) {
    state = restoredState;
    _tiles = restoredTiles;
  }

  int get totalTiles => _tiles.length;
  List<Tile> get tiles => _tiles;
  Tile get currentTile => _tiles[state.currentPlayer.position];
  Tile tileAt(int index) => _tiles[index.clamp(0, totalTiles - 1)];

  int? rollDice() {
    if (state.waitingForNextTurn || state.isGameOver) return null;
    final roll = _random.nextInt(6) + 1;
    state.lastDiceRoll = roll;
    state.waitingForNextTurn = true;
    return roll;
  }

  List<int> movementPathForRoll(int steps) {
    final player = state.currentPlayer;
    final finaleIndex = totalTiles - 1;
    final path = <int>[];
    for (int i = 1; i <= steps; i++) {
      final next = (player.position + i).clamp(0, finaleIndex);
      path.add(next);
      if (next == finaleIndex) break;
    }
    return path;
  }

  List<int> movementPathFromCurrent(int delta) {
    final player = state.currentPlayer;
    final finaleIndex = totalTiles - 1;
    if (delta == 0) return const [];

    final steps = delta.abs();
    final direction = delta.isNegative ? -1 : 1;
    final path = <int>[];
    var current = player.position;
    for (int i = 0; i < steps; i++) {
      current = (current + direction).clamp(0, finaleIndex);
      path.add(current);
      if (current == 0 || current == finaleIndex) break;
    }
    return path;
  }

  void setCurrentPlayerPosition(int position) {
    state.currentPlayer.position = position.clamp(0, totalTiles - 1);
    if (state.currentPlayer.position >= totalTiles - 1) {
      state.isGameOver = true;
    }
  }

  TileActionResult resolveCurrentTile({Player? selectedPlayer}) {
    final player = state.currentPlayer;
    final tile = currentTile;

    if (tile.type == TileType.finale) {
      state.isGameOver = true;
      final summary = '${player.name} llegó a la meta.';
      logEvent('Final', summary);
      return TileActionResult(summary: summary);
    }

    // Same-tile penalty: other players already on this tile drink 2 extra
    String penaltyNote = '';
    if (tile.type != TileType.finale) {
      final cohabitants = state.players.where((p) => p != player && p.position == player.position).toList();
      if (cohabitants.isNotEmpty) {
        for (final other in cohabitants) {
          other.drinksConsumed = max(0, other.drinksConsumed + 2);
        }
        final names = cohabitants.map((p) => p.name).join(', ');
        penaltyNote = '\n$names bebe${cohabitants.length > 1 ? 'n' : ''} 2 tragos extra por compartir casilla.';
        logEvent('Penalización', penaltyNote.trim());
      }
    }

    if (tile.type == TileType.wildcard) {
      final summary = '${player.name} cayó en un comodín.$penaltyNote';
      logEvent('Comodín', summary);
      return TileActionResult(summary: summary);
    }

    if (tile.type != TileType.special) {
      final summary = '${player.name} cayó en la casilla ${player.position + 1}. ${tile.text}$penaltyNote';
      logEvent('Turno de ${player.name}', summary);
      return TileActionResult(summary: summary);
    }

    switch (tile.specialEffect) {
      case SpecialTileEffect.rollAgain:
        final summary = '${player.name} vuelve a tirar el dado.$penaltyNote';
        logEvent('Casilla especial', summary);
        return TileActionResult(summary: summary, shouldRollAgain: true);
      case SpecialTileEffect.moveBack3:
        final summary = '${player.name} activa una casilla especial y retrocede 3 casillas.$penaltyNote';
        logEvent('Casilla especial', summary);
        return TileActionResult(summary: 'Retrocede 3 casillas.$penaltyNote', movementDelta: -3);
      case SpecialTileEffect.moveForwardByLastRoll:
        final extra = state.lastDiceRoll ?? 0;
        final summary = '${player.name} duplica el movimiento y avanza $extra casillas extra.$penaltyNote';
        logEvent('Casilla especial', summary);
        return TileActionResult(summary: summary, movementDelta: extra);
      case SpecialTileEffect.swapWithPlayer:
        if (selectedPlayer == null) {
          return const TileActionResult(
            summary: 'Elige con quién intercambiar posición.',
            requiresTargetSelection: true,
          );
        }
        final oldPosition = player.position;
        player.position = selectedPlayer.position;
        selectedPlayer.position = oldPosition;
        final summary = '${player.name} intercambia posición con ${selectedPlayer.name}.$penaltyNote';
        logEvent('Casilla especial', summary);
        return TileActionResult(summary: summary);
      case null:
        final summary = '${player.name} cayó en una casilla especial.$penaltyNote';
        logEvent('Casilla especial', summary);
        return TileActionResult(summary: summary);
    }
  }

  /// Resets state so the current player can roll again (used for rollAgain tiles).
  void resetForReroll() {
    state.waitingForNextTurn = false;
  }

  void addRule(String text, String playerName) {
    state.addRule(ActiveRule(text: text, createdBy: playerName));
    logEvent('Regla nueva', '$playerName añadió la regla: $text');
  }

  void adjustDrinks(Player player, int delta) {
    player.drinksConsumed = max(0, player.drinksConsumed + delta);
  }

  void logEvent(String title, String detail) {
    state.addLog(GameLogEntry(title: title, detail: detail, createdAt: DateTime.now()));
  }

  List<Player> rankings() {
    final ranked = List<Player>.from(state.players);
    ranked.sort((a, b) {
      final positionCompare = b.position.compareTo(a.position);
      if (positionCompare != 0) return positionCompare;
      return a.drinksConsumed.compareTo(b.drinksConsumed);
    });
    return ranked;
  }

  void nextTurn() {
    state.advanceTurn();
  }
}
