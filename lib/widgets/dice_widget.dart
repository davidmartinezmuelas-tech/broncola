import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int? value;
  final bool canRoll;
  final VoidCallback onRoll;
  final Color glowColor;

  const DiceWidget({
    super.key,
    required this.value,
    required this.canRoll,
    required this.onRoll,
    this.glowColor = const Color(0xFF7C3AED),
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  late AnimationController _bounceCtrl;
  late Animation<double> _bounce;
  int _displayValue = 1;
  bool _isRolling = false;
  Timer? _rollTimer;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _bounce = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));
    if (widget.value != null) _displayValue = widget.value!;
  }

  @override
  void didUpdateWidget(covariant DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isRolling &&
        widget.value != null &&
        widget.value != oldWidget.value) {
      setState(() => _displayValue = widget.value!);
      _bounceCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _handleRoll() {
    if (!widget.canRoll || _isRolling) return;
    _isRolling = true;
    widget.onRoll();
    int tick = 0;
    const totalTicks = 10;

    void schedule() {
      final delay = Duration(milliseconds: 45 + (tick * 22).clamp(0, 180));
      _rollTimer = Timer(delay, () {
        if (!mounted) return;
        tick++;
        setState(() => _displayValue = _rng.nextInt(6) + 1);
        if (tick < totalTicks) {
          schedule();
        } else {
          _isRolling = false;
          setState(() => _displayValue = widget.value ?? _displayValue);
          _bounceCtrl.forward(from: 0);
        }
      });
    }

    schedule();
  }

  @override
  Widget build(BuildContext context) {
    final canRoll = widget.canRoll && !_isRolling;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _handleRoll,
          child: AnimatedBuilder(
            animation: Listenable.merge([_bounceCtrl, _bounce]),
            builder: (_, __) {
              final scale = _isRolling
                  ? (1.0 + sin(_bounceCtrl.value * pi * 8) * 0.05)
                  : (1.0 + (_bounce.value - 1.0).abs() * 0.1);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: canRoll || _isRolling
                          ? [const Color(0xFFF7F7F7), const Color(0xFFE3E3E3)]
                          : [const Color(0xFF555555), const Color(0xFF333333)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: canRoll
                            ? widget.glowColor.withOpacity(0.85)
                            : Colors.transparent,
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: canRoll
                            ? widget.glowColor.withOpacity(0.38)
                            : Colors.black26,
                        blurRadius: canRoll ? 18 : 6,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _DiceFacePainter(
                      value: _displayValue,
                      dotColor: canRoll || _isRolling
                          ? const Color(0xFF181818)
                          : const Color(0xFF888888),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: !_isRolling && widget.value != null
              ? Text('${widget.value}',
                  key: ValueKey(widget.value),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900))
              : const SizedBox(height: 28),
        ),
        Text(
          canRoll
              ? 'Toca para lanzar'
              : (_isRolling ? 'Rodando...' : 'Esperando'),
          style: TextStyle(
              color: canRoll ? widget.glowColor : Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DiceFacePainter extends CustomPainter {
  final int value;
  final Color dotColor;

  const _DiceFacePainter({required this.value, required this.dotColor});

  static const Map<int, List<Offset>> _dots = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.28, 0.28), Offset(0.72, 0.72)],
    3: [Offset(0.28, 0.28), Offset(0.5, 0.5), Offset(0.72, 0.72)],
    4: [
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72)
    ],
    5: [
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.5, 0.5),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72)
    ],
    6: [
      Offset(0.28, 0.22),
      Offset(0.72, 0.22),
      Offset(0.28, 0.5),
      Offset(0.72, 0.5),
      Offset(0.28, 0.78),
      Offset(0.72, 0.78)
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    final dotRadius = size.width * 0.085;
    final positions = _dots[value.clamp(1, 6)] ?? _dots[1]!;
    for (final position in positions) {
      canvas.drawCircle(
          Offset(position.dx * size.width, position.dy * size.height),
          dotRadius,
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiceFacePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.dotColor != dotColor;
  }
}
