import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // ── Premium Color Palette (Rose Quartz & Midnight Pearl) ───────────────────
  static const Color roseGold = Color(0xFFF48FB1); // More vibrant rose
  static const Color softRose = Color(0xFFFFF1F5); // Creamy soft rose
  static const Color deepRose = Color(0xFFD81B60);
  static const Color midnightPlum = Color(0xFF2D1B36); // Deep, high contrast text
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

  // Glass Design System
  static const double glassOpacity = 0.12;
  static const double glassBlur = 16.0;

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
    'Menstrual': Color(0xFFF06292), // Vibrant Rose
    'Follicular': Color(0xFFFFB2C1), // Soft Nude Pink
    'Ovulation': Color(0xFFAB47BC), // Deep Orchid
    'Luteal': Color(0xFF9575CD), // Muted Lavender
  };

  static const Map<String, Color> hormoneColors = {
    'Estrogen': Color(0xFFF06292),
    'Progesterone': Color(0xFFAB47BC),
    'LH': Color(0xFF42A5F5), // Premium Azure
    'FSH': Color(0xFF66BB6A), // Premium Emerald
  };

  // Aliases for Backward Compatibility
  static const Color primaryPink = roseGold;
  static const Color accentPurple = Color(0xFFAB47BC); // Ovulation phase deep orchid
  static const Color lavender = Color(0xFF9575CD); // Luteal phase muted lavender
  static const Color softPink = softRose;

  static Color phaseColor(String phase) => phaseColors[phase] ?? roseGold;

  // ── Spacing System (8px Grid) ─────────────────────────────────────────────
  static const double gridUnit = 8.0;
  static const double margin = 16.0;
  static const double padding = 24.0;

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

  static BoxDecoration glassDecoration({
    double radius = 24,
    double opacity = 0.1,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: (borderColor ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (borderColor ?? Colors.white).withOpacity(0.2),
        width: 1.5,
      ),
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
}
