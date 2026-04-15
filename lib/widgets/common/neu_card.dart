import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_theme.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final double? borderRadius;
  final VoidCallback? onTap;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDesignTokens.space16),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.neuBg,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppDesignTokens.radiusLG,
        ),
        boxShadow: AppTheme.neuShadows(isDark: isDark, size: ShadowSize.card),
      ),
      child: child,
    );

    if (onTap != null) {
      return Semantics(
        button: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap!();
          },
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return content;
  }
}
