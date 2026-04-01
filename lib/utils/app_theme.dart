import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cycle_engine.dart';
// Re-export constants for backward compat with files that import app_theme.dart
export 'constants.dart';

abstract final class AppTheme {
  // ── Premium Color Palette (Rose Quartz & Midnight Pearl) ───────────────────
  static const Color roseGold = Color(0xFFF48FB1); // More vibrant rose
  static const Color softRose = Color(0xFFFFF1F5); // Creamy soft rose
  static const Color deepRose = Color(0xFFD81B60);
  static const Color midnightPlum = Color(
    0xFF2D1B36,
  ); // Deep, high contrast text
  static const Color textDark = midnightPlum;
  static const Color textSecondary = Color(0xFF6B5876); // Muted plum

  // Design Foundations
  static const Color bgColor = Color(0xFFFDEEF4); // Subtle pink surface
  static const Color surfaceColor = bgColor;
  static const Color neuLightShadow = Color(0xFFFFFFFF);
  static const Color neuDarkShadow = Color(0xFFEBCAD8);

  // Aliases
  static const Color frameColor = bgColor;
  static const Color accentPink = roseGold;
  static const Color shadowLight = neuLightShadow;
  static const Color shadowDark = neuDarkShadow;

  // Background Gradient (Sophisticated Trio)
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF8FB), // Top Left: High light
      Color(0xFFFDEEF4), // Middle: Main surface
      Color(0xFFF6D9E6), // Bottom Right: Depth
    ],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [roseGold, Color(0xFF8E24AA)], // Rose to Rich Purple
  );

  static const Map<String, Color> phaseColors = {
    'Menstrual': Color(0xFFFF486A), // Vibrant Coral Red
    'Follicular': Color(0xFF7DD8FF), // Sky Blue
    'Ovulation': Color(0xFFD481FF), // Bright Orchid Purple
    'Luteal': Color(0xFFFFB347), // Sunset Orange
  };

  static const Map<String, Color> hormoneColors = {
    'Estrogen': Color(0xFFF06292),
    'Progesterone': Color(0xFFD481FF), // Match Ovulation
    'LH': Color(0xFF42A5F5),
    'FSH': Color(0xFF66BB6A),
  };

  // Aliases for Backward Compatibility
  static const Color primaryPink = roseGold;
  static const Color accentPurple = Color(0xFFD481FF); // New Ovulation color
  static const Color lavender = Color(0xFFFFB347); // New Luteal color (Orange)
  static const Color softPink = softRose;

  static Color phaseColor(String phase) => phaseColors[phase] ?? roseGold;

  static Color getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return phaseColors['Menstrual']!;
      case CyclePhase.follicular:
        return phaseColors['Follicular']!;
      case CyclePhase.ovulation:
        return phaseColors['Ovulation']!;
      case CyclePhase.luteal:
        return phaseColors['Luteal']!;
      case CyclePhase.unknown:
        return roseGold;
    }
  }

  // ── Spacing System (Consistent 8px Grid) ──────────────────────────────────
  static const double spacingXsmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXlarge = 32.0;
  static const double spacingXXlarge = 48.0;
  static const double spacingHuge = 64.0;

  // ── Responsive Scaling Helper ─────────────────────────────────────────────
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static bool isSmallScreen(BuildContext context) => screenWidth(context) < 360;

  static double clamp(double min, double val, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }

  static double adaptiveFontSize(BuildContext context, double baseSize) {
    double width = screenWidth(context);
    // Mimic CSS clamp behavior: clamp(min, preferred, max)
    double preferred = baseSize * (width / 375); // 375 is standard design width
    return clamp(baseSize * 0.85, preferred, baseSize * 1.2);
  }

  static double responsiveFontSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) return baseSize * 0.85; // Small phones
    if (screenWidth(context) < 400) return baseSize * 0.95; // Medium phones
    return baseSize;
  }

  static double scale(BuildContext context, double value) {
    double width = screenWidth(context);
    if (width < 360) return value * 0.8;
    return value;
  }

  // ── Neumorphic Shadows ───────────────────────────────────────────────────
  static List<BoxShadow> neuShadows({
    double offset = 8.0,
    double blur = 16.0,
    Color lightColor = neuLightShadow,
    Color darkColor = neuDarkShadow,
  }) {
    return [
      BoxShadow(
        color: lightColor,
        offset: Offset(-offset, -offset),
        blurRadius: blur,
      ),
      BoxShadow(
        color: darkColor,
        offset: Offset(offset, offset),
        blurRadius: blur,
      ),
    ];
  }

  // Glass Design System
  static const double glassOpacity = 0.08;
  static const double glassBlur = 16.0;

  static BoxDecoration glassDecoration({
    double radius = 24,
    double opacity = 0.08,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1.5,
      ),
    );
  }

  static BoxDecoration premiumGlassDecoration({
    double radius = 32,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Typography - Premium Fonts
  static TextStyle playfair({
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
    );
  }

  static TextStyle outfit({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
    );
  }

  static ({String headline}) phaseTip(String phase) {
    switch (phase) {
      case 'Menstrual':
        return (headline: 'Rest and Rejuvenate');
      case 'Follicular':
        return (headline: 'Plan and Initiate');
      case 'Ovulation':
        return (headline: 'Connect and Express');
      case 'Luteal':
        return (headline: 'Analyze and Complete');
      default:
        return (headline: 'Balance and Listen');
    }
  }

  // ── Phase Health Support (Refined) ────────────────────────────────────────
  static ({List<String> exercise, List<String> diet, List<String> nutrients})
  getPhaseHealthTips(String phase) {
    switch (phase) {
      case 'Menstrual':
        return (
          exercise: [
            'Gentle Yoga',
            'Light Walking',
            'Symptom Relief Stretches',
          ],
          diet: ['Warm Herbal Soups', 'Magnesium-Rich Oats', 'Ginger Tea'],
          nutrients: ['Iron (rebuild)', 'Magnesium (cramps)', 'Vitamin C'],
        );
      case 'Follicular':
        return (
          exercise: ['Light Cardio', 'Creative Movement', 'Power Walking'],
          diet: ['Fermented Salads', 'Sprouted Grains', 'Lean Proteins'],
          nutrients: ['Zinc (hormone balance)', 'Vitamin B12', 'Vitamin E'],
        );
      case 'Ovulation':
        return (
          exercise: [
            'HIIT Sessions',
            'High Intensity Cardio',
            'Social Workouts',
          ],
          diet: [
            'Rainbow Salads',
            'Cold Berries',
            'Anti-inflammatory Crucifers',
          ],
          nutrients: ['Folate (cell health)', 'Amino Acids', 'Vitamin B'],
        );
      case 'Luteal':
        return (
          exercise: [
            'Steady-state Pilates',
            'Mindful Resistance',
            'Long Stretches',
          ],
          diet: ['Complex Root Veggies', 'Dark Chocolate (70%+)', 'Omega Fats'],
          nutrients: ['Vitamin B6 (mood)', 'Magnesium (sleep)', 'Omega-3'],
        );
      default:
        return (
          exercise: ['Listen to your pulse'],
          diet: ['Mindful nutrition'],
          nutrients: ['Essential Multivitamin'],
        );
    }
  }

  static List<String> getPhaseSymptoms(String phase) {
    switch (phase) {
      case 'Menstrual':
        return ['Cramps', 'Fatigue', 'Low Back Pain'];
      case 'Follicular':
        return ['Rising Energy', 'Optimism', 'Focus'];
      case 'Ovulation':
        return ['High Libido', 'Mild Cramp', 'Energy↑'];
      case 'Luteal':
        return ['Bloating', 'Mood Swings', 'Sensitivity'];
      default:
        return ['Varies'];
    }
  }

  // ── Theme Definition ───────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        primary: primaryPink,
        surface: surfaceColor,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
    );
  }

  // ── Dark Mode Colours ─────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF1A0F22); // Deep midnight plum
  static const Color darkSurface = Color(
    0xFF241630,
  ); // Slightly lighter surface
  static const Color darkCard = Color(0xFF2E1C3E); // Card background
  static const Color darkTextPrimary = Color(0xFFF3E0EC); // Creamy off-white
  static const Color darkTextSecondary = Color(0xFFAA8FBB); // Muted lavender
  static const Color darkNeuLight = Color(0xFF3A2450); // Light shadow
  static const Color darkNeuDark = Color(0xFF100A18); // Dark shadow

  static const LinearGradient darkBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E1128), // Deep top-left
      Color(0xFF1A0F22), // Main dark surface
      Color(0xFF0F0814), // Bottom-right depth
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: roseGold,
        brightness: Brightness.dark,
        primary: roseGold,
        surface: darkSurface,
        onSurface: darkTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      cardColor: darkCard,
      dividerColor: darkNeuLight.withValues(alpha: 0.3),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: darkCard),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.inter(color: darkTextPrimary),
      ),
    );
  }
}
