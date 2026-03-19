import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/info_widgets.dart';
import '../widgets/cycle_widgets.dart';

import 'log_period_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedGraphDay;

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
        explanation: 'The home dashboard is designed to be minimal. You can tap the ⓘ icons on any card to learn more about your current cycle metrics.',
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
      backgroundColor: AppTheme.frameColor,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                _GreetingSection(storage: storage),
                const SizedBox(height: 32),
                
                if (storage.userGoal == 'pregnant')
                  _buildPregnancyDashboard(context, storage)
                else if (storage.userGoal == 'conceive')
                  _buildTTCDashboard(context, storage)
                else
                  _buildCycleDashboard(context, storage, pred),
                  
                const SizedBox(height: 32),
                _buildMedicalDisclaimer(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCycleDashboard(BuildContext context, StorageService storage, PredictionService pred) {
    final cycleDay = pred.currentCycleDay;
    final daysToNext = pred.daysUntilNextPeriod;
    final phaseName = pred.phaseDisplayName;
    final cycleLen = pred.averageCycleLength;
    final hasLogs = storage.getLogs().isNotEmpty;

    if (!hasLogs) return _buildNewUserContent(context, storage);

    return Column(
      children: [
        _buildPhaseCard(context, pred),
        const SizedBox(height: 24),
        CycleTimeline(
          currentDay: cycleDay,
          cycleLength: cycleLen,
          pred: pred,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        HormoneGraph(
          pred: pred,
          onDaySelected: (day) => setState(() => _selectedGraphDay = day),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 16),
        if (_selectedGraphDay != null)
          _buildHormoneDetailCard(pred, _selectedGraphDay!),
        const SizedBox(height: 32),
        _buildCycleStatusRow(cycleDay, daysToNext),
        const SizedBox(height: 24),
        if (phaseName == 'Ovulation' || phaseName == 'Follicular')
          _buildFertilityCard(pred),
      ],
    );
  }

  Widget _buildTTCDashboard(BuildContext context, StorageService storage) {
    final pred = context.watch<PredictionService>();
    final nextOvulation = pred.nextPeriodDate?.subtract(const Duration(days: 14)) ?? DateTime.now();

    return Column(
      children: [
        _buildFertilityCard(pred, title: 'TTC Focus: Fertility Window'),
        const SizedBox(height: 24),
        GlassContainer(
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next Ovulation', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(DateFormat('MMM d').format(nextOvulation), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  ],
                ),
              ),
              const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 28),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildPregnancyDashboard(BuildContext context, StorageService storage) {
    final weeks = storage.pregnancyWeeks ?? 8;
    final dueDate = storage.dueDate ?? DateTime.now().add(const Duration(days: 220));
    final daysRemaining = dueDate.difference(DateTime.now()).inDays;
    
    String babySize = 'Raspberry';
    if (weeks >= 12) babySize = 'Lime';
    if (weeks >= 20) babySize = 'Banana';
    if (weeks >= 40) babySize = 'Watermelon';

    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(28),
          radius: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pregnancy Progress', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Week $weeks', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const Icon(Icons.pregnant_woman_rounded, color: AppTheme.accentPink, size: 40),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        GlassContainer(
          padding: const EdgeInsets.all(28),
          radius: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Baby Size', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('About the size of a $babySize', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 24),
        _buildCycleStatusRow(weeks, daysRemaining, label1: 'Weeks', label2: 'Days Left'),
      ],
    );
  }

  Widget _buildPhaseCard(BuildContext context, PredictionService pred) {
    final phaseName = pred.phaseDisplayName;
    final day = pred.currentCycleDay;
    final hormoneStatus = pred.getHormoneDescriptions(day);

    return GlassContainer(
      padding: const EdgeInsets.all(28),
      radius: 32,
      borderColor: AppTheme.phaseColor(phaseName).withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Current Phase', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              GlassInfoButton(
                onTap: () => showGlassInfoPopup(
                  context,
                  title: 'Cycle Phases',
                  explanation: 'Your cycle consists of four main phases: Menstrual, Follicular, Ovulation, and Luteal.',
                  tip: 'Each phase brings unique hormonal changes affecting your energy and mood.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phaseName, style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  Text(AppTheme.phaseTip(phaseName).headline, style: GoogleFonts.inter(fontSize: 16, color: AppTheme.phaseColor(phaseName), fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Estrogen: ${hormoneStatus['Estrogen']}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  Text('Progesterone: ${hormoneStatus['Progesterone']}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildCycleStatusRow(dynamic val1, dynamic val2, {String label1 = 'Cycle Day', String label2 = 'Next Period'}) {
    return GlassContainer(
      padding: const EdgeInsets.all(28),
      radius: 32,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label1, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('$val1', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              ],
            ),
          ),
          // Vertical divider
          Container(width: 1.5, height: 40, color: Colors.white.withOpacity(0.2)),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label2, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(val2 is int && val2 < 0 ? '${val2.abs()}d late' : (label2 == 'Days Left' ? '$val2' : 'In $val2 days'), 
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildFertilityCard(PredictionService pred, {String title = 'Fertility Status'}) {
    final chance = pred.currentConceptionChance;
    return GlassContainer(
      padding: const EdgeInsets.all(28),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(chance > 50 ? 'High probability today' : 'Low probability today', 
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                ],
              ),
              GlassContainer(
                radius: 16,
                padding: const EdgeInsets.all(12),
                borderColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.favorite_rounded, color: AppTheme.accentPink, size: 24)
                  .animate(onPlay: (c) => c.repeat())
                  .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 800.ms, curve: Curves.easeInOut),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chance of Conception', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              Text('$chance%', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.accentPink)),
            ],
          ),
          const SizedBox(height: 12),
          // Simple Progress Bar
          Container(
            height: 12, width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (chance / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentPink,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: AppTheme.accentPink.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildNewUserContent(BuildContext context, StorageService storage) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      radius: 40,
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentPink, size: 48),
          const SizedBox(height: 20),
          Text(
            'Ready to start?',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark),
          ),
          const SizedBox(height: 12),
          Text(
            'Log your first period to see your cycle predictions and insights.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          GlassContainer(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LogPeriodScreen(),
              );
            },
            radius: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text('Log First Period', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.accentPink)),
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
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6), fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildHormoneDetailCard(PredictionService pred, int day) {
    final levels = pred.getHormoneLevels(day);
    final descriptions = pred.getHormoneDescriptions(day);
    final phase = pred.getPhaseForDay(DateTime.now().add(Duration(days: day - pred.currentCycleDay)));

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day $day Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.phaseColor(phase.displayName).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(phase.displayName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.phaseColor(phase.displayName))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _hormoneStat('Estrogen', descriptions['Estrogen']!, AppTheme.hormoneColors['Estrogen']!),
              _hormoneStat('Progesterone', descriptions['Progesterone']!, AppTheme.hormoneColors['Progesterone']!),
              _hormoneStat('LH', (levels['LH']! > 0.7) ? 'Peak' : 'Stable', AppTheme.hormoneColors['LH']!),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            day == pred.currentCycleDay ? 'You are currently in your ${phase.displayName} phase.' : 'On Day $day, you will likely be in the ${phase.displayName} phase.',
            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.05);
  }

  Widget _hormoneStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final StorageService storage;
  const _GreetingSection({required this.storage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        GlassContainer(
          radius: 12,
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
  }
}
