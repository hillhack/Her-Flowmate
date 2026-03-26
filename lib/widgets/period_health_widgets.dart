import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'neu_container.dart';

class PeriodHealthModal extends StatelessWidget {
  const PeriodHealthModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.frameColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: NeuContainer(
        radius: 40,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Period Health Insights',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Understand your cycle indicators',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                // Period Color Section
                _buildSectionTitle('🩸', 'Period Color'),
                const SizedBox(height: 16),
                NeuContainer(
                  radius: 28,
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/period_colour.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Clots Section
                _buildSectionTitle('🔬', 'Clots'),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Small clots (size of a penny or smaller) are usually normal and happen when the blood is shedding quickly. If you see large clots (larger than a quarter), it might be worth mentioning to your doctor.',
                ),
                const SizedBox(height: 32),

                // Pain Level Section
                _buildSectionTitle('📉', 'Pain Level'),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Mild cramping is common and can often be managed with heat or gentle movement. However, debilitating pain that prevents daily activities is not "normal" and should be discussed with a healthcare professional.',
                ),

                const SizedBox(height: 48),
                NeuContainer(
                  radius: 20,
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Close',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentPink,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String text) {
    return NeuContainer(
      radius: 24,
      padding: const EdgeInsets.all(20),
      style: NeuStyle.concave,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.6,
          color: AppTheme.textDark.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
