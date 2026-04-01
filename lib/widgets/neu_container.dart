import 'package:flutter/material.dart';


enum NeuStyle { flat, concave, convex, embossed }

class NeuContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final NeuStyle style;
  final bool isSelected;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;

  const NeuContainer({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.style = NeuStyle.flat,
    this.isSelected = false,
    this.color,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(radius ?? 24);

    Widget container = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: gradient != null ? null : (color ?? theme.colorScheme.surface),
        gradient: gradient,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.3 : 0.1),
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.white,
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }

    return container;
  }
}
