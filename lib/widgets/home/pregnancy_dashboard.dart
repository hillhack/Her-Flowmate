import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../models/pregnancy_week_data.dart';

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
        _buildMilestoneHero(context, info, progress, activeColor),
        const SizedBox(height: 24),
        _buildWeeklySpotlight(context, weekData, activeColor),
        const SizedBox(height: 24),
        _buildHealthTracker(context, storage, activeColor),
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

  // --- Hero Milestone ---
  Widget _buildMilestoneHero(
    BuildContext context,
    _PregnancyInfo info,
    double progress,
    Color color,
  ) {
    final weekData = getPregnancyWeekData(info.week);

    return Container(
      height: 280, // Increased height to accommodate baby size
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.9), color],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEK',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      info.week.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 62,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Day ${info.day}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
                // Baby Size Visualization
                Column(
                  children: [
                    Text(
                      weekData.sizeEmoji,
                      style: const TextStyle(fontSize: 48),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.bounceOut,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size of a',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      weekData.sizeName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${info.daysLeft} days until due date',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  // --- Weekly Spotlight ---
  Widget _buildWeeklySpotlight(
    BuildContext context,
    PregnancyWeekData data,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _spotlightCard(
                context,
                'Baby Development',
                data.milestone,
                color,
                Icons.child_care_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _spotlightCard(
                context,
                'Your Body',
                data.bodyUpdate,
                Theme.of(context).colorScheme.secondary,
                Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _wideSpotlightCard(
          context,
          'Weekly Tip',
          data.weeklyTip,
          Theme.of(context).colorScheme.primary,
          Icons.tips_and_updates_rounded,
        ),
        const SizedBox(height: 12),
        _wideSpotlightCard(
          context,
          'Nutrition Focus',
          'Key Nutrients: ${data.nutritionFocus}',
          const Color(0xFF4CAF50),
          Icons.restaurant_rounded,
        ),
      ],
    );
  }

  Widget _spotlightCard(
    BuildContext context,
    String title,
    String text,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideSpotlightCard(
    BuildContext context,
    String title,
    String text,
    Color color,
    IconData icon,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Health Tracker Row ---
  Widget _buildHealthTracker(
    BuildContext context,
    StorageService storage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metricTile(
            context,
            'Water',
            '${storage.getHydrationToday()}/15',
            Icons.water_drop,
            Colors.blueAccent,
          ),
          _metricTile(
            context,
            'Steps',
            '${storage.getStepsToday()}',
            Icons.directions_walk,
            Colors.orangeAccent,
          ),
          _metricTile(
            context,
            'Sleep',
            '${storage.getSleepHours()}h',
            Icons.bedtime,
            Theme.of(context).colorScheme.secondary,
          ),
          _metricTile(
            context,
            'Mood',
            storage.getMoodToday(),
            Icons.favorite,
            Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _metricTile(
    BuildContext context,
    String label,
    String val,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Log your $label data in the Check-in menu! 📝'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
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
