import 'active_rule.dart';
import 'game_log_entry.dart';
import 'game_mode.dart';
import 'game_setup.dart';
import 'player.dart';
import 'tile.dart';

class GameState {
  final List<Player> players;
  final GameMode gameMode;
  final GameSetup setup;
  int currentPlayerIndex;
  int turnCount;
  final List<ActiveRule> activeRules;
  final List<GameLogEntry> logEntries;
  List<Tile> deck;

  static const int maxRules = 4;

  GameState({
    required this.players,
    required this.gameMode,
    required this.setup,
    this.currentPlayerIndex = 0,
    this.turnCount = 0,
    List<ActiveRule>? activeRules,
    List<GameLogEntry>? logEntries,
    List<Tile>? deck,
  })  : activeRules = activeRules ?? [],
        logEntries = logEntries ?? [],
        deck = deck ?? [];

  Player get currentPlayer => players[currentPlayerIndex];

  void advanceTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    turnCount++;
  }

  void addRule(ActiveRule rule) {
    if (activeRules.length >= maxRules) {
      activeRules.removeAt(0);
    }
    activeRules.add(rule);
  }

  void addLog(GameLogEntry entry) {
    logEntries.insert(0, entry);
    if (logEntries.length > 40) {
      logEntries.removeLast();
    }
  }
}
