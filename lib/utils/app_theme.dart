import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cycle_engine.dart';
// Re-export constants for backward compat with files that import app_theme.dart
export 'constants.dart';
export 'app_responsive.dart';

class AppDesignTokens {
  // Typography scale
  static const double displaySize   = 32;
  static const double headlineSize  = 26;
  static const double titleSize     = 20;
  static const double bodyLargeSize = 16;
  static const double bodySize      = 14;
  static const double captionSize   = 12;
  static const double buttonSize    = 16;
  static const double labelSize     = 10;

  // Spacing (8pt grid)
  static const double space4  = 4;
  static const double space8  = 8;
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
  static const double buttonHPad   = 24.0;
  static const double buttonVPad   = 16.0;

  // Neumorphic shadows – tuned for warm ivory background
  static List<BoxShadow> neuShadow(
    BuildContext context, {
    bool isPressed = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppTheme.neuShadows(isDark: isDark, isPressed: isPressed);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  🌹  Rose-Coral + Warm Berry Design System
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppTheme {

  // ── Primary: Rose Coral ───────────────────────────────────────────────────
  static const Color roseCoralPrimary = Color(0xFFE8446A);
  static const Color roseCoralLight   = Color(0xFFFF8096);
  static const Color roseCoralDark    = Color(0xFFC43059);
  static const Color roseCoralDeep    = Color(0xFF9B1E44);
  static const Color roseCoralPale    = Color(0xFFFFF0F3);
  static const Color roseCoralSoft    = Color(0xFFFFD6DE);

  // ── Secondary: Warm Berry ─────────────────────────────────────────────────
  static const Color berryPrimary = Color(0xFFAD2D6B);
  static const Color berryLight   = Color(0xFFD4569A);
  static const Color berryDark    = Color(0xFF7B1C4F);
  static const Color berrySoft    = Color(0xFFEFC0D8);

  // ── Accent: Peach Glow ────────────────────────────────────────────────────
  static const Color peachAccent = Color(0xFFFF8A70);
  static const Color peachSoft   = Color(0xFFFFD4C2);

  // ── Semantic Semantic Palette ────────────────────────────────────────────────
  static const Color primary    = roseCoralPrimary;
  static const Color secondary  = berryPrimary;
  static const Color accent     = peachAccent;
  
  static const Color lightSurface    = Colors.white;
  static const Color lightBackground = Color(0xFFFFF5F0); // warm ivory
  static const Color lightOnSurface  = textDark;
  
  static const Color darkSurface    = Color(0xFF2D1822); // deep wine surface
  static const Color darkBackground = Color(0xFF231118); // rich velvety wine
  static const Color darkOnSurface  = Color(0xFFFCEFF2); // soft warm ivory pink

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textDark      = Color(0xFF2B1020); // deep warm plum
  static const Color textSecondary = Color(0xFF7A4E62); // muted rose-grey
  static const Color textLight     = Color(0xFFEFB8C8); // soft warm pink
  static const Color midnightPlum  = textDark; // Essential alias for UI consistency

  // ── Design Foundations (Consolidated) ─────────────────────────────────────
  static const Color bgColor        = lightBackground;
  static const Color accentPink     = roseCoralPrimary; 
  static const Color primaryPink    = roseCoralPrimary; 
  static const Color frameColor     = lightBackground;
  static const Color accentPurple   = berryPrimary;
  static const Color accentColor    = roseCoralPrimary;
  
  // Backward-compat spacing (Migration to AppDesignTokens)
  static const String _spacingNote = 'Use AppDesignTokens for new spacing. Pointing to 8pt grid.';

  @Deprecated(_spacingNote)
  static const double spacingXsmall  = spacingXs;
  @Deprecated(_spacingNote)
  static const double spacingSmall   = spacingSm;
  @Deprecated(_spacingNote)
  static const double spacingMedium  = spacingMd;
  @Deprecated(_spacingNote)
  static const double spacingLarge   = spacingLg;
  @Deprecated(_spacingNote)
  static const double spacingXlarge  = spacingXl;
  @Deprecated(_spacingNote)
  static const double spacingXXlarge = spacingXxl;

  // Backward-compat colors (Migration Phase)
  static const Color primaryPink300 = roseCoralLight;
  static const Color primaryPink500 = roseCoralPrimary;
  static const Color primaryPink700 = berryPrimary;
  static const Color darkTextPrimary = darkOnSurface;
  static const Color darkBg = darkBackground;
  static const Color darkNeuLight = Color(0xFF3D1A2E);
  static const Color darkNeuDark = Color(0xFF0D0308);
  static const Color darkCard = Color(0xFF341828);
  static const Color darkTextSecondary = Color(0xFFBB8FA0);
  static const Color lightError = Color(0xFFE53935);
  
  // Neumorphic shadow tokens
  static const Color shadowLight = Colors.white;
  static const Color shadowDark  = Color(0xFFEDCED6);
  static const Color shadowMid   = Color(0xFFFFBDC8);
  static const Color neuLightShadow = shadowLight;
  static const Color neuDarkShadow = shadowDark;
  static const Color neuMidShadow = shadowMid;

  // ── Gradients ─────────────────────────────────────────────────────────────

  /// Light mode: Warm Ivory → Blush Rose → Near-White
  static const LinearGradient bgGradient = LinearGradient(
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
    colors: [
      Color(0xFFFFF5F0),
      Color(0xFFFFF0F3),
      Color(0xFFFFFBF8),
    ],
  );

  /// Dark mode: Rich pink-wine depths
  static const LinearGradient vibrantDarkGradient = LinearGradient(
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
    colors: [Color(0xFF28141C), Color(0xFF331822), Color(0xFF1B0A11)],
  );

  /// Primary CTA: Rose Coral → Warm Berry
  static const LinearGradient brandGradient = LinearGradient(
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
    colors: [roseCoralPrimary, berryPrimary],
  );

  /// Warm peach highlight gradient
  static const LinearGradient peachGradient = LinearGradient(
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
    colors: [roseCoralLight, peachAccent],
  );

  /// Subtle card gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
    colors: [Color(0xFFFFEEF2), Color(0xFFFFF5F0)],
  );

  static BoxDecoration getBackgroundDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: isDark ? vibrantDarkGradient : bgGradient,
    );
  }

