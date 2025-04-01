import 'package:flutter/material.dart';

class AppTheme {

  static const Color primaryColor = Color(0xFF9ADCEB);
  static const Color secondaryColor = Color(0xFF2B3042);
  static const Color scaffoldBackgroundColor = Color(0xFFECF4FC);
  static const Color darkScaffoldBackgroundColor = Color(0xFF2A2F40);
  static const Color accentColor = Color(0xFFDCB03D);

  /// Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    // Define a custom highlight color
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor, // Highlight color for light mode
    ),
  );

  /// Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.black,
    cardColor: secondaryColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[900],
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    // Define a custom highlight color for dark mode
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: accentColor,
    ),
  );
}
