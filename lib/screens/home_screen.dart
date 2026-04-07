import 'package:flutter/material.dart';

import '../services/game_storage.dart';
import 'game_screen.dart';
import 'setup_screen.dart';
import 'store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameStorage _storage = GameStorage();
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hasSavedGame = await _storage.hasSavedGame();
    if (!mounted) return;
    setState(() => _hasSavedGame = hasSavedGame);
  }

  Future<void> _resumeGame() async {
    final saved = await _storage.loadGame();
    if (!mounted || saved == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(savedGame: saved)),
    );
    _loadData();
  }

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 220,
                    height: 220,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'BRONCOLA',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 6),
                ),
                const SizedBox(height: 10),
                const Text(
                  'El juego de mesa que destroza amistades y llena copas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupScreen())).then((_) => _loadData()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('Nueva partida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                ),
                if (_hasSavedGame) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _resumeGame,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF80CBC4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text('Reanudar partida guardada'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
                  icon: const Text('🛒', style: TextStyle(fontSize: 16)),
                  label: const Text('Tienda', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ),
                const Spacer(),
                const Text(
                  'Solo para mayores de 18 años. Bebe con responsabilidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
