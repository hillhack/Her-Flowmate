import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cycle_engine.dart';
// Re-export constants for backward compat with files that import app_theme.dart
export 'constants.dart';

abstract final class AppTheme {
  // ── Modern Pinkish Neumorphism Palette ─────────────────────────────────────
  // Primary Pink Shades
  static const Color primaryPink50 = Color(0xFFFFF1F5); // Softest pink
  static const Color primaryPink100 = Color(0xFFFFE0F0); // Very light pink
  static const Color primaryPink200 = Color(0xFFFFC1D6); // Light pink
  static const Color primaryPink300 = Color(0xFFFF9CBA); // Medium light pink
  static const Color primaryPink400 = Color(0xFFFF7BA4); // Medium pink
  static const Color primaryPink500 = Color(
    0xFFFF5D8C,
  ); // Vibrant pink (primary)
  static const Color primaryPink600 = Color(0xFFE64980); // Dark pink
  static const Color primaryPink700 = Color(0xFFC33774); // Very dark pink
  static const Color primaryPink800 = Color(0xFFA13668); // Deep pink
  static const Color primaryPink900 = Color(0xFF7D2B5C); // Deepest pink

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
          isDark ? Colors.white.withOpacity(0.1) : accentPink.withOpacity(0.2),
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

  // ── Spacing System (Consistent 8px Grid) ──────────────────────────────────
  static const double spacingXsmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXlarge = 32.0;
  static const double spacingXXlarge = 48.0;
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

  // Optimized Heading sizes for mobile
  static double h1(BuildContext context) => adaptiveFontSize(context, 26);
  static double h2(BuildContext context) => adaptiveFontSize(context, 22);
  static double h3(BuildContext context) => adaptiveFontSize(context, 18);
  static double body(BuildContext context) => adaptiveFontSize(context, 16);
  static double label(BuildContext context) => adaptiveFontSize(context, 12);

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

  // ── Modern Theme Definition ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        primary: accentColor,
        secondary: primaryPink600,
        surface: surfaceColor,
        onSurface: textDark,
        onPrimary: Colors.white,
        background: bgColor,
        onError: Colors.red,
        brightness: Brightness.light,
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
      // Enhanced theme colors
      primaryColor: accentColor,
      primaryColorLight: primaryPink200,
      primaryColorDark: primaryPink700,
      canvasColor: surfaceColor,
      shadowColor: shadowDarkColor,
      indicatorColor: accentColor,
      splashFactory: InkRipple.splashFactory,
      unselectedWidgetColor: textSecondary,
      disabledColor: textSecondary.withOpacity(0.5),
      dialogBackgroundColor: surfaceColor,
      dividerColor: shadowMidColor.withOpacity(0.2),
      focusColor: accentColor.withOpacity(0.2),
      hoverColor: accentColor.withOpacity(0.1),
      highlightColor: accentColor.withOpacity(0.2),
      splashColor: accentColor.withOpacity(0.2),
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: surfaceColor,
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: shadowMidColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: shadowMidColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: accentColor,
        disabledColor: textSecondary.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textTheme: ButtonTextTheme.primary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: accentColor,
        secondarySelectedColor: primaryPink200,
        disabledColor: textSecondary.withOpacity(0.2),
        labelStyle: TextStyle(color: textDark),
        secondaryLabelStyle: TextStyle(color: textDark),
        brightness: Brightness.light,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: StadiumBorder(),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: textDark,
        selectedColor: Colors.white,
        fillColor: accentColor,
        borderColor: shadowMidColor,
        selectedBorderColor: accentColor,
        disabledBorderColor: shadowMidColor,
        borderRadius: BorderRadius.circular(8),
        borderWidth: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentColor,
        inactiveTrackColor: shadowMidColor,
        disabledActiveTrackColor: shadowMidColor,
        disabledInactiveTrackColor: shadowMidColor,
        activeTickMarkColor: accentColor,
        inactiveTickMarkColor: shadowMidColor,
        disabledActiveTickMarkColor: shadowMidColor,
        disabledInactiveTickMarkColor: shadowMidColor,
        thumbColor: accentColor,
        overlappingShapeStrokeColor: Colors.white,
        overlayColor: accentColor.withOpacity(0.2),
        valueIndicatorColor: accentColor,
        minThumbSeparation: 24,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
        tickMarkShape: RoundSliderTickMarkShape(),
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        showValueIndicator: ShowValueIndicator.always,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(accentColor),
        trackColor: WidgetStateProperty.all(primaryPink100),
        overlayColor: WidgetStateProperty.all(accentColor.withOpacity(0.2)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(accentColor),
        overlayColor: MaterialStateProperty.all(accentColor.withOpacity(0.2)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(accentColor),
        checkColor: WidgetStateProperty.all(Colors.white),
        overlayColor: WidgetStateProperty.all(accentColor.withOpacity(0.2)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: TextStyle(color: textDark),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        unselectedLabelTextStyle: TextStyle(color: textSecondary),
        selectedLabelTextStyle: TextStyle(color: textDark),
        groupAlignment: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        modalBackgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        elevation: 8,
      ),
      tooltipTheme: TooltipThemeData(
        height: 32,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        margin: EdgeInsets.all(8),
        verticalOffset: -8,
        preferBelow: true,
        excludeFromSemantics: false,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: neuShadows(
            isDark: false, // Tooltip in light theme context
            offset: 4,
            blur: 8,
          ),
        ),
        textStyle: TextStyle(color: textDark),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        actionTextColor: accentColor,
        disabledActionTextColor: textSecondary,
        contentTextStyle: TextStyle(color: textDark),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        shadowColor: shadowDarkColor,
        elevation: 4,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        selectedIconTheme: IconThemeData(color: accentColor),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedItemColor: accentColor,
        unselectedItemColor: textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        toolbarTextStyle: TextStyle(color: textDark, fontSize: 16),
        iconTheme: IconThemeData(color: textDark),
        actionsIconTheme: IconThemeData(color: textDark),
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: surfaceColor,
          systemNavigationBarDividerColor: shadowMidColor,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
    );
  }

  // ── Dark Mode Colours ─────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF281635); // Vibrant Dark Pink-Purple
  static const Color darkSurface = Color(0xFF351C45); // Lighter Surface
  static const Color darkCard = Color(0xFF2E1C3E); // Card background
  static const Color darkTextPrimary = Color(0xFFF3E0EC); // Creamy off-white
  static const Color darkTextSecondary = Color(0xFFAA8FBB); // Muted lavender
  static const Color darkNeuLight = Color(0xFF452659); // Vibrant light shadow
  static const Color darkNeuDark = Color(0xFF1B0E23); // Deep shadow

  static const LinearGradient darkBgGradient = vibrantDarkGradient;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
        primary: accentColor,
        surface: darkSurface,
        onSurface: darkTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
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
