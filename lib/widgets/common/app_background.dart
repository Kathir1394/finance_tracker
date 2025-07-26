import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main vertical linear gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF1F3FF), // Light Lavender
                Color(0xFFD7DBFF), // Cool Bluish-Purple
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Soft radial glow in the top-left corner
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [
                Colors.white.withAlpha(38), // Correct way to set opacity
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}