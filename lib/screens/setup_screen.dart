import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/content_pack.dart';
import '../models/game_mode.dart';
import '../models/game_setup.dart';
import '../models/player.dart';
import '../services/game_storage.dart';
import '../services/user_access_service.dart';
import '../theme/game_palette.dart';
import 'spin_screen.dart';
import 'store_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _playerCount = 2;
  GameMode _mode = GameMode.light;
  final List<TextEditingController> _controllers = [];
  final List<Uint8List?> _avatars = [];
  final List<TextEditingController> _customTileControllers = [];
  final Set<ContentPack> _selectedPacks = {};
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  List<Player> _savedRoster = [];
  final _storage = GameStorage();

  static const _privateBuild = bool.fromEnvironment('PRIVATE_PACK');

  List<ContentPack> get _availablePacks => ContentPack.values
      .where((p) =>
          !p.isFree &&
          UserAccessService.instance.access.hasPackUnlocked(p) &&
          (!p.isPrivate || _privateBuild))
      .toList();

  @override
  void initState() {
    super.initState();
    _rebuildControllers(2);
    _addCustomTileField();
    _loadRoster();
  }

  Future<void> _loadRoster() async {
    final roster = await _storage.loadRoster();
    if (mounted) setState(() => _savedRoster = roster);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final controller in _customTileControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  GamePalette get _palette => paletteFor(_mode);

  void _rebuildControllers(int count) {
    final existingNames = _controllers.map((controller) => controller.text).toList();
    final existingAvatars = List<Uint8List?>.from(_avatars);
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers
      ..clear()
      ..addAll(
        List.generate(
          count,
          (index) => TextEditingController(text: index < existingNames.length ? existingNames[index] : ''),
        ),
      );
    _avatars
      ..clear()
      ..addAll(List.generate(count, (index) => index < existingAvatars.length ? existingAvatars[index] : null));
  }

  Future<void> _pickAvatar(int index) async {
    final source = await _showSourcePicker();
    if (source == null) return;

    try {
      final file = await _picker.pickImage(source: source, maxWidth: 400, maxHeight: 400, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _avatars[index] = bytes);
    } catch (_) {}
  }

  Future<ImageSource?> _showSourcePicker() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _palette.panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text('Foto de perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Galería', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Cámara', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addCustomTileField() {
    _customTileControllers.add(TextEditingController());
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    final players = List.generate(
      _playerCount,
      (i) => Player(name: _controllers[i].text.trim(), color: _colorForIndex(i), avatarBytes: _avatars[i]),
    );
    // Auto-save all players to the persistent roster
    for (final player in players) {
      await _storage.upsertPlayerInRoster(player);
    }
    final setup = GameSetup(
      customTileTexts: _customTileControllers.map((controller) => controller.text.trim()).where((text) => text.isNotEmpty).toList(),
      selectedPacks: _selectedPacks.toList(),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SpinScreen(players: players, gameMode: _mode, setup: setup)),
    );
  }

  void _addSavedPlayerToGame(Player saved) {
    final emptyIdx = _controllers.indexWhere((c) => c.text.trim().isEmpty);
    if (emptyIdx >= 0) {
      setState(() {
        _controllers[emptyIdx].text = saved.name;
        _avatars[emptyIdx] = saved.avatarBytes;
      });
    } else {
      setState(() {
        _playerCount++;
        _controllers.add(TextEditingController(text: saved.name));
        _avatars.add(saved.avatarBytes);
      });
    }
  }

  void _removePlayerRow(int index) {
    setState(() {
      _controllers.removeAt(index).dispose();
      _avatars.removeAt(index);
      _playerCount = _controllers.length;
    });
  }

  Future<void> _confirmRemoveFromRoster(Player player) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _palette.panel,
        title: const Text('Quitar jugador guardado', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar a ${player.name} de los jugadores guardados?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _storage.removePlayerFromRoster(player.name);
      if (mounted) setState(() => _savedRoster.removeWhere((p) => p.name == player.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Nueva partida', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
            tooltip: 'Tienda',
            icon: const Text('🛒', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _palette.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _sectionLabel('Modo de juego'),
              const SizedBox(height: 12),
              _modeSelector(),
              const SizedBox(height: 24),
              if (_savedRoster.isNotEmpty) ...[
                _sectionLabel('Jugadores guardados'),
                const SizedBox(height: 6),
                const Text(
                  'Toca para añadir · Mantén para eliminar',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 74,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _savedRoster.length,
                    itemBuilder: (_, i) => _savedPlayerChip(_savedRoster[i]),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _sectionLabel('Jugadores'),
              const SizedBox(height: 12),
              ...List.generate(_playerCount, _playerRow),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _playerCount++;
                      _controllers.add(TextEditingController());
                      _avatars.add(null);
                    });
                  },
                  icon: const Icon(Icons.person_add, color: Colors.white54),
                  label: const Text('Añadir jugador', style: TextStyle(color: Colors.white54)),
                ),
              ),
              const SizedBox(height: 20),
              if (_availablePacks.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionLabel('Packs de contenido'),
                const SizedBox(height: 6),
                const Text(
                  'Activa los packs que quieras incluir en esta partida. Sus preguntas se mezclan con el mazo.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 12),
                ..._availablePacks.map(_packToggle),
              ],
              const SizedBox(height: 24),
              _sectionLabel('Casillas personalizadas'),
              const SizedBox(height: 6),
              if (UserAccessService.instance.access.hasPremium) ...[
                const Text('Añade pruebas tuyas antes de empezar. Se mezclarán con el tablero.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
                ..._customTileFields(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(_addCustomTileField),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Añadir otra', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ] else
                _customTilesLocked(),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _palette.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Empezar partida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _customTileFields() {
    return List.generate(_customTileControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _customTileControllers[index],
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Casilla personalizada ${index + 1}'),
              ),
            ),
            if (_customTileControllers.length > 1)
              IconButton(
                onPressed: () {
                  setState(() {
                    _customTileControllers.removeAt(index).dispose();
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
          ],
        ),
      );
    });
  }

  Widget _savedPlayerChip(Player player) {
    return GestureDetector(
      onTap: () => _addSavedPlayerToGame(player),
      onLongPress: () => _confirmRemoveFromRoster(player),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: player.color,
                  backgroundImage: player.avatarBytes != null ? MemoryImage(player.avatarBytes!) : null,
                  child: player.avatarBytes == null
                      ? Text(player.initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                      : null,
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () => _confirmRemoveFromRoster(player),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(color: Colors.red.shade800, shape: BoxShape.circle, border: Border.all(color: Colors.black26)),
                      child: const Icon(Icons.close, color: Colors.white, size: 11),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              player.name.length > 8 ? '${player.name.substring(0, 7)}…' : player.name,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerRow(int index) {
    final color = _colorForIndex(index);
    final hasAvatar = _avatars[index] != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickAvatar(index),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: color,
              backgroundImage: hasAvatar ? MemoryImage(_avatars[index]!) : null,
              child: hasAvatar ? null : Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _controllers[index],
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Jugador ${index + 1}').copyWith(labelStyle: TextStyle(color: color)),
              validator: (value) => value == null || value.trim().isEmpty ? 'Introduce un nombre' : null,
            ),
          ),
          if (_playerCount > 2)
            IconButton(
              onPressed: () => _removePlayerRow(index),
              icon: const Icon(Icons.person_remove_outlined, color: Colors.white38, size: 20),
              tooltip: 'Quitar jugador',
            ),
        ],
      ),
    );
  }

  Widget _modeSelector() {
    return Column(
      children: GameMode.values.map((mode) {
        final palette = paletteFor(mode);
        final selected = _mode == mode;
        return GestureDetector(
          onTap: () => setState(() => _mode = mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? palette.accent.withOpacity(0.18) : Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? palette.accent : Colors.white10, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Text(mode.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mode.label, style: TextStyle(color: selected ? palette.accentSoft : Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(mode.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: palette.accentSoft),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _palette.accent, width: 2)),
    );
  }

  Color _colorForIndex(int i) {
    const base = [
      Color(0xFFE53935),
      Color(0xFF1E88E5),
      Color(0xFF43A047),
      Color(0xFFFDD835),
      Color(0xFFFF7043),
      Color(0xFF8E24AA),
      Color(0xFF00ACC1),
      Color(0xFFFFB300),
    ];
    if (i < base.length) return base[i];
    final hue = (i * 137.5) % 360;
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  Widget _packToggle(ContentPack pack) {
    final selected = _selectedPacks.contains(pack);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedPacks.remove(pack);
        } else {
          _selectedPacks.add(pack);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _palette.accent.withOpacity(0.15) : Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _palette.accent : Colors.white12,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(pack.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pack.label, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(pack.description, style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: selected ? _palette.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? _palette.accent : Colors.white24, width: 2),
              ),
              child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _customTilesLocked() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Función Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('Desbloquea Premium para añadir tus propias casillas.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFF7A45), borderRadius: BorderRadius.circular(10)),
              child: const Text('Ver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 1));
  }
}
