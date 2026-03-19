import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // ── Color Palette (Exact Specification) ───────────────────────────────────
  static const Color bgColor      = Color(0xFFF8E9EE);
  static const Color surfaceColor  = Color(0xFFF3DDE5);
  static const Color accentPink    = Color(0xFFE88BA3);
  static const Color textDark      = Color(0xFF4A2F3A);
  static const Color textSecondary = Color(0xFFA97C8B);
  
  // Aliases for legacy compatibility
  static const Color frameColor    = bgColor;
  static const Color neuSurface    = surfaceColor;
  static const Color textMain       = textDark;
  static const Color textMuted      = textSecondary;
  static const Color shadowLight   = Colors.white;
  static const Color shadowDark    = Color(0xFFD9B9C4);

  // Visualization Colors
  static const Color accentPurple  = Color(0xFFBA68C8);
  static const Color accentCyan    = Color(0xFF4DD0E1);
  static const Color neonGreen     = Color(0xFF81C784);
  
  static const double glassOpacity = 0.4;
  static const double glassBlur    = 16.0;

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgColor, Color(0xFFFAEBEF)],
  );

  static const Map<String, Color> phaseColors = {
    'Menstrual':  Color(0xFFD81B60), // Deep Pink
    'Follicular': Color(0xFFFFCCBC), // Soft Peach
    'Ovulation':  Color(0xFFBA68C8), // Purple
    'Luteal':     Color(0xFFD1C4E9), // Lavender/Light Purple
  };

  static const Map<String, Color> hormoneColors = {
    'Estrogen':     Color(0xFFFFCCBC), // Peach Pink
    'Progesterone': Color(0xFFD1C4E9), // Lavender
    'LH':           Color(0xFFF06292), // Bright Pink
    'FSH':          Color(0xFFFFAB91), // Soft Coral
  };

  static Color phaseColor(String phase) => phaseColors[phase] ?? accentPink;


  // ── Glassmorphism Decorations ─────────────────────────────────────────────
  static BoxDecoration glassDecoration({
    double radius = 32.0,
    Color? color,
    Color? borderColor,
    double opacity = glassOpacity,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(
              color: (borderColor ?? Colors.white).withOpacity(0.3),
              width: 1.2,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ── Phase tip helper ──────────────────────────────────────────────────────
  static ({String headline, String body}) phaseTip(String phase) {
    switch (phase) {
      case 'Menstrual': return (headline: 'Focus on Rest', body: 'Energy is lower. Gentle movements only.');
      case 'Follicular': return (headline: 'Energy Rising', body: 'Perfect for starting new projects.');
      case 'Ovulation': return (headline: 'Peak Vitality', body: 'You are at your most vibrant.');
      case 'Luteal': return (headline: 'Nurture Yourself', body: 'Prioritize comfort and slow pace.');
      default: return (headline: 'Stay Mindful', body: 'Listen to your body\'s needs.');
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentPink,
        primary: accentPink,
        surface: surfaceColor,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
    );
  }
}
