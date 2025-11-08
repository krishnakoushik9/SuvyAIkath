import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF6D8A38);   // Buttons
  static const primaryLight = Color(0xFF9ABD5F);
  static const primaryDark = Color(0xFF4D5C2F);
  
  // Secondary Colors
  static const secondary = Color(0xFFDDAF4B);  // Accent borders or icons
  static const secondaryLight = Color(0xFFFFE082);
  static const secondaryDark = Color(0xFFB58C3D);
  
  // Background & Surface
  static const background = Color(0xFFF3E6C9); // Background
  static const surface = Color(0xFFFFF9EB);    // Cards
  
  // Text
  static const textPrimary = Color(0xFF3E2F1C);  // Titles
  static const textSecondary = Color(0xFF6C5748); // Subtext
  
  // Feedback
  static const success = Color(0xFF6D8A38);     // Primary color
  static const error = Color(0xFFB75D3C);       // Error/Alert
  static const warning = Color(0xFFDDAF4B);     // Secondary color
  
  // UI Elements
  static const divider = Color(0xFFE0D6C3);     // Light divider
  static const iconInactive = Color(0xFFBDAE9D); // Inactive NavBar icons
  static const iconActive = Color(0xFF6D8A38);   // Active NavBar icons
  static const cardShadow = Color(0x0D000000);  // 5% opacity black
  static const pressed = Color(0x1A6D8A38);     // Primary with 10% opacity
  static const track = Color(0x1A6D8A38);       // 10% primary color
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryLight,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    
    scaffoldBackgroundColor: AppColors.background,
    
    // Text Theme
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryDark.withOpacity(0.2);
            }
            return null; // Use the default overlay color
          },
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    ),
    
    // Navigation Bar Theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withOpacity(0.1),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.iconActive,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return TextStyle(
            color: AppColors.iconInactive,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        },
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
        (Set<WidgetState> states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.iconActive
                : AppColors.iconInactive,
            size: 24,
          );
        },
      ),
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.track,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: TextStyle(color: AppColors.textSecondary),
      hintStyle: TextStyle(color: AppColors.iconInactive),
      errorStyle: const TextStyle(color: AppColors.error),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      disabledColor: AppColors.background,
      selectedColor: AppColors.primary.withOpacity(0.1),
      secondarySelectedColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
      brightness: Brightness.light,
    ),
    
    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
