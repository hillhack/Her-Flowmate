import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/delight_widgets.dart';
import 'prediction_details_screen.dart';

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

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      drawer: _buildDrawer(context, storage),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: GlassContainer(
              padding: const EdgeInsets.all(8),
              radius: 12,
              child: const Icon(Icons.menu_rounded, color: AppTheme.textDark),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Cycle Calendar',
          style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GlassContainer(
              padding: const EdgeInsets.all(8),
              radius: 12,
              child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GlassContainer(
                    radius: 32,
                    padding: const EdgeInsets.all(16),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _showDailyLogSheet(context, selectedDay);
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                        leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppTheme.accentPink, size: 28),
                        rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppTheme.accentPink, size: 28),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w700),
                        weekendStyle: GoogleFonts.inter(color: AppTheme.accentPink, fontWeight: FontWeight.w700),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          return _buildCalendarCell(day, pred, isSelected: false);
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return _buildCalendarCell(day, pred, isSelected: true);
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return _buildCalendarCell(day, pred, isSelected: false, isToday: true);
                        },
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildLegend(pred),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 24),

                // Floating Phase Explanation Card
                if (_selectedDay != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildPhaseExplanationCard(context, pred, _selectedDay!),
                  ),

                const SizedBox(height: 24),

                // Additional Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          radius: 20,
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text('Add Note', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textDark))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassContainer(
                          radius: 20,
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text('View Insights', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textDark))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseExplanationCard(BuildContext context, PredictionService pred, DateTime date) {
    final cycleDay = pred.getCycleDay(date);
    final phase = pred.getPhaseForDay(date);
    final biology = pred.getPhaseBiology(cycleDay);
    final chance = pred.getConceptionChance(date);

    return GlassContainer(
      padding: const EdgeInsets.all(24),
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
                  Text(DateFormat('MMMM d').format(date), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  Text('Cycle Day: $cycleDay', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.phaseColor(phase.displayName).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(phase.displayName, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.phaseColor(phase.displayName))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('What is happening today:', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 6),
          Text(biology['insight']!, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.4, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Text('Hormone activity:', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(biology['hormoneActivity']!, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.accentPink, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text('Fertility status:', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(pred.getConceptionStatus(chance), style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PredictionDetailsScreen())),
                child: Text('Learn More →', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.accentPink)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  Widget _buildLegend(PredictionService pred) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      radius: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Period', AppTheme.phaseColors['Menstrual']!),
          _buildLegendItem('Follicular', AppTheme.phaseColors['Follicular']!),
          _buildLegendItem('Ovulation', AppTheme.phaseColors['Ovulation']!),
          _buildLegendItem('Luteal', AppTheme.phaseColors['Luteal']!),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day, PredictionService pred, {required bool isSelected, bool isToday = false}) {
    final phase = pred.getPhaseForDay(day);
    final isPeriod = phase == CyclePhase.menstrual;
    final isOvulation = phase == CyclePhase.ovulation;
    final isFollicular = phase == CyclePhase.follicular;
    final isLuteal = phase == CyclePhase.luteal;

    Color? bgColor;
    BoxBorder? border;
    
    if (isSelected) {
      bgColor = AppTheme.accentPink.withOpacity(0.8);
      border = Border.all(color: AppTheme.accentPink, width: 2);
    } else if (isPeriod) {
      bgColor = AppTheme.phaseColors['Menstrual'];
    } else if (isFollicular) {
      bgColor = AppTheme.phaseColors['Follicular']!.withOpacity(0.3);
    } else if (isLuteal) {
      bgColor = AppTheme.phaseColors['Luteal']!.withOpacity(0.3);
    }

    if (isToday && !isSelected) {
      border = Border.all(color: AppTheme.accentPink.withOpacity(0.5), width: 1.5);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
        boxShadow: isOvulation ? [
          BoxShadow(color: AppTheme.phaseColors['Ovulation']!.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)
        ] : null,
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${day.day}',
            style: GoogleFonts.inter(
              color: isSelected || isPeriod ? Colors.white : AppTheme.textDark,
              fontWeight: isSelected || isToday || isPeriod ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (isOvulation)
            Positioned(
              bottom: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.phaseColors['Ovulation'],
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.phaseColors['Ovulation']!, blurRadius: 4)]
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, StorageService storage) {
    final initial = storage.userName.isNotEmpty ? storage.userName[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: AppTheme.frameColor,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            GlassContainer(
              width: 80, height: 80,
              radius: 40,
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.poppins(color: AppTheme.accentPink, fontWeight: FontWeight.bold, fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              storage.userName.isNotEmpty ? storage.userName : 'Guest',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            const SizedBox(height: 48),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _drawerActionItem(context, icon: Icons.home_rounded, title: 'Home', onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
                  const SizedBox(height: 12),
                  _drawerActionItem(context, icon: Icons.calendar_month_rounded, title: 'Calendar', onTap: () => Navigator.pop(context)),
                  const SizedBox(height: 12),
                  _drawerActionItem(context, icon: Icons.lightbulb_rounded, title: 'Insights', onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
                  
                  const SizedBox(height: 24),
                  Divider(color: AppTheme.shadowDark.withOpacity(0.3)),
                  const SizedBox(height: 24),

                  _drawerActionItem(context, icon: Icons.settings_rounded, title: 'Settings', onTap: () {}),
                  const SizedBox(height: 12),
                  _drawerActionItem(context, icon: Icons.contact_support_rounded, title: 'Contact Support', onTap: () {}),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text(
                'HerFlowmate v1.2.0',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerActionItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      radius: 20,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: ListTile(
        leading: Icon(icon, color: AppTheme.accentPink, size: 24),
        title: Text(title, style: GoogleFonts.inter(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
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
    final statusText = isHigh ? 'High Fertility' : (chance >= 10 ? 'Moderate Fertility' : 'Low Fertility');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.frameColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: GlassContainer(
        radius: 40,
        opacity: 0.05,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 6, decoration: BoxDecoration(color: AppTheme.shadowDark, borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('MMMM d').format(date), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                      Text(DateFormat('EEEE').format(date), style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                    GlassContainer(
                      radius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Day ${pred.getCycleDay(date)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.accentPink)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text('Phase:', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(pred.getPhaseForDay(date).displayName, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Hormone Status Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  radius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hormone Status', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _hormoneMiniItem('Estrogen', pred.getHormoneDescriptions(pred.getCycleDay(date))['Estrogen']!),
                          _hormoneMiniItem('Progesterone', pred.getHormoneDescriptions(pred.getCycleDay(date))['Progesterone']!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            
            // Conception Chance Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                radius: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fertility Window', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(statusText, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Chance of Conception', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                        Text('$chance%', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.accentPink)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 10, width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (chance / 100).clamp(0.01, 1.0),
                        child: Container(decoration: BoxDecoration(color: AppTheme.accentPink, borderRadius: BorderRadius.circular(5))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'This is an estimate based on your cycle patterns.',
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6), fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: GlassContainer(
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
                              Text('Log Period', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.accentPink)),
                              const SizedBox(width: 4),
                              const Text('🦋', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassContainer(
                      radius: 20,
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('Log Symptom', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textDark))),
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
    );
  }

  Widget _hormoneMiniItem(String label, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        Text(status, style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textDark, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