  static BoxDecoration getGlassDecoration(
    BuildContext context, {
    double radius  = 24,
    double opacity = 0.10,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return glassDecoration(
      radius:      radius,
      isDark:      isDark,
      opacity:     isDark ? opacity * 0.8 : opacity,
      showBorder:  true,
      borderColor: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : roseCoralPrimary.withValues(alpha: 0.18),
    );
  }

  // ── Cycle Phase Colors ────────────────────────────────────────────────────
  static const Map<String, Color> phaseColors = {
    'Menstrual'  : Color(0xFFE84050), // Crimson Red
    'Follicular' : Color(0xFF29B6C4), // Teal-Cyan
    'Ovulation'  : Color(0xFF9B6FFF), // Violet
    'Luteal'     : Color(0xFFFF9547), // Amber Orange
  };

  static const Map<String, Color> hormoneColors = {
    'Estrogen'     : Color(0xFFE8446A),
    'Progesterone' : Color(0xFF9B6FFF),
    'LH'           : Color(0xFF29B6C4),
    'FSH'          : Color(0xFF4CAF70),
  };

  static Color phaseColor(String phase) => phaseColors[phase] ?? roseCoralPrimary;

  static Color getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:  return phaseColors['Menstrual']!;
      case CyclePhase.follicular: return phaseColors['Follicular']!;
      case CyclePhase.ovulation:  return phaseColors['Ovulation']!;
      case CyclePhase.luteal:     return phaseColors['Luteal']!;
      case CyclePhase.unknown:    return roseCoralPrimary;
    }
  }

  // ── Spacing System (Consigolidated to 8-pt Grid) ───────────────────────────
  // Note: New code should prefer AppDesignTokens.space* directly.
  static const double spacingXs   = AppDesignTokens.space4;
  static const double spacingSm   = AppDesignTokens.space8;
  static const double spacingMd   = AppDesignTokens.space16;
  static const double spacingLg   = AppDesignTokens.space24;
  static const double spacingXl   = AppDesignTokens.space32;
  static const double spacingXxl  = AppDesignTokens.space48;
  static const double spacingHuge = AppDesignTokens.space64;

  static BoxDecoration loginContainerDecoration({bool isDark = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin:  Alignment.topLeft,
        end:    Alignment.bottomRight,
        colors: isDark
            ? [darkBackground, darkSurface]
            : [roseCoralPrimary.withValues(alpha: 0.04), Colors.white],
      ),
      borderRadius: BorderRadius.circular(32),
      boxShadow: neuShadows(isDark: isDark),
    );
  }

  // ── Responsive Helpers ────────────────────────────────────────────────────
  static double screenWidth(BuildContext context)  => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static bool   isSmallScreen(BuildContext context) => screenWidth(context) < 360;

  static double clamp(double min, double val, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }

  static double adaptiveFontSize(BuildContext context, double baseSize) {
    final preferred = baseSize * (screenWidth(context) / 375);
    return clamp(baseSize * 0.85, preferred, baseSize * 1.2);
  }

  @Deprecated('Use adaptiveFontSize for modern scaling')
  static double responsiveFontSize(BuildContext context, double baseSize) =>
      adaptiveFontSize(context, baseSize);

  static double scale(BuildContext context, double value) =>
      screenWidth(context) < 360 ? value * 0.8 : value;

  // ── Glass Design System ───────────────────────────────────────────────────
  static const double glassOpacity       = 0.12;
  static const double glassBlur          = 12.0;
  static const double glassBorderOpacity = 0.15;

  static BoxDecoration glassDecoration({
    double radius      = 24,
    double opacity     = glassOpacity,
    bool isDark        = false,
    Color? borderColor,
    bool showBorder    = true,
  }) {
    return BoxDecoration(
      color:        (isDark ? Colors.black : Colors.white).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(
              color: (borderColor ?? (isDark ? Colors.white : Colors.black))
                  .withValues(alpha: glassBorderOpacity),
              width: 1.0,
            )
          : null,
    );
  }

  static BoxDecoration premiumGlassDecoration({
    double radius  = 32,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      color:        Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: glassBorderOpacity),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color:        Colors.black.withValues(alpha: 0.08),
          blurRadius:   25,
          spreadRadius: 0,
          offset:       const Offset(0, 12),
        ),
      ],
    );
  }

  // ── Typography ────────────────────────────────────────────────────────────
  static TextStyle playfair({
    BuildContext?  context,
    double         fontSize    = 32,
    FontWeight     fontWeight  = FontWeight.w700,
    Color?         color,
    double?        letterSpacing,
    double?        height,
  }) {
    final resolvedSize = context != null ? adaptiveFontSize(context, fontSize) : fontSize;
    final resolvedColor = context != null
        ? (color ?? Theme.of(context).colorScheme.onSurface)
        : (color ?? textDark);
    return GoogleFonts.playfairDisplay(
      fontSize:      resolvedSize,
      fontWeight:    fontWeight,
      color:         resolvedColor,
      letterSpacing: letterSpacing,
      height:        height,
    );
  }

  static TextStyle outfit({
    BuildContext?  context,
    double         fontSize    = 16,
    FontWeight     fontWeight  = FontWeight.w500,
    Color?         color,
    double?        letterSpacing,
    double?        height,
  }) {
    final resolvedSize = context != null ? adaptiveFontSize(context, fontSize) : fontSize;
    final resolvedColor = context != null
        ? (color ?? Theme.of(context).colorScheme.onSurface)
        : (color ?? textDark);
    return GoogleFonts.outfit(
      fontSize:      resolvedSize,
      fontWeight:    fontWeight,
      color:         resolvedColor,
      letterSpacing: letterSpacing,
      height:        height,
    );
  }

  static TextTheme textTheme(BuildContext context) => Theme.of(context).textTheme;

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3:            true,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary:   roseCoralPrimary,
        secondary: berryPrimary,
        surface:   lightSurface,
        onSurface: lightOnSurface,
        onPrimary: Colors.white,
        error:     Color(0xFFE53935),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize:      26,
          fontWeight:    FontWeight.w900,
          color:         textDark,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize:   22,
          fontWeight: FontWeight.w800,
          color:      textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize:   18,
          fontWeight: FontWeight.w700,
          color:      textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize:   16,
          fontWeight: FontWeight.w500,
          color:      textDark,
          height:     1.5,
        ),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        labelSmall: GoogleFonts.inter(
          fontSize:      12,
          fontWeight:    FontWeight.w800,
          color:         textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      primaryColor:          roseCoralPrimary,
      primaryColorLight:     roseCoralSoft,
      primaryColorDark:      roseCoralDark,
      canvasColor:           lightSurface,
      shadowColor:           shadowDark,
      tabBarTheme:           const TabBarThemeData(indicatorColor: roseCoralPrimary),
      splashFactory:         InkRipple.splashFactory,
      unselectedWidgetColor: textSecondary,
      disabledColor:         textSecondary.withValues(alpha: 0.5),
      dialogTheme:           const DialogThemeData(backgroundColor: lightSurface),
      dividerColor:          shadowMid.withValues(alpha: 0.2),
      cardTheme: CardThemeData(
        color:       lightSurface,
        elevation:   4,
        shape:       RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(24),
                      ),
        shadowColor: shadowDark.withValues(alpha: 0.2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:    Colors.transparent,
        elevation:          0,
        centerTitle:        true,
        titleTextStyle: GoogleFonts.poppins(
          color:      textDark,
          fontSize:   20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme:          const IconThemeData(color: textDark),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary:   roseCoralLight,
        secondary: berryLight,
        surface:   darkSurface,
        onSurface: darkOnSurface,
        onPrimary: darkBackground,
        error:     Color(0xFFFF5252),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize:      26,
          fontWeight:    FontWeight.w900,
          color:         darkOnSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize:   22,
          fontWeight: FontWeight.w800,
          color:      darkOnSurface,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize:   18,
          fontWeight: FontWeight.w700,
          color:      darkOnSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize:   16,
          fontWeight: FontWeight.w500,
          color:      darkOnSurface,
          height:     1.5,
        ),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFBB8FA0)),
        labelSmall: GoogleFonts.inter(
          fontSize:      12,
          fontWeight:    FontWeight.w800,
          color:         const Color(0xFFBB8FA0),
          letterSpacing: 0.5,
        ),
      ),
      primaryColor:      roseCoralLight,
      primaryColorLight: roseCoralDark,
      primaryColorDark:  berryDark,
      canvasColor:       darkSurface,
      shadowColor:       const Color(0xFF0D0308),
      tabBarTheme:       const TabBarThemeData(indicatorColor: roseCoralLight),
      dividerColor:      const Color(0xFF4A2535).withValues(alpha: 0.2),
      cardTheme: CardThemeData(
        color:     const Color(0xFF2D1822),
        elevation: 0,
        shape:     RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(24),
                   ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:    Colors.transparent,
        elevation:          0,
        centerTitle:        true,
        titleTextStyle: GoogleFonts.poppins(
          color:      darkOnSurface,
          fontSize:   20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme:          const IconThemeData(color: darkOnSurface),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  // ── Helper Methods ────────────────────────────────────────────────────────
  static List<BoxShadow> neuShadows({
    bool isDark = false,
    bool isPressed = false,
  }) {
    if (isPressed) {
      return [
        BoxShadow(
          color:
              isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : roseCoralPrimary.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(1, 1),
        ),
      ];
    }

    if (isDark) {
      // Dark Mode Pink Neumorphism: Deep wine shadows + Rose glow lift
      return [
        BoxShadow(
          color: const Color(0xFF12060B).withValues(alpha: 0.6),
          blurRadius: 10,
          offset: const Offset(5, 5),
        ),
        BoxShadow(
          color: const Color(0xFF3D222E).withValues(alpha: 0.4),
          blurRadius: 10,
          offset: const Offset(-5, -5),
        ),
      ];
    }
    
    // Light Mode shadows: derivation from surface color for realism
    // Background surface is #FFF5F0 (Warm Ivory)
    const surfaceTint = Color(0xFFE8D5DC); // Dynamic sink color
    return [
      BoxShadow(
        color: surfaceTint.withValues(alpha: 0.7),
        blurRadius: 10,
        offset: const Offset(4, 4),
      ),
      const BoxShadow(
        color: Colors.white,
        blurRadius: 10,
        offset: Offset(-4, -4),
      ),
    ];
  }

  static double h1(BuildContext context)        => adaptiveFontSize(context, 26);
  static double h2(BuildContext context)        => adaptiveFontSize(context, 22);
  static double h3(BuildContext context)        => adaptiveFontSize(context, 18);
  static double bodySize(BuildContext context)  => adaptiveFontSize(context, 16);
  static double labelSize(BuildContext context) => adaptiveFontSize(context, 12);
  static double body(BuildContext context)      => bodySize(context);
  static double label(BuildContext context)     => labelSize(context);

  static ({String headline}) phaseTip(String phase) {
    switch (phase) {
      case 'Menstrual':  return (headline: 'Rest and Rejuvenate');
      case 'Follicular': return (headline: 'Plan and Initiate');
      case 'Ovulation':  return (headline: 'Connect and Express');
      case 'Luteal':     return (headline: 'Analyze and Complete');
      default:           return (headline: 'Balance and Listen');
    }
  }

  static ({List<String> exercise, List<String> diet, List<String> nutrients})
  getPhaseHealthTips(String phase) {
    switch (phase) {
      case 'Menstrual':
        return (
          exercise:  ['Gentle Yoga', 'Light Walking', 'Symptom Relief Stretches'],
          diet:      ['Warm Herbal Soups', 'Magnesium-Rich Oats', 'Ginger Tea'],
          nutrients: ['Iron (rebuild)', 'Magnesium (cramps)', 'Vitamin C'],
        );
      case 'Follicular':
        return (
          exercise:  ['Light Cardio', 'Creative Movement', 'Power Walking'],
          diet:      ['Fermented Salads', 'Sprouted Grains', 'Lean Proteins'],
          nutrients: ['Zinc (hormone balance)', 'Vitamin B12', 'Vitamin E'],
        );
      case 'Ovulation':
        return (
          exercise:  ['HIIT Sessions', 'High Intensity Cardio', 'Social Workouts'],
          diet:      ['Rainbow Salads', 'Cold Berries', 'Anti-inflammatory Crucifers'],
          nutrients: ['Folate (cell health)', 'Amino Acids', 'Vitamin B'],
        );
      case 'Luteal':
        return (
          exercise:  ['Steady-state Pilates', 'Mindful Resistance', 'Long Stretches'],
          diet:      ['Complex Root Veggies', 'Dark Chocolate (70%+)', 'Omega Fats'],
          nutrients: ['Vitamin B6 (mood)', 'Magnesium (sleep)', 'Omega-3'],
        );
      default:
        return (
          exercise:  ['Listen to your pulse'],
          diet:      ['Mindful nutrition'],
          nutrients: ['Essential Multivitamin'],
        );
    }
  }

  static List<String> getPhaseSymptoms(String phase) {
    switch (phase) {
      case 'Menstrual':  return ['Cramps', 'Fatigue', 'Low Back Pain'];
      case 'Follicular': return ['Rising Energy', 'Optimism', 'Focus'];
      case 'Ovulation':  return ['High Libido', 'Mild Cramp', 'Energy\u2191'];
      case 'Luteal':     return ['Bloating', 'Mood Swings', 'Sensitivity'];
      default:           return ['Varies'];
    }
  }

  // ── Theme Accessors ──
  static Color onSurface(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  static Color primaryColor(BuildContext context) => Theme.of(context).colorScheme.primary;
  static Color surface(BuildContext context) => Theme.of(context).colorScheme.surface;
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

}

// ── Text Theme Extensions ─────────────────────────────────────────────────────
extension CustomTextTheme on TextTheme {
  TextStyle get headline => GoogleFonts.poppins(
    fontSize:      32,
    fontWeight:    FontWeight.bold,
    letterSpacing: -0.5,
  );

  TextStyle get subheadline => GoogleFonts.poppins(
    fontSize:      24,
    fontWeight:    FontWeight.w700,
    letterSpacing: -0.2,
  );

  TextStyle get bodySemiBold =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  TextStyle get body    => GoogleFonts.inter(fontSize: 14, height: 1.5);

  TextStyle get caption => GoogleFonts.inter(
    fontSize:      12,
    color:         AppTheme.textSecondary,
    letterSpacing: 0.2,
  );
}

// ── Phase Color Extension ─────────────────────────────────────────────────────
extension PhaseColors on ColorScheme {
  Color phaseColor(String phase) {
    switch (phase) {
      case 'Menstrual' || 'Period':
        return primary;
      case 'Follicular':
        return secondary;
      case 'Ovulation' || 'Ovulatory':
        return brightness == Brightness.light
            ? const Color(0xFF9B6FFF)
            : const Color(0xFFB98CFF);
      case 'Luteal':
        return primary.withValues(alpha: 0.7);
      default:
        return primary;
    }
  }
}

// ── Theme Access Extensions ──────────────────────────────────────────────────
extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Quick access to common semantic colors
  Color get primary => colorScheme.primary;
  Color get secondary => colorScheme.secondary;
  Color get surface => colorScheme.surface;
  Color get onSurface => colorScheme.onSurface;
  Color get error => colorScheme.error;
  Color get accent => AppTheme.accent;

  Color get secondaryText    => isDarkMode ? const Color(0xFFD4A5B5) : AppTheme.textSecondary;
  Color get transparentPink => AppTheme.roseCoralPrimary.withValues(alpha: 0.1);

  double screenWidth([BuildContext? context]) => MediaQuery.of(context ?? this).size.width;
}
