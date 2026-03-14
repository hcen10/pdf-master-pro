import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const _accent  = Color(0xFF7C6FF7);
  static const _accent2 = Color(0xFFFF6B8A);

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary:   _accent,
      secondary: _accent2,
      surface:   const Color(0xFF13131E),
      background: const Color(0xFF0A0A12),
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0A12),
    cardColor: const Color(0xFF1C1C2E),
    dividerColor: const Color(0xFF2A2A3F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0A12),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF10101A),
      selectedItemColor: _accent,
      unselectedItemColor: Color(0xFF8888AA),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1C2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A2A3F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A2A3F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF8888AA)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFCCCCEE)),
      bodySmall: TextStyle(color: Color(0xFF8888AA)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),
  );

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary:    _accent,
      secondary:  _accent2,
      surface:    Colors.white,
      background: const Color(0xFFF4F4FF),
      onPrimary:  Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F4FF),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFCCCCEE),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF4F4FF),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: Colors.grey[900],
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _accent,
      unselectedItemColor: Color(0xFF9999BB),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCCCCEE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCCCCEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 2),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w900),
      headlineMedium: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: Colors.grey[800]),
      bodyMedium: TextStyle(color: Colors.grey[700]),
      bodySmall: TextStyle(color: Colors.grey[500]),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),
  );
}
