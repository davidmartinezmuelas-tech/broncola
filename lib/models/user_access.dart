import 'content_pack.dart';

class UserAccess {
  final bool hasPremium;
  final Set<ContentPack> unlockedPacks;

  const UserAccess({
    this.hasPremium = false,
    this.unlockedPacks = const {ContentPack.base},
  });

  /// El pack base siempre está disponible.
  /// El resto requiere estar en unlockedPacks.
  bool hasPackUnlocked(ContentPack pack) {
    return pack == ContentPack.base || unlockedPacks.contains(pack);
  }

  UserAccess copyWith({bool? hasPremium, Set<ContentPack>? unlockedPacks}) {
    return UserAccess(
      hasPremium: hasPremium ?? this.hasPremium,
      unlockedPacks: unlockedPacks ?? this.unlockedPacks,
    );
  }
}
