import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/pregnancy_week_data.dart';
import '../../utils/app_theme.dart';

class PregnancyTimelineStrip extends StatefulWidget {
  final int currentWeek;
  final Function(int) onWeekSelected;

  const PregnancyTimelineStrip({
    super.key,
    required this.currentWeek,
    required this.onWeekSelected,
  });

  @override
  State<PregnancyTimelineStrip> createState() => _PregnancyTimelineStripState();
}

class _PregnancyTimelineStripState extends State<PregnancyTimelineStrip> {
  late ScrollController _scrollController;
  late int _selectedWeek;

  @override
  void initState() {
    super.initState();
    _selectedWeek = widget.currentWeek;
    _scrollController = ScrollController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeek(_selectedWeek);
    });
  }

  void _scrollToWeek(int week) {
    if (_scrollController.hasClients) {
      final target = (week - 1) * 70.0 - (MediaQuery.of(context).size.width / 2) + 35;
      _scrollController.animateTo(
        target.clamp(0.0, _scrollController.position.maxScrollExtent),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Timeline',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 40,
            itemBuilder: (context, index) {
              final week = index + 1;
              final isSelected = week == _selectedWeek;
              final isCurrent = week == widget.currentWeek;
              final weekData = getPregnancyWeekData(week);
              
              Color weekColor;
              if (week <= 12) {
                weekColor = AppTheme.primaryPink700;
              } else if (week <= 27) {
                weekColor = AppTheme.accentPurple;
              } else {
                weekColor = const Color(0xFF4DBBFF);
              }

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedWeek = week);
                  widget.onWeekSelected(week);
                  _scrollToWeek(week);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? weekColor.withValues(alpha: 0.15)
                        : (isCurrent ? weekColor.withValues(alpha: 0.05) : Colors.transparent),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected 
                          ? weekColor 
                          : (isCurrent ? weekColor.withValues(alpha: 0.3) : Colors.transparent),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Week',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? weekColor : AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '$week',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? weekColor : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        weekData.sizeEmoji,
                        style: const TextStyle(fontSize: 16),
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
