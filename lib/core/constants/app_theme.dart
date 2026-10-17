import 'package:flutter/material.dart';

/// App Theme & Design Tokens adhering to Material 3 principles.
/// Features a refined Deep Indigo/Slate palette with Soft Mint & Coral accents.
class AppTheme {
  AppTheme._();

  // Primary Palette
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryDarkIndigo = Color(0xFF3730A3);
  static const Color primaryLightIndigo = Color(0xFFEEF2FF);

  // Secondary Accents
  static const Color accentMint = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Grammar Component Color Badges
  static const Color subjectColor = Color(0xFF3B82F6);     // Soft Blue
  static const Color subjectColorBg = Color(0xFFEFF6FF);
  static const Color objectColor = Color(0xFFF59E0B);      // Warm Amber
  static const Color objectColorBg = Color(0xFFFFFBEB);
  static const Color locationColor = Color(0xFF0D9488);    // Rich Teal
  static const Color locationColorBg = Color(0xFFF0FDFA);
  static const Color predicateColor = Color(0xFF8B5CF6);   // Royal Purple
  static const Color predicateColorBg = Color(0xFFF5F3FF);
  static const Color particleColor = Color(0xFF06B6D4);    // Soft Cyan
  static const Color particleColorBg = Color(0xFFECFEFF);

  // Neutral Colors (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);  // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceCardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight = Color(0xFF94A3B8);   // Slate 400
  static const Color borderLight = Color(0xFFE2E8F0);      // Slate 200

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF0F172A);   // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B);      // Slate 800
  static const Color surfaceCardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF334155);

  // Border Radii
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Elevation BoxShadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadowActive => [
        BoxShadow(
          color: primaryIndigo.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryIndigo,
        brightness: Brightness.light,
        surface: surfaceLight,
        primary: primaryIndigo,
        onPrimary: Colors.white,
        secondary: accentCyan,
        tertiary: accentCoral,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardThemeData(
        color: surfaceCardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimaryLight),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        elevation: 3,
        indicatorColor: primaryLightIndigo,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryIndigo,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryIndigo, size: 24);
          }
          return const IconThemeData(color: textSecondaryLight, size: 24);
        }),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryIndigo,
        brightness: Brightness.dark,
        surface: surfaceDark,
        primary: const Color(0xFF818CF8),
        onPrimary: Colors.black,
        secondary: accentCyan,
        tertiary: accentCoral,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardThemeData(
        color: surfaceCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimaryDark),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        elevation: 3,
        indicatorColor: const Color(0xFF312E81),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF818CF8),
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondaryDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF818CF8), size: 24);
          }
          return const IconThemeData(color: textSecondaryDark, size: 24);
        }),
      ),
    );
  }
}
