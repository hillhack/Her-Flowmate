import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/home/modern_bento_dashboard.dart';
import '../widgets/home/ttc_dashboard.dart';
import '../widgets/home/pregnancy_dashboard.dart';
import '../widgets/home/greeting_section.dart';
import '../widgets/themed_container.dart';
import '../widgets/info_widgets.dart';
import '../widgets/skeleton_widgets.dart';
import '../widgets/common/neu_card.dart';
import '../widgets/common/primary_button.dart';
import 'log_period_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      body: Stack(
        children: [
          Container(decoration: AppTheme.getBackgroundDecoration(context)),
          RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              final s = context.read<StorageService>();
              await s.syncUserWithBackend();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.pad(context),
                  MediaQuery.of(context).padding.top + AppDesignTokens.space16,
                  AppResponsive.pad(context),
                  MediaQuery.of(context).padding.bottom + AppDesignTokens.space64,
                ),
                child: Column(
                  children: [
                    _buildTopRow(context, storage),
                    const SizedBox(height: AppTheme.spacingXl),
                    GreetingSection(storage: storage),
                    const SizedBox(height: AppTheme.spacingXl),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: storage.isLoading
                          ? _buildSkeletonDashboard()
                          : _getDashboard(context, storage, pred),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    _buildMedicalDisclaimer(),
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
                    Theme.of(context).colorScheme.primary,
                    AppTheme.primaryPink700,
                    Colors.blueAccent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          storage.isLoading || storage.userGoal == 'pregnant'
              ? null
              : Semantics(
                  label: 'Log an event',
                  button: true,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: const LogPeriodScreen(),
                        ),
                      );
                    },
                    label: Text(
                      'Log Event',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                  ).animate().scale(delay: 1.seconds, curve: Curves.bounceOut),
                ),
    );
  }

  Widget _getDashboard(BuildContext context, StorageService storage, PredictionService pred) {
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
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }
  }

  Widget _buildTopRow(BuildContext context, StorageService storage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Open navigation drawer',
              button: true,
              child: ThemedContainer(
                type: ContainerType.glass,
                radius: 18,
                padding: const EdgeInsets.all(10),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Scaffold.of(context).openDrawer();
                },
                child: Icon(
                  Icons.menu_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 26,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: storage.isLoading
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ).animate().fadeIn()
                  : const SizedBox(width: 28), // Keeps layout stable
            ),
          ],
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

    return Semantics(
      label: 'Selected mode: $modeLabel. Tap to change.',
      button: true,
      child: ThemedContainer(
        type: ContainerType.glass,
        radius: 20,
        onTap: () {
          HapticFeedback.selectionClick();
          _showModeSelectionSheet(context, storage);
        },
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              modeLabel,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
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
            color: Theme.of(context).scaffoldBackgroundColor,
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
      color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : Colors.transparent,
      border:
          isSelected
              ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
              : Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
              ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
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
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to start?',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tracking your cycle regularly improves predictions and uncovers personalized health insights.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                      Icon(Icons.calendar_month_rounded, size: 24, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('Log often', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
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
                      Icon(Icons.insights_rounded, size: 24, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('Get insights', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
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
                builder: (context) => Padding(
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

  Widget _buildMedicalDisclaimer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ThemedContainer(
        type: ContainerType.glass,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Estimates are not medical advice. Consult a healthcare professional for concerns.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
