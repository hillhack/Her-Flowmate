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

  const NeuContainer({
    super.key,
    required this.child,
    this.radius = 32.0,
    this.padding,
    this.margin,
    this.color = AppTheme.bgColor,
    this.width,
    this.height,
    this.onTap,
    this.style = NeuStyle.flat,
    this.offset = 8.0,
    this.blur = 16.0,
    this.borderColor,
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

    // Design guide spec:
    // Outset: 8x8x16 #e3c7d6, -8x-8x16 #ffffff
    // Inset: 6x6x12 #e3c7d6, -6x-6x12 #ffffff

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
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
          border: widget.borderColor != null
              ? Border.all(color: widget.borderColor!, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              offset: Offset(-currentOffset, -currentOffset),
              blurRadius: currentBlur,
              inset: isConcave,
            ),
            BoxShadow(
              color: AppTheme.shadowDark,
              offset: Offset(currentOffset, currentOffset),
              blurRadius: currentBlur,
              inset: isConcave,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
