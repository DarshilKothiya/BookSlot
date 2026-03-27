import 'package:flutter/material.dart';

class MinimalTheme {
  // Color Palette
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primaryAccent = Color(0xFF2D2D2D);
  static const Color secondaryAccent = Color(0xFF6C63FF);
  static const Color activeBadge = Color(0xFF22C55E);
  static const Color inactiveBadge = Color(0xFFEF4444);
  static const Color subtext = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color softWhite = Color(0xFFFFFFFF);

  // Minimal Card Decoration
  static BoxDecoration getCardDecoration() {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Badge Decoration
  static BoxDecoration getBadgeDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    );
  }

  // Button Decoration
  static BoxDecoration getButtonDecoration() {
    return BoxDecoration(
      color: secondaryAccent,
      borderRadius: BorderRadius.circular(25),
    );
  }

  // Input Field Decoration
  static InputDecoration getInputDecoration({
    required String labelText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon, color: secondaryAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondaryAccent, width: 2),
      ),
      labelStyle: const TextStyle(color: subtext),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondaryAccent,
        brightness: Brightness.light,
        primary: secondaryAccent,
        surface: background,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBackground,
        foregroundColor: primaryAccent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryAccent,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: subtext),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: secondaryAccent,
        unselectedItemColor: subtext,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: primaryAccent,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: primaryAccent,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: primaryAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: primaryAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: primaryAccent,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: primaryAccent,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: primaryAccent,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: subtext,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: subtext,
          fontSize: 12,
        ),
      ),
    );
  }
}
