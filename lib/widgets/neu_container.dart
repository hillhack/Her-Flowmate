import 'package:flutter/material.dart' hide BoxShadow, BoxDecoration;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import '../utils/app_theme.dart';

enum NeuStyle { flat, convex, concave }

class NeuContainer extends StatefulWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final NeuStyle style;
  final double offset;
  final double blur;
  final Color? borderColor;
  final Gradient? gradient;

  const NeuContainer({
    super.key,
    required this.child,
    this.radius = 32.0,
    this.padding,
    this.margin,
    this.color = AppTheme.softPink,
    this.width,
    this.height,
    this.onTap,
    this.style = NeuStyle.flat,
    this.offset = 6.0,
    this.blur = 12.0,
    this.borderColor,
    this.gradient,
  });

  @override
  State<NeuContainer> createState() => _NeuContainerState();
}

class _NeuContainerState extends State<NeuContainer> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Specifically follow the design guide's shadow rules
    final bool isConcave = widget.style == NeuStyle.concave || _isPressed;

    // Enhanced design guide spec:
    // Outset: 8x8x16 #e3c7d6, -8x-8x16 #ffffff
    // Inset: 6x6x12 #e3c7d6, -6x-6x12 #ffffff
    // Enhanced: Multiple shadows for depth

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double currentOffset = isConcave ? 6.0 : widget.offset;
    final double currentBlur = isConcave ? 12.0 : widget.blur;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.gradient == null ? widget.color : null,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: (widget.borderColor ?? AppTheme.borderColor).withValues(
              alpha: isDark ? 0.1 : 0.3,
            ),
            width: 1.0,
          ),
          boxShadow:
              AppTheme.neuShadows(
                    isDark: isDark,
                    offset: currentOffset,
                    blur: currentBlur,
                  )
                  .map(
                    (s) => BoxShadow(
                      color: s.color,
                      offset: s.offset,
                      blurRadius: s.blurRadius,
                      inset: isConcave,
                    ),
                  )
                  .toList(),
        ),
        child: widget.child,
      ),
    );
  }
}
