import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cycle_engine.dart';
// Re-export constants for backward compat with files that import app_theme.dart
export 'constants.dart';
export 'app_responsive.dart';

class AppDesignTokens {
  // Typography scale
  static const double displaySize = 32;
  static const double headlineSize = 26;
  static const double titleSize = 20;
  static const double bodyLargeSize = 16;
  static const double bodySize = 14;
  static const double captionSize = 12;
  static const double buttonSize = 16;
  static const double labelSize = 10;

  // Spacing (8pt grid)
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  // Border radii
  static const double radiusXS = 8;
  static const double radiusSM = 12;
  static const double radiusMD = 20;
  static const double radiusLG = 28;
  static const double radiusXL = 40;

  // Button dimensions
  static const double buttonHeight = 56.0;
  static const double buttonHPad = 24.0;
  static const double buttonVPad = 16.0;

  // Neumorphic shadows
  static List<BoxShadow> neuShadowLight({bool isPressed = false}) {
    final color = const Color(0xFFFF5D8C); // primaryPink500
    return isPressed
        ? [
            BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(1, 1))
          ]
        : [
            BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(4, 4)),
            const BoxShadow(
                color: Colors.white,
                blurRadius: 8,
                offset: Offset(-4, -4)),
          ];
  }

  static List<BoxShadow> neuShadowDark({bool isPressed = false}) {
    final color = Colors.black;
    return isPressed
        ? [
            BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(1, 1))
          ]
        : [
            BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(4, 4)),
            BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(-4, -4)),
          ];
  }

  static List<BoxShadow> neuShadow(BuildContext context, {bool isPressed = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? neuShadowDark(isPressed: isPressed) : neuShadowLight(isPressed: isPressed);
  }
}

abstract final class AppTheme {
  // ── Modern Pinkish Neumorphism Palette ─────────────────────────────────────
  // Primary Pink Shades
  static const Color primaryPink50 = Color(0xFFFFF1F5);
  static const Color primaryPink100 = Color(0xFFFFE0F0);
  static const Color primaryPink200 = Color(0xFFFFC1D6);
  static const Color primaryPink300 = Color(0xFFFF9CBA);
  static const Color primaryPink400 = Color(0xFFFF7BA4);
  static const Color primaryPink500 = Color(
    0xFFFF5D8C,
  ); // Vibrant pink (primary)
  static const Color primaryPink600 = Color(0xFFE64980);
  static const Color primaryPink700 = Color(0xFFC33774);
  static const Color primaryPink800 = Color(0xFFA13668);
  static const Color primaryPink900 = Color(0xFF7D2B5C);

  // Semantic Light Palette
  static const Color lightPrimary = primaryPink500;
  static const Color lightSecondary = primaryPink300;
  static const Color lightSurface = Colors.white;
  static const Color lightBackground = Color(0xFFFDF8FA);
  static const Color lightError = Color(0xFFFF5252);
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSurface = textDark;

  // Semantic Dark Palette
  static const Color darkPrimary = primaryPink300; // Softer pink for dark mode
  static const Color darkSecondary = primaryPink700;
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkError = Color(0xFFFF5252);
  static const Color darkOnPrimary = Color(0xFF121212);
  static const Color darkOnSurface = Color(0xFFE0E0E0);

  // Legacy/Required Dark Colors
  static const Color darkBg = darkBackground;
  static const Color darkNeuLight = Color(0xFF2D2D3F);
  static const Color darkNeuDark = Color(0xFF0F0F1A);
  static const Color darkCard = Color(0xFF252538);
  static const Color darkTextPrimary = darkOnSurface;
  static const Color darkTextSecondary = Color(0xFFAA8FBB);

  // Text Colors
  static const Color textDark = Color(0xFF2D1B36); // Deep plum (unchanged)
  static const Color textSecondary = Color(
    0xFF6B5876,
  ); // Muted plum (unchanged)
  static const Color textLight = Color(0xFFE0B4C4); // Soft pink text
  static const Color midnightPlum = textDark; // Alias for textDark
  static const Color deepRose = primaryPink600; // Alias for primaryPink600

