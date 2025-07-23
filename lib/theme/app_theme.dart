import 'package:flutter/material.dart';

class AppTheme {
  // Define a list of vibrant colors for charts
  static const List<Color> chartColors = [
    Color(0xFF53fdd7),
    Color(0xFFf5a623),
    Color(0xFFf8e71c),
    Color(0xFF8b572a),
    Color(0xFF7ed321),
    Color(0xFF4a90e2),
    Color(0xFFbd10e0),
    Color(0xFF9013fe),
    Color(0xFF4a4a4a),
    Color(0xFFd0021b),
  ];

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4A90E2),
      primary: const Color(0xFF4A90E2),
      secondary: const Color(0xFF50E3C2),
      surface: Colors.white,
      onSurface: const Color(0xFF1C1C2E),
    ),
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
          color: Color(0xFF1C1C2E),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter'),
      iconTheme: IconThemeData(color: Color(0xFF1C1C2E)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white.withAlpha(178),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withAlpha(230), width: 1.5),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withAlpha(200),
      selectedItemColor: const Color(0xFF4A90E2),
      unselectedItemColor: Colors.grey.shade500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF50E3C2),
      primary: const Color(0xFF50E3C2),
      secondary: const Color(0xFF4A90E2),
      surface: const Color(0xFF2A2A40),
      onSurface: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C2E),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter'),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1C1C2E).withAlpha(128),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withAlpha(51), width: 1.5),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF2A2A40).withAlpha(200),
      selectedItemColor: const Color(0xFF50E3C2),
      unselectedItemColor: Colors.grey.shade400,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}