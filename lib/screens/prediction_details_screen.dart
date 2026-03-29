import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';

class PredictionDetailsScreen extends StatelessWidget {
  const PredictionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const GlassContainer(
            padding: EdgeInsets.all(8),
            radius: 12,
            child: Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cycle Phases',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildPhaseSection(
                'Menstrual Phase',
                'Day 1 - 5',
                'The uterus sheds its lining because pregnancy did not occur in the previous cycle. This marks the beginning of a new cycle.',
                'Low Estrogen & Progesterone',
                AppTheme.phaseColors['Menstrual']!,
              ),
              const SizedBox(height: 24),
              _buildPhaseSection(
                'Follicular Phase',
                'Day 6 - 13',
                'Your body prepares for ovulation. Ovaries develop follicles, and estrogen levels rise, thickening the uterine lining.',
                'Rising Estrogen',
                AppTheme.phaseColors['Follicular']!,
              ),
              const SizedBox(height: 24),
              _buildPhaseSection(
                'Ovulation Phase',
                'Day 14',
                'An egg is released from the ovary. It survives for 12-24 hours. This is the peak of fertility.',
                'Peak Estrogen & LH Surge',
                AppTheme.phaseColors['Ovulation']!,
              ),
              const SizedBox(height: 24),
              _buildPhaseSection(
                'Luteal Phase',
                'Day 15 - 28',
                'Progesterone increases to support a potential pregnancy. If fertilization doesn\'t occur, hormone levels drop, leading to the next period.',
                'High Progesterone',
                AppTheme.phaseColors['Luteal']!,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseSection(
    String name,
    String days,
    String description,
    String hormones,
    Color color,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(
                  Icons.biotech_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            days,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.accentPink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.waves_rounded, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hormone State',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        hormones,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }
}
