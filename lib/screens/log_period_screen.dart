import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/prediction_service.dart';
import '../models/period_log.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/brand_widgets.dart';

class LogPeriodScreen extends StatefulWidget {
  const LogPeriodScreen({super.key});

  @override
  State<LogPeriodScreen> createState() => _LogPeriodScreenState();
}

class _LogPeriodScreenState extends State<LogPeriodScreen> {
  DateTime? _selectedDate;
  bool _isAM = true;
  String? _flowIntensity = 'Medium';
  final List<String> _selectedSymptoms = [];
  String? _selectedMood;
  final TextEditingController _durationController = TextEditingController(
    text: '5',
  );

  final List<String> _allSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Acne',
    'Backache',
    'Tender Breasts',
    'Nausea',
  ];

  final Map<String, String> _allMoods = {
    'Happy': '😊',
    'Energetic': '⚡',
    'Tired': '😴',
    'Sad': '😢',
    'Anxious': '😰',
    'Angry': '😠',
    'Cravings': '🍪',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.frameColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: GlassContainer(
        radius: 40,
        opacity: 0.05,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Log Your Period',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Help '),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: BrandName(fontSize: 15),
                      ),
                      const TextSpan(text: ' learn your cycle better.'),
                    ],
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 40),

                // ── Step 1: Date ────────────────────────────────────────────
                _stepLabel('1', 'When did it start?'),
                const SizedBox(height: 16),
                GlassContainer(
                  radius: 24,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.accentPink,
                            onPrimary: Colors.white,
                            surface: AppTheme.frameColor,
                            onSurface: AppTheme.textDark,
                          ),
                          dialogBackgroundColor: AppTheme.frameColor,
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.accentPink,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat(
                                  'EEEE, MMM d, yyyy',
                                ).format(_selectedDate!),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: _selectedDate == null
                                ? AppTheme.textSecondary
                                : AppTheme.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedDate != null)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.accentPink,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // ── Step 2: AM / PM ─────────────────────────────────────────
                _stepLabel('2', 'Select Start Time'),
                const SizedBox(height: 16),
                GlassContainer(
                  radius: 24,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _amPmButton(
                          'AM',
                          _isAM,
                          () => setState(() => _isAM = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _amPmButton(
                          'PM',
                          !_isAM,
                          () => setState(() => _isAM = false),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 32),

                _stepLabel('3', 'How many days?'),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.glassDecoration(
                    radius: 16,
                    opacity: 0.1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Number of days',
                      hintStyle: GoogleFonts.inter(
                        color: AppTheme.textSecondary.withOpacity(0.4),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 32),

                // ── Step 4: Flow Intensity ──────────────────────────────────
                _stepLabel('4', 'Flow Intensity'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['Light', 'Medium', 'Heavy'].map((flow) {
                    final isSelected = _flowIntensity == flow;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _flowIntensity = flow),
                          child: GlassContainer(
                            radius: 16,
                            opacity: isSelected ? 0.2 : 0.05,
                            borderColor: isSelected
                                ? AppTheme.accentPink
                                : Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  flow,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                    color: isSelected
                                        ? AppTheme.accentPink
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                // ── Step 5: Symptoms ────────────────────────────────────────
                _stepLabel('5', 'Symptoms'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _allSymptoms.map((symptom) {
                    final isSelected = _selectedSymptoms.contains(symptom);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSymptoms.remove(symptom);
                          } else {
                            _selectedSymptoms.add(symptom);
                          }
                        });
                      },
                      child: GlassContainer(
                        radius: 12,
                        opacity: isSelected ? 0.2 : 0.05,
                        borderColor: isSelected
                            ? AppTheme.accentPink
                            : Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Text(
                            symptom,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isSelected
                                  ? AppTheme.accentPink
                                  : AppTheme.textDark,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 32),

                // ── Step 6: Mood ────────────────────────────────────────────
                _stepLabel('6', 'Current Mood'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: _allMoods.entries.map((entry) {
                      final isSelected = _selectedMood == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedMood = entry.key),
                          child: GlassContainer(
                            radius: 20,
                            width: 64,
                            opacity: isSelected ? 0.2 : 0.05,
                            borderColor: isSelected
                                ? AppTheme.accentPink
                                : Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 26),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.key,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppTheme.textDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 48),

                // ── Save Button ─────────────────────────────────────────────
                GlassContainer(
                  radius: 24,
                  padding: EdgeInsets.zero,
                  borderColor: _selectedDate == null
                      ? Colors.transparent
                      : AppTheme.accentPink.withOpacity(0.4),
                  onTap: _selectedDate == null
                      ? () {}
                      : () async {
                          final dateWithTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _isAM ? 8 : 20,
                          );
                          final duration =
                              int.tryParse(_durationController.text.trim()) ??
                              5;
                          final log = PeriodLog(
                            startDate: dateWithTime,
                            duration: duration,
                            flowIntensity: _flowIntensity,
                            symptoms: _selectedSymptoms,
                            mood: _selectedMood,
                          );
                          final storage = Provider.of<StorageService>(
                            context,
                            listen: false,
                          );
                          final predView = Provider.of<PredictionService>(
                            context,
                            listen: false,
                          );
                          await storage.saveLog(log);

                          if (mounted) {
                            showPhaseDelight(
                              context,
                              predView.phaseDisplayName,
                            );
                            Navigator.pop(context);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Period logged! ✨'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.accentPink,
                            ),
                          );
                        },
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_done_rounded,
                          color: _selectedDate == null
                              ? AppTheme.textSecondary
                              : AppTheme.accentPink,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Save Log',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _selectedDate == null
                                ? AppTheme.textSecondary
                                : AppTheme.accentPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepLabel(String step, String label) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppTheme.accentPink,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _amPmButton(String label, bool isActive, VoidCallback onTap) {
    return GlassContainer(
      radius: 18,
      opacity: isActive ? 0.15 : 0.05,
      borderColor: isActive
          ? AppTheme.accentPink.withOpacity(0.3)
          : Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'AM'
                  ? Icons.wb_sunny_rounded
                  : Icons.nights_stay_rounded,
              color: isActive ? AppTheme.accentPink : AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                color: isActive ? AppTheme.accentPink : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
