import 'dart:math';

import '../models/active_rule.dart';
import '../models/game_log_entry.dart';
import '../models/game_mode.dart';
import '../models/game_setup.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import 'deck_builder.dart';

class TileActionResult {
  final String summary;
  final bool requiresTargetSelection;
  final bool shouldDrawAgain;

  const TileActionResult({
    required this.summary,
    this.requiresTargetSelection = false,
    this.shouldDrawAgain = false,
  });
}

class GameController {
  late GameState state;

  void initialize(List<Player> players, GameMode mode, GameSetup setup) {
    final deck = DeckBuilder.buildDeck(mode, setup.selectedPacks, setup.customTileTexts);
    state = GameState(
      players: players,
      gameMode: mode,
      setup: setup,
      deck: deck,
    );
    state.addLog(GameLogEntry(
      title: 'Partida creada',
      detail: '${players.length} jugadores en modo ${mode.label}.',
      createdAt: DateTime.now(),
    ));
  }

  void restore(GameState restoredState) {
    state = restoredState;
  }

  /// Draws the next card from the deck. Reshuffles when empty.
  Tile drawCard() {
    if (state.deck.isEmpty) {
      state.deck = DeckBuilder.buildDeck(
        state.gameMode,
        state.setup.selectedPacks,
        state.setup.customTileTexts,
      );
    }
    return state.deck.removeLast();
  }

  /// Resolves the effects of a drawn card.
  TileActionResult resolveCard(Tile card, {Player? selectedPlayer}) {
    final player = state.currentPlayer;

    if (card.type == TileType.special) {
      switch (card.specialEffect) {
        case SpecialTileEffect.rollAgain:
          logEvent('Carta extra', '${player.name} roba otra carta.');
          return const TileActionResult(summary: '', shouldDrawAgain: true);

        case SpecialTileEffect.swapWithPlayer:
          if (selectedPlayer == null) {
            return const TileActionResult(
              summary: '',
              requiresTargetSelection: true,
            );
          }
          final myDrinks = player.drinksConsumed;
          player.drinksConsumed = selectedPlayer.drinksConsumed;
          selectedPlayer.drinksConsumed = myDrinks;
          logEvent('Intercambio', '${player.name} intercambió tragos con ${selectedPlayer.name}.');
          return TileActionResult(
            summary: 'Intercambiaste con ${selectedPlayer.name}: tú ahora tienes ${player.drinksConsumed} 🍺',
          );

        default:
          return const TileActionResult(summary: '');
      }
    }

    logEvent('Turno de ${player.name}', card.text);
    return const TileActionResult(summary: '');
  }

  void nextTurn() => state.advanceTurn();

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

  /// Returns players sorted by most drinks consumed.
  List<Player> rankings() {
    final ranked = List<Player>.from(state.players);
    ranked.sort((a, b) => b.drinksConsumed.compareTo(a.drinksConsumed));
    return ranked;
  }
}
