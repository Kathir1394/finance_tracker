import 'package:flutter/material.dart';

class CircuitPainter extends CustomPainter {
  final Animation<double> animation;

  CircuitPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Glow Paint: Made much stronger for a vivid neon effect
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 // Thicker stroke for the glow
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        6.0 + (animation.value * 8.0), // Significantly larger and more dynamic glow radius
      );

    // Center Line Paint: Made slightly brighter
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final path = Path();
    // Simplified path for a cleaner look
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.9, 0);
    path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.1);
    path.lineTo(size.width, size.height * 0.9);
    path.quadraticBezierTo(size.width, size.height, size.width * 0.9, size.height);
    path.lineTo(size.width * 0.1, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height * 0.9);
    path.lineTo(0, size.height * 0.1);
    path.quadraticBezierTo(0, 0, size.width * 0.1, 0);

    // Draw the blue and purple glows with higher opacity
    glowPaint.color = Colors.blue.withAlpha((255 * (0.7 + (animation.value * 0.3))).round());
    canvas.drawPath(path, glowPaint);

    glowPaint.color = Colors.purple.withAlpha((255 * (0.5 + (animation.value * 0.5))).round());
    canvas.drawPath(path, glowPaint);

    // Draw the bright center line on top
    linePaint.color = Colors.white.withAlpha(230);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}