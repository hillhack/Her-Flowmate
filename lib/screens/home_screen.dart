import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

import 'log_period_screen.dart';
import 'phase_details_screen.dart';
import 'prediction_details_screen.dart';
import 'timeline_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILDING HomeScreen...');
    final pred    = context.watch<PredictionService>();
    final storage = context.watch<StorageService>();

    final phaseName = pred.phaseDisplayName;
    final cycleDay    = pred.currentCycleDay.clamp(1, 999);
    final daysToNext  = pred.daysUntilNextPeriod;

    if (storage.userGoal == 'pregnant') {
      return Scaffold(
        backgroundColor: AppTheme.frameColor,
        body: Center(
          child: Text('Pregnancy Tracking coming soon! 🤰', 
            style: GoogleFonts.poppins(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      );
    }

    final hasLogs = storage.getLogs().isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // ── Greeting Section ────────────────────────────────────
            _GreetingSection(storage: storage),
            const SizedBox(height: 24),

            if (!hasLogs) ...[
              _buildNewUserContent(context, storage),
            ] else ...[
              // ── Primary Cycle Status (Large Card) ──────────────────
              _PhaseCard(
                phaseName: phaseName,
                subtitle: AppTheme.phaseTip(phaseName).headline,
                color: AppTheme.phaseColor(phaseName),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),
              
              // ── Cycle Summary (Side-by-Side Cards) ────────────────
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Cycle Day',
                      value: 'Day $cycleDay',
                      icon: Icons.calendar_today_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimelineScreen())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Next Period',
                      value: daysToNext >= 0 ? 'In $daysToNext days' : '${daysToNext.abs()}d late',
                      icon: Icons.water_drop_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictionDetailsScreen())),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              // ── Fertility Indicator (Optional) ────────────────────
              if (phaseName == 'Ovulation' || phaseName == 'Follicular') ...[
                const SizedBox(height: 16),
                _PhaseCard(
                  phaseName: 'Fertility Window',
                  subtitle: 'Peak Window Open',
                  color: AppTheme.phaseColors['Fertile']!,
                  icon: Icons.favorite_rounded,
                  isSecondary: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              ],
            ],

            const SizedBox(height: 120), // clear FAB + nav bar
          ],
        ),
      ),
    );
  }


  Widget _buildNewUserContent(BuildContext context, StorageService storage) {
    String title = 'Welcome, ${storage.userName}! 🌸';
    String body = 'Add your last period date to start tracking your cycle.';
    IconData icon = Icons.add_rounded;
    String btnLabel = 'Add Period Date';

    if (storage.userGoal == 'conceive') {
      title = 'Hi ${storage.userName}! 💕';
      body = 'Enter your last period date to estimate your fertile window and ovulation day.';
      icon = Icons.water_drop_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration:
          AppTheme.neuDecoration(radius: 28, color: AppTheme.frameColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 10),
          Text(body,
              style: GoogleFonts.inter(
                  fontSize: 15, color: AppTheme.textDark.withOpacity(0.6), height: 1.5)),
          const SizedBox(height: 24),
          _primaryButton(context,
              icon: icon,
              label: btnLabel,
              onTap: () => _showLogSheet(context)),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _primaryButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Container(
      decoration:
          AppTheme.neuDecoration(radius: 20, color: AppTheme.frameColor),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: AppTheme.accentPink),
        label: Text(label,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentPink)),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogPeriodScreen(),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final StorageService storage;
  const _GreetingSection({required this.storage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hi, ${storage.userName} 👋',
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
        const SizedBox(height: 4),
        Text('Hope you\'re feeling great today.',
            style: GoogleFonts.inter(
                fontSize: 15, color: AppTheme.textDark.withOpacity(0.6))),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final String phaseName, subtitle;
  final Color color;
  final IconData icon;
  final bool isSecondary;
  final VoidCallback? onTap;

  const _PhaseCard({
    required this.phaseName, required this.subtitle, required this.color,
    this.icon = Icons.auto_awesome_rounded,
    this.isSecondary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => PhaseDetailsScreen(phaseName: phaseName))),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.neuDecoration(radius: 32, color: AppTheme.frameColor),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isSecondary ? 'Status' : 'Current Phase',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark.withOpacity(0.5))),
                  const SizedBox(height: 2),
                  Text(phaseName,
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.shadowDark, size: 28),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.label, required this.value, required this.icon, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.neuDecoration(radius: 28, color: AppTheme.frameColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.accentPink, size: 22),
            const SizedBox(height: 16),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark.withOpacity(0.5))),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }
}

// Removed _DetailScreenStub as it is no longer used.
