import 'content_pack.dart';

class GameSetup {
  final List<String> customTileTexts;
  final List<ContentPack> selectedPacks;

  const GameSetup({
    this.customTileTexts = const [],
    this.selectedPacks = const [],
  });

  Map<String, dynamic> toJson() => {
        'customTileTexts': customTileTexts,
        'selectedPacks': selectedPacks.map((p) => p.name).toList(),
      };

  factory GameSetup.fromJson(Map<String, dynamic> json) {
    final rawPacks = json['selectedPacks'] as List<dynamic>? ?? const [];
    final packs = rawPacks
        .map((raw) {
          for (final pack in ContentPack.values) {
            if (pack.name == raw.toString()) return pack;
          }
          return null;
        })
        .whereType<ContentPack>()
        .toList();

    return GameSetup(
      customTileTexts: (json['customTileTexts'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      selectedPacks: packs,
    );
  }
}
