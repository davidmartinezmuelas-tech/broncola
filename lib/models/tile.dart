import 'content_pack.dart';
import 'game_mode.dart';

enum TileType { drink, groupDrink, social, rule, chaos, special, wildcard, finale }

enum TileCategory { truth, dare, neverHaveIEver, actOut, whoIsMostLikely, custom }

enum SpecialTileEffect { moveBack3, moveForwardByLastRoll, swapWithPlayer, rollAgain }

class Tile {
  final int id;
  final TileType type;
  final String text;
  final GameMode? mode;
  final TileCategory? category;
  final SpecialTileEffect? specialEffect;
  final bool isCustom;
  final ContentPack pack;

  const Tile({
    required this.id,
    required this.type,
    required this.text,
    this.mode,
    this.category,
    this.specialEffect,
    this.isCustom = false,
    this.pack = ContentPack.base,
  });

  Tile copyWith({
    int? id,
    TileType? type,
    String? text,
    GameMode? mode,
    TileCategory? category,
    SpecialTileEffect? specialEffect,
    bool? isCustom,
    ContentPack? pack,
  }) {
    return Tile(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      mode: mode ?? this.mode,
      category: category ?? this.category,
      specialEffect: specialEffect ?? this.specialEffect,
      isCustom: isCustom ?? this.isCustom,
      pack: pack ?? this.pack,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        'mode': mode?.name,
        'category': category?.name,
        'specialEffect': specialEffect?.name,
        'isCustom': isCustom,
        'pack': pack.name,
      };

  factory Tile.fromJson(Map<String, dynamic> json) {
    GameMode? parseMode() {
      final raw = json['mode'];
      if (raw == null) return null;
      for (final value in GameMode.values) {
        if (value.name == raw) return value;
      }
      return null;
    }

    TileCategory? parseCategory() {
      final raw = json['category'];
      if (raw == null) return null;
      for (final value in TileCategory.values) {
        if (value.name == raw) return value;
      }
      return null;
    }

    SpecialTileEffect? parseEffect() {
      final raw = json['specialEffect'];
      if (raw == null) return null;
      for (final value in SpecialTileEffect.values) {
        if (value.name == raw) return value;
      }
      return null;
    }

    ContentPack parsePack() {
      final raw = json['pack'];
      if (raw == null) return ContentPack.base;
      for (final value in ContentPack.values) {
        if (value.name == raw) return value;
      }
      return ContentPack.base;
    }

    return Tile(
      id: json['id'] as int? ?? 0,
      type: TileType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => TileType.social,
      ),
      text: json['text'] as String? ?? '',
      mode: parseMode(),
      category: parseCategory(),
      specialEffect: parseEffect(),
      isCustom: json['isCustom'] as bool? ?? false,
      pack: parsePack(),
    );
  }
}
