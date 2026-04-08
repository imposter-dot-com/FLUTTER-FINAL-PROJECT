import 'package:flutter/material.dart';

class BikeAppColors {
  BikeAppColors._();

  static const Color primary    = Color(0xFFD05F26); // Orange
  static const Color secondary  = Color(0xFFFFFFFF); // White
  static const Color tertiary   = Color(0xFF8C8C8C); // Grey
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface    = Color(0xFF2A2A2A); // Dark Grey
  static const Color error      = Color(0xFFD05F26);
  
  // Added for Light Mode visibility
  static const Color textPrimary = Color(0xFF1A1A1A); 
  static const Color lightGrey   = Color(0xFFF5F5F5);
}

class BikeAppRadius {
  BikeAppRadius._();

  static const double default_ = 45.0;
  static const BorderRadius rounded = BorderRadius.all(Radius.circular(default_));
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Inter',

        colorScheme: const ColorScheme.light(
          primary:    BikeAppColors.primary,
          onPrimary:  BikeAppColors.secondary,
          secondary:  BikeAppColors.secondary,
          onSecondary: BikeAppColors.textPrimary,
          tertiary:   BikeAppColors.tertiary,
          surface:    BikeAppColors.background,
          onSurface:  BikeAppColors.textPrimary,
          error:      BikeAppColors.error,
        ),

        scaffoldBackgroundColor: BikeAppColors.background,

        appBarTheme: const AppBarTheme(
          backgroundColor: BikeAppColors.background,
          foregroundColor: BikeAppColors.textPrimary,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: BikeAppColors.textPrimary,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BikeAppColors.primary,
            foregroundColor: BikeAppColors.secondary,
            shape: const RoundedRectangleBorder(borderRadius: BikeAppRadius.rounded),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: BikeAppColors.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BikeAppRadius.rounded,
            borderSide: BorderSide.none,
          ),
        ),

        cardTheme: const CardThemeData(
          color: BikeAppColors.secondary,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BikeAppRadius.rounded),
        ),

        // --- THE "MISSING" SECTIONS FIXED FOR LIGHT MODE ---

        // Chip: Using light grey background so white text isn't needed
        chipTheme: const ChipThemeData(
          backgroundColor: BikeAppColors.lightGrey,
          labelStyle: TextStyle(color: BikeAppColors.textPrimary, fontFamily: 'Inter'),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BikeAppRadius.rounded,
          ),
        ),

        // Switch: Updated with proper Material 3 State Properties
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return BikeAppColors.primary;
            return BikeAppColors.tertiary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return BikeAppColors.primary.withAlpha(100);
            }
            return BikeAppColors.lightGrey;
          }),
        ),

        // Divider: Slightly darker for light mode visibility
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEEEEEE),
          thickness: 1.0,
        ),

        // Icon: Switched to Dark so they appear on the White background
        iconTheme: const IconThemeData(
          color: BikeAppColors.textPrimary,
          size: 24,
        ),

        // Text Theme
        textTheme: const TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.bold,   color: BikeAppColors.textPrimary),
          bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: BikeAppColors.textPrimary),
          bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: BikeAppColors.textPrimary),
          bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: BikeAppColors.tertiary),
        ),
      );
}