  // Neumorphic Colors
  static const Color neuLightShadow = Color(0xFFFFFFFF); // White light
  static const Color neuDarkShadow = Color(
    0xFFFFE0F0,
  ); // Very light pink shadow
  static const Color neuMidShadow = Color(0xFFFFC1D6); // Light pink shadow
  static const Color neuDarkestShadow = Color(
    0xFFFF9CBA,
  ); // Medium light pink shadow

  // Design Foundations
  static const Color bgColor = primaryPink50; // Softest pink surface
  static const Color surfaceColor = primaryPink100; // Very light pink surface
  static const Color cardColor = primaryPink200; // Light pink cards
  static const Color containerColor =
      primaryPink300; // Medium light pink containers
  static const Color accentColor = primaryPink500; // Vibrant pink accent
  static const Color borderColor = primaryPink600; // Dark pink borders
  static const Color shadowLightColor = neuLightShadow;
  static const Color shadowDarkColor = neuDarkShadow;
  static const Color shadowMidColor = neuMidShadow;
  static const Color shadowDarkestColor = neuDarkestShadow;

  // Aliases
  static const Color frameColor = bgColor;
  static const Color accentPink = accentColor;
  static const Color shadowLight = shadowLightColor;
  static const Color shadowDark = shadowDarkColor;
  static const Color shadowMid = shadowMidColor;
  static const Color shadowDarkest = shadowDarkestColor;

