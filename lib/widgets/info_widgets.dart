import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'glass_container.dart';

class GlassInfoButton extends StatelessWidget {
  final VoidCallback onTap;
  const GlassInfoButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(
          Icons.info_outline_rounded,
          color: AppTheme.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}

void showGlassInfoPopup(
  BuildContext context, {
  required String title,
  required String explanation,
  String? tip,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder:
        (context) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.frameColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          padding: const EdgeInsets.only(top: 16),
          child: GlassContainer(
            radius: 40,
            opacity: 0.05,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.shadowDark,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    explanation,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textDark,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (tip != null) ...[
                    const SizedBox(height: 24),
                    GlassContainer(
                      radius: 20,
                      opacity: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  GlassContainer(
                    radius: 20,
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Got it!',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentPink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
