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
  const SavedGameData({required this.state});
}

class GameStorage {
  static const _savedGameKey = 'broncola_saved_game';
  static const _statsKey = 'broncola_stats';
  static const _rosterKey = 'broncola_player_roster';

  Future<void> saveGame({required GameState state}) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'players': state.players.map(_playerToJson).toList(),
      'gameMode': state.gameMode.name,
      'setup': state.setup.toJson(),
      'currentPlayerIndex': state.currentPlayerIndex,
      'turnCount': state.turnCount,
      'activeRules': state.activeRules.map((r) => r.toJson()).toList(),
      'logEntries': state.logEntries.map((e) => e.toJson()).toList(),
      'deck': state.deck.map((t) => t.toJson()).toList(),
    });
    await prefs.setString(_savedGameKey, payload);
  }

  Future<SavedGameData?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedGameKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;

      final players = (json['players'] as List<dynamic>? ?? [])
          .map((item) => _playerFromJson(item as Map<String, dynamic>))
          .toList();
      final activeRules = (json['activeRules'] as List<dynamic>? ?? [])
          .map((item) => ActiveRule.fromJson(item as Map<String, dynamic>))
          .toList();
      final logEntries = (json['logEntries'] as List<dynamic>? ?? [])
          .map((item) => GameLogEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      final deck = (json['deck'] as List<dynamic>? ?? [])
          .map((item) => Tile.fromJson(item as Map<String, dynamic>))
          .toList();

      final modeName = json['gameMode'] as String? ?? GameMode.light.name;
      final mode = GameMode.values.firstWhere(
        (v) => v.name == modeName,
        orElse: () => GameMode.light,
      );

      return SavedGameData(
        state: GameState(
          players: players,
          gameMode: mode,
          setup: GameSetup.fromJson(json['setup'] as Map<String, dynamic>? ?? {}),
          currentPlayerIndex: json['currentPlayerIndex'] as int? ?? 0,
          turnCount: json['turnCount'] as int? ?? 0,
          activeRules: activeRules,
          logEntries: logEntries,
          deck: deck,
        ),
      );
    } catch (_) {
      // Incompatible save format — clear it
      await clearSavedGame();
      return null;
    }
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
    final current = prefs.getStringList(_statsKey) ?? [];
    final updated = [jsonEncode(summary.toJson()), ...current].take(12).toList();
    await prefs.setStringList(_statsKey, updated);
  }

  Future<List<GameSummary>> loadCompletedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_statsKey) ?? [];
    return current
        .map((item) => GameSummary.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  // ── Player roster ──────────────────────────────────────────────────────────

  Future<List<Player>> loadRoster() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_rosterKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => _playerFromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRoster(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rosterKey, jsonEncode(players.map(_playerToJson).toList()));
  }

  Future<void> upsertPlayerInRoster(Player player) async {
    final roster = await loadRoster();
    final idx = roster.indexWhere((p) => p.name.toLowerCase() == player.name.toLowerCase());
    if (idx >= 0) {
      roster[idx] = player;
    } else {
      roster.add(player);
    }
    await _saveRoster(roster);
  }

  Future<void> removePlayerFromRoster(String name) async {
    final roster = await loadRoster();
    roster.removeWhere((p) => p.name.toLowerCase() == name.toLowerCase());
    await _saveRoster(roster);
  }

  // ───────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> _playerToJson(Player player) => {
        'name': player.name,
        'color': player.color.toARGB32(),
        'drinksConsumed': player.drinksConsumed,
        'avatarBytes': player.avatarBytes == null ? null : base64Encode(player.avatarBytes!),
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
      drinksConsumed: json['drinksConsumed'] as int? ?? 0,
      avatarBytes: avatarBytes,
    );
  }
}
