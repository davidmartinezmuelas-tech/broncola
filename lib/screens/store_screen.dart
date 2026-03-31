import 'package:flutter/material.dart';

import '../models/content_pack.dart';
import '../services/user_access_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  bool get _hasPremium => UserAccessService.instance.access.hasPremium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF08141A), Color(0xFF1E102E), Color(0xFF1A0C0D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Tienda',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Amplía Broncola con más contenido y funciones.',
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Premium (casillas personalizadas)
                    _PremiumCard(
                      hasPremium: _hasPremium,
                      onBuy: _onBuyPremium,
                    ),
                    const SizedBox(height: 16),

                    // Packs de contenido
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'PACKS DE CONTENIDO',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                      ),
                    ),
                    ...ContentPack.values
                        .where((pack) => !pack.isFree && !pack.isPrivate &&
                            (!pack.isPrivate || const bool.fromEnvironment('PRIVATE_PACK')))
                        .map((pack) => _PackCard(
                              pack: pack,
                              isUnlocked: UserAccessService.instance.access.hasPackUnlocked(pack),
                              onBuy: () => _onBuyPack(pack),
                            )),
                    if (ContentPack.values.every((p) => p.isFree))
                      _ComingSoonCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onBuyPremium() async {
    // TODO: integrar RevenueCat aquí
    // Ejemplo: await Purchases.purchaseProduct('broncola_premium');
    // Por ahora mostramos un placeholder
    _showComingSoon();
  }

  Future<void> _onBuyPack(ContentPack pack) async {
    // TODO: integrar RevenueCat aquí
    // Ejemplo: await Purchases.purchaseProduct(pack.name);
    _showComingSoon();
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E102E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Próximamente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Las compras se activarán en la próxima versión de la app. ¡Quédate atento!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido', style: TextStyle(color: Color(0xFFFF7A45))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PremiumCard extends StatelessWidget {
  final bool hasPremium;
  final VoidCallback onBuy;

  const _PremiumCard({required this.hasPremium, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasPremium
              ? [const Color(0xFF1B3A2A), const Color(0xFF2E6B45)]
              : [const Color(0xFF2A1A00), const Color(0xFF5C3800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPremium ? const Color(0xFF4CAF50) : const Color(0xFFFF7A45),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Broncola Premium', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                    Text('Acceso a funciones exclusivas', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              if (hasPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Activo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const _FeatureRow(emoji: '✍️', text: 'Casillas personalizadas sin límite'),
          const SizedBox(height: 6),
          const _FeatureRow(emoji: '🔓', text: 'Acceso anticipado a nuevos packs'),
          const SizedBox(height: 6),
          const _FeatureRow(emoji: '🚫', text: 'Sin publicidad (cuando se añada)'),
          if (!hasPremium) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Desbloquear Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String emoji;
  final String text;
  const _FeatureRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PackCard extends StatelessWidget {
  final ContentPack pack;
  final bool isUnlocked;
  final VoidCallback onBuy;

  const _PackCard({required this.pack, required this.isUnlocked, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white.withOpacity(0.07) : Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnlocked ? Colors.white24 : Colors.white12),
      ),
      child: Row(
        children: [
          Text(pack.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pack.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(pack.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
          else
            ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Comprar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ComingSoonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        children: [
          Text('🔮', style: TextStyle(fontSize: 36)),
          SizedBox(height: 10),
          Text(
            'Packs en camino',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Pronto habrá nuevos packs de preguntas y retos. Mantén la app actualizada.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
