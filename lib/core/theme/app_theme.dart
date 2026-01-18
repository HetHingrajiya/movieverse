import 'package:flutter/material.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE50914), // Netflix Red
      brightness: Brightness.dark,
      surface: const Color(0xFF141414), // Dark Background
      onSurface: Colors.white,
    ).copyWith(
      surface: const Color(0xFF1F1F1F), // Card/Surface color
    ),
    scaffoldBackgroundColor: const Color(0xFF141414),
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF141414),
      selectedItemColor: Color(0xFFE50914),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
