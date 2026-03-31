import 'dart:math';

import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final bool active;

  const ConfettiOverlay({super.key, required this.active});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _rng = Random();

  static const int _count = 80;
  static const List<Color> _colors = [
    Color(0xFFFF7A45),
    Color(0xFFFFD700),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
    Color(0xFF26C6DA),
    Color(0xFFFFCA28),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..addListener(() => setState(() {}));
    _particles = List.generate(_count, (_) => _Particle(_rng));
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _particles = List.generate(_count, (_) => _Particle(_rng));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active && !_controller.isAnimating) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(
          particles: _particles,
          progress: _controller.value,
          colors: _colors,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Particle {
  final double x; // 0..1 horizontal start
  final double delay; // 0..1 delay before falling
  final double speed; // fall speed multiplier
  final double size;
  final double drift; // horizontal drift
  final double rotation;
  final double rotationSpeed;
  final int colorIndex;
  final bool isCircle;

  _Particle(Random rng)
      : x = rng.nextDouble(),
        delay = rng.nextDouble() * 0.4,
        speed = 0.5 + rng.nextDouble() * 0.8,
        size = 6 + rng.nextDouble() * 8,
        drift = (rng.nextDouble() - 0.5) * 0.3,
        rotation = rng.nextDouble() * pi * 2,
        rotationSpeed = (rng.nextDouble() - 0.5) * 8,
        colorIndex = rng.nextInt(8),
        isCircle = rng.nextBool();
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final List<Color> colors;

  const _ConfettiPainter({required this.particles, required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final fallT = Curves.easeIn.transform(t);
      final x = (p.x + p.drift * t) * size.width;
      final y = -p.size + (size.height + p.size * 2) * fallT * p.speed;
      final alpha = t < 0.8 ? 1.0 : 1.0 - ((t - 0.8) / 0.2);
      final color = colors[p.colorIndex].withOpacity(alpha.clamp(0, 1));
      final paint = Paint()..color = color;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * t);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5), paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
