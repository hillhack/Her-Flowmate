import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'glass_container.dart';

class HerFramedButton extends StatelessWidget {
  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap;
  final Color? textColor;

  const HerFramedButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.onInfoTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: GlassContainer(
        radius: 50,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 12)],
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              if (onInfoTap != null)
                GestureDetector(
                  onTap: onInfoTap,
                  child: GlassContainer(
                    width: 28,
                    height: 28,
                    radius: 50,
                    opacity: 0.1,
                    child: Center(
                      child: Text(
                        'i',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
