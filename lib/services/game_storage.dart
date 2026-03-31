import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/active_rule.dart';
import '../models/game_log_entry.dart';
import '../models/game_mode.dart';
import '../models/game_setup.dart';
import '../models/game_state.dart';
import '../models/game_summary.dart';
import '../models/player.dart';
import '../models/tile.dart';

class SavedGameData {
  final GameState state;
  final List<Tile> tiles;

  const SavedGameData({required this.state, required this.tiles});
}

class GameStorage {
  static const _savedGameKey = 'broncola_saved_game';
  static const _statsKey = 'broncola_stats';

  Future<void> saveGame({
    required GameState state,
    required List<Tile> tiles,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'state': {
        'players': state.players.map(_playerToJson).toList(),
        'gameMode': state.gameMode.name,
        'setup': state.setup.toJson(),
        'currentPlayerIndex': state.currentPlayerIndex,
        'lastDiceRoll': state.lastDiceRoll,
        'waitingForNextTurn': state.waitingForNextTurn,
        'isGameOver': state.isGameOver,
        'turnCount': state.turnCount,
        'activeRules': state.activeRules.map((rule) => rule.toJson()).toList(),
        'logEntries': state.logEntries.map((entry) => entry.toJson()).toList(),
      },
      'tiles': tiles.map((tile) => tile.toJson()).toList(),
    });
    await prefs.setString(_savedGameKey, payload);
  }

  Future<SavedGameData?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedGameKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final stateJson = decoded['state'] as Map<String, dynamic>;
    final tilesJson = decoded['tiles'] as List<dynamic>? ?? const [];

    final players = (stateJson['players'] as List<dynamic>? ?? const [])
        .map((item) => _playerFromJson(item as Map<String, dynamic>))
        .toList();
    final activeRules = (stateJson['activeRules'] as List<dynamic>? ?? const [])
        .map((item) => ActiveRule.fromJson(item as Map<String, dynamic>))
        .toList();
    final logEntries = (stateJson['logEntries'] as List<dynamic>? ?? const [])
        .map((item) => GameLogEntry.fromJson(item as Map<String, dynamic>))
        .toList();
    final tiles = tilesJson
        .map((item) => Tile.fromJson(item as Map<String, dynamic>))
        .toList();

    final modeName = stateJson['gameMode'] as String? ?? GameMode.light.name;
    final mode = GameMode.values.firstWhere(
      (value) => value.name == modeName,
      orElse: () => GameMode.light,
    );

    return SavedGameData(
      state: GameState(
        players: players,
        gameMode: mode,
        setup: GameSetup.fromJson(
            stateJson['setup'] as Map<String, dynamic>? ?? const {}),
        currentPlayerIndex: stateJson['currentPlayerIndex'] as int? ?? 0,
        lastDiceRoll: stateJson['lastDiceRoll'] as int?,
        waitingForNextTurn: stateJson['waitingForNextTurn'] as bool? ?? false,
        isGameOver: stateJson['isGameOver'] as bool? ?? false,
        turnCount: stateJson['turnCount'] as int? ?? 0,
        activeRules: activeRules,
        logEntries: logEntries,
      ),
      tiles: tiles,
    );
  }

  Future<bool> hasSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_savedGameKey);
  }

  Future<void> clearSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedGameKey);
  }

  Future<void> addCompletedGame(GameSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_statsKey) ?? <String>[];
    final updated = [
      jsonEncode(summary.toJson()),
      ...current,
    ].take(12).toList();
    await prefs.setStringList(_statsKey, updated);
  }

  Future<List<GameSummary>> loadCompletedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_statsKey) ?? <String>[];
    return current
        .map((item) =>
            GameSummary.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> _playerToJson(Player player) => {
        'name': player.name,
        'color': player.color.toARGB32(),
        'position': player.position,
        'drinksConsumed': player.drinksConsumed,
        'avatarBytes': player.avatarBytes == null
            ? null
            : base64Encode(player.avatarBytes!),
      };

  Player _playerFromJson(Map<String, dynamic> json) {
    final avatarRaw = json['avatarBytes'];
    Uint8List? avatarBytes;
    if (avatarRaw is String && avatarRaw.isNotEmpty) {
      avatarBytes = base64Decode(avatarRaw);
    }

    return Player(
      name: json['name'] as String? ?? '',
      color: Color(json['color'] as int? ?? 0xFFFFFFFF),
      position: json['position'] as int? ?? 0,
      drinksConsumed: json['drinksConsumed'] as int? ?? 0,
      avatarBytes: avatarBytes,
    );
  }
}
