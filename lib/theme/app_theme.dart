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
      surface: Colors.white, // Card color
      onSurface: Colors.black, // Text on card color
    ),
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF3F4F6),
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    // FIX: Removed 'const' because BorderRadius.circular is not a const constructor
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF4A90E2),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    fontFamily: 'Inter',
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF50E3C2),
      primary: const Color(0xFF50E3C2),
      secondary: const Color(0xFF4A90E2),
      surface: const Color(0xFF2A2A40), // Card color
      onSurface: Colors.white, // Text on card color
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C2E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C2E),
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    // FIX: Removed 'const' because BorderRadius.circular is not a const constructor
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF2A2A40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2A2A40),
      selectedItemColor: Color(0xFF50E3C2),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    fontFamily: 'Inter',
  );
}