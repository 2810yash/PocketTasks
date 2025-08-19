import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final int completed;
  final int total;
  final double size;

  const ProgressRing({
    super.key,
    required this.completed,
    required this.total,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressPainter(
          progress: total == 0 ? 0 : completed / total,
          color: Theme.of(context).colorScheme.primary,
          background: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        ),
        child: Center(
          child: Text(
            total == 0 ? '0/0' : (completed.toString() + '/' + total.toString()),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color background;

  _ProgressPainter({required this.progress, required this.color, required this.background});

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = 6;
    final Rect rect = Offset.zero & size;
    final Offset center = rect.center;
    final double radius = math.min(size.width, size.height) / 2 - stroke;
    final Paint track = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final Paint arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final double sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
      final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(arcRect, -math.pi / 2, sweep, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.background != background;
  }
}


