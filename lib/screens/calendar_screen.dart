import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/notification_widgets.dart';
import 'insights_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showDailyLogSheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DailyLogSheet(date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();
    final storage = context.watch<StorageService>();

    return Material(
      color: AppTheme.frameColor,
      child: Container(
        decoration: AppTheme.getBackgroundDecoration(context),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isSmallScreen = screenWidth < 360;
              final hPad = isSmallScreen ? 12.0 : 20.0;

              return Column(
                children: [
                  // Custom Top Bar (replacing AppBar)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppTheme.spacingLg,
                      right: AppTheme.spacingLg,
                      top: 24,
                      bottom: 16,
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder:
                              (context) => Semantics(
                                label: 'Open Sidebar Menu',
                                button: true,
                                child: ThemedContainer(
                                  type: ContainerType.neu,
                                  padding: const EdgeInsets.all(10),
                                  radius: 18,
                                  onTap:
                                      () => Scaffold.of(context).openDrawer(),
                                  child: const Icon(
                                    Icons.menu_rounded,
                                    color: AppTheme.primaryPink700,
                                    size: 26,
                                  ),
                                ),
                              ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Cycle Calendar',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),
                        const NotificationBell(),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: isSmallScreen ? 8 : 16),
                          Padding(
                                padding: EdgeInsets.symmetric(horizontal: hPad),
                                child: ThemedContainer(
                                  type: ContainerType.glass,
                                  radius: 32,
                                  padding: const EdgeInsets.all(16),
                                  child: TableCalendar(
                                    firstDay: DateTime.utc(2020, 1, 1),
                                    lastDay: DateTime.utc(2030, 12, 31),
                                    focusedDay: _focusedDay,
                                    selectedDayPredicate:
                                        (day) => isSameDay(_selectedDay, day),
                                    onDaySelected: (selectedDay, focusedDay) {
                                      setState(() {
                                        _selectedDay = selectedDay;
                                        _focusedDay = focusedDay;
                                      });
                                      _showDailyLogSheet(context, selectedDay);
                                    },
                                    onHeaderTapped: (focusedDay) {
                                      _showMonthPicker(context);
                                    },
                                    calendarFormat: CalendarFormat.month,
                                    headerStyle: HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      titleTextStyle: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      leftChevronPadding: const EdgeInsets.all(
                                        12,
                                      ),
                                      rightChevronPadding: const EdgeInsets.all(
                                        12,
                                      ),
                                      leftChevronIcon: const Icon(
                                        Icons.chevron_left_rounded,
                                        color: AppTheme.accentPink,
                                        size: 32,
                                      ),
                                      rightChevronIcon: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppTheme.accentPink,
                                        size: 32,
                                      ),
                                    ),
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      weekdayStyle: GoogleFonts.inter(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      weekendStyle: GoogleFonts.inter(
                                        color: AppTheme.accentPink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    calendarBuilders: CalendarBuilders(
                                      defaultBuilder: (
                                        context,
                                        day,
                                        focusedDay,
                                      ) {
                                        return _buildCalendarCell(
                                          day,
                                          pred,
                                          storage,
                                          isSelected: false,
                                        );
                                      },
                                      selectedBuilder: (
                                        context,
                                        day,
                                        focusedDay,
                                      ) {
                                        return _buildCalendarCell(
                                          day,
                                          pred,
                                          storage,
                                          isSelected: true,
                                        );
                                      },
                                      todayBuilder: (context, day, focusedDay) {
                                        return _buildCalendarCell(
                                          day,
                                          pred,
                                          storage,
                                          isSelected: false,
                                          isToday: true,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.1),

                          SizedBox(height: isSmallScreen ? 16 : 32),

                          // Legend
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: _buildLegend(
                              pred,
                              isSmallScreen: isSmallScreen,
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Floating Phase Explanation Card
                          if (_selectedDay != null)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: hPad),
                              child: _buildPhaseExplanationCard(
                                context,
                                pred,
                                _selectedDay!,
                                isSmallScreen: isSmallScreen,
                              ),
                            ),

                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Additional Actions - disabled on small screens to save space
                          if (!isSmallScreen)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: hPad),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ThemedContainer(
                                      type: ContainerType.neu,
                                      radius: 20,
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Note taking is coming soon!'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Add Note',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ThemedContainer(
                                      type: ContainerType.neu,
                                      radius: 20,
                                      onTap: () => Navigator.pop(context),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'View Insights',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 400.ms),

                          SizedBox(height: isSmallScreen ? 80 : 100),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseExplanationCard(
    BuildContext context,
    PredictionService pred,
    DateTime date, {
    bool isSmallScreen = false,
  }) {
    final cycleDay = pred.getCycleDay(date);
    final phase = pred.getPhaseForDay(date);
    final biology = pred.getPhaseBiology(cycleDay);
    final chance = pred.getConceptionChance(date);

    return ThemedContainer(
      type: ContainerType.glass,
      padding: const EdgeInsets.all(20),
      radius: 28,
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
                    DateFormat('MMMM d').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Cycle Day: $cycleDay',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              _buildPhaseBadge(phase),
            ],
          ),
          const SizedBox(height: 20),
          // Icon-based status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusIconItem('⚡', 'Energy', biology['energy']!),
              _statusIconItem('🎭', 'Mood', biology['mood']!),
              _statusIconItem('🩸', 'Hormones', biology['hormoneActivity']!),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppTheme.accentPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pred.getConceptionStatus(chance),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InsightsScreen(),
                    ),
                  ),
              child: Text(
                'Full Insights →',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentPink,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  Widget _buildPhaseBadge(CyclePhase phase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.phaseColor(phase.displayName).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.phaseColor(phase.displayName).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        phase.displayName,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppTheme.phaseColor(phase.displayName),
        ),
      ),
    );
  }

  Widget _statusIconItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ThemedContainer(
            type: ContainerType.glass,
            radius: 32,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Date',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: CalendarDatePicker(
                    initialDate: _focusedDay,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onDateChanged: (date) {
                      setState(() {
                        _focusedDay = date;
                        _selectedDay = date;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLegend(PredictionService pred, {bool isSmallScreen = false}) {
    return ThemedContainer(
      type: ContainerType.neu,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 16 : 24,
        horizontal: isSmallScreen ? 8 : 16,
      ),
      radius: isSmallScreen ? 20 : 28,
      child: Wrap(
        spacing: isSmallScreen ? 8 : 12,
        runSpacing: 4,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            context,
            'Period',
            AppTheme.phaseColors['Menstrual']!,
            isSmallScreen,
          ),
          _buildLegendItem(
            context,
            'Follicular',
            AppTheme.phaseColors['Follicular']!,
            isSmallScreen,
          ),
          _buildLegendItem(
            context,
            'Ovulation',
            AppTheme.phaseColors['Ovulation']!,
            isSmallScreen,
          ),
          _buildLegendItem(
            context,
            'Luteal',
            AppTheme.phaseColors['Luteal']!,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    bool isSmallScreen,
  ) {
    return Semantics(
      label: 'Phase $label indicated by color.',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallScreen ? 14 : 16,
            height: isSmallScreen ? 14 : 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 4 : 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.midnightPlum,
              fontSize: isSmallScreen ? 10 : 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(
    DateTime day,
    PredictionService pred,
    StorageService storage, {
    required bool isSelected,
    bool isToday = false,
  }) {
    final phase = pred.getPhaseForDay(day);
    final isPeriod = phase == CyclePhase.menstrual;
    final isOvulation = phase == CyclePhase.ovulation;
    final isFollicular = phase == CyclePhase.follicular;
    final isLuteal = phase == CyclePhase.luteal;

    Color? bgColor;
    Gradient? gradient;
    BoxBorder? border;

    if (isSelected) {
      gradient = const LinearGradient(
        colors: [AppTheme.accentPink, AppTheme.accentPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      border = Border.all(color: Colors.white, width: 2);
    } else if (isPeriod) {
      gradient = LinearGradient(
        colors: [
          AppTheme.phaseColors['Menstrual']!,
          AppTheme.phaseColors['Menstrual']!.withValues(alpha: 0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (isFollicular) {
      bgColor = AppTheme.phaseColors['Follicular']!.withValues(alpha: 0.15);
    } else if (isLuteal) {
      bgColor = AppTheme.phaseColors['Luteal']!.withValues(alpha: 0.15);
    }

    if (isToday && !isSelected) {
      border = Border.all(
        color: AppTheme.accentPink.withValues(alpha: 0.6),
        width: 1.5,
      );
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gradient,
        shape: BoxShape.circle,
        border: border,
        boxShadow:
            isOvulation
                ? [
                  BoxShadow(
                    color: AppTheme.phaseColors['Ovulation']!.withValues(
                      alpha: 0.6,
                    ),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                : (isSelected
                    ? [
                      BoxShadow(
                        color: AppTheme.accentPink.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                    : null),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${day.day}',
            style: GoogleFonts.inter(
              color:
                  isSelected || isPeriod
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.midnightPlum),
              fontWeight:
                  isSelected || isToday || isPeriod
                      ? FontWeight.w900
                      : FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (isOvulation)
            Positioned(
              bottom: 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.phaseColors['Ovulation'],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.phaseColors['Ovulation']!,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          if (storage.getDailyLog(day) != null)
            Positioned(
              bottom: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyLogSheet extends StatelessWidget {
  final DateTime date;
  const _DailyLogSheet({required this.date});

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();
    final chance = pred.getConceptionChance(date);
    final isHigh = chance >= 25;
    final statusText =
        isHigh
            ? 'High Fertility'
            : (chance >= 10 ? 'Moderate Fertility' : 'Low Fertility');

    final storage = context.watch<StorageService>();
    final dailyLog = storage.getDailyLog(date);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.frameColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.shadowDark,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM d').format(date),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color:
                                isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.midnightPlum,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE').format(date),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ThemedContainer(
                      type: ContainerType.neu,
                      radius: 16,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Day ${pred.getCycleDay(date)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentPink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Phase:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      pred.getPhaseForDay(date).displayName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Hormone Status Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ThemedContainer(
                  type: ContainerType.neu,
                  padding: const EdgeInsets.all(20),
                  radius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hormone Status',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _hormoneMiniItem(
                            'Estrogen',
                            pred.getHormoneDescriptions(
                              pred.getCycleDay(date),
                            )['Estrogen']!,
                          ),
                          _hormoneMiniItem(
                            'Progesterone',
                            pred.getHormoneDescriptions(
                              pred.getCycleDay(date),
                            )['Progesterone']!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (dailyLog != null) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ThemedContainer(
                    type: ContainerType.neu,
                    padding: const EdgeInsets.all(20),
                    radius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daily Check-in',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (dailyLog.moods?.isNotEmpty == true)
                              Text(
                                dailyLog.moods!.first,
                                style: const TextStyle(fontSize: 24),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (dailyLog.symptoms?.isNotEmpty == true) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                dailyLog.symptoms!
                                    .map(
                                      (s) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentPink.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          s,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppTheme.accentPink,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (dailyLog.waterIntake != null &&
                            dailyLog.waterIntake! > 0) ...[
                          Row(
                            children: [
                              const Text('💧', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Text(
                                '${dailyLog.waterIntake} Glasses',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (dailyLog.notes?.isNotEmpty == true) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dailyLog.notes!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Conception Chance Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ThemedContainer(
                  type: ContainerType.neu,
                  padding: const EdgeInsets.all(24),
                  radius: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fertility Window',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chance of Conception',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$chance%',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentPink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (chance / 100).clamp(0.01, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.accentPink,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'This is an estimate based on your cycle patterns.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ThemedContainer(
                        type: ContainerType.neu,
                        radius: 20,
                        onTap: () {
                          showPhaseDelight(context, 'Period Logged');
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Log Period',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentPink,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  '🦋',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ThemedContainer(
                        type: ContainerType.neu,
                        radius: 20,
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Log Symptom',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hormoneMiniItem(String label, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          status,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
