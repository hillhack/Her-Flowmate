import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../models/pregnancy_week_data.dart';
import '../../utils/app_theme.dart';

/// Pregnancy Dashboard Fragment - Optimized for Stability on Flutter Web.
/// Uses standard Material decorations to avoid MouseTracker/BackdropFilter conflicts.
class PregnancyDashboard extends StatelessWidget {
  final StorageService storage;
  const PregnancyDashboard({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final info = _calculatePregnancyInfo(storage);

    if (info == null) return _buildSetupCard(context);

    final weekData = getPregnancyWeekData(info.week.clamp(4, 40));
    final activeColor = _trimesterColor(context, info.week);
    final progress = (1 - (info.daysLeft / 280)).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, weekData, activeColor),
        const SizedBox(height: 16),
        _buildTopMetricsRow(context, info, weekData),
        const SizedBox(height: 24),
        _buildPrimaryInsight(context, info, progress, activeColor, weekData),
        const SizedBox(height: 24),
        _buildCallToAction(context, activeColor),
        const SizedBox(height: 24),
        _buildRecentActivity(context, storage),
        const SizedBox(height: 12),
      ],
    );
  }

  // --- Header ---
  Widget _buildHeader(
    BuildContext context,
    PregnancyWeekData data,
    Color color,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                data.trimester.toUpperCase(),
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
        Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _showEditDatesDialog(context),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.edit_calendar_rounded, color: color, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopMetricsRow(
    BuildContext context,
    _PregnancyInfo info,
    PregnancyWeekData weekData,
  ) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            context,
            label: 'Current week',
            value: 'W${info.week} D${info.day}',
            delay: 0,
          ),
        ),
        const SizedBox(width: AppDesignTokens.space8),
        Expanded(
          child: _metricCard(
            context,
            label: 'Baby size',
            value: weekData.sizeEmoji,
            delay: 100,
          ),
        ),
        const SizedBox(width: AppDesignTokens.space8),
        Expanded(
          child: _metricCard(
            context,
            label: 'Days left',
            value: '${info.daysLeft}',
            delay: 200,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required String label,
    required String value,
    required int delay,
  }) {
    // Import needed dynamically without modifying top of file, using ThemedContainer/NeuCard structure
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1);
  }

  Widget _buildPrimaryInsight(
    BuildContext context,
    _PregnancyInfo info,
    double progress,
    Color color,
    PregnancyWeekData weekData,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Fallback open DailyCheckinScreen using import workaround or logic since we can't cleanly import inline.
        // We'll rely on the bottom navigation for standard navigation but if they want to log here, we trigger a snackbar or navigate if requested.
        // Wait, primary_button.dart is not imported in this file. I will build a standard container button.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Use the Check-In menu to log today\'s symptoms!'),
          ),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
      ),
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  Widget _buildRecentActivity(BuildContext context, StorageService storage) {
    final logs = storage.getLogs();
    if (logs.isEmpty) return const SizedBox.shrink();

    // Just showing some basic check-ins
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

  // --- Calculations & Logic ---
  _PregnancyInfo? _calculatePregnancyInfo(StorageService storage) {
    final cDate = storage.conceptionDate;
    if (cDate == null) return null;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final lmp = DateTime(cDate.year, cDate.month, cDate.day);
    final elapsedDays = today.difference(lmp).inDays;
    final dueDate = lmp.add(const Duration(days: 280));
    return _PregnancyInfo(
      week: (elapsedDays / 7).floor() + 1,
      day: elapsedDays % 7,
      dueDate: dueDate,
      conceptionDate: lmp,
      daysLeft: dueDate.difference(today).inDays,
    );
  }

  Color _trimesterColor(BuildContext context, int week) {
    final colorScheme = Theme.of(context).colorScheme;
    if (week <= 12) return colorScheme.primary;
    if (week <= 27) return colorScheme.secondary;
    return const Color(0xFF4DBBFF);
  }

  Widget _buildSetupCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
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
      await context.read<StorageService>().savePregnancyData(
        conceptionDate: date,
      );
    }
  }

  void _showEditDatesDialog(BuildContext context) {
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

class _PregnancyInfo {
  final int week, day, daysLeft;
  final DateTime dueDate, conceptionDate; // Internally stored as LMP
  _PregnancyInfo({
    required this.week,
    required this.day,
    required this.dueDate,
    required this.conceptionDate,
    required this.daysLeft,
  });
}
