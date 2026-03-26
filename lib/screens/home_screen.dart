import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/info_widgets.dart';
import '../widgets/cycle_widgets.dart';
import '../widgets/neu_container.dart';
import 'log_period_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeInfo();
    });
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

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        ),
        _buildDreamyBackground(),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildTopRow(context, storage),
                const SizedBox(height: 24),
                _GreetingSection(storage: storage),
                const SizedBox(height: 40),

                if (storage.userGoal == 'pregnant')
                  _buildPregnancyDashboard(context, storage)
                else if (storage.userGoal == 'conceive')
                  _buildTTCDashboard(context, storage)
                else
                  _buildCycleDashboard(context, storage, pred),

                const SizedBox(height: 48),
                _buildMedicalDisclaimer(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopRow(BuildContext context, StorageService storage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sidebar Menu Button
        Builder(
          builder: (context) => NeuContainer(
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
          size: 250,
          color: AppTheme.accentPink.withOpacity(0.08),
        ),
        _buildGlowBlob(
          bottom: 100,
          left: -80,
          size: 300,
          color: AppTheme.accentPurple.withOpacity(0.05),
        ),
        _buildGlowBlob(
          top: 400,
          right: -120,
          size: 200,
          color: Colors.white.withOpacity(0.2),
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
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 100, spreadRadius: 50),
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
              color: AppTheme.accentPink.withOpacity(0.2),
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
            color: AppTheme.textSecondary.withOpacity(0.5),
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
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        decoration: BoxDecoration(
          color: AppTheme.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
      borderColor: isSelected
          ? AppTheme.accentPink.withOpacity(0.5)
          : Colors.white.withOpacity(0.5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentPink.withOpacity(0.1)
                  : AppTheme.textSecondary.withOpacity(0.05),
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

  Widget _buildCycleDashboard(
    BuildContext context,
    StorageService storage,
    PredictionService pred,
  ) {
    final hasLogs = storage.getLogs().isNotEmpty;

    if (!hasLogs) return _buildNewUserContent(context, storage);

    return Column(
      children: [
        _buildFloralRingDashboard(context, pred),
        const SizedBox(height: 48),
        _buildFertilityCard(pred),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hormone Trends',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            IconButton(
              onPressed: () => _showHormonePopup(context, pred),
              icon: NeuContainer(
                radius: 12,
                padding: const EdgeInsets.all(8),
                style: NeuStyle.convex,
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppTheme.accentPink,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        RepaintBoundary(
          child: HormoneGraph(
            pred: pred,
            showHeader: false,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ),
        const SizedBox(height: 24),
        HormoneFocusWidget(pred: pred),
        const SizedBox(height: 24),
        PhaseHealthTipsWidget(pred: pred),
      ],
    );
  }

  void _showHormonePopup(BuildContext context, PredictionService pred) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: HormoneGraph(pred: pred),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTTCDashboard(BuildContext context, StorageService storage) {
    final pred = context.watch<PredictionService>();
    final nextOvulation =
        pred.nextPeriodDate?.subtract(const Duration(days: 14)) ??
        DateTime.now();

    return Column(
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

  Widget _buildPregnancyDashboard(
    BuildContext context,
    StorageService storage,
  ) {
    final weeks = storage.pregnancyWeeks ?? 8;
    final dueDate =
        storage.dueDate ?? DateTime.now().add(const Duration(days: 220));
    final daysRemaining = dueDate.difference(DateTime.now()).inDays;

    String babySize = 'Raspberry';
    if (weeks >= 12) babySize = 'Lime';
    if (weeks >= 20) babySize = 'Banana';
    if (weeks >= 40) babySize = 'Watermelon';

    return Column(
      children: [
        NeuContainer(
          padding: const EdgeInsets.all(28),
          radius: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pregnancy Progress',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Week $weeks',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Icon(
                    Icons.pregnant_woman_rounded,
                    color: AppTheme.accentPink,
                    size: 40,
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        NeuContainer(
          padding: const EdgeInsets.all(28),
          radius: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Baby Size',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'About the size of a $babySize',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),
        NeuContainer(
          padding: const EdgeInsets.all(28),
          radius: 32,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weeks',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$weeks',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Vertical divider
              Container(
                width: 1.5,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Days Left',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$daysRemaining',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildFloralRingDashboard(
    BuildContext context,
    PredictionService pred,
  ) {
    final phaseName = pred.phaseDisplayName;
    final day = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLen = pred.averageCycleLength;

    return Center(
      child: SizedBox(
        width: 330,
        height: 330,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring Progress
            SizedBox(
              width: 320,
              height: 320,
              child: CustomPaint(
                painter: _CycleRingPainter(
                  progress: day / (cycleLen == 0 ? 28 : cycleLen),
                  activeColor: AppTheme.phaseColor(phaseName),
                  trackColor: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            // Inner Neumorphic Circle
            NeuContainer(
              width: 290,
              height: 290,
              radius: 145, // Perfect circle
              style: NeuStyle.convex,
              borderColor: Colors.white.withOpacity(0.5),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CYCLE DAY',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$day',
                    style: GoogleFonts.poppins(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    phaseName.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.phaseColor(phaseName),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: AppTheme.textSecondary.withOpacity(0.1),
                    indent: 40,
                    endIndent: 40,
                    height: 1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                        pred.currentPhase == CyclePhase.ovulation
                            ? 'PEAK FERTILITY'
                            : 'OVULATION IN ${pred.daysUntilOvulation}D',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentPurple,
                          letterSpacing: 1.2,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(
                        duration: 2.seconds,
                        color: AppTheme.accentPurple.withOpacity(0.3),
                      ),
                  const SizedBox(height: 8),
                  Text(
                    pred.nextPeriodDate != null
                        ? 'Period in ${pred.daysUntilNextPeriod} days'
                        : 'Next period: ...',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              NeuContainer(
                radius: 20,
                padding: const EdgeInsets.all(12),
                style: NeuStyle.concave,
                color: AppTheme.bgColor,
                child:
                    const Icon(
                          Icons.favorite_rounded,
                          color: AppTheme.accentPink,
                          size: 24,
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.15, 1.15),
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONCEPTION CHANCE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$chance%',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accentPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Premium Progress Bar
          NeuContainer(
            height: 16,
            width: double.infinity,
            padding: EdgeInsets.zero,
            radius: 8,
            style: NeuStyle.concave,
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: (chance / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentPink.withOpacity(0.6),
                          AppTheme.accentPink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
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
            color: AppTheme.textSecondary.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final StorageService storage;
  const _GreetingSection({required this.storage});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${storage.userName.split(' ').first}!',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
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
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // 2. Prepare Gradient & Paint for Active Arc
    final sweepAngle = 2 * 3.14159265359 * progress;

    // Outer Glow (More Vibrant)
    final shadowPaint = Paint()
      ..color = activeColor.withOpacity(0.4)
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

    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: [activeColor.withOpacity(0.4), activeColor, activeColor],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(-3.14159265359 / 2),
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
