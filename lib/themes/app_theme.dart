import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Accents - Modern Light Bluish Palette
  static const Color blueAccent = Color(0xFF38BDF8); // Vibrant Light Sky Blue (Electric Cerulean)
  static const Color lightBlueAccent = Color(0xFF60A5FA); // Soft Light Blue
  static const Color limeAccent = Color(0xFF38BDF8); // VYNL Signature Accent (Light Bluish)
  static const Color goldAccent = Color(0xFF38BDF8); // Default light blueish accent
  static const Color goldLight = Color(0xFFBAE6FD);  // Soft sky-blue pastel

  // Dark Theme Colors (Deep Ocean / Slate Blueish Palette)
  static const Color darkBg = Color(0xFF0B1120);          // Deep Slate Midnight Blue
  static const Color darkSurface = Color(0xFF131D33);     // Translucent Oceanic Blue Surface
  static const Color darkSurfaceCard = Color(0xFF1B2744); // Elevated Slate-Blue Card
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Crisp Off-white
  static const Color darkTextSecondary = Color(0xFF94A9C9); // Soft Muted Blue Grey

  // Light Theme Colors (Modern Light Bluish Aesthetic)
  static const Color lightBg = Color(0xFFEEF5FB);          // Crisp Light Bluish background
  static const Color lightSurface = Color(0xFFE0EDF8);     // Soft Light Bluish surface
  static const Color lightSurfaceCard = Color(0xFFFFFFFF); // Clean white card with sky-blue tint
  static const Color lightTextPrimary = Color(0xFF0F1E36); // Deep Slate Navy
  static const Color lightTextSecondary = Color(0xFF476282); // Muted Steel Blue Grey

  // Roundness
  static const double cardRadius = 24.0;
  static const double pillRadius = 500.0;

  // Custom Glassmorphic Box Decoration Helper
  static BoxDecoration glassDecoration({
    required BuildContext context,
    double opacity = 0.08,
    double borderOpacity = 0.1,
    double radius = cardRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : Colors.black;
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: color.withOpacity(borderOpacity),
        width: 1.0,
      ),
    );
  }

  // Create Dark ThemeData from dynamic accent color
  static ThemeData buildDarkTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: accentColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
      ),
      textTheme: TextTheme(
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: darkTextPrimary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: darkTextPrimary,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentColor,
        inactiveTrackColor: Colors.white.withOpacity(0.1),
        thumbColor: accentColor,
        overlayColor: accentColor.withOpacity(0.2),
        trackHeight: 4,
      ),
    );
  }

  // Create Light ThemeData from dynamic accent color
  static ThemeData buildLightTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: accentColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: accentColor,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        onSurfaceVariant: lightTextSecondary,
      ),
      textTheme: TextTheme(
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: lightTextPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: lightTextSecondary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: lightTextPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: lightTextPrimary,
        ),
      ),
      iconTheme: const IconThemeData(
        color: lightTextPrimary,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentColor,
        inactiveTrackColor: Colors.black.withOpacity(0.06),
        thumbColor: accentColor,
        overlayColor: accentColor.withOpacity(0.2),
        trackHeight: 4,
      ),
    );
  }
}
