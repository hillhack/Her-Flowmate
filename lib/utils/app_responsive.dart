import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppResponsive {
  static double pad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 12;
    if (w < 400) return 16;
    return 24;
  }

  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  static double font(BuildContext context, double base) =>
      AppTheme.adaptiveFontSize(context, base);
}
