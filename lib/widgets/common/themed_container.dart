import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../glass_container.dart';
import '../neu_container.dart';

enum ContainerType { glass, neu }

class ThemedContainer extends StatelessWidget {
  final Widget child;
  final ContainerType type;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;

  const ThemedContainer({
    super.key,
    required this.child,
    this.type = ContainerType.neu,
    this.radius = 24.0,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (type == ContainerType.glass) {
      return GlassContainer(
        radius: radius,
        padding: padding,
        margin: margin,
        onTap: onTap,
        child: child,
      );
    }

    return NeuContainer(
      radius: radius,
      padding: padding,
      margin: margin,
      onTap: onTap,
      color: color ?? (isDark ? AppTheme.darkSurface : AppTheme.softPink),
      gradient: gradient,
      child: child,
    );
  }
}
