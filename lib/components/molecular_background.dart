
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
  // Use a fixed count of small, sharp bubbles
  final List<BubbleNode> _bubbles = List.generate(20, (index) => BubbleNode());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Longer duration for slower, smoother drift
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
  // Random base positions
  double startX = math.Random().nextDouble();
  double startY = math.Random().nextDouble();

  // Varied drift strengths for non-uniform movement
  double driftX = 0.08 + math.Random().nextDouble() * 0.12;
  double driftY = 0.08 + math.Random().nextDouble() * 0.12;

  // Phase offsets for the compound oscillation
  double phase1 = math.Random().nextDouble() * math.pi * 2;
  double phase2 = math.Random().nextDouble() * math.pi * 2;

  // Frequencies
  double freq1 = 0.5 + math.Random().nextDouble();
  double freq2 = 1.2 + math.Random().nextDouble();

  // Micro-size: 15 to 45 pixels
  double size = 12 + math.Random().nextDouble() * 28;

  Color color = math.Random().nextBool()
      ? const Color(0xFF02B3A9) // Teal
      : const Color(0xFFF19842); // Orange

  // Low blur for sharpness
  double blur = 3 + math.Random().nextDouble() * 4;
}

class BubblePainter extends CustomPainter {
  final List<BubbleNode> bubbles;
  final double progress;
  final bool isLight;
  BubblePainter({required this.bubbles, required this.progress, required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    // Current loop time (radians)
    final double time = progress * math.pi * 2;

    for (var bubble in bubbles) {
      // Compound oscillation for ultra-smooth "wandering"
      // Combines two different sine waves to create an unpredictable organic path
      final double driftValX = (math.sin(time * bubble.freq1 + bubble.phase1) * 0.6) +
          (math.sin(time * bubble.freq2 + bubble.phase2) * 0.4);

      final double driftValY = (math.cos(time * bubble.freq1 + bubble.phase1) * 0.6) +
          (math.cos(time * bubble.freq2 + bubble.phase2) * 0.4);

      // Calculate final pixel coordinates
      final double x = (bubble.startX + driftValX * bubble.driftX).clamp(0.0, 1.0) * size.width;
      final double y = (bubble.startY + driftValY * bubble.driftY).clamp(0.0, 1.0) * size.height;

      // Pulse the size slightly for life
      final double pulse = 1.0 + (math.sin(time * 2 + bubble.phase1) * 0.05);
      final double currentSize = bubble.size * pulse;

      // Primary Bubble Body
      final paint = Paint()
        ..color = bubble.color.withValues(alpha: isLight ? 0.35 : 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, bubble.blur);

      canvas.drawCircle(Offset(x, y), currentSize, paint);

      // Tiny specular highlight (Glint) to create 3D spherical look
      final glintPaint = Paint()
        ..color = Colors.white.withValues(alpha: isLight ? 0.4 : 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
          Offset(x - currentSize * 0.35, y - currentSize * 0.35),
          currentSize * 0.2,
          glintPaint
      );

      // Subtle outer glow
      final glowPaint = Paint()
        ..color = bubble.color.withValues(alpha: isLight ? 0.05 : 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, bubble.blur * 4);
      canvas.drawCircle(Offset(x, y), currentSize * 1.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
