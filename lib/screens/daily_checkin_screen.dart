import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/daily_log.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_container.dart';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({super.key});

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedMoods = []; // Now supports multiple moods
  int _waterIntake = 0;
  String? _selectedFlow;
  final List<String> _selectedActivities = [];
  final TextEditingController _notesController = TextEditingController();

  // New health fields
  double _sleepHours = 7.0;
  int? _energyLevel;
  int? _stressLevel;
  int _stepsCount = 0;
  final TextEditingController _stepsController = TextEditingController();

  final List<String> _standardSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Acne',
    'Backache',
    'Tender Breasts',
    'Nausea',
    'Fatigue',
    'Cravings',
  ];

  final List<String> _pregnancySymptoms = [
    'Morning Sickness',
    'Heartburn',
    'Back Pain',
    'Swollen Feet',
    'Frequent Urination',
    'Ligament Pain',
    'Breast Changes',
    'Dizziness',
    'Fatigue',
    'Cravings',
  ];

  final List<String> _allFlows = ['Light', 'Medium', 'Heavy'];
  final List<String> _allActivities = [
    'Walking',
    'Running',
    'Yoga',
    'Strength',
    'Cycling',
    'Swimming',
    'Rest Day',
  ];

  final Map<String, String> _allMoods = {
    'Happy': '😊',
    'Energetic': '⚡',
    'Tired': '😴',
    'Sad': '😢',
    'Anxious': '😰',
    'Angry': '😠',
    'Sensitive': '🥺',
  };

  @override
  void initState() {
    super.initState();
    _stepsController.text = '0';
    // Preload if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = context.read<StorageService>();
      final existing = storage.getDailyLog(_selectedDate);
      if (existing != null) {
        setState(() {
          _selectedMoods
            ..clear()
            ..addAll(existing.moods ?? []);
          _selectedSymptoms.addAll(existing.symptoms ?? []);
          _waterIntake = existing.waterIntake ?? 0;
          _notesController.text = existing.notes ?? '';
          _selectedFlow = existing.flowIntensity;
          _selectedActivities.addAll(existing.physicalActivity ?? []);
          _sleepHours = existing.sleepHours ?? 7.0;
          _energyLevel = existing.energyLevel;
          _stressLevel = existing.stressLevel;
          _stepsCount = existing.stepsCount ?? 0;
          _stepsController.text = '$_stepsCount';
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.frameColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.only(top: 16),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
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
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Daily Check-in',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    'How are you feeling today?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 40),

                  // ── Date ────────────────────────────────────────────
                  _stepLabel(context, '📅', 'Date'),
                  const SizedBox(height: 16),
                  NeuContainer(
                    radius: 24,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder:
                            (ctx, child) => Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppTheme.accentPink,
                                  surface: AppTheme.frameColor,
                                ),
                              ),
                              child: child!,
                            ),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                          _selectedSymptoms.clear();
                          _selectedMoods.clear();
                          _waterIntake = 0;
                          _notesController.clear();
                          _selectedFlow = null;
                          _selectedActivities.clear();
                          _sleepHours = 7.0;
                          _energyLevel = null;
                          _stressLevel = null;
                          _stepsCount = 0;
                          _stepsController.text = '0';
                        });
                        if (!context.mounted) return;
                        final existing = context
                            .read<StorageService>()
                            .getDailyLog(date);
                        if (existing != null) {
                          setState(() {
                            _selectedMoods
                              ..clear()
                              ..addAll(existing.moods ?? []);
                            _selectedSymptoms.addAll(existing.symptoms ?? []);
                            _waterIntake = existing.waterIntake ?? 0;
                            _notesController.text = existing.notes ?? '';
                            _selectedFlow = existing.flowIntensity;
                            _selectedActivities.addAll(
                              existing.physicalActivity ?? [],
                            );
                            _sleepHours = existing.sleepHours ?? 7.0;
                            _energyLevel = existing.energyLevel;
                            _stressLevel = existing.stressLevel;
                            _stepsCount = existing.stepsCount ?? 0;
                            _stepsController.text = '$_stepsCount';
                          });
                        }
                      }
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
                            DateFormat(
                              'EEEE, MMM d, yyyy',
                            ).format(_selectedDate),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color:
                                  isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.textDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
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

                  // ── Mood ────────────────────────────────────────────
                  _stepLabel(context, '🎭', 'Mood (pick all that apply)'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        _allMoods.entries.map((e) {
                          final isSel = _selectedMoods.contains(e.key);
                          return GestureDetector(
                            onTap:
                                () => setState(() {
                                  isSel
                                      ? _selectedMoods.remove(e.key)
                                      : _selectedMoods.add(e.key);
                                }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSel
                                        ? AppTheme.accentPink
                                        : (isDark
                                            ? AppTheme.darkSurface.withValues(
                                              alpha: 0.5,
                                            )
                                            : Colors.white.withValues(
                                              alpha: 0.5,
                                            )),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow:
                                    isSel
                                        ? [
                                          BoxShadow(
                                            color: AppTheme.accentPink
                                                .withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    e.value,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    e.key,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight:
                                          isSel
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                      color:
                                          isSel
                                              ? Colors.white
                                              : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  // ── Symptoms ────────────────────────────────────────────
                  _stepLabel(context, '🤒', 'Symptoms'),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final isPregnant =
                          context.read<StorageService>().userGoal == 'pregnant';
                      final symptoms =
                          isPregnant ? _pregnancySymptoms : _standardSymptoms;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            symptoms.map((sym) {
                              final isSel = _selectedSymptoms.contains(sym);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSel
                                        ? _selectedSymptoms.remove(sym)
                                        : _selectedSymptoms.add(sym);
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSel
                                            ? const Color(0xFFBA68C8)
                                            : (isDark
                                                ? AppTheme.darkSurface
                                                    .withValues(alpha: 0.5)
                                                : Colors.white.withValues(
                                                  alpha: 0.5,
                                                )),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow:
                                        isSel
                                            ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFFBA68C8,
                                                ).withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                            : [],
                                  ),
                                  child: Text(
                                    sym,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight:
                                          isSel
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                      color:
                                          isSel
                                              ? Colors.white
                                              : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 32),

                  // ── Flow Intensity (Only if not pregnant) ──────────────────
                  Builder(
                    builder: (context) {
                      final isPregnant =
                          context.read<StorageService>().userGoal == 'pregnant';
                      if (isPregnant) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _stepLabel(context, '🩸', 'Flow Intensity'),
                          const SizedBox(height: 16),
                          Row(
                            children:
                                _allFlows.map((flowStr) {
                                  final isSel = _selectedFlow == flowStr;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(
                                            () => _selectedFlow = flowStr,
                                          ),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: EdgeInsets.only(
                                          right:
                                              flowStr == _allFlows.last
                                                  ? 0
                                                  : 12,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSel
                                                  ? AppTheme.accentPink
                                                  : Colors.white.withValues(
                                                    alpha: 0.5,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow:
                                              isSel
                                                  ? [
                                                    BoxShadow(
                                                      color: AppTheme.accentPink
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ]
                                                  : [],
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          flowStr,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight:
                                                isSel
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                            color:
                                                isSel
                                                    ? Colors.white
                                                    : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 32),

                  // ── Physical Activity ─────────────────────────────────────────
                  _stepLabel(context, '🏃‍♀️', 'Physical Activity'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        _allActivities.map((act) {
                          final isSel = _selectedActivities.contains(act);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                isSel
                                    ? _selectedActivities.remove(act)
                                    : _selectedActivities.add(act);
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSel
                                        ? const Color(0xFF81C784)
                                        : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow:
                                    isSel
                                        ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF81C784,
                                            ).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Text(
                                act,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight:
                                      isSel ? FontWeight.bold : FontWeight.w600,
                                  color:
                                      isSel
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 32),

                  // ── Water Intake ─────────────────────────────────────────
                  _stepLabel(context, '💧', 'Water Intake (Glasses)'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppTheme.accentPink,
                          size: 32,
                        ),
                        onPressed: () {
                          if (_waterIntake > 0) setState(() => _waterIntake--);
                        },
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$_waterIntake',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppTheme.accentPink,
                          size: 32,
                        ),
                        onPressed: () {
                          if (_waterIntake < 20) setState(() => _waterIntake++);
                        },
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 32),

                  // ── Sleep ─────────────────────────────────────────────────
                  _stepLabel(context, '🌙', 'Sleep Hours'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${_sleepHours.toStringAsFixed(1)}h',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _sleepHours < 6
                            ? '😴 Rest more'
                            : (_sleepHours >= 8 ? '✨ Well rested' : '😌 Ok'),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.accentPink,
                      inactiveTrackColor: AppTheme.accentPink.withValues(
                        alpha: 0.2,
                      ),
                      thumbColor: AppTheme.accentPink,
                      overlayColor: AppTheme.accentPink.withValues(alpha: 0.15),
                    ),
                    child: Slider(
                      value: _sleepHours,
                      min: 3.0,
                      max: 12.0,
                      divisions: 18,
                      onChanged: (val) => setState(() => _sleepHours = val),
                    ),
                  ).animate().fadeIn(delay: 550.ms),

                  const SizedBox(height: 32),

                  // ── Energy Level ──────────────────────────────────────────
                  _stepLabel(context, '⚡', 'Energy Level'),
                  const SizedBox(height: 4),
                  Text(
                    '1 = Exhausted  ·  5 = Super Energetic',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLevelRow(
                    current: _energyLevel,
                    emojis: const ['😴', '🥱', '😐', '😊', '🤩'],
                    onTap: (v) => setState(() => _energyLevel = v),
                  ).animate().fadeIn(delay: 580.ms),

                  const SizedBox(height: 32),

                  // ── Stress Level ──────────────────────────────────────────
                  _stepLabel(context, '🧘', 'Stress Level'),
                  const SizedBox(height: 4),
                  Text(
                    '1 = Very Calm  ·  5 = Very Stressed',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLevelRow(
                    current: _stressLevel,
                    emojis: const ['😌', '🙂', '😐', '😟', '😰'],
                    onTap: (v) => setState(() => _stressLevel = v),
                  ).animate().fadeIn(delay: 610.ms),

                  const SizedBox(height: 32),

                  // ── Steps ─────────────────────────────────────────────────
                  _stepLabel(context, '👟', 'Steps Today'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _stepsController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _stepsCount = int.tryParse(v) ?? 0,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g. 6500',
                        hintStyle: GoogleFonts.inter(
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.directions_walk_rounded,
                          color: AppTheme.accentPink,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fadeIn(delay: 630.ms),

                  const SizedBox(height: 32),

                  // ── Notes ─────────────────────────────────────────
                  _stepLabel(context, '📝', 'Journal'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'How was your day?',
                        hintStyle: GoogleFonts.inter(
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                      style: GoogleFonts.inter(
                        color:
                            isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.textDark,
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 48),

                  // ── Save Button ─────────────────────────────────────────────
                  GestureDetector(
                    onTap: () async {
                      await context.read<StorageService>().saveDailyLog(
                        DailyLog(
                          date: _selectedDate,
                          moods:
                              _selectedMoods.isNotEmpty
                                  ? List.from(_selectedMoods)
                                  : null,
                          symptoms:
                              _selectedSymptoms.isNotEmpty
                                  ? List.from(_selectedSymptoms)
                                  : null,
                          waterIntake: _waterIntake,
                          notes:
                              _notesController.text.isNotEmpty
                                  ? _notesController.text
                                  : null,
                          flowIntensity: _selectedFlow,
                          physicalActivity:
                              _selectedActivities.isNotEmpty
                                  ? List.from(_selectedActivities)
                                  : null,
                          sleepHours: _sleepHours,
                          energyLevel: _energyLevel,
                          stressLevel: _stressLevel,
                          stepsCount: _stepsCount,
                        ),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Check-in saved! 🌸',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF4CAF50),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBA68C8), AppTheme.accentPink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentPink.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Save Check-in',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepLabel(BuildContext context, String emoji, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 14),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  /// A 1-5 emoji rating row for energy/stress level pickers.
  Widget _buildLevelRow({
    required int? current,
    required List<String> emojis,
    required void Function(int) onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final level = i + 1;
        final isSelected = current == level;
        return GestureDetector(
          onTap: () => onTap(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppTheme.accentPink
                      : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppTheme.accentPink.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emojis[i], style: const TextStyle(fontSize: 20)),
                Text(
                  '$level',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
