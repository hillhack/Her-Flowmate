import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

void showPeriodColorGuide(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/period_colour.jpg',
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: AppTheme.frameColor,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.broken_image_rounded,
                          color: AppTheme.accentPink,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please save your uploaded image as\nassets/images/period_colour.jpg',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
  );
}
