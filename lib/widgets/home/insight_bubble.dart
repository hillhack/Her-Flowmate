import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themed_container.dart';

class InsightBubble extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;

  const InsightBubble({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ThemedContainer(
          type: ContainerType.glass,
          width: 68,
          height: 68,
          radius: 34,
          padding: EdgeInsets.zero,
          opacity: isExpanded ? 0.25 : 0.1,
          borderColor:
              isExpanded ? color.withValues(alpha: 0.5) : Colors.white24,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Center(
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 28,
                shadows: [
                  if (isExpanded)
                    Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isExpanded ? FontWeight.w900 : FontWeight.w700,
            color:
                isExpanded
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
