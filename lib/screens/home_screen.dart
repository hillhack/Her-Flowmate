import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/info_widgets.dart';
import '../widgets/neu_container.dart';
import '../widgets/skeleton_widgets.dart';
import '../widgets/cycle_widgets.dart';
import '../widgets/home/cycle_core_ring.dart';
import '../widgets/home/insight_bubble.dart';
import '../widgets/home/water_intake_card.dart';
import '../widgets/home/wellness_stats.dart';
import '../widgets/home/body_insight_card.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/home/predictive_chips.dart';
import '../widgets/pregnancy_dashboard.dart';
import 'wellness_reminders_screen.dart';
import 'log_period_screen.dart';
import '../widgets/home/daily_insight_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  bool _isLocalLoading = true;

  // ───── Under the Hood Expansion States ─────
  bool _isHormonesExpanded = false;
  bool _isWaterExpanded = false;
  bool _isSleepExpanded = false;
  bool _isStreakExpanded = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeInfo();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _isLocalLoading = false);
        }
      });
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

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final pred = context.watch<PredictionService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(decoration: AppTheme.getBackgroundDecoration(context)),

          _buildDreamyBackground(),

          RefreshIndicator(
            color: AppTheme.accentPink,
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 100),
                child: Column(
                  children: [
                    _buildTopRow(context, storage),
                    const SizedBox(height: 32),
                    GreetingSection(storage: storage),
                    const SizedBox(height: 32),
                    if (_isLocalLoading)
                      _buildSkeletonDashboard()
                    else if (storage.userGoal == 'pregnant')
                      PregnancyDashboard(storage: storage)
                    else if (storage.userGoal == 'conceive')
                      _buildTTCDashboard(storage, pred)
                    else
                      _buildModernBentoDashboard(context, storage, pred),

                    const SizedBox(height: 24),
                    _buildMedicalDisclaimer(),
                  ],
                ),
              ),
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppTheme.accentPink,
                AppTheme.accentPurple,
                Colors.blueAccent,
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
        Builder(
          builder:
              (context) => GlassContainer(
                radius: 18,
                padding: const EdgeInsets.all(10),
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(
                  Icons.menu_rounded,
                  color: AppTheme.textDark,
                  size: 26,
                ),
              ),
        ),
        _buildCurrentModeBadge(storage),
      ],
    );
  }

  Widget _buildCurrentModeBadge(StorageService storage) {
    final mode = storage.userGoal;
    String modeLabel =
        mode == 'conceive'
            ? 'Conceive'
            : (mode == 'pregnant' ? 'Pregnancy' : 'Period Tracking');

    return GlassContainer(
      radius: 20,
      onTap: () => _showModeSelectionSheet(context, storage),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_rounded,
            color: AppTheme.accentPink,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            modeLabel,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showModeSelectionSheet(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modeOption(
                  context,
                  storage,
                  'track_cycle',
                  'Period Tracking',
                  Icons.calendar_today_rounded,
                  storage.userGoal == 'track_cycle',
                ),
                const SizedBox(height: 12),
                _modeOption(
                  context,
                  storage,
                  'conceive',
                  'Conceive',
                  Icons.favorite_rounded,
                  storage.userGoal == 'conceive',
                ),
                const SizedBox(height: 12),
                _modeOption(
                  context,
                  storage,
                  'pregnant',
                  'Pregnancy',
                  Icons.pregnant_woman_rounded,
                  storage.userGoal == 'pregnant',
                ),
              ],
            ),
          ),
    );
  }

  Widget _modeOption(
    BuildContext context,
    StorageService storage,
    String goal,
    String title,
    IconData icon,
    bool isSelected,
  ) {
    return GlassContainer(
      radius: 16,
      onTap: () {
        storage.updateUserGoal(goal);
        Navigator.pop(context);
        setState(() {});
      },
      padding: const EdgeInsets.all(16),
      borderColor: isSelected ? AppTheme.accentPink : Colors.white24,
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.accentPink : AppTheme.textSecondary,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: AppTheme.accentPink),
        ],
      ),
    );
  }

  Widget _buildTTCDashboard(StorageService storage, PredictionService pred) {
    return Column(
      children: [
        PredictiveChips(pred: pred),
        const SizedBox(height: 24),
        _buildWellnessGoalsCard(context, storage),
      ],
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
      children: [
        CycleCoreRing(pred: pred)
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.9, 0.9)),
        const SizedBox(height: 24),
        DailyInsightCard(
          pred: pred,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        _buildInsightBubbles(),
        const SizedBox(height: 24),

        if (_isHormonesExpanded)
          ...[
            HormoneGraph(pred: pred),
            const SizedBox(height: 16),
            PhaseHealthTipsWidget(pred: pred),
            const SizedBox(height: 16),
          ].animate().fadeIn().slideY(begin: -0.05),

        if (_isWaterExpanded)
          WaterIntakeCard(
            storage: storage,
            onGoalReached: () => _confettiController.play(),
          ).animate().fadeIn().slideY(begin: -0.05),

        if (_isSleepExpanded)
          SleepCard(
            storage: storage,
            pred: pred,
          ).animate().fadeIn().slideY(begin: -0.05),

        if (_isStreakExpanded)
          StreakCard(
            storage: storage,
            onMilestoneReached: () => _confettiController.play(),
          ).animate().fadeIn().slideY(begin: -0.05),

        const SizedBox(height: 16),
        BodyInsightCard(pred: pred),
        const SizedBox(height: 24),
        _buildWellnessGoalsCard(context, storage),
      ],
    );
  }

  Widget _buildInsightBubbles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InsightBubble(
          icon: '🧪',
          label: 'Hormones',
          color: AppTheme.accentPurple,
          isExpanded: _isHormonesExpanded,
          onTap:
              () => setState(() => _isHormonesExpanded = !_isHormonesExpanded),
        ),
        InsightBubble(
          icon: '💧',
          label: 'Water',
          color: Colors.blueAccent,
          isExpanded: _isWaterExpanded,
          onTap: () => setState(() => _isWaterExpanded = !_isWaterExpanded),
        ),
        InsightBubble(
          icon: '🌙',
          label: 'Sleep',
          color: const Color(0xFF66BB6A),
          isExpanded: _isSleepExpanded,
          onTap: () => setState(() => _isSleepExpanded = !_isSleepExpanded),
        ),
        InsightBubble(
          icon: '🔥',
          label: 'Streak',
          color: AppTheme.accentPink,
          isExpanded: _isStreakExpanded,
          onTap: () => setState(() => _isStreakExpanded = !_isStreakExpanded),
        ),
      ],
    );
  }

  Widget _buildWellnessGoalsCard(BuildContext context, StorageService storage) {
    final upcoming = storage.getUpcomingAppointments();
    final hasGoals = upcoming.isNotEmpty;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      radius: 28,
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WellnessRemindersScreen()),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const Spacer(),
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
            Text(
              'Scheduled for ${DateFormat('MMM d').format(upcoming.first.date)}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ] else
            Text(
              'No upcoming goals. Tap to set a reminder!',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
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
          const SizedBox(height: 32),
          GlassContainer(
            onTap:
                () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const LogPeriodScreen(),
                ),
            radius: 20,
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

  Widget _buildSkeletonDashboard() {
    return const Column(
      children: [
        SkeletonCard(height: 180),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SkeletonCard(height: 140)),
            SizedBox(width: 12),
            Expanded(child: SkeletonCard(height: 140)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(flex: 2, child: SkeletonCard(height: 120)),
            SizedBox(width: 12),
            Expanded(flex: 3, child: SkeletonCard(height: 120)),
          ],
        ),
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
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalDisclaimer() {
    return Center(
      child: Text(
        'This is an estimate and should not be considered medical advice.',
        style: GoogleFonts.inter(
          fontSize: 10,
          color: AppTheme.textSecondary.withValues(alpha: 0.6),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
