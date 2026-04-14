import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../models/daily_log.dart';
import '../utils/app_theme.dart';

class DailyCheckinScreen extends StatefulWidget {
  const DailyCheckinScreen({super.key});

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  int _currentStep = 0; // 0: Feels, 1: Body, 2: Day
  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedMoods = [];
  int _waterIntake = 0;
  String? _selectedFlow;
  final List<String> _selectedActivities = [];
  final TextEditingController _notesController = TextEditingController();

  double _sleepHours = 7.0;
  int? _energyLevel;
  int? _stressLevel;
  int _stepsCount = 0;
  final TextEditingController _stepsController = TextEditingController();

  final List<String> _standardSymptoms = [
    'Cramps', 'Headache', 'Bloating', 'Acne', 'Backache',
    'Tender Breasts', 'Nausea', 'Fatigue', 'Cravings',
  ];

  final List<String> _pregnancySymptoms = [
    'Morning Sickness', 'Heartburn', 'Back Pain', 'Swollen Feet',
    'Frequent Urination', 'Ligament Pain', 'Breast Changes',
    'Dizziness', 'Fatigue', 'Cravings',
  ];

  final List<String> _allFlows = ['Light', 'Medium', 'Heavy'];
  final List<String> _allActivities = [
    'Walking', 'Running', 'Yoga', 'Strength', 'Cycling', 'Swimming', 'Rest Day',
  ];

  final Map<String, String> _allMoods = {
    'Happy': '😊', 'Energetic': '⚡', 'Tired': '😴', 'Sad': '😢',
    'Anxious': '😰', 'Angry': '😠', 'Sensitive': '🥺',
  };

