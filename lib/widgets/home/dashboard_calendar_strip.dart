import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/prediction_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';

class DashboardCalendarStrip extends StatefulWidget {
  final PredictionService pred;
  final StorageService storage;
  final Function(DateTime) onDateSelected;

  const DashboardCalendarStrip({
    super.key,
    required this.pred,
    required this.storage,
    required this.onDateSelected,
  });

  @override
  State<DashboardCalendarStrip> createState() => _DashboardCalendarStripState();
}

class _DashboardCalendarStripState extends State<DashboardCalendarStrip> {
  late ScrollController _scrollController;
  final DateTime _today = DateTime.now();
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _today;
    _scrollController = ScrollController();
    // Center on today after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        30 * 60.0 - (MediaQuery.of(context).size.width / 2) + 30,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate 60 days of calendar (30 before, 30 after today)
    final days = List.generate(61, (index) {
      return DateTime(_today.year, _today.month, _today.day).add(Duration(days: index - 30));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Cycle Calendar',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = DateUtils.isSameDay(day, _selectedDay);
              final isToday = DateUtils.isSameDay(day, _today);
              
              final phase = widget.pred.getPhaseForDay(day);
              final phaseColor = AppTheme.phaseColor(phase.displayName);
              final isPeriod = phase == CyclePhase.menstrual;
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDay = day);
                  widget.onDateSelected(day);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? phaseColor.withValues(alpha: 0.2)
                        : (isToday ? phaseColor.withValues(alpha: 0.05) : Colors.transparent),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? phaseColor 
                          : (isToday ? phaseColor.withValues(alpha: 0.3) : Colors.transparent),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(day),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? phaseColor : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? phaseColor : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (isPeriod)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: phaseColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
