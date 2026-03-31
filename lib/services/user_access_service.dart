import 'package:shared_preferences/shared_preferences.dart';

import '../models/content_pack.dart';
import '../models/user_access.dart';

/// Singleton que gestiona el acceso del usuario a contenido premium y packs.
/// En el futuro conectará con RevenueCat para validar compras reales.
class UserAccessService {
  static final UserAccessService _instance = UserAccessService._();
  static UserAccessService get instance => _instance;
  UserAccessService._();

  static const _keyPremium = 'user_has_premium';
  static const _keyPacks = 'user_unlocked_packs';

  UserAccess _access = const UserAccess();
  UserAccess get access => _access;

  /// Llama esto al arrancar la app (antes de runApp).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPremium = prefs.getBool(_keyPremium) ?? false;
    final rawPacks = prefs.getStringList(_keyPacks) ?? [];

    final unlockedPacks = <ContentPack>{ContentPack.base};
    for (final raw in rawPacks) {
      for (final pack in ContentPack.values) {
        if (pack.name == raw) unlockedPacks.add(pack);
      }
    }

    _access = UserAccess(hasPremium: hasPremium, unlockedPacks: unlockedPacks);
  }

  /// Activa el acceso premium (llamar desde RevenueCat al confirmar compra).
  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPremium, value);
    _access = _access.copyWith(hasPremium: value);
  }

  /// Desbloquea un pack concreto (llamar desde RevenueCat al confirmar compra).
  Future<void> unlockPack(ContentPack pack) async {
    final newPacks = {..._access.unlockedPacks, pack};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyPacks, newPacks.map((p) => p.name).toList());
    _access = _access.copyWith(unlockedPacks: newPacks);
  }

  /// Solo para desarrollo: simula que el usuario tiene todo desbloqueado.
  Future<void> debugUnlockAll() async {
    await setPremium(true);
    for (final pack in ContentPack.values) {
      await unlockPack(pack);
    }
  }

  /// Resetea el acceso (para pruebas).
  Future<void> debugReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPremium);
    await prefs.remove(_keyPacks);
    _access = const UserAccess();
  }
}