  @override
  void initState() {
    super.initState();
    _stepsController.text = '0';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = context.read<StorageService>();
      final existing = storage.getDailyLog(_selectedDate);
      if (existing != null) _loadLog(existing);
    });
  }

  void _loadLog(DailyLog log) {
    setState(() {
      _selectedMoods..clear()..addAll(log.moods ?? []);
      _selectedSymptoms..clear()..addAll(log.symptoms ?? []);
      _waterIntake = log.waterIntake ?? 0;
      _notesController.text = log.notes ?? '';
      _selectedFlow = log.flowIntensity;
      _selectedActivities..clear()..addAll(log.physicalActivity ?? []);
      _sleepHours = log.sleepHours ?? 7.0;
      _energyLevel = log.energyLevel;
      _stressLevel = log.stressLevel;
      _stepsCount = log.stepsCount ?? 0;
      _stepsController.text = '$_stepsCount';
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
          color: isDark ? AppTheme.darkBackground : AppTheme.frameColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(44)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildDragHandle(),
            const SizedBox(height: 16),
            _buildHeader(),
            _buildProgressBar(),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: 400.ms,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(_currentStep),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _getStepContent(),
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 44,
        height: 6,
        decoration: BoxDecoration(
          color: AppTheme.accentPink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['How You Feel', 'Your Body', 'Your Day'];
    final subs = ['Vibe & Energy', 'Symptoms & Cycle', 'Wellness & Notes'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            titles[_currentStep],
            style: AppTheme.playfair(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkOnSurface : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subs[_currentStep],
            style: AppTheme.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      height: 6,
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: 300.ms,
              margin: EdgeInsets.only(right: i == 2 ? 0 : 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accentPink : AppTheme.accentPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0: return _buildFeelsStep();
      case 1: return _buildBodyStep();
      case 2: return _buildDayStep();
      default: return const SizedBox();
    }
  }

  Widget _buildFeelsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        _stepLabel('📅', 'Date'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppTheme.accentPink, size: 22),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkOnSurface : AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.edit_rounded, color: AppTheme.accentPink, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        _stepLabel('🎭', 'Mood'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _allMoods.entries.map((e) {
            final isSel = _selectedMoods.contains(e.key);
            return _pillButton(label: e.key, emoji: e.value, isSelected: isSel, onTap: () {
              setState(() => isSel ? _selectedMoods.remove(e.key) : _selectedMoods.add(e.key));
            });
          }).toList(),
        ),
        const SizedBox(height: 32),
        _stepLabel('⚡', 'Energy & Stress'),
        const SizedBox(height: 16),
        _buildLevelPicker(
          label: 'Energy',
          current: _energyLevel,
          emojis: ['😴', '🥱', '😐', '😊', '🤩'],
          onTap: (v) => setState(() => _energyLevel = v),
        ),
        const SizedBox(height: 20),
        _buildLevelPicker(
          label: 'Stress',
          current: _stressLevel,
          emojis: ['😌', '🙂', '😐', '😟', '😰'],
          onTap: (v) => setState(() => _stressLevel = v),
        ),
      ],
    );
  }

  Widget _buildBodyStep() {
    final storage = context.read<StorageService>();
    final isPregnant = storage.userGoal == 'pregnant';
    final symptoms = isPregnant ? _pregnancySymptoms : _standardSymptoms;

    return Column(
      children: [
        _stepLabel('🤒', 'Physical Symptoms'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: symptoms.map((sym) {
            final isSel = _selectedSymptoms.contains(sym);
            return _pillButton(
              label: sym,
              isSelected: isSel,
              onTap: () => setState(() => isSel ? _selectedSymptoms.remove(sym) : _selectedSymptoms.add(sym)),
              activeColor: const Color(0xFFBA68C8),
            );
          }).toList(),
        ),
        if (!isPregnant) ...[
          const SizedBox(height: 32),
          _stepLabel('🩸', 'Flow Intensity'),
          const SizedBox(height: 16),
          Row(
            children: _allFlows.map((f) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _pillButton(
                  label: f,
                  isSelected: _selectedFlow == f,
                  onTap: () => setState(() => _selectedFlow = f),
                ),
              ),
            )).toList(),
          ),
        ],
        const SizedBox(height: 32),
        _stepLabel('💧', 'Hydration'),
        const SizedBox(height: 16),
        _buildWaterPicker(),
      ],
    );
  }

  Widget _buildDayStep() {
    return Column(
      children: [
        _stepLabel('🏃‍♀️', 'Activities'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _allActivities.map((act) {
            final isSel = _selectedActivities.contains(act);
            return _pillButton(
              label: act,
              isSelected: isSel,
              onTap: () => setState(() => isSel ? _selectedActivities.remove(act) : _selectedActivities.add(act)),
              activeColor: const Color(0xFF81C784),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        _stepLabel('🌙', 'Sleep & Steps'),
        const SizedBox(height: 16),
        _buildLifestylePickers(),
        const SizedBox(height: 32),
        _stepLabel('📝', 'Personal Notes'),
        const SizedBox(height: 16),
        _buildNotesField(),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSurface : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              IconButton(
                onPressed: () => setState(() => _currentStep--),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppTheme.textSecondary,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _onPrimaryAction,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPink.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _currentStep == 2 ? 'Save Check-in' : 'Next Step',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPrimaryAction() {
    HapticFeedback.mediumImpact();
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _saveLog();
    }
  }

  Future<void> _saveLog() async {
    final storage = context.read<StorageService>();
    final log = DailyLog(
      date: _selectedDate,
      moods: _selectedMoods.isNotEmpty ? List.from(_selectedMoods) : null,
      symptoms: _selectedSymptoms.isNotEmpty ? List.from(_selectedSymptoms) : null,
      waterIntake: _waterIntake,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      flowIntensity: _selectedFlow,
      physicalActivity: _selectedActivities.isNotEmpty ? List.from(_selectedActivities) : null,
      sleepHours: _sleepHours,
      energyLevel: _energyLevel,
      stressLevel: _stressLevel,
      stepsCount: _stepsCount,
    );
    
    await storage.saveDailyLog(log);
    if (!mounted) return;
    
    _showSaveSuccess();
    Navigator.pop(context);
  }

  void _showSaveSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log saved gracefully 🌸', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.accentPink),
        ),
        child: child!,
      ),
    );
    if (!context.mounted) {
      return;
    }
    if (date != null) {
      _selectedDate = date;
      // ignore: use_build_context_synchronously
      final existing = context.read<StorageService>().getDailyLog(date);
      if (existing != null) {
        _loadLog(existing);
      } else {
        setState(() {
          _selectedMoods.clear();
          _selectedSymptoms.clear();
          _selectedActivities.clear();
          _waterIntake = 0;
          _notesController.clear();
          _stepsCount = 0;
          _stepsController.text = '0';
        });
      }
    }
  }

  // --- Helper Widgets ---

  Widget _stepLabel(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTheme.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkOnSurface : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _pillButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? emoji,
    Color? activeColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = activeColor ?? AppTheme.accentPink;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: 250.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primary : AppTheme.accentPink.withValues(alpha: 0.08)),
          boxShadow: isSelected ? [BoxShadow(color: primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[Text(emoji), const SizedBox(width: 8)],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelPicker({required String label, required int? current, required List<String> emojis, required Function(int) onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final level = i + 1;
            final isSel = current == level;
            return GestureDetector(
              onTap: () => onTap(level),
              child: AnimatedContainer(
                duration: 200.ms,
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSel ? AppTheme.accentPink : (isDark ? Colors.white12 : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSel ? AppTheme.accentPink : AppTheme.accentPink.withValues(alpha: 0.05)),
                ),
                alignment: Alignment.center,
                child: Text(emojis[i], style: const TextStyle(fontSize: 20)),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.outfit(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildWaterPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleIconButton(Icons.remove_rounded, () { if (_waterIntake > 0) setState(() => _waterIntake--); }),
        const SizedBox(width: 32),
        Text('$_waterIntake', style: AppTheme.playfair(fontSize: 40, fontWeight: FontWeight.w900)),
        const SizedBox(width: 32),
        _circleIconButton(Icons.add_rounded, () { if (_waterIntake < 20) setState(() => _waterIntake++); }),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.accentPink, width: 2)),
        child: Icon(icon, color: AppTheme.accentPink),
      ),
    );
  }

  Widget _buildLifestylePickers() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.accentPink.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_sleepHours.toStringAsFixed(1)}h Sleep', style: AppTheme.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(_sleepHours < 7 ? 'Needs rest' : 'Healthy sleep', style: AppTheme.outfit(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          Slider(
            value: _sleepHours, min: 2, max: 14, divisions: 12,
            activeColor: AppTheme.accentPink,
            onChanged: (v) => setState(() => _sleepHours = v),
          ),
          const Divider(height: 32),
          TextField(
            controller: _stepsController,
            keyboardType: TextInputType.number,
            onChanged: (v) => _stepsCount = int.tryParse(v) ?? 0,
            decoration: InputDecoration(
              icon: const Icon(Icons.directions_walk_rounded, color: AppTheme.accentPink),
              hintText: 'Steps today', border: InputBorder.none,
              hintStyle: AppTheme.outfit(fontSize: 16, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        hintText: 'Any specific memories or pains?',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }
}

