import 'dart:math';

import '../models/content_pack.dart';
import '../models/game_mode.dart';
import '../models/tile.dart';
import '../services/user_access_service.dart';
import 'tile_catalog.dart';

class DeckBuilder {
  /// Builds a shuffled deck of all eligible tiles for the given mode and packs.
  /// Custom tile texts are inserted as special tiles.
  static List<Tile> buildDeck(
    GameMode mode,
    List<ContentPack> selectedPacks,
    List<String> customTileTexts,
  ) {
    final rng = Random();
    final base = _basePoolFor(mode);
    final packs = _packTilesFor(mode, selectedPacks);
    final custom = _customTiles(customTileTexts);

    final all = [...base, ...packs, ...custom]..shuffle(rng);
    return all;
  }

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
    return all
        .where((tile) =>
            tile.pack == ContentPack.base &&
            access.hasPackUnlocked(tile.pack) &&
            tile.type != TileType.finale)
        .toList();
  }

  static List<Tile> _packTilesFor(GameMode mode, List<ContentPack> selectedPacks) {
    if (selectedPacks.isEmpty) return [];
    final access = UserAccessService.instance.access;

    final allPackTiles = [
      ...TileCatalog.exToxico,
      ...TileCatalog.amigos,
    ];

    return allPackTiles.where((tile) {
      if (!selectedPacks.contains(tile.pack)) return false;
      if (!access.hasPackUnlocked(tile.pack)) return false;
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