  // Background Gradient (Modern Pinkish)
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF0F5), // Lavender Blush
      Color(0xFFFDEEF4), // Airy Pink
      Colors.white,
    ],
  );

  static const LinearGradient vibrantDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF281635), Color(0xFF321E3F), Color(0xFF1B0E23)],
  );

  static BoxDecoration getBackgroundDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(gradient: isDark ? vibrantDarkGradient : bgGradient);
  }

  static BoxDecoration getGlassDecoration(
    BuildContext context, {
    double radius = 24,
    double opacity = 0.1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return glassDecoration(
      radius: radius,
      opacity: isDark ? opacity * 0.8 : opacity,
      showBorder: true,
      borderColor:
          isDark
              ? Colors.white.withValues(alpha: 0.1)
              : accentPink.withValues(alpha: 0.2),
    );
  }

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor, // Vibrant pink
      primaryPink700, // Deep pink
    ],
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
  static const Color primaryPink = accentColor;
  static const Color accentPurple = primaryPink700; // Deep pink
  static const Color lavender = primaryPink600; // Dark pink
  static const Color softPink = primaryPink50; // Softest pink

  static Color phaseColor(String phase) => phaseColors[phase] ?? accentColor;

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
        return accentColor;
    }
  }

  // ── Spacing System ────────────────────────────────────────────────────────
  static const double spacingXs = 5.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Backward compatibility aliases
  static const double spacingXsmall = spacingXs;
  static const double spacingSmall = spacingSm;
  static const double spacingMedium = spacingMd;
  static const double spacingLarge = spacingLg;
  static const double spacingXlarge = spacingXl;
  static const double spacingXXlarge = spacingXxl;
  static const double spacingHuge = 64.0;

  static BoxDecoration loginContainerDecoration({bool isDark = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            isDark
                ? [darkBg, darkSurface]
                : [accentPink.withValues(alpha: 0.05), Colors.white],
      ),
      borderRadius: BorderRadius.circular(32),
      boxShadow:
          isDark
              ? []
              : [
                BoxShadow(
                  color: accentPink.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
    );
  }

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

  // ── Enhanced Neumorphic Shadows ───────────────────────────────────────────
  static List<BoxShadow> neuShadows({
    required bool isDark,
    double offset = 6.0,
    double blur = 12.0,
  }) {
    final Color light = isDark ? darkNeuLight : neuLightShadow;
    final Color dark = isDark ? darkNeuDark : neuDarkShadow;

    return [
      BoxShadow(
        color: light.withValues(alpha: isDark ? 0.35 : 0.8),
        offset: Offset(-offset, -offset),
        blurRadius: blur,
      ),
      BoxShadow(
        color: dark.withValues(alpha: isDark ? 0.5 : 0.8),
        offset: Offset(offset, offset),
        blurRadius: blur,
      ),
    ];
  }

  // Optimized Glass Design System (Lighter for Performance)
  static const double glassOpacity = 0.1;
  static const double glassBlur = 12.0; // Lower blur is faster to render
  static const double glassBorderOpacity = 0.15; // Subtle borders

  static BoxDecoration glassDecoration({
    double radius = 24,
    double opacity = glassOpacity,
    Color? borderColor,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border:
          showBorder
              ? Border.all(
                color: (borderColor ?? Colors.white).withValues(
                  alpha: glassBorderOpacity,
                ),
                width: 1.0,
              )
              : null,
    );
  }

  static BoxDecoration premiumGlassDecoration({
    double radius = 32,
    double opacity = 0.15, // More visible
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: glassBorderOpacity),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08), // Stronger shadow
          blurRadius: 25,
          spreadRadius: 0,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  // Typography - Premium Fonts
  static TextStyle playfair({
    BuildContext? context,
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    Color resolvedColor = color ?? textDark;
    if (context != null) {
      resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;
    }
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: resolvedColor,
    );
  }

  static TextStyle outfit({
    BuildContext? context,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    Color resolvedColor = color ?? textDark;
    if (context != null) {
      resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;
    }
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: resolvedColor,
    );
  }

  static TextTheme textTheme(BuildContext context) =>
      Theme.of(context).textTheme;

  // ── Theme Definitions ──────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        onSurface: lightOnSurface,
        onPrimary: lightOnPrimary,
        error: lightError,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: textDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      primaryColor: lightPrimary,
      primaryColorLight: primaryPink200,
      primaryColorDark: primaryPink700,
      canvasColor: lightSurface,
      shadowColor: shadowDarkColor,
      tabBarTheme: const TabBarThemeData(indicatorColor: accentColor),
      splashFactory: InkRipple.splashFactory,
      unselectedWidgetColor: textSecondary,
      disabledColor: textSecondary.withValues(alpha: 0.5),
      dialogTheme: const DialogThemeData(backgroundColor: lightSurface),
      dividerColor: shadowMidColor.withValues(alpha: 0.2),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadowColor: shadowDarkColor.withValues(alpha: 0.2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textDark),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        onSurface: darkOnSurface,
        onPrimary: darkOnPrimary,
        error: darkError,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: darkOnSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: darkOnSurface,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkOnSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: darkTextSecondary),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: darkTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
      primaryColor: darkPrimary,
      primaryColorLight: primaryPink600,
      primaryColorDark: primaryPink900,
      canvasColor: darkSurface,
      shadowColor: darkNeuDark,
      tabBarTheme: const TabBarThemeData(indicatorColor: darkPrimary),
      dividerColor: darkNeuLight.withValues(alpha: 0.2),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: darkOnSurface),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  // ── Helper Methods ─────────────────────────────────────────────────────────

  static double h1(BuildContext context) => adaptiveFontSize(context, 26);
  static double h2(BuildContext context) => adaptiveFontSize(context, 22);
  static double h3(BuildContext context) => adaptiveFontSize(context, 18);
  static double bodySize(BuildContext context) => adaptiveFontSize(context, 16);
  static double labelSize(BuildContext context) =>
      adaptiveFontSize(context, 12);

  // Aliases for backward compatibility
  static double body(BuildContext context) => bodySize(context);
  static double label(BuildContext context) => labelSize(context);

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
}

extension CustomTextTheme on TextTheme {
  TextStyle get headline => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  TextStyle get subheadline => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  TextStyle get bodySemiBold =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  TextStyle get body => GoogleFonts.inter(fontSize: 14, height: 1.5);

  TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    color: AppTheme.textSecondary,
    letterSpacing: 0.2,
  );
}

// ── Theme Extensions ─────────────────────────────────────────────────────────
extension PhaseColors on ColorScheme {
  Color phaseColor(String phase) {
    switch (phase) {
      case 'Menstrual' || 'Period':
        return primary;
      case 'Follicular':
        return secondary;
      case 'Ovulation' || 'Ovulatory':
        return tertiaryContainer.withValues(alpha: 0.8) == Colors.transparent
            ? primary
            : (brightness == Brightness.light
                ? const Color(0xFFBA68C8)
                : const Color(0xFFCE93D8));
      case 'Luteal':
        return primary.withValues(alpha: 0.7);
      default:
        return primary;
    }
  }
}
