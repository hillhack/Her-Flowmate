import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wellness_reminders_screen.dart';
import '../models/appointment.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/info_widgets.dart';
import '../widgets/cycle_widgets.dart';
import '../widgets/neu_container.dart';
import '../widgets/glass_container.dart';
import '../widgets/pregnancy_dashboard.dart';
import '../models/daily_log.dart';
import 'log_period_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  // ───── Confetti guard ─────
  // Prevents confetti from firing on every rebuild when the streak happens
  // to be a multiple of 7.  Once the confetti has been shown for the current
  // milestone it is suppressed until the streak value changes.
  int? _lastConfettiMilestone;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeInfo();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkFirstTimeInfo() {
    final storage = context.read<StorageService>();
    if (!storage.hasSeenInfoPopup && storage.getLogs().isNotEmpty) {
      showGlassInfoPopup(
        context,
        title: 'Welcome to Your Dashboard 🌸',
        explanation:
            'The home dashboard is designed to be minimal. You can tap the ⓘ icons on any card to learn more about your current cycle metrics.',
        tip: 'Tapping a card directly will take you to its detailed breakdown.',
      );
      storage.markInfoPopupAsSeen();
    }
  }

  /// Fires confetti *once* when the streak hits a 7‑day milestone and the
  /// milestone has not already been celebrated in the current session.
  void _maybeFireConfetti(int streak) {
    if (streak <= 0) return;
    final isMilestone = streak % 7 == 0;
    if (!isMilestone) {
      // Streak is no longer a milestone — reset so confetti can fire again
      // when the user hits the next one.
      _lastConfettiMilestone = null;
      return;
    }
    // Already showed confetti for this milestone this session.
    if (_lastConfettiMilestone == streak) return;

    _lastConfettiMilestone = streak;
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final pred = context.watch<PredictionService>();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          ),
          _buildDreamyBackground(),
          SafeArea(
            bottom: false,
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final hPad = (screenWidth * 0.05).clamp(16.0, 24.0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: _buildTopRow(context, storage),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.accentPink,
                        backgroundColor: AppTheme.bgColor,
                        onRefresh: () async => setState(() {}),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _GreetingSection(storage: storage),
                              const SizedBox(height: 12),
                              if (storage.userGoal == 'pregnant')
                                _buildPregnancyDashboard(context, storage)
                              else if (storage.userGoal == 'conceive')
                                _buildTTCDashboard(context, storage)
                              else
                                _buildModernBentoDashboard(
                                  context,
                                  storage,
                                  pred,
                                ),
                              const SizedBox(height: 16),
                              _buildInsightCarousel(context),
                              const SizedBox(height: 16),
                              _buildMedicalDisclaimer(),
                              const SizedBox(height: 88),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Confetti overlay at the top center
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Straight down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.2,
              colors: const [
                AppTheme.accentPink,
                AppTheme.accentPurple,
                Colors.blueAccent,
                Colors.amber,
                Colors.tealAccent,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, StorageService storage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sidebar Menu Button
        Builder(
          builder:
              (context) => NeuContainer(
                radius: 18,
                padding: const EdgeInsets.all(10),
                style: NeuStyle.convex,
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: const Icon(
                  Icons.menu_rounded,
                  color: AppTheme.textDark,
                  size: 26,
                ),
              ),
        ),

        // Mode Badge
        _buildCurrentModeBadge(storage),
      ],
    );
  }

  Widget _buildDreamyBackground() {
    return Stack(
      children: [
        _buildGlowBlob(
          top: -100,
          right: -50,
          size: 300,
          color: AppTheme.accentPink.withValues(alpha: 0.12),
        ),
        _buildGlowBlob(
          bottom: 200,
          left: -100,
          size: 400,
          color: AppTheme.accentPurple.withValues(alpha: 0.08),
        ),
        _buildGlowBlob(
          top: 300,
          right: -80,
          size: 250,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        // Removed FloatingSparkles for Web Stability
      ],
    );
  }

  Widget _buildGlowBlob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 60, spreadRadius: 30),
          ],
        ),
      ), // Removed active scaling animation for performance
    );
  }

  Widget _buildCurrentModeBadge(StorageService storage) {
    final mode = storage.userGoal;
    String modeLabel = 'Period Tracking';
    if (mode == 'conceive') modeLabel = 'Conceive';
    if (mode == 'pregnant') modeLabel = 'Pregnancy';

    return NeuContainer(
      radius: 20,
      onTap: () => _showModeSelectionSheet(context, storage),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppTheme.accentPink,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            modeLabel,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showModeSelectionSheet(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            decoration: const BoxDecoration(
              color: AppTheme.bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Switch Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your current health goal',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _modeOption(
                    context,
                    storage,
                    'track_cycle',
                    'Period Tracking',
                    'Track your cycle and symptoms',
                    Icons.calendar_today_rounded,
                    storage.userGoal == 'track_cycle',
                  ),
                  const SizedBox(height: 12),
                  _modeOption(
                    context,
                    storage,
                    'conceive',
                    'Conceive',
                    'Identify your most fertile days',
                    Icons.favorite_rounded,
                    storage.userGoal == 'conceive',
                  ),
                  const SizedBox(height: 12),
                  _modeOption(
                    context,
                    storage,
                    'pregnant',
                    'Pregnancy',
                    'Track your baby\'s development',
                    Icons.pregnant_woman_rounded,
                    storage.userGoal == 'pregnant',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
    );
  }

  Widget _modeOption(
    BuildContext context,
    StorageService storage,
    String goal,
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
  ) {
    return NeuContainer(
      radius: 20,
      onTap: () {
        storage.updateUserGoal(goal);
        Navigator.pop(context);
        setState(() {}); // Rebuild home screen with new mode dashboard
      },
      padding: const EdgeInsets.all(16),
      borderColor:
          isSelected
              ? AppTheme.accentPink.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppTheme.accentPink.withValues(alpha: 0.1)
                      : AppTheme.textSecondary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? AppTheme.accentPink : AppTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.accentPink,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildModernBentoDashboard(
    BuildContext context,
    StorageService storage,
    PredictionService pred,
  ) {
    if (storage.getLogs().isEmpty) {
      return _buildNewUserContent(context, storage);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFloralRingDashboard(context, pred)
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.9, 0.9)),
        const SizedBox(height: 24),
        _buildYourBodyTodayCard(
          context,
          pred,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 16),
        _buildBentoWaterCard(
          storage,
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 12),
        // ── Sleep & Streak row ─────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSleepCard(
                storage,
                pred,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStreakCard(
                context,
                storage,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
            ),
          ],
        ),
        const SizedBox(height: 20),
        HormoneGraph(
          pred: pred,
        ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),
        PhaseHealthTipsWidget(
          pred: pred,
        ).animate().fadeIn(delay: 900.ms, duration: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 24),
        _buildWellnessGoalsCard(
          context,
          storage,
        ).animate().fadeIn(delay: 1000.ms, duration: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildSleepCard(StorageService storage, PredictionService pred) {
    final sleepHours = storage.getSleepHours();
    final hasData = sleepHours != null;
    final phase = pred.phaseDisplayName;

    final sleepTips = {
      'Menstrual': 'Rest extra — your body rebuilds tonight.',
      'Follicular': 'Energy rising — 7–8h keeps you sharp.',
      'Ovulation': 'You\'re peaking — protect quality sleep!',
      'Luteal': 'Progesterone dips — magnesium helps.',
    };
    final tip = sleepTips[phase] ?? 'Aim for 7–9h for hormonal balance.';

    String quality = '—';
    Color qualityColor = AppTheme.textSecondary;
    if (hasData) {
      if (sleepHours >= AppConstants.greatSleepHours) {
        quality = 'Great';
        qualityColor = const Color(0xFF66BB6A);
      } else if (sleepHours >= AppConstants.okSleepHours) {
        quality = 'Ok';
        qualityColor = const Color(0xFFFFB347);
      } else {
        quality = 'Low';
        qualityColor = const Color(0xFFFF686B);
      }
    }

    return NeuContainer(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Sleep',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: hasData ? sleepHours.toStringAsFixed(1) : '—',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                if (hasData)
                  TextSpan(
                    text: 'h',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (hasData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: qualityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quality,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: qualityColor,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            tip,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (!hasData) ...[
            const SizedBox(height: 6),
            Text(
              'Log in daily check-in ✏️',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.accentPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, StorageService storage) {
    final streak = storage.getCheckinStreak();

    // Use a guard to prevent confetti from firing on every rebuild.
    _maybeFireConfetti(streak);

    String streakLabel;
    Color streakColor;
    String emoji;
    if (streak >= AppConstants.streakMilestones.last) {
      streakLabel = 'Legend!';
      streakColor = const Color(0xFFD481FF);
      emoji = '🏆';
    } else if (streak >= AppConstants.streakMilestones[1]) {
      streakLabel = 'On fire!';
      streakColor = const Color(0xFFFF9800);
      emoji = '🔥';
    } else if (streak >= AppConstants.streakMilestones.first) {
      streakLabel = '1 week!';
      streakColor = const Color(0xFF66BB6A);
      emoji = '⭐';
    } else if (streak >= 1) {
      streakLabel = 'Keep it up';
      streakColor = AppTheme.accentPink;
      emoji = '✨';
    } else {
      streakLabel = 'Start today';
      streakColor = AppTheme.textSecondary;
      emoji = '📅';
    }

    return NeuContainer(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Streak',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$streak',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: streakColor,
                  ),
                ),
                TextSpan(
                  text: ' days',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: streakColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              streakLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: streakColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            streak == 0
                ? 'Log your check-in daily to start a streak!'
                : 'Next milestone: ${streak < 7
                    ? 7 - streak
                    : streak < 14
                    ? 14 - streak
                    : 30 - streak} days away',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Your Body Today - Magazine Style Insight Card
  Widget _buildYourBodyTodayCard(BuildContext context, PredictionService pred) {
    final phaseName = pred.phaseDisplayName;
    final day = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final biology = pred.getPhaseBiology(day);
    final phaseColor = AppTheme.getPhaseColor(pred.currentPhase);

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.accentPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'YOUR BODY TODAY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  phaseName.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: phaseColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _insightRow(
            '🧪',
            'HORMONES',
            biology['hormoneActivity'] ?? '',
            AppTheme.accentPurple,
          ),
          const Divider(height: 32, thickness: 0.5),
          _insightRow(
            '⚡',
            'ENERGY',
            biology['energy'] ?? '',
            Colors.orangeAccent,
          ),
          const Divider(height: 32, thickness: 0.5),
          _insightRow('🧘', 'MOOD', biology['mood'] ?? '', AppTheme.accentPink),
        ],
      ),
    );
  }

  Widget _insightRow(String icon, String label, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoWaterCard(StorageService storage) {
    final log = storage.getDailyLog(DateTime.now());
    final water = log?.waterIntake ?? 0;
    final goal = storage.hydrationGoal;

    return NeuContainer(
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showGlassInfoPopup(
                    context,
                    title: 'Hydration Tracking 💧',
                    explanation:
                        'Staying hydrated during your cycle helps reduce cramps, bloating, and fatigue.',
                    tip:
                        'Try reaching your 15-glass goal every day to maintain a healthy streak!',
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HYDRATION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Larger hit-targets (44×44) per accessibility guidelines
              Row(
                children: [
                  NeuContainer(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _removeWater(storage);
                    },
                    width: 44,
                    height: 44,
                    radius: 14,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.remove_rounded,
                      color: Colors.blueAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  NeuContainer(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _addWater(storage);
                    },
                    width: 44,
                    height: 44,
                    radius: 14,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.blueAccent,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Glass markers row (dynamic based on goal)
          Row(
            children: List.generate(goal, (i) {
              final filled = i < water;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 2),
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        filled
                            ? Colors.blueAccent
                            : Colors.blueAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '$water / ${storage.hydrationGoal} glasses',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildInsightCarousel(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.60).clamp(160.0, 220.0);
    final pred = context.watch<PredictionService>();
    final phase = pred.currentPhase.displayName;

    // Phase-aware insights
    final Map<String, List<Map<String, String>>> phaseInsights = {
      'Menstruation': [
        {
          'title': 'Rest & Restore',
          'sub': 'Light stretching eases cramps',
          'icon': '🛌',
        },
        {
          'title': 'Iron Foods',
          'sub': 'Spinach & lentils replenish iron',
          'icon': '🥬',
        },
        {
          'title': 'Heat Therapy',
          'sub': 'Warm compress relieves pain',
          'icon': '🌡️',
        },
        {
          'title': 'Magnesium',
          'sub': 'Dark chocolate reduces cramping',
          'icon': '🍫',
        },
      ],
      'Follicular': [
        {
          'title': 'Energy Rising',
          'sub': 'Great time for new workouts',
          'icon': '⚡',
        },
        {
          'title': 'Brain Power',
          'sub': 'Estrogen boosts focus & memory',
          'icon': '🧠',
        },
        {'title': 'Protein Up', 'sub': 'Fuel your active phase', 'icon': '🥚'},
        {
          'title': 'Social Time',
          'sub': 'You\'re at your most outgoing',
          'icon': '🌸',
        },
      ],
      'Ovulation': [
        {
          'title': 'Peak Fertility',
          'sub': 'Highest conception window now',
          'icon': '🌟',
        },
        {
          'title': 'High Energy',
          'sub': 'HIIT and strength training ideal',
          'icon': '💪',
        },
        {
          'title': 'Zinc Rich',
          'sub': 'Seeds & eggs support ovulation',
          'icon': '🌻',
        },
        {
          'title': 'Stay Hydrated',
          'sub': 'Cervical fluid needs water',
          'icon': '💧',
        },
      ],
      'Luteal': [
        {'title': 'PMS Support', 'sub': 'B6 reduces mood swings', 'icon': '🌿'},
        {
          'title': 'Slow Down',
          'sub': 'Yoga & walking suit this phase',
          'icon': '🧘‍♀️',
        },
        {
          'title': 'Sleep First',
          'sub': 'Progesterone disrupts sleep',
          'icon': '🌙',
        },
        {
          'title': 'Cravings OK',
          'sub': 'Magnesium cuts chocolate cravings',
          'icon': '🍵',
        },
      ],
    };

    final insights =
        phaseInsights[phase] ??
        [
          {
            'title': 'Track Your Cycle',
            'sub': 'Log a period to see insights',
            'icon': '🌸',
          },
          {
            'title': 'Stay Hydrated',
            'sub': 'Drink 8 glasses daily',
            'icon': '💧',
          },
          {
            'title': 'Rest Well',
            'sub': '8h sleep for hormonal balance',
            'icon': '🌙',
          },
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Today\'s Insights',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: insights.length,
            itemBuilder: (context, i) {
              return Container(
                width: cardWidth,
                margin: const EdgeInsets.only(right: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  radius: 24,
                  child: Row(
                    children: [
                      Text(
                        insights[i]['icon']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insights[i]['title']!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.midnightPlum,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              insights[i]['sub']!,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (i * 200).ms).slideX(begin: 0.2);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTTCDashboard(BuildContext context, StorageService storage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TTCDashboard(storage: storage),
        const SizedBox(height: 24),
        _buildWellnessGoalsCard(context, storage),
      ],
    );
  }

  Widget _buildPregnancyDashboard(
    BuildContext context,
    StorageService storage,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PregnancyDashboard(storage: storage),
        const SizedBox(height: 12),
        _buildWellnessGoalsCard(context, storage),
      ],
    );
  }

  Widget _buildNewUserContent(BuildContext context, StorageService storage) {
    return NeuContainer(
      padding: const EdgeInsets.all(32),
      radius: 40,
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppTheme.accentPink,
            size: 48,
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to start?',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Log your first period to see your cycle predictions and insights.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          NeuContainer(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LogPeriodScreen(),
              );
            },
            radius: 20,
            style: NeuStyle.convex,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Log First Period',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentPink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalDisclaimer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'This is an estimate based on cycle patterns and should not be considered medical advice.',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _addWater(StorageService storage) async {
    debugPrint('HomeScreen: _addWater called');
    final now = DateTime.now();
    final log = storage.getDailyLog(now) ?? DailyLog(date: now, waterIntake: 0);
    final goal = storage.hydrationGoal;
    final newWater = ((log.waterIntake ?? 0) + 1).clamp(0, goal);

    // Check for celebration milestone
    if (newWater == goal && (log.waterIntake ?? 0) < goal) {
      _confettiController.play();
      if (mounted) {
        showGlassInfoPopup(
          context,
          title: 'Hydration Goal Met! 💧',
          explanation:
              'Amazing! You successfully reached $goal glasses of water today.',
          tip:
              'You are maintaining a great hydration streak. Your body thanks you!',
        );
      }
    }

    final updatedLog = DailyLog(
      date: log.date,
      moods: log.moods,
      symptoms: log.symptoms,
      waterIntake: newWater,
      notes: log.notes,
      flowIntensity: log.flowIntensity,
      physicalActivity: log.physicalActivity,
    );

    debugPrint('HomeScreen: Saving waterIntake = ${updatedLog.waterIntake}');
    await storage.saveDailyLog(updatedLog);
    if (mounted) setState(() {});
  }

  Future<void> _removeWater(StorageService storage) async {
    debugPrint('HomeScreen: _removeWater called');
    final now = DateTime.now();
    final log = storage.getDailyLog(now);
    if (log == null) return;

    final goal = storage.hydrationGoal;
    final updatedLog = DailyLog(
      date: log.date,
      moods: log.moods,
      symptoms: log.symptoms,
      waterIntake: ((log.waterIntake ?? 0) - 1).clamp(0, goal),
      notes: log.notes,
      flowIntensity: log.flowIntensity,
      physicalActivity: log.physicalActivity,
    );

    debugPrint('HomeScreen: Saving waterIntake = ${updatedLog.waterIntake}');
    await storage.saveDailyLog(updatedLog);
    if (mounted) setState(() {});
  }

  Widget _buildFloralRingDashboard(
    BuildContext context,
    PredictionService pred,
  ) {
    final phaseName = pred.phaseDisplayName;
    final day = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLen = pred.averageCycleLength;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on screen width
    final ringSize = (screenWidth * 0.55).clamp(160.0, 240.0);
    final innerSize = ringSize * 0.77; // ~170/220 ratio
    final glowSize = ringSize * 0.64; // ~140/220 ratio
    final outerRing = ringSize * 0.95; // ~210/220 ratio

    return Column(
      children: [
        // Center: Glowing Ring
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft Glow Effect
              Container(
                width: glowSize,
                height: glowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.phaseColor(
                        phaseName,
                      ).withValues(alpha: 0.25),
                      blurRadius: ringSize * 0.18,
                      spreadRadius: ringSize * 0.04,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: outerRing,
                height: outerRing,
                child: CustomPaint(
                  painter: _CycleRingPainter(
                    progress: day / (cycleLen == 0 ? 28 : cycleLen),
                    activeColor: AppTheme.phaseColor(phaseName),
                    trackColor: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
              NeuContainer(
                onTap: () {
                  final biology = pred.getPhaseBiology(day);
                  final phase = pred.phaseDisplayName;
                  final symptoms = AppTheme.getPhaseSymptoms(phase);

                  showGlassInfoPopup(
                    context,
                    title: '$phase Phase',
                    explanation:
                        '${biology['hormoneActivity']}\n\n${biology['energy']}\n\n${biology['mood']}',
                    tip: 'Common symptoms: ${symptoms.join(", ")}',
                  );
                },
                width: innerSize,
                height: innerSize,
                radius: innerSize / 2,
                style: NeuStyle.convex,
                borderColor: Colors.white.withValues(alpha: 0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        phaseName.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: (ringSize * 0.073).clamp(12.0, 16.0),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.phaseColor(phaseName),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Day $day / $cycleLen',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: (ringSize * 0.064).clamp(11.0, 14.0),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPredictiveMessage(pred),
      ],
    );
  }

  Widget _buildPredictiveMessage(PredictionService pred) {
    final chance = pred.currentConceptionChance;
    final daysToPeriod = pred.daysUntilNextPeriod;
    final daysToOvulation = pred.daysUntilOvulation;
    final nextPeriod = pred.nextPeriodDate;
    final avgLen = pred.averageCycleLength;
    final nextOvulation = pred.currentPeriodStart?.add(
      Duration(days: avgLen - 14),
    );

    final chips = <_ChipData>[];

    chips.add(
      _ChipData(
        icon: Icons.favorite_rounded,
        label: 'Conception $chance%',
        color: AppTheme.accentPink,
        explanation: 'Your current estimated chance of conception is $chance%.',
        tip:
            chance > 20
                ? 'You are in or approaching your fertile window.'
                : 'Chances are currently low based on your cycle day.',
      ),
    );

    if (nextOvulation != null) {
      chips.add(
        _ChipData(
          icon: Icons.wb_sunny_rounded,
          label: 'Ovulation in ${daysToOvulation}d',
          color: AppTheme.accentPurple,
          explanation:
              'Ovulation is estimated to occur in $daysToOvulation days.',
          tip: 'This is usually your highest phase of energy and fertility.',
        ),
      );
    }

    if (nextPeriod != null) {
      chips.add(
        _ChipData(
          icon: Icons.calendar_today_rounded,
          label: 'Period in ${daysToPeriod}d',
          color: AppTheme.textSecondary,
          explanation:
              'Your next period is predicted to start in $daysToPeriod days.',
          tip: 'Log any PMS symptoms to improve future predictions.',
        ),
      );
    }

    if (daysToOvulation > 0 && daysToOvulation <= 5) {
      final peakIn = (daysToOvulation - 1).clamp(0, 5);
      chips.add(
        _ChipData(
          icon: Icons.auto_awesome_rounded,
          label: peakIn == 0 ? 'Peak today!' : 'Peak in ${peakIn}d',
          color: AppTheme.accentPink,
          explanation: 'Your fertility peak is very close.',
          tip:
              'Track your basal body temperature and cervical mucus for higher accuracy.',
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = chips[i];
          return GestureDetector(
            onTap:
                () => showGlassInfoPopup(
                  context,
                  title: c.label,
                  explanation: c.explanation,
                  tip: c.tip,
                ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.color.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c.icon, size: 13, color: c.color),
                  const SizedBox(width: 6),
                  Text(
                    c.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWellnessGoalsCard(BuildContext context, StorageService storage) {
    final upcoming = storage.getUpcomingAppointments();
    final hasGoals = upcoming.isNotEmpty;

    return NeuContainer(
      padding: const EdgeInsets.all(24),
      radius: 28,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WellnessRemindersScreen()),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.spa_rounded,
                    color: AppTheme.accentPink,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'WELLNESS GOALS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (hasGoals) ...[
            Text(
              upcoming.first.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    upcoming.first.category.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentPink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Scheduled for ${DateFormat('MMM d').format(upcoming.first.date)}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'No upcoming goals. Tap to set a wellness reminder!',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final StorageService storage;
  const _GreetingSection({required this.storage});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    String emoji = '☀️';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '🌤️';
    } else if (hour >= 17 || hour < 5) {
      greeting = 'Good Evening';
      emoji = '🌙';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$emoji $greeting, ',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${storage.userName.split(' ').first}!',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.midnightPlum,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.05);
  }
}

class TTCDashboard extends StatelessWidget {
  final StorageService storage;

  const TTCDashboard({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();
    final nextOvulation =
        pred.nextPeriodDate?.subtract(const Duration(days: 14)) ??
        DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFertilityCard(pred, title: 'TTC Focus: Fertility Window'),
        const SizedBox(height: 24),
        NeuContainer(
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Ovulation',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM d').format(nextOvulation),
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.wb_sunny_rounded,
                color: Colors.orangeAccent,
                size: 28,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildFertilityCard(
    PredictionService pred, {
    String title = 'FERTILITY STATUS',
  }) {
    final chance = pred.currentConceptionChance;
    return NeuContainer(
      padding: const EdgeInsets.all(32),
      radius: 40,
      style: NeuStyle.convex,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chance > 50
                        ? 'High probability today'
                        : 'Low probability today',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.spa_rounded,
                color: AppTheme.phaseColor(
                  pred.phaseDisplayName,
                ).withValues(alpha: 0.6),
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (chance / 100).clamp(0.05, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.phaseColor(pred.phaseDisplayName),
              ),
              minHeight: 10,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 100.ms),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _CycleRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // 1. Draw Track
    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // 2. Prepare Gradient & Paint for Active Arc
    final sweepAngle = 2 * 3.14159265359 * progress;

    // Outer Glow (More Vibrant)
    final shadowPaint =
        Paint()
          ..color = activeColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2,
      sweepAngle,
      false,
      shadowPaint,
    );

    final activePaint =
        Paint()
          ..shader = SweepGradient(
            colors: [
              activeColor.withValues(alpha: 0.4),
              activeColor,
              activeColor,
            ],
            stops: const [0.0, 0.5, 1.0],
            transform: const GradientRotation(-3.14159265359 / 2),
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2, // Start at top
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor;
  }
}

/// Lightweight data holder for the predictive chip strip.
class _ChipData {
  final IconData icon;
  final String label;
  final Color color;
  final String explanation;
  final String tip;

  const _ChipData({
    required this.icon,
    required this.label,
    required this.color,
    required this.explanation,
    required this.tip,
  });
}
