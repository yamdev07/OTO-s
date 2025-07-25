import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0F1E54);
  static const Color accentColor = Color(0xFF00C6FF);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}
