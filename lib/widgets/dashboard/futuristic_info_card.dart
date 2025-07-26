import 'package:flutter/material.dart';
import 'circuit_painter.dart';

class FuturisticInfoCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;

  const FuturisticInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  State<FuturisticInfoCard> createState() => _FuturisticInfoCardState();
}

class _FuturisticInfoCardState extends State<FuturisticInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 15,
            offset: const Offset(5, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // ✅ FIX: This ensures the CustomPaint has a size to draw on
            Positioned.fill(
              child: CustomPaint(
                painter: CircuitPainter(animation: _controller),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                children: [
                  // ✅ FIX: Icon is centered at the top
                  Icon(
                    widget.icon,
                    color: Colors.white.withAlpha(204),
                    size: 32,
                  ),
                  // ✅ FIX: Value is centered and expands
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.value,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32, // Larger font
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ✅ FIX: Label is larger, brighter, and at the bottom
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}