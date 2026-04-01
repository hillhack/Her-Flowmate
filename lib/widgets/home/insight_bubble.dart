import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../glass_container.dart';

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
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: GlassContainer(
            width: 68,
            height: 68,
            radius: 34,
            padding: EdgeInsets.zero,
            opacity: isExpanded ? 0.25 : 0.1,
            borderColor:
                isExpanded ? color.withValues(alpha: 0.5) : Colors.white24,
            child: Center(
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 28,
                  shadows: [
                    if (isExpanded)
                      Shadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                  ],
                ),
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
            color: isExpanded ? AppTheme.textDark : AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
