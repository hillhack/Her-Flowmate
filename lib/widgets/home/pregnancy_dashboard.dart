import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../services/pregnancy_service.dart';
import '../../models/pregnancy_week_data.dart';
import '../../utils/app_theme.dart';
import '../../widgets/themed_container.dart';
import 'pregnancy_timeline_strip.dart';

class PregnancyDashboard extends StatelessWidget {
  final StorageService storage;
  const PregnancyDashboard({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final pregnancy = context.watch<PregnancyService>();
    final info = pregnancy.currentWeekData;

    if (pregnancy.conceptionDate == null) return _buildSetupCard(context);

    final week = pregnancy.currentWeek;
    final activeColor = _trimesterColor(context, week);
    final progress = pregnancy.progress;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, pregnancy.trimester, activeColor, pregnancy),
        const SizedBox(height: AppDesignTokens.space16),
        
        PregnancyTimelineStrip(
          currentWeek: week,
          onWeekSelected: (w) {
            // Future: Show info for selected week
          },
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: AppDesignTokens.space24),

        if (info != null)
          _buildPrimaryInsight(context, progress, activeColor, info),
        
        const SizedBox(height: AppDesignTokens.space24),
        _buildCallToAction(context, activeColor),
        const SizedBox(height: AppDesignTokens.space24),
        _buildRecentActivity(context, storage),
        const SizedBox(height: AppDesignTokens.space12),
      ],
    );
  }

  // --- Header ---
  Widget _buildHeader(
    BuildContext context,
    String trimester,
    Color color,
    PregnancyService service,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Journey',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            ThemedContainer(
              type: ContainerType.simple,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              radius: 12,
              color: color.withValues(alpha: 0.1),
              child: Text(
                trimester.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        ThemedContainer(
          type: ContainerType.neu,
          padding: EdgeInsets.zero,
          radius: 18,
          onTap: () => _showEditDatesDialog(context, service),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.edit_calendar_rounded, color: color, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryInsight(
    BuildContext context,
    double progress,
    Color color,
    PregnancyWeekData weekData,
  ) {
    return ThemedContainer(
      type: ContainerType.glass,
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.child_care_rounded, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                'Weekly Milestone',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(weekData.sizeEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekData.milestone,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tip: ${weekData.weeklyTip}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildCallToAction(BuildContext context, Color color) {
    return ThemedContainer(
      type: ContainerType.simple,
      height: 56,
      color: color,
      radius: 28,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Use the Check-In menu to log today\'s symptoms!'),
          ),
        );
      },
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            'Daily check-in',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  Widget _buildRecentActivity(BuildContext context, StorageService storage) {
    final logs = storage.getLogs();
    if (logs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Logged:',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            children: [
              Text(
                '• ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Yesterday',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                ' - Weight logged',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Color _trimesterColor(BuildContext context, int week) {
    final colorScheme = Theme.of(context).colorScheme;
    if (week <= 12) return colorScheme.primary;
    if (week <= 27) return colorScheme.secondary;
    return const Color(0xFF4DBBFF);
  }

  Widget _buildSetupCard(BuildContext context) {
    return ThemedContainer(
      type: ContainerType.glass,
      padding: const EdgeInsets.all(40),
      radius: 32,
      child: Column(
        children: [
          const Text('🤰', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Track Your Journey',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showConceptionDatePicker(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Setup Start Date (LMP)',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _showConceptionDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 14)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
      helpText: 'Select Start of Last Period (LMP)',
    );
    if (context.mounted && date != null) {
      await context.read<PregnancyService>().savePregnancyData(
        conceptionDate: date,
      );
    }
  }

  void _showEditDatesDialog(BuildContext context, PregnancyService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder:
          (_) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Journey',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Recalibrate your weeks based on your Last Period (LMP).',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showConceptionDatePicker(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Update Last Period (LMP)',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
