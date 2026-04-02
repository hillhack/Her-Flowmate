import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/themed_container.dart';

class PhaseDetailsScreen extends StatelessWidget {
  final String phaseName;

  const PhaseDetailsScreen({super.key, required this.phaseName});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.phaseColor(phaseName);
    final details = _getPhaseDetails(phaseName);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const ThemedContainer(
              type: ContainerType.glass,
              radius: 12,
              padding: EdgeInsets.zero,
              child: Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
            ),
          ),
        ),
        title: Text(
          'Phase Details',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                ThemedContainer(
                  type: ContainerType.glass,
                  radius: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const SparkleEffect(
                            trigger: true,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          phaseName,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          details.oneLiner,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Description
                _buildSectionTitle('What\'s happening?'),
                const SizedBox(height: 12),
                Text(
                  details.description,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textDark.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Tips
                _buildSectionTitle('Self-Care Tips'),
                const SizedBox(height: 16),
                ...details.tips.map((tip) => _buildTipItem(tip, color)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }

  Widget _buildTipItem(String tip, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ThemedContainer(
        type: ContainerType.glass,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  tip,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textDark.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1);
  }

  _PhaseInfo _getPhaseDetails(String phase) {
    switch (phase) {
      case 'Menstrual':
        return _PhaseInfo(
          oneLiner: 'Time for Reset and Reflection',
          description:
              'Your cycle begins on the first day of your period. Progesterone and estrogen levels are at their lowest, which can lead to lower energy levels. Your body is working hard to shed its lining.',
          tips: [
            'Prioritize rest and gentle movement like light yoga.',
            'Stay warm and hydrated with herbal teas.',
            'Focus on iron-rich foods like spinach and lean proteins.',
            'Use a heating pad for comfort if experiencing cramps.',
          ],
        );
      case 'Follicular':
        return _PhaseInfo(
          oneLiner: 'Energy and Creativity Peak',
          description:
              'Estrogen levels begin to rise as your body prepares to release an egg. This is often when you feel most vibrant, focused, and ready to take on new challenges.',
          tips: [
            'Try high-intensity workouts or new fitness classes.',
            'Great time for creative projects or social planning.',
            'Include probiotic-rich foods to support hormone metabolism.',
            'Stay socially active and embrace your rising energy.',
          ],
        );
      case 'Ovulation':
        return _PhaseInfo(
          oneLiner: 'The Height of Your Cycle',
          description:
              'The release of an egg marks your peak fertility. Libido is often higher, and you may feel extra confident and social. This is a short but powerful phase.',
          tips: [
            'Connect with others; your communication skills are peaking.',
            'Support liver health with leafy greens and cruciferous vegetables.',
            'Notice your body\'s signals like changes in temperature or fluid.',
            'Stay hydrated to support metabolic processes.',
          ],
        );
      case 'Luteal':
        return _PhaseInfo(
          oneLiner: 'Turning Inward and Slowing Down',
          description:
              'Progesterone rises, making you feel more relaxed but potentially more sensitive. Towards the end of this phase, you might notice PMS symptoms as hormones prepare to drop.',
          tips: [
            'Opt for strength training or steady-pace cardio.',
            'Increase complex carbohydrates like sweet potatoes to stabilize mood.',
            'Practice mindfulness and prioritize early bedtimes.',
            'Cut back on caffeine to help reduce pre-period anxiety.',
          ],
        );
      default:
        return _PhaseInfo(
          oneLiner: 'Understand Your Rhythm',
          description:
              'Tracking your cycle helps you live in harmony with your natural biological fluctuations.',
          tips: [
            'Keep logging your symptoms every day.',
            'Notice patterns across different months.',
            'Be patient with yourself as your energy shifts.',
          ],
        );
    }
  }
}

class _PhaseInfo {
  final String oneLiner, description;
  final List<String> tips;
  _PhaseInfo({
    required this.oneLiner,
    required this.description,
    required this.tips,
  });
}
