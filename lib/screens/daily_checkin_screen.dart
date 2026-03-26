import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/daily_log.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_container.dart';
import '../widgets/delight_widgets.dart';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({super.key});

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedSymptoms = [];
  String? _selectedMood;
  int _waterIntake = 0;
  String? _selectedFlow;
  final List<String> _selectedActivities = [];
  final TextEditingController _notesController = TextEditingController();

  final List<String> _allSymptoms = [
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
    // Preload if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = context.read<StorageService>();
      final existing = storage.getDailyLog(_selectedDate);
      if (existing != null) {
        setState(() {
          if (existing.moods?.isNotEmpty == true)
            _selectedMood = existing.moods!.first;
          _selectedSymptoms.addAll(existing.symptoms ?? []);
          _waterIntake = existing.waterIntake ?? 0;
          _notesController.text = existing.notes ?? '';
          _selectedFlow = existing.flowIntensity;
          _selectedActivities.addAll(existing.physicalActivity ?? []);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.frameColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: NeuContainer(
        radius: 40,
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
                      color: Colors.white.withOpacity(0.2),
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
                    color: AppTheme.textDark,
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
                _stepLabel('📅', 'Date'),
                const SizedBox(height: 16),
                NeuContainer(
                  radius: 24,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppTheme.accentPink,
                            surface: AppTheme.frameColor,
                          ),
                          dialogBackgroundColor: AppTheme.frameColor,
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                        _selectedSymptoms.clear();
                        _selectedMood = null;
                        _waterIntake = 0;
                        _notesController.clear();
                        _selectedFlow = null;
                        _selectedActivities.clear();
                      });
                      final existing = context
                          .read<StorageService>()
                          .getDailyLog(date);
                      if (existing != null) {
                        setState(() {
                          if (existing.moods?.isNotEmpty == true)
                            _selectedMood = existing.moods!.first;
                          _selectedSymptoms.addAll(existing.symptoms ?? []);
                          _waterIntake = existing.waterIntake ?? 0;
                          _notesController.text = existing.notes ?? '';
                          _selectedFlow = existing.flowIntensity;
                          _selectedActivities.addAll(
                            existing.physicalActivity ?? [],
                          );
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
                          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.textDark,
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
                _stepLabel('🎭', 'Mood'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _allMoods.entries.map((e) {
                    final isSel = _selectedMood == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppTheme.accentPink
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: AppTheme.accentPink.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(e.value, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              e.key,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSel
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
                _stepLabel('🤒', 'Symptoms'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _allSymptoms.map((sym) {
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
                          color: isSel
                              ? const Color(0xFFBA68C8)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFBA68C8,
                                    ).withOpacity(0.3),
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
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSel
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                // ── Flow Intensity ─────────────────────────────────────────
                _stepLabel('🩸', 'Flow Intensity'),
                const SizedBox(height: 16),
                Row(
                  children: _allFlows.map((flowStr) {
                    final isSel = _selectedFlow == flowStr;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFlow = flowStr),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(
                            right: flowStr == _allFlows.last ? 0 : 12,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppTheme.accentPink
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: AppTheme.accentPink.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            flowStr,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isSel
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSel
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 32),

                // ── Physical Activity ─────────────────────────────────────────
                _stepLabel('🏃‍♀️', 'Physical Activity'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _allActivities.map((act) {
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
                          color: isSel
                              ? const Color(0xFF81C784)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF81C784,
                                    ).withOpacity(0.3),
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
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSel
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
                _stepLabel('💧', 'Water Intake (Glasses)'),
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

                // ── Notes ─────────────────────────────────────────
                _stepLabel('📝', 'Journal'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'How was your day?',
                      hintStyle: GoogleFonts.inter(
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                    ),
                    style: GoogleFonts.inter(color: AppTheme.textDark),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 48),

                // ── Save Button ─────────────────────────────────────────────
                GestureDetector(
                  onTap: () async {
                    final log = DailyLog(
                      date: _selectedDate,
                      moods: _selectedMood != null ? [_selectedMood!] : null,
                      symptoms: _selectedSymptoms.isNotEmpty
                          ? List.from(_selectedSymptoms)
                          : null,
                      waterIntake: _waterIntake,
                      notes: _notesController.text.isNotEmpty
                          ? _notesController.text
                          : null,
                      flowIntensity: _selectedFlow,
                      physicalActivity: _selectedActivities.isNotEmpty
                          ? List.from(_selectedActivities)
                          : null,
                    );

                    await context.read<StorageService>().saveDailyLog(log);
                    if (mounted) Navigator.pop(context);
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
                          color: AppTheme.accentPink.withOpacity(0.4),
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
    );
  }

  Widget _stepLabel(String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
