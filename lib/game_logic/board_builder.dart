import 'dart:math';

import '../models/content_pack.dart';
import '../models/game_mode.dart';
import '../models/game_setup.dart';
import '../models/tile.dart';
import '../services/user_access_service.dart';
import 'tile_catalog.dart';

class BoardBuilder {
  static List<Tile> build(
    GameMode mode, {
    required int boardLength,
    List<String> customTileTexts = const [],
    List<ContentPack> selectedPacks = const [],
  }) {
    final rng = Random();
    final customTiles = _customTiles(customTileTexts);
    final targetWithoutFinal = boardLength - 1;

    // Tiles de los packs seleccionados (garantizados en el tablero)
    final packTiles = _packTilesFor(mode, selectedPacks)..shuffle(rng);

    // Si los pack tiles superan el tablero, tomamos un subconjunto aleatorio
    final packSlots = packTiles.length.clamp(0, targetWithoutFinal - customTiles.length);
    final guaranteedPackTiles = packTiles.take(packSlots).toList();

    // Casillas base para rellenar el resto
    final basePool = _basePoolFor(mode);
    final baseCount = (targetWithoutFinal - customTiles.length - packSlots).clamp(0, targetWithoutFinal);
    final shuffledBase = List<Tile>.from(basePool)..shuffle(rng);
    final base = <Tile>[];
    while (base.length < baseCount) {
      base.addAll(List<Tile>.from(shuffledBase)..shuffle(rng));
    }
    final baseBoard = base.take(baseCount).toList();

    // Mezclar packs y base juntos
    final board = [...guaranteedPackTiles, ...baseBoard]..shuffle(rng);

    // Insertar casillas personalizadas en posiciones aleatorias
    for (final tile in customTiles) {
      final pos = rng.nextInt(board.length + 1);
      board.insert(pos, tile);
    }

    return [
      for (int i = 0; i < board.length; i++)
        Tile(
          id: i,
          type: board[i].type,
          text: board[i].text,
          mode: board[i].mode,
          category: board[i].category,
          specialEffect: board[i].specialEffect,
          isCustom: board[i].isCustom,
          pack: board[i].pack,
        ),
      Tile(
        id: targetWithoutFinal,
        type: TileCatalog.finale.type,
        text: TileCatalog.finale.text,
      ),
    ];
  }

  /// Tiles del catálogo base (ContentPack.base) según el modo de juego.
  static List<Tile> _basePoolFor(GameMode mode) {
    final access = UserAccessService.instance.access;
    List<Tile> all;
    switch (mode) {
      case GameMode.light:
        all = [...TileCatalog.universal, ...TileCatalog.light];
        break;
      case GameMode.spicy:
        all = [...TileCatalog.universal, ...TileCatalog.light, ...TileCatalog.spicy];
        break;
      case GameMode.wild:
        all = [...TileCatalog.universal, ...TileCatalog.spicy, ...TileCatalog.wild];
        break;
    }
    return all.where((tile) => tile.pack == ContentPack.base && access.hasPackUnlocked(tile.pack)).toList();
  }

  /// Tiles de los packs seleccionados, filtrados por modo de juego.
  static List<Tile> _packTilesFor(GameMode mode, List<ContentPack> selectedPacks) {
    if (selectedPacks.isEmpty) return [];
    final access = UserAccessService.instance.access;

    // Todos los tiles de packs extra disponibles en el catálogo
    final allPackTiles = [
      ...TileCatalog.exToxico,
      ...TileCatalog.amigos,
      // Añadir aquí los tiles de futuros packs
    ];

    return allPackTiles.where((tile) {
      // El pack debe estar seleccionado y desbloqueado
      if (!selectedPacks.contains(tile.pack)) return false;
      if (!access.hasPackUnlocked(tile.pack)) return false;
      // Filtrar por modo: wild incluye todo, spicy excluye wild, light solo light
      switch (mode) {
        case GameMode.light:
          return tile.mode == GameMode.light || tile.mode == null;
        case GameMode.spicy:
          return tile.mode == GameMode.spicy || tile.mode == GameMode.light || tile.mode == null;
        case GameMode.wild:
          return true;
      }
    }).toList();
  }

  static List<Tile> _customTiles(List<String> texts) {
    final cleaned = texts.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    return [
      for (int i = 0; i < cleaned.length; i++)
        Tile(
          id: 800 + i,
          type: TileType.social,
          text: cleaned[i],
          category: TileCategory.custom,
          isCustom: true,
        ),
    ];
  }
}
