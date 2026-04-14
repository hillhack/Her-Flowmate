import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';

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
          icon: ThemedContainer(
            type: ContainerType.glass,
            padding: const EdgeInsets.all(8),
            radius: 12,
            child: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cycle Phases',
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface,
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
                context,
                'Menstrual Phase',
                'Day 1 - 5',
                'The uterus sheds its lining because pregnancy did not occur in the previous cycle. This marks the beginning of a new cycle.',
                'Low Estrogen & Progesterone',
                AppTheme.phaseColors['Menstrual']!,
                Icons.water_drop_rounded,
              ),
              const SizedBox(height: 24),
              _buildPhaseSection(
                context,
                'Follicular Phase',
                'Day 6 - 13',
                'Your body prepares for ovulation. Ovaries develop follicles, and estrogen levels rise, thickening the uterine lining.',
                'Rising Estrogen',
                AppTheme.phaseColors['Follicular']!,
                Icons.local_florist_rounded,
              ),
              const SizedBox(height: 24),
              _buildPhaseSection(
                context,
                'Ovulation Phase',
                'Day 14',
                'An egg is released from the ovary. It survives for 12-24 hours. This is the peak of fertility.',
                'Peak Estrogen & LH Surge',
                AppTheme.phaseColors['Ovulation']!,
                Icons.egg_alt_rounded,
              ),
              const SizedBox(height: 24),
              _buildPhaseSection(
                context,
                'Luteal Phase',
                'Day 15 - 28',
                'Progesterone increases to support a potential pregnancy. If fertilization doesn\'t occur, hormone levels drop, leading to the next period.',
                'High Progesterone',
                AppTheme.phaseColors['Luteal']!,
                Icons.nights_stay_rounded,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseSection(
    BuildContext context,
    String name,
    String days,
    String description,
    String hormones,
    Color color,
    IconData icon,
  ) {
    return ThemedContainer(
      type: ContainerType.glass,
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 20),
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
