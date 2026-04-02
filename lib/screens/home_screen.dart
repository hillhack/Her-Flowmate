import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
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
import 'log_period_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  bool _isLocalLoading = true;

  // Expansion logic moved to ModernBentoDashboard Widget

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
          Container(decoration: AppTheme.getBackgroundDecoration(context)),
          RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingLg,
                  80,
                  AppTheme.spacingLg,
                  100,
                ),
                child: Column(
                  children: [
                    _buildTopRow(context, storage),
                    const SizedBox(height: AppTheme.spacingXl),
                    GreetingSection(storage: storage),
                    const SizedBox(height: AppTheme.spacingXl),
                    if (_isLocalLoading)
                      _buildSkeletonDashboard()
                    else if (storage.userGoal == 'pregnant')
                      Semantics(
                        label: 'Pregnancy Dashboard',
                        child: PregnancyDashboard(storage: storage),
                      )
                    else if (storage.userGoal == 'conceive')
                      Semantics(
                        label: 'Conception Dashboard',
                        child: TTCDashboard(storage: storage, pred: pred),
                      )
                    else
                      Semantics(
                        label: 'Cycle Tracking Dashboard',
                        child: _buildCycleDashboard(context, storage, pred),
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
        ],
      ),
      floatingActionButton:
          _isLocalLoading || storage.userGoal == 'pregnant'
              ? null
              : FloatingActionButton.extended(
                onPressed:
                    () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const LogPeriodScreen(),
                    ),
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
    );
  }

  Widget _buildTopRow(BuildContext context, StorageService storage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder:
              (context) => ThemedContainer(
                type: ContainerType.glass,
                radius: 18,
                padding: const EdgeInsets.all(10),
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Icon(
                  Icons.menu_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
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

    return ThemedContainer(
      type: ContainerType.glass,
      radius: 20,
      onTap: () => _showModeSelectionSheet(context, storage),
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
      type: ContainerType.glass,
      radius: 16,
      onTap: () {
        storage.updateUserGoal(goal);
        Navigator.pop(context);
        setState(() {});
      },
      padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.all(32),
      radius: 40,
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 48,
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to start?',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 32),
          ThemedContainer(
            type: ContainerType.glass,
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
                  color: Theme.of(context).colorScheme.primary,
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

  Widget _buildMedicalDisclaimer() {
    return Center(
      child: Text(
        'This is an estimate and should not be considered medical advice.',
        style: GoogleFonts.inter(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
