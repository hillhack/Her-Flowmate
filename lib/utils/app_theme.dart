import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // ── Color Palette (Exact Specification) ───────────────────────────────────
  static const Color primaryPink   = Color(0xFFFF7FA5);
  static const Color softPink      = Color(0xFFFADADD);
  static const Color lavender      = Color(0xFFEBDFFF);
  static const Color accentPurple  = Color(0xFFCBA8FF);
  static const Color textDark      = Color(0xFF6A5C7A);
  
  // Neumorphic Design System (No Borders, Soft Shadows)
  static const Color bgColor       = Color(0xFFF8D6E6); // Neumorphic Surface
  static const Color surfaceColor   = Color(0xFFF8D6E6);
  static const Color neuLightShadow = Color(0xFFFFFFFF);
  static const Color neuDarkShadow  = Color(0xFFE3C7D6);
  
  // Aliases and Secondary Colors
  static const Color frameColor    = bgColor;
  static const Color textSecondary = Color(0xFF8A7E96); // Harmonized with textDark
  static const Color accentPink    = primaryPink;
  static const Color shadowLight   = neuLightShadow;
  static const Color shadowDark    = neuDarkShadow;

  // Glass Design System
  static const double glassOpacity = 0.15;
  static const double glassBlur    = 12.0;

  // Background Gradient
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE6F0),
      Color(0xFFEBDFFF),
      Color(0xFFFFD6EC),
    ],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryPink,
      accentPurple,
    ],
  );

  static const Map<String, Color> phaseColors = {
    'Menstrual':  Color(0xFFFF7FA5), // Primary Pink
    'Follicular': Color(0xFFFADADD), // Soft Pink
    'Ovulation':  Color(0xFFCBA8FF), // Accent Purple
    'Luteal':     Color(0xFFEBDFFF), // Lavender
  };

  static const Map<String, Color> hormoneColors = {
    'Estrogen': Color(0xFFFF7FA5),
    'Progesterone': Color(0xFFCBA8FF),
    'LH': Color(0xFF90CAF9),
    'FSH': Color(0xFFA5D6A7),
  };

  static Color phaseColor(String phase) => phaseColors[phase] ?? primaryPink;

  // ── Spacing System (8px Grid) ─────────────────────────────────────────────
  static const double gridUnit = 8.0;
  static const double margin   = 16.0;
  static const double padding  = 24.0;

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
  static ({List<String> exercise, List<String> diet, List<String> nutrients}) getPhaseHealthTips(String phase) {
    switch (phase) {
      case 'Menstrual':
        return (
          exercise: ['Gentle Yoga', 'Light Walking', 'Symptom Relief Stretches'],
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
          exercise: ['HIIT Sessions', 'High Intensity Cardio', 'Social Workouts'],
          diet: ['Rainbow Salads', 'Cold Berries', 'Anti-inflammatory Crucifers'],
          nutrients: ['Folate (cell health)', 'Amino Acids', 'Vitamin B'],
        );
      case 'Luteal':
        return (
          exercise: ['Steady-state Pilates', 'Mindful Resistance', 'Long Stretches'],
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
