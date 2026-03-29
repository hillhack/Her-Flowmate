import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/pregnancy_week_data.dart';
import '../utils/app_theme.dart';

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
    final activeColor = _trimesterColor(info.week);
    final progress = (1 - (info.daysLeft / 280)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, weekData, activeColor),
        const SizedBox(height: 16),
        _buildMilestoneHero(context, info, progress, activeColor),
        const SizedBox(height: 24),
        _buildWeeklySpotlight(weekData, activeColor),
        const SizedBox(height: 24),
        _buildHealthTracker(storage, activeColor),
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
                color: AppTheme.textDark,
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
          color: Colors.white,
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
    return Container(
      height: 240,
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
        padding: const EdgeInsets.all(28),
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
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${info.daysLeft} days left',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(info.dueDate),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
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
                  'Progress',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
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
  Widget _buildWeeklySpotlight(PregnancyWeekData data, Color color) {
    return Row(
      children: [
        Expanded(
          child: _spotlightCard(
            'Baby',
            data.milestone,
            color,
            'assets/images/baby_placeholder.png',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _spotlightCard(
            'Body',
            data.bodyUpdate,
            AppTheme.accentPurple,
            null,
          ),
        ),
      ],
    );
  }

  Widget _spotlightCard(
    String title,
    String text,
    Color color,
    String? imgPath,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (imgPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imgPath,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Icon(Icons.child_care, color: color, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- Health Tracker Row ---
  Widget _buildHealthTracker(StorageService storage, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metricTile(
            'Water',
            '${storage.getHydrationToday()}/15',
            Icons.water_drop,
            Colors.blueAccent,
          ),
          _metricTile(
            'Steps',
            '${storage.getStepsToday()}',
            Icons.directions_walk,
            Colors.orangeAccent,
          ),
          _metricTile(
            'Sleep',
            '${storage.getSleepHours()}h',
            Icons.bedtime,
            AppTheme.accentPurple,
          ),
          _metricTile(
            'Mood',
            storage.getMoodToday(),
            Icons.favorite,
            AppTheme.accentPink,
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String val, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 6),
        Text(
          val,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 7,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
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

  Color _trimesterColor(int week) {
    if (week <= 12) return AppTheme.accentPink;
    if (week <= 27) return AppTheme.accentPurple;
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
              backgroundColor: AppTheme.accentPink,
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
      backgroundColor: AppTheme.bgColor,
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
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Recalibrate your weeks based on your Last Period (LMP).',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showConceptionDatePicker(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
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
                      color: AppTheme.textSecondary,
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
