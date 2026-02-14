
import 'package:flutter/material.dart';
import 'dart:math' as math;

class MolecularBackground extends StatefulWidget {
  final Widget child;
  final bool isLight;
  const MolecularBackground({super.key, required this.child, this.isLight = false});

  @override
  State<MolecularBackground> createState() => _MolecularBackgroundState();
}

class _MolecularBackgroundState extends State<MolecularBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<BubbleNode> _bubbles = List.generate(18, (index) => BubbleNode());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // Reduced from 40s to make bubbles move faster
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BubblePainter(
                  bubbles: _bubbles,
                  progress: _controller.value,
                  isLight: widget.isLight,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class BubbleNode {
  double startX = math.Random().nextDouble();
  double startY = math.Random().nextDouble();
  double driftX = 0.05 + math.Random().nextDouble() * 0.1;
  double driftY = 0.05 + math.Random().nextDouble() * 0.1;
  double phase1 = math.Random().nextDouble() * math.pi * 2;
  double phase2 = math.Random().nextDouble() * math.pi * 2;
  double freq1 = 0.4 + math.Random().nextDouble() * 0.4;
  double freq2 = 0.8 + math.Random().nextDouble() * 0.4;
  double size = 15 + math.Random().nextDouble() * 30;

  Color color = math.Random().nextBool()
      ? const Color(0xFF02B3A9)
      : const Color(0xFFF19842);

  double blur = 4 + math.Random().nextDouble() * 6;
}

class BubblePainter extends CustomPainter {
  final List<BubbleNode> bubbles;
  final double progress;
  final bool isLight;
  BubblePainter({required this.bubbles, required this.progress, required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    final double time = progress * math.pi * 2;

    for (var bubble in bubbles) {
      final double driftValX = (math.sin(time * bubble.freq1 + bubble.phase1) * 0.7) +
          (math.sin(time * bubble.freq2 + bubble.phase2) * 0.3);

      final double driftValY = (math.cos(time * bubble.freq1 + bubble.phase1) * 0.7) +
          (math.cos(time * bubble.freq2 + bubble.phase2) * 0.3);

      final double x = (bubble.startX + driftValX * bubble.driftX).clamp(0.0, 1.0) * size.width;
      final double y = (bubble.startY + driftValY * bubble.driftY).clamp(0.0, 1.0) * size.height;

      final double pulse = 1.0 + (math.sin(time * 1.5 + bubble.phase1) * 0.08);
      final double currentSize = bubble.size * pulse;

      final paint = Paint()
        ..color = bubble.color.withValues(alpha: isLight ? 0.25 : 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, bubble.blur);

      canvas.drawCircle(Offset(x, y), currentSize, paint);

      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: isLight ? 0.3 : 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
          Offset(x - currentSize * 0.3, y - currentSize * 0.3),
          currentSize * 0.15,
          glintPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}