import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'package:intl/intl.dart';
import '../widgets/home/modern_bento_dashboard.dart';
import '../widgets/home/ttc_dashboard.dart';
import '../widgets/home/pregnancy_dashboard.dart';
import '../widgets/themed_container.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/info_widgets.dart';
import '../widgets/skeleton_widgets.dart';
import '../widgets/common/neu_card.dart';
import '../widgets/common/primary_button.dart';
import 'log_period_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  const HomeScreen({super.key, this.onMenuPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  // Expansion logic moved to ModernBentoDashboard Widget

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

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final pred = context.watch<PredictionService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: SharedAppBar(
        title: 'Flowmate',
        subtitle: DateFormat('EEEE, d MMMM').format(DateTime.now()),
        onMenuPressed: widget.onMenuPressed,
        actions: [
          _buildCurrentModeBadge(storage),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Container(decoration: AppTheme.getBackgroundDecoration(context)),
          RefreshIndicator(
            color: context.primary,
            onRefresh: () async {
              final s = context.read<StorageService>();
              await s.syncUserWithBackend();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.pad(context),
                  kToolbarHeight + MediaQuery.of(context).padding.top + 32,
                  AppResponsive.pad(context),
                  MediaQuery.of(context).padding.bottom + AppDesignTokens.space64,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppTheme.spacingLg),
                    // NOTE: Do not use FadeTransition (AnimatedOpacity) as the
                    // transitionBuilder inside a SingleChildScrollView — it receives
                    // an unbounded height constraint and crashes with a NaN Rect error.
                    // The default AnimatedSwitcher transition (a simple crossfade)
                    // is safe because it sizes to the child, not infinity.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: storage.isLoading
                          ? _buildSkeletonDashboard()
                          : _getDashboard(context, storage, pred),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: Semantics(
                excludeSemantics: true,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: [
                    context.primary,
                    AppTheme.accentPink,
                    Colors.blueAccent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDashboard(
    BuildContext context,
    StorageService storage,
    PredictionService pred,
  ) {
    try {
      Widget dashboardWidget;
      if (storage.userGoal == 'pregnant') {
        dashboardWidget = PregnancyDashboard(storage: storage);
      } else if (storage.userGoal == 'conceive') {
        dashboardWidget = TTCDashboard(storage: storage, pred: pred);
      } else {
        dashboardWidget = _buildCycleDashboard(context, storage, pred);
      }
      return Semantics(
        key: ValueKey(storage.userGoal),
        label: '${storage.userGoal} dashboard',
        child: dashboardWidget,
      );
    } catch (e) {
      return Center(
        child: ThemedContainer(
          type: ContainerType.glass,
          padding: const EdgeInsets.all(24),
          child: Text(
            'Cannot load dashboard right now.\nEnsure syncing is working.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.error),
          ),
        ),
      );
    }
  }

  Widget _buildCurrentModeBadge(StorageService storage) {
    final mode = storage.userGoal;
    String modeLabel =
        mode == 'conceive'
            ? 'Conceive'
            : (mode == 'pregnant' ? 'Pregnancy' : 'Period Tracking');
    
    IconData modeIcon = mode == 'pregnant' 
        ? Icons.pregnant_woman_rounded 
        : (mode == 'conceive' ? Icons.favorite_rounded : Icons.calendar_today_rounded);

    return Semantics(
      label: 'Selected mode: $modeLabel. Tap to change.',
      button: true,
      child: ThemedContainer(
        type: ContainerType.glass,
        radius: 14,
        onTap: () {
          HapticFeedback.selectionClick();
          _showModeSelectionSheet(context, storage);
        },
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              modeIcon,
              color: context.primary,
              size: 20,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: context.secondaryText,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showModeSelectionSheet(BuildContext context, StorageService storage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ThemedContainer(
            type: ContainerType.simple,
            radius: 32,
            padding: const EdgeInsets.all(24),
            color: context.surface,
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
    return ThemedContainer(
      type: ContainerType.simple,
      radius: 16,
      onTap: () {
        HapticFeedback.lightImpact();
        storage.updateUserGoal(goal);
        Navigator.pop(context);
        // no setState needed; Provider will trigger rebuild
      },
      padding: const EdgeInsets.all(16),
      color:
          isSelected
              ? context.primary.withValues(alpha: 0.05)
              : Colors.transparent,
      border:
          isSelected
              ? Border.all(
                color: context.primary,
                width: 2,
              )
              : Border.all(
                color: context.secondaryText.withValues(alpha: 0.2),
              ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                isSelected
                    ? context.primary
                    : context.secondaryText,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: context.onSurface,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: context.primary,
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
    if (storage.getLogs().isEmpty) {
      return _buildNewUserContent(context, storage);
    }

    return ModernBentoDashboard(
      storage: storage,
      pred: pred,
      confettiController: _confettiController,
    );
  }

  Widget _buildNewUserContent(BuildContext context, StorageService storage) {
    return ThemedContainer(
      type: ContainerType.neu,
      padding: const EdgeInsets.all(24),
      radius: 32,
      child: Column(
        children: [
          Icon(
                Icons.auto_awesome_rounded,
                color: context.primary,
                size: 64,
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(
                begin: 1.0,
                end: 1.2,
                duration: 1500.ms,
                curve: Curves.easeInOut,
              )
              .shimmer(duration: 2000.ms, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Ready to start?',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: context.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tracking your cycle regularly improves predictions and uncovers personalized health insights.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: context.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: NeumorphicCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 24,
                        color: context.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Log often',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeumorphicCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        size: 24,
                        color: context.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get insights',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Log First Period',
            icon: Icons.add_rounded,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: const LogPeriodScreen(),
                    ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
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


}
