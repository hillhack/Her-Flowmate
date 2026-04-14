import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'main_navigation_screen.dart';
import '../models/period_log.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isEmailUser;
  final String prefillName; 
  final String? forceGoal;
  final int initialPage;

  const OnboardingScreen({
    super.key,
    this.isEmailUser = false,
    this.prefillName = '',
    this.forceGoal,
    this.initialPage = 0,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  final TextEditingController _weeksController = TextEditingController();
  final TextEditingController _avgCycleController = TextEditingController(text: '28');
  final TextEditingController _durationController = TextEditingController(text: '5');
  DateTime? _conceptionDate;

  String? _weeksError;
  String? _dateError;

  late int _currentPage;
  static const int _totalPages = 3;
  late String _selectedGoal;
  DateTime? _lastPeriodStart;
  bool _isAM = true;
  String _pregnancyInputMode = 'weeks'; 

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    _selectedGoal = widget.forceGoal ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _weeksController.dispose();
    _avgCycleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _next() {
    setState(() {
      _weeksError = null;
      _dateError = null;
    });

    if (_currentPage == 0 && _selectedGoal.isEmpty) return;
    
    if (_currentPage == 1) {
      if (_selectedGoal == 'pregnant') {
        if (_pregnancyInputMode == 'weeks' && _weeksController.text.trim().isEmpty) {
          setState(() => _weeksError = 'Please enter how many weeks pregnant you are.');
          return;
        }
        if (_pregnancyInputMode == 'date' && _conceptionDate == null) {
          setState(() => _dateError = 'Please select your conception date.');
          return;
        }
      } else if (_lastPeriodStart == null) {
        setState(() => _dateError = 'Please select your last period start date.');
        return;
      }
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final storage = context.read<StorageService>();
    final avgCycleLength = int.tryParse(_avgCycleController.text.trim()) ?? 28;

    await storage.completeRadicalOnboarding(
      goal: _selectedGoal,
      avgCycleLength: avgCycleLength,
    );

    if (_selectedGoal == 'pregnant') {
      final w = int.tryParse(_weeksController.text.trim());
      await storage.savePregnancyData(
        conceptionDate: _pregnancyInputMode == 'date' ? _conceptionDate : null,
        weeks: _pregnancyInputMode == 'weeks' ? w : null,
      );
    } else if (_lastPeriodStart != null) {
      final logDate = DateTime(
        _lastPeriodStart!.year,
        _lastPeriodStart!.month,
        _lastPeriodStart!.day,
        _isAM ? 9 : 21,
      );
      final duration = int.tryParse(_durationController.text.trim()) ?? 5;

      final periodLog = PeriodLog(
        startDate: logDate,
        duration: duration,
        endDate: logDate.add(Duration(days: duration - 1)),
        isAM: _isAM,
      );
      await storage.saveLog(periodLog);
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  bool _isPageValid() {
    switch (_currentPage) {
      case 0:
        return _selectedGoal.isNotEmpty;
      case 1:
        if (_selectedGoal == 'pregnant') {
          if (_pregnancyInputMode == 'weeks') {
            final w = int.tryParse(_weeksController.text.trim());
            return w != null && w > 0 && w <= 42;
          }
          return _conceptionDate != null;
        }
        return _lastPeriodStart != null;
      case 2:
        return true; // Cycle length is optional/defaulted
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.getBackgroundDecoration(context),
      child: PopScope(
        canPop: _currentPage == widget.initialPage,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isSmall = constraints.maxWidth < 360;
                    final double horizontalPadding = isSmall ? 18.0 : 28.0;
                    final bool isValid = _isPageValid();

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              if (_currentPage > widget.initialPage)
                                ThemedContainer(
                                  type: ContainerType.neu,
                                  padding: const EdgeInsets.all(12),
                                  radius: 16,
                                  onTap: () {
                                    _pageController.previousPage(duration: 400.ms, curve: Curves.easeOutCubic);
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    size: 18,
                                  ),
                                )
                              else
                                const SizedBox(width: 42),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Step ${_currentPage + 1} • ${_getStepName(_currentPage)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _ProgressBar(
                                      current: _currentPage,
                                      total: _totalPages,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 54),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => FocusScope.of(context).unfocus(),
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              onPageChanged: (i) => setState(() => _currentPage = i),
                              children: [
                                _GoalPage(
                                  selectedGoal: _selectedGoal,
                                  onGoalSelected: (goal) => setState(() => _selectedGoal = goal),
                                  isSmall: isSmall,
                                  horizontalPadding: horizontalPadding,
                                ).animate().fadeIn(duration: 400.ms),
                                _DatePage(
                                  selectedGoal: _selectedGoal,
                                  weeksController: _weeksController,
                                  lastPeriodStart: _lastPeriodStart,
                                  conceptionDate: _conceptionDate,
                                  isAM: _isAM,
                                  pregnancyInputMode: _pregnancyInputMode,
                                  weeksError: _weeksError,
                                  dateError: _dateError,
                                  onWeeksChanged: () => setState(() {}),
                                  onDateChanged: (d) => setState(() => _lastPeriodStart = d),
                                  onConceptionDateChanged: (d) => setState(() => _conceptionDate = d),
                                  onAMPMChanged: (val) => setState(() => _isAM = val),
                                  onInputModeChanged: (mode) => setState(() => _pregnancyInputMode = mode),
                                  isSmall: isSmall,
                                  horizontalPadding: horizontalPadding,
                                ).animate().fadeIn(duration: 400.ms),
                                _PersonalizationPage(
                                  selectedGoal: _selectedGoal,
                                  avgCycleController: _avgCycleController,
                                  durationController: _durationController,
                                  isSmall: isSmall,
                                  horizontalPadding: horizontalPadding,
                                  onSkip: _finish,
                                ).animate().fadeIn(duration: 400.ms),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 24),
                          child: Opacity(
                            opacity: isValid ? 1.0 : 0.5,
                            child: GestureDetector(
                              onTap: isValid ? _next : null,
                              child: ThemedContainer(
                                type: ContainerType.simple,
                                width: double.infinity,
                                height: 58,
                                radius: 20,
                                gradient: AppTheme.brandGradient,
                                boxShadow: [
                                  if (isValid)
                                    BoxShadow(
                                      color: AppTheme.accentPink.withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                ],
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentPage == _totalPages - 1 ? "Start Your Journey" : "Continue",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _currentPage == _totalPages - 1 ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  final String selectedGoal;
  final Function(String) onGoalSelected;
  final bool isSmall;
  final double horizontalPadding;

  const _GoalPage({
    required this.selectedGoal,
    required this.onGoalSelected,
    required this.isSmall,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            "What's your goal?",
            style: AppTheme.playfair(fontSize: 32, fontWeight: FontWeight.w900),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            "We'll customize your companion based on your choice.",
            style: AppTheme.outfit(color: AppTheme.textSecondary),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 40),
          _goalCard(context, 'track_cycle', 'Track my cycle', 'Log periods and symptoms.', Icons.calendar_today_rounded),
          const SizedBox(height: 16),
          _goalCard(context, 'conceive', 'I want to conceive', 'Pinpoint your fertile window.', Icons.favorite_rounded),
          const SizedBox(height: 16),
          _goalCard(context, 'pregnant', 'I am pregnant', 'Track milestones and growth.', Icons.child_care_rounded),
        ],
      ),
    );
  }

  Widget _goalCard(BuildContext context, String id, String title, String subtitle, IconData icon) {
    final isSelected = selectedGoal == id;
    return GestureDetector(
      onTap: () => onGoalSelected(id),
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: 300.ms,
        child: ThemedContainer(
          type: isSelected ? ContainerType.elevated : ContainerType.glass,
          padding: const EdgeInsets.all(20),
          radius: 24,
          border: isSelected ? Border.all(color: AppTheme.accentPink, width: 2) : null,
          child: Row(
            children: [
              ThemedContainer(
                type: ContainerType.simple,
                padding: const EdgeInsets.all(12),
                radius: 40,
                color: isSelected ? AppTheme.accentPink : AppTheme.accentPink.withValues(alpha: 0.05),
                child: Icon(icon, color: isSelected ? Colors.white : AppTheme.accentPink, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: isSelected ? AppTheme.accentPink : null)),
                    Text(subtitle, style: AppTheme.outfit(fontSize: 14, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePage extends StatelessWidget {
  final String selectedGoal;
  final TextEditingController weeksController;
  final DateTime? lastPeriodStart;
  final DateTime? conceptionDate;
  final bool isAM;
  final String pregnancyInputMode;
  final String? weeksError;
  final String? dateError;
  final VoidCallback onWeeksChanged;
  final Function(DateTime) onDateChanged;
  final Function(DateTime) onConceptionDateChanged;
  final Function(bool) onAMPMChanged;
  final Function(String) onInputModeChanged;
  final bool isSmall;
  final double horizontalPadding;

  const _DatePage({
    required this.selectedGoal,
    required this.weeksController,
    required this.lastPeriodStart,
    required this.conceptionDate,
    required this.isAM,
    required this.pregnancyInputMode,
    this.weeksError,
    this.dateError,
    required this.onWeeksChanged,
    required this.onDateChanged,
    required this.onConceptionDateChanged,
    required this.onAMPMChanged,
    required this.onInputModeChanged,
    required this.isSmall,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            selectedGoal == 'pregnant' ? "Almost there!" : "One more thing...",
            style: AppTheme.playfair(fontSize: 32, fontWeight: FontWeight.w900),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            selectedGoal == 'pregnant' ? "How far along are you?" : "When did your last period start?",
            style: AppTheme.outfit(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 40),
          if (selectedGoal == 'pregnant') _pregnancyInput(context) else _cycleInput(context),
        ],
      ),
    );
  }

  Widget _pregnancyInput(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _toggleItem(context, 'weeks', 'Weeks', pregnancyInputMode == 'weeks'),
            const SizedBox(width: 12),
            _toggleItem(context, 'date', 'LMP Date', pregnancyInputMode == 'date'),
          ],
        ),
        const SizedBox(height: 32),
        if (pregnancyInputMode == 'weeks')
          _setupInput(context, "I AM PREGNANT (WEEKS)", weeksController, "e.g. 8", isNumeric: true)
        else
          _dateSelectionField(context, conceptionDate, onConceptionDateChanged, 'Select LMP date'),
      ],
    );
  }

  Widget _cycleInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dateSelectionField(context, lastPeriodStart, onDateChanged, 'Select period start date'),
        const SizedBox(height: 32),
        Text("TIME OF DAY (OPTIONAL)", style: AppTheme.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        Row(
          children: [
            _ampmToggle(context, true, 'Morning', '9:00 AM'),
            const SizedBox(width: 12),
            _ampmToggle(context, false, 'Evening', '9:00 PM'),
          ],
        ),
      ],
    );
  }

  Widget _dateSelectionField(BuildContext context, DateTime? selectedDate, Function(DateTime) onDatePicked, String hint) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 300)),
          lastDate: DateTime.now(),
        );
        if (d != null) onDatePicked(d);
      },
      child: ThemedContainer(
        type: ContainerType.glass,
        radius: 20,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppTheme.accentPink, size: 24),
            const SizedBox(width: 16),
            Text(
              selectedDate == null ? hint : DateFormat('MMMM dd, yyyy').format(selectedDate),
              style: AppTheme.outfit(fontSize: 18, color: selectedDate == null ? AppTheme.textSecondary : null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(BuildContext context, String mode, String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onInputModeChanged(mode),
        child: AnimatedScale(
          scale: active ? 1.05 : 1.0,
          duration: 300.ms,
          child: ThemedContainer(
            type: ContainerType.simple,
            padding: const EdgeInsets.symmetric(vertical: 14),
            radius: 16,
            color: active ? AppTheme.accentPink : AppTheme.accentPink.withValues(alpha: 0.05),
            child: Center(
              child: Text(
                label, 
                style: AppTheme.outfit(fontWeight: FontWeight.w700, color: active ? Colors.white : AppTheme.textSecondary)
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _ampmToggle(BuildContext context, bool value, String label, String time) {
    final active = isAM == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onAMPMChanged(value),
        child: ThemedContainer(
          type: ContainerType.simple,
          padding: const EdgeInsets.all(16),
          radius: 20,
          color: active ? AppTheme.accentPink.withValues(alpha: 0.1) : AppTheme.accentPink.withValues(alpha: 0.03),
          border: Border.all(color: active ? AppTheme.accentPink : Colors.transparent, width: 2),
          child: Column(
            children: [
              Text(label, style: AppTheme.outfit(fontWeight: FontWeight.w800, color: active ? AppTheme.accentPink : null)),
              Text(time, style: AppTheme.outfit(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setupInput(BuildContext context, String label, TextEditingController controller, String hint, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
        const SizedBox(height: 12),
        ThemedContainer(
          type: ContainerType.glass,
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: AppTheme.outfit(fontSize: 18),
            decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: AppTheme.outfit(color: AppTheme.textSecondary.withValues(alpha: 0.5))),
          ),
        ),
      ],
    );
  }
}

class _PersonalizationPage extends StatelessWidget {
  final String selectedGoal;
  final TextEditingController avgCycleController;
  final TextEditingController durationController;
  final bool isSmall;
  final double horizontalPadding;
  final VoidCallback onSkip;

  const _PersonalizationPage({
    required this.selectedGoal,
    required this.avgCycleController,
    required this.durationController,
    required this.isSmall,
    required this.horizontalPadding,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            "Personalize",
            style: AppTheme.playfair(fontSize: 32, fontWeight: FontWeight.w900),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            "Help us tune our predictions to your body.",
            style: AppTheme.outfit(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 40),
          _setupInput(context, "AVERAGE CYCLE LENGTH (DAYS)", avgCycleController, "Default is 28", isNumeric: true),
          const SizedBox(height: 24),
          _setupInput(context, "AVERAGE PERIOD DURATION (DAYS)", durationController, "Default is 5", isNumeric: true),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                "I'm not sure, skip for now",
                style: AppTheme.outfit(color: AppTheme.accentPink, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setupInput(BuildContext context, String label, TextEditingController controller, String hint, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
        const SizedBox(height: 12),
        ThemedContainer(
          type: ContainerType.glass,
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: AppTheme.outfit(fontSize: 18),
            decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: AppTheme.outfit(color: AppTheme.textSecondary.withValues(alpha: 0.5))),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current, total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      type: ContainerType.simple,
      height: 6,
      width: double.infinity,
      radius: 10,
      color: AppTheme.accentPink.withValues(alpha: 0.1),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (current + 1) / total,
        child: const ThemedContainer(
          type: ContainerType.simple,
          radius: 10,
          gradient: AppTheme.brandGradient,
          child: SizedBox.shrink(),
        ),
      ),
    );
  }
}

String _getStepName(int page) {
  switch (page) {
    case 0: return 'Goal';
    case 1: return 'Date';
    case 2: return 'Personalization';
    default: return '';
  }
}

