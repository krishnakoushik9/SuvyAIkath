import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  const primary = Color(0xFF00BFA6); // Mint/Teal
  const bg = Color(0xFFF9FAFB); // Soft off-white
  const textPrimary = Color(0xFF111827); // Dark gray
  const textSecondary = Color(0xFF6B7280); // Muted
  const cardShadow = Color(0x0D000000); // 5% black
  const pressed = Color(0xFF0EA391);
  const track = Color(0x14000000); // 8% black
  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: textPrimary,
      background: bg,
    ),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: textPrimary),
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.pressed) ? pressed : null),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      indicatorColor: Color(0x1400BFA6), // subtle primary tint
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: primary)),
      labelTextStyle: WidgetStatePropertyAll(TextStyle(color: textPrimary)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: track,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shadowColor: cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
  );
}
