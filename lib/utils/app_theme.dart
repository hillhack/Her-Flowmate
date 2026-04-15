import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cycle_engine.dart';

// Re-export constants for backward compat
export 'constants.dart';
export 'app_responsive.dart';

enum ShadowSize { card, button, chip, pressed }

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

  // Border radii (Standardized)
  static const double radiusXS = 8;
  static const double radiusSM = 12; // Icon containers, chips
  static const double radiusMD = 16; // Buttons
  static const double radiusLG = 20; // Cards
  static const double radiusXL = 28; // Hero containers

  // Button dimensions
  static const double buttonHeight = 56.0;
  static const double buttonHPad = 24.0;
  static const double buttonVPad = 16.0;

  static List<BoxShadow> neuShadow(
    BuildContext context, {
    bool isPressed = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppTheme.neuShadows(isDark: isDark, isPressed: isPressed);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  🌸 MODERN PINK NEUMORPHISM DESIGN SYSTEM (2025)
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppTheme {
  // ── Surface & Base ────────────────────────────────────────────────────────
  static const Color neuBg = Color(0xFFF9EEF3); // Unified blush pink surface

  // ── Derived Shadows ───────────────────────────────────────────────────────
  static const Color neuShadowLight = Colors.white;
  static const Color neuShadowDark = Color(
    0xFFDBC5D0,
  ); // Mathematically derived

  // ── Accent Colors ─────────────────────────────────────────────────────────
  static const Color neuAccent = Color(0xFFD63384); // Primary vibrant pink
  static const Color neuAccentLight = Color(0xFFEC4899); // Gradient end
  static const Color neuAccentSoft = Color(0xFFF3B8D0); // Tinted icon circles

  // ── Text Palette ──────────────────────────────────────────────────────────
  static const Color neuTextPrimary = Color(0xFF4A2035); // Deep plum
  static const Color neuTextSecondary = Color(0xFF9E6882); // Muted rose
  static const Color neuTextMuted = Color(0xFFC4A0B4); // Placeholder/Hint

  // ── Semantic Semantic Palette (Backward Compat) ───────────────────────────
  static const Color primary = neuAccent;
  static const Color secondary = neuAccentLight;
  static const Color accent = neuAccentLight;

  static const Color lightSurface = neuBg;
  static const Color lightBackground = neuBg;
  static const Color lightOnSurface = neuTextPrimary;

  static const Color darkSurface = Color(0xFF2D1822);
  static const Color darkBackground = Color(0xFF231118);
  static const Color darkOnSurface = Color(0xFFFCEFF2);

  // ── Legacy Aliases (Consolidated to new palette) ─────────────────────────
  static const Color accentPink = neuAccent;
  static const Color primaryPink = neuAccent;
  static const Color accentPurple = Color(0xFFAD2D6B);
  static const Color frameColor = neuBg;
  static const Color midnightPlum = neuTextPrimary;
  static const Color darkCard = Color(0xFF341828);
  static const Color roseCoralPrimary = neuAccent;
  static const Color roseCoralLight = neuAccentLight;
  static const Color roseCoralDark = Color(0xFFC43059);
  static const Color roseCoralSoft = neuAccentSoft;
  static const Color textDark = neuTextPrimary;
  static const Color textSecondary = neuTextSecondary;
  static const Color berryPrimary = Color(0xFFAD2D6B);
  static const Color peachAccent = Color(0xFFFF8A70);
  static const Color bgColor = neuBg;
  static const Color shadowDark = neuShadowDark;
  static const Color primaryPink700 = Color(0xFFAD2D6B);
  static const Color primaryPink500 = neuAccent;
  static const Color primaryPink300 = neuAccentSoft;
  static const Color lightError = Color(0xFFE84050);
  static const Color roseCoralPale = Color(0xFFFFF0F5);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neuAccent, neuAccentLight],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neuBg, Color(0xFFFCF5F8), Color(0xFFF9EEF3)],
  );

  static BoxDecoration getBackgroundDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? darkBackground : neuBg,
      gradient: isDark ? null : bgGradient,
    );
  }

  // ── Neumorphic Shadow Engine ──────────────────────────────────────────────
  static List<BoxShadow> neuShadows({
    bool isDark = false,
    bool isPressed = false,
    ShadowSize size = ShadowSize.button,
  }) {
    if (isPressed) {
      return [
        BoxShadow(
          color: isDark ? Colors.black38 : neuShadowDark.withValues(alpha: 0.5),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
        BoxShadow(
          color:
              isDark ? Colors.white10 : neuShadowLight.withValues(alpha: 0.5),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ];
    }

    if (isDark) {
      return [
        BoxShadow(
          color: const Color(0xFF12060B).withValues(alpha: 0.8),
          blurRadius: 15,
          offset: const Offset(6, 6),
        ),
        BoxShadow(
          color: const Color(0xFF3D222E).withValues(alpha: 0.4),
          blurRadius: 15,
          offset: const Offset(-6, -6),
        ),
      ];
    }

    double blur, offsetVal;
    switch (size) {
      case ShadowSize.card:
        blur = 18;
        offsetVal = 8;
        break;
      case ShadowSize.button:
        blur = 12;
        offsetVal = 5;
        break;
      case ShadowSize.chip:
        blur = 8;
        offsetVal = 3;
        break;
      case ShadowSize.pressed:
        blur = 4;
        offsetVal = 2;
        break;
    }

    return [
      BoxShadow(
        color: neuShadowDark.withValues(alpha: 0.45),
        blurRadius: blur,
        offset: Offset(offsetVal, offsetVal),
      ),
      BoxShadow(
        color: neuShadowLight.withValues(alpha: 0.9),
        blurRadius: blur,
        offset: Offset(-offsetVal, -offsetVal),
      ),
    ];
  }

  // ── Neumorphic Decorations ───────────────────────────────────────────────
  static BoxDecoration neuCardDecoration({double? radius}) => BoxDecoration(
    color: neuBg,
    borderRadius: BorderRadius.circular(radius ?? AppDesignTokens.radiusLG),
    boxShadow: neuShadows(size: ShadowSize.card),
  );

  static BoxDecoration neuButtonDecoration({bool isPressed = false}) =>
      BoxDecoration(
        color: neuBg,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD),
        boxShadow: neuShadows(isPressed: isPressed, size: ShadowSize.button),
      );

  static BoxDecoration loginContainerDecoration({bool isDark = false}) =>
      BoxDecoration(
        color: isDark ? darkSurface : neuBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: neuShadows(isDark: isDark, size: ShadowSize.card),
      );

  // ── Cycle Themes ─────────────────────────────────────────────────────────
  static const Map<String, Color> phaseColors = {
    'Menstrual': Color(0xFFE84050),
    'Follicular': Color(0xFF29B6C4),
    'Ovulation': Color(0xFF9B6FFF),
    'Luteal': Color(0xFFFF9547),
  };

  static const Map<String, Color> hormoneColors = {
    'Estrogen': neuAccent,
    'Progesterone': Color(0xFF9B6FFF),
    'LH': Color(0xFF29B6C4),
    'FSH': Color(0xFF4CAF70),
  };

  static Color phaseColor(String phase) => phaseColors[phase] ?? neuAccent;

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
      default:
        return neuAccent;
    }
  }

  // ── Typography ────────────────────────────────────────────────────────────
  // BRAND ONLY: Playfair Display
  static TextStyle brandStyle({double fontSize = 32, Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color ?? neuTextPrimary,
      );

  // UI EVERYTHING: Poppins
  static TextStyle poppins({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? neuTextPrimary,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Backward-compat typography methods rebranded to Poppins
  static TextStyle playfair({
    // Used for legacy brand placements
    BuildContext? context,
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double? height,
  }) => poppins(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextStyle outfit({
    // Rebranded to Poppins for UI consistency
    BuildContext? context,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? letterSpacing,
    double? height,
  }) => poppins(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  // ── Theme Data ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: neuBg,
    colorScheme: const ColorScheme.light(
      primary: neuAccent,
      secondary: neuAccentLight,
      surface: neuBg,
      onSurface: neuTextPrimary,
      onPrimary: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: poppins(fontSize: 26, fontWeight: FontWeight.w700),
      bodyLarge: poppins(fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: poppins(fontSize: 14, color: neuTextSecondary),
    ),
  );

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: neuAccentLight,
      surface: darkSurface,
      onSurface: darkOnSurface,
    ),
  );

  // ── Deprecated Decorations (Use Neumorphic instead) ──────────────────────
  @Deprecated('Use neuCardDecoration or neuButtonDecoration')
  static BoxDecoration glassDecoration({
    double radius = 24,
    double opacity = 0.1,
    bool isDark = false,
    Color? borderColor,
    bool showBorder = true,
  }) => BoxDecoration(
    color: Colors.white.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(radius),
  );

  @Deprecated('Use neuCardDecoration')
  static BoxDecoration premiumGlassDecoration({
    double radius = 32,
    double opacity = 0.15,
  }) => BoxDecoration(
    color: Colors.white.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(radius),
  );

  // ── Backward Compat Constants ─────────────────────────────────────────────
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  static double adaptiveFontSize(BuildContext context, double baseSize) =>
      baseSize * (MediaQuery.of(context).size.width / 375).clamp(0.85, 1.2);

  // Legacy health tips placeholders to avoid breakages
  static ({List<String> exercise, List<String> diet, List<String> nutrients})
  getPhaseHealthTips(String phase) => (exercise: [], diet: [], nutrients: []);
  static List<String> getPhaseSymptoms(String phase) => ['Varies'];

  static String phaseTip(String phase) {
    switch (phase) {
      case 'Menstrual' || 'Period':
        return 'Prioritize rest and nourish your body.';
      case 'Follicular':
        return 'Time for new beginnings and energy.';
      case 'Ovulation':
        return 'You are at your most vibrant today.';
      case 'Luteal':
        return 'Slow down and practice self-care.';
      default:
        return 'Tune into your body\'s natural rhythm.';
    }
  }

  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;
}

// ── Extensions ──────────────────────────────────────────────────────────────
extension CustomTextTheme on TextTheme {
  TextStyle get headline =>
      GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold);
  TextStyle get subheadline =>
      GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold);
  TextStyle get bodySemiBold =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600);
  TextStyle get body => GoogleFonts.poppins(fontSize: 14, height: 1.5);
  TextStyle get caption =>
      GoogleFonts.poppins(fontSize: 12, color: AppTheme.neuTextSecondary);
}

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;
  Color get primary => theme.colorScheme.primary;
  Color get surface => theme.colorScheme.surface;
  Color get onSurface => theme.colorScheme.onSurface;
  Color get error => theme.colorScheme.error;
  Color get secondaryText =>
      isDarkMode ? const Color(0xFFD4A5B5) : AppTheme.neuTextSecondary;
  Color get secondary => theme.colorScheme.secondary;
  Color get accent => AppTheme.accent;
  Color get transparentPink => AppTheme.neuAccent.withValues(alpha: 0.1);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  double get screenWidth => MediaQuery.of(this).size.width;
}

extension PhaseColors on ColorScheme {
  Color phaseColor(String phase) {
    switch (phase) {
      case 'Menstrual' || 'Period':
        return AppTheme.neuAccent;
      case 'Follicular':
        return const Color(0xFF29B6C4);
      case 'Ovulation' || 'Ovulatory':
        return const Color(0xFF9B6FFF);
      case 'Luteal':
        return const Color(0xFFFF9547);
      default:
        return AppTheme.neuAccent;
    }
  }
}
