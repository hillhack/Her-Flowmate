import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_navigation_screen.dart';
import '../models/period_log.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import '../widgets/brand_widgets.dart';
import 'package:intl/intl.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isEmailUser;
  final String prefillName; // auto-filled from Google profile
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
  late final TextEditingController _nameController;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weeksController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(
    text: '5',
  );
  DateTime? _conceptionDate;

  String? _nameError;
  String? _ageError;
  String? _weeksError;
  String? _dateError;

  late int _currentPage;
  static const int _totalPages = 3;
  late String _selectedGoal;
  DateTime? _lastPeriodStart;
  bool _isAM = true;
  String _pregnancyInputMode = 'weeks'; // 'weeks' or 'date'

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    _nameController = TextEditingController(text: widget.prefillName);
    _selectedGoal = widget.forceGoal ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weeksController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _next() {
    setState(() {
      _nameError = null;
      _ageError = null;
      _weeksError = null;
      _dateError = null;
    });

    if (_currentPage == 0 && _selectedGoal.isEmpty) return;
    if (_currentPage == 1) {
      if (_nameController.text.trim().isEmpty) {
        setState(() => _nameError = 'Please enter your name.');
        return;
      }

      final ageStr = _ageController.text.trim();
      if (ageStr.isEmpty) {
        setState(() => _ageError = 'Please enter your age.');
        return;
      }

      final age = int.tryParse(ageStr);
      if (age == null || age < 10 || age > 100) {
        setState(() => _ageError = 'Please enter a valid age between 10 and 100.');
        return;
      }
    }
    if (_currentPage == 2) {
      if (_selectedGoal == 'pregnant') {
        if (_pregnancyInputMode == 'weeks' &&
            _weeksController.text.trim().isEmpty) {
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
    final age = int.tryParse(_ageController.text.trim());
    final storage = context.read<StorageService>();

    if (widget.initialPage == 0) {
      await storage.completeOnboarding(
        _selectedGoal,
        _nameController.text.trim(),
        age: age,
      );
    } else {
      await storage.updateUserGoal(_selectedGoal);
    }

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

      // FIX: Save period log correctly for track_cycle or conceive goals
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
        final age = int.tryParse(_ageController.text.trim());
        return _nameController.text.trim().isNotEmpty &&
            age != null &&
            age >= 10 &&
            age <= 100;
      case 2:
        if (_selectedGoal == 'pregnant') {
          if (_pregnancyInputMode == 'weeks') {
            final w = int.tryParse(_weeksController.text.trim());
            return w != null && w > 0 && w <= 42;
          }
          return _conceptionDate != null;
        }
        return _lastPeriodStart != null;
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
            // Unified Theme Background
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isSmall = constraints.maxWidth < 360;
                  final double horizontalPadding = isSmall ? 18.0 : 28.0;
                  final bool isValid = _isPageValid();

                  return Column(
                    children: [
                      // Custom App Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            if (_currentPage == widget.initialPage)
                              ThemedContainer(
                                type: ContainerType.neu,
                                padding: const EdgeInsets.all(12),
                                radius: 16,
                                onTap: () {
                                  Navigator.of(context).pop();
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
                            const SizedBox(
                              width: 80,
                            ), // Balance the leading button
                          ],
                        ),
                      ),
                      // Pages
                      Expanded(
                        child: GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged:
                                (i) => setState(() => _currentPage = i),
                            children: [
                              _GoalPage(
                                selectedGoal: _selectedGoal,
                                onGoalSelected:
                                    (goal) =>
                                        setState(() => _selectedGoal = goal),
                                isSmall: isSmall,
                                horizontalPadding: horizontalPadding,
                              ).animate().fadeIn(duration: 400.ms),
                              _InfoPage(
                                nameController: _nameController,
                                ageController: _ageController,
                                nameError: _nameError,
                                ageError: _ageError,
                                onChanged: () {
                                  if (_nameError != null || _ageError != null) {
                                    setState(() {
                                      _nameError = null;
                                      _ageError = null;
                                    });
                                  }
                                  setState(() {});
                                },
                                isSmall: isSmall,
                                horizontalPadding: horizontalPadding,
                              ).animate().fadeIn(duration: 400.ms),
                              _PeriodPage(
                                selectedGoal: _selectedGoal,
                                weeksController: _weeksController,
                                durationController: _durationController,
                                lastPeriodStart: _lastPeriodStart,
                                conceptionDate: _conceptionDate,
                                isAM: _isAM,
                                pregnancyInputMode: _pregnancyInputMode,
                                weeksError: _weeksError,
                                dateError: _dateError,
                                onWeeksChanged: () {
                                  if (_weeksError != null) setState(() => _weeksError = null);
                                  setState(() {});
                                },
                                onDurationChanged: () => setState(() {}),
                                onDateChanged:
                                    (d) {
                                      if (_dateError != null) setState(() => _dateError = null);
                                      setState(() => _lastPeriodStart = d);
                                    },
                                onConceptionDateChanged:
                                    (d) {
                                      if (_dateError != null) setState(() => _dateError = null);
                                      setState(() => _conceptionDate = d);
                                    },
                                onAMPMChanged:
                                    (val) => setState(() => _isAM = val),
                                onInputModeChanged:
                                    (mode) => setState(
                                      () {
                                        _pregnancyInputMode = mode;
                                        _weeksError = null;
                                        _dateError = null;
                                      }
                                    ),
                                isSmall: isSmall,
                                horizontalPadding: horizontalPadding,
                              ).animate().fadeIn(duration: 400.ms),
                            ],
                          ),
                        ),
                      ),
                      // Continue Button
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          4,
                          horizontalPadding,
                          24,
                        ),
                        child: Opacity(
                          opacity: isValid ? 1.0 : 0.5,
                          child: GestureDetector(
                            onTap: isValid ? _next : null,
                            child: Container(
                              width: double.infinity,
                              height: 58,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF5C8A),
                                    Color(0xFF9F6BFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  if (isValid)
                                    BoxShadow(
                                      color: Colors.pink.withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentPage == _totalPages - 1
                                          ? "Finish Setup"
                                          : "Continue",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _currentPage == _totalPages - 1
                                          ? Icons.check_circle_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(
                        begin: 0.2,
                        end: 0,
                        curve: Curves.easeOutBack,
                      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "How would you like to use ",
                  style: textTheme.headlineLarge,
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: BrandName(fontSize: AppTheme.h1(context)),
                ),
                TextSpan(text: "?", style: textTheme.headlineLarge),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            "Select your primary goal to personalize your journey.",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
          _goalCard(
            context,
            'track_cycle',
            'Track my cycle',
            'Log periods, symptoms and get predictions.',
            Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 16),
          _goalCard(
            context,
            'conceive',
            'Conceive',
            'Pinpoint ovulation and maximize your chances.',
            Icons.favorite_rounded,
          ),
          const SizedBox(height: 16),
          _goalCard(
            context,
            'pregnant',
            'I am pregnant',
            'Track your pregnancy journey and milestones.',
            Icons.child_care_rounded,
          ),
        ],
      ),
    );
  }

  Widget _goalCard(
    BuildContext context,
    String id,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final bool isSelected = selectedGoal == id;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => onGoalSelected(id),
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: 300.ms,
        curve: Curves.easeOutBack,
        child: ThemedContainer(
          type: isSelected ? ContainerType.elevated : ContainerType.neu,
          padding: const EdgeInsets.all(20),
          radius: 24,
          border:
              isSelected
                  ? Border.all(color: AppTheme.accentPink, width: 2)
                  : null,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppTheme.accentPink
                          : colorScheme.onSurface.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.accentPink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        color:
                            isSelected
                                ? AppTheme.accentPink
                                : colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

class _InfoPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final VoidCallback onChanged;
  final bool isSmall;
  final String? nameError;
  final String? ageError;
  final double horizontalPadding;

  const _InfoPage({
    required this.nameController,
    required this.ageController,
    this.nameError,
    this.ageError,
    required this.onChanged,
    required this.isSmall,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            "Let's get to know you",
            style: textTheme.headlineLarge,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            "This helps us tailor your experience perfectly.",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 40),
          _setupInput(
            context,
            "WHAT'S YOUR NAME?",
            nameController,
            'Enter name...',
            icon: Icons.person_outline_rounded,
            isRequired: true,
            errorText: nameError,
            onChanged: (v) => onChanged(),
          ),
          const SizedBox(height: 24),
          _setupInput(
            context,
            "AND YOUR AGE?",
            ageController,
            'Enter age...',
            icon: Icons.cake_outlined,
            isNumeric: true,
            isRequired: true,
            errorText: ageError,
            onChanged: (v) => onChanged(),
          ),
        ],
      ),
    );
  }

  Widget _setupInput(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hint, {
    IconData? icon,
    bool isNumeric = false,
    bool isRequired = false,
    String? errorText,
    required Function(String) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: textTheme.labelSmall),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppTheme.accentPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ThemedContainer(
          type: ContainerType.glass,
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            onChanged: onChanged,
            style: textTheme.titleLarge,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon:
                  icon != null
                      ? Icon(icon, color: AppTheme.accentPink, size: 22)
                      : null,
              hintText: hint,
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              errorText,
              style: const TextStyle(
                color: AppTheme.accentPink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn().slideY(begin: -0.2),
          ),
      ],
    );
  }
}

class _PeriodPage extends StatelessWidget {
  final String selectedGoal;
  final TextEditingController weeksController;
  final TextEditingController durationController;
  final DateTime? lastPeriodStart;
  final DateTime? conceptionDate;
  final bool isAM;
  final String pregnancyInputMode;
  final String? weeksError;
  final String? dateError;
  final VoidCallback onWeeksChanged;
  final VoidCallback onDurationChanged;
  final Function(DateTime) onDateChanged;
  final Function(DateTime) onConceptionDateChanged;
  final Function(bool) onAMPMChanged;
  final Function(String) onInputModeChanged;
  final bool isSmall;
  final double horizontalPadding;

  const _PeriodPage({
    required this.selectedGoal,
    required this.weeksController,
    required this.durationController,
    required this.lastPeriodStart,
    required this.conceptionDate,
    required this.isAM,
    required this.pregnancyInputMode,
    this.weeksError,
    this.dateError,
    required this.onWeeksChanged,
    required this.onDurationChanged,
    required this.onDateChanged,
    required this.onConceptionDateChanged,
    required this.onAMPMChanged,
    required this.onInputModeChanged,
    required this.isSmall,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedGoal == 'pregnant') {
      return _pregnancyPage(context);
    }
    return _trackingPage(context);
  }

  Widget _pregnancyPage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            "Congratulations! 🎉",
            style: textTheme.headlineLarge,
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            "How far along are you?",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          ThemedContainer(
            type: ContainerType.glass,
            radius: 16,
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _toggleItem(
                  context,
                  'weeks',
                  'Weeks',
                  pregnancyInputMode == 'weeks',
                ),
                _toggleItem(
                  context,
                  'date',
                  'LMP Date',
                  pregnancyInputMode == 'date',
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
          if (pregnancyInputMode == 'weeks')
            _setupInput(
              context,
              "WEEKS PREGNANT",
              weeksController,
              "e.g. 8",
              icon: Icons.calendar_month_outlined,
              isNumeric: true,
              isRequired: true,
              onChanged: (v) => onWeeksChanged(),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LAST PERIOD (LMP) DATE", style: textTheme.labelSmall),
                const SizedBox(height: 12),
                _dateSelectionField(
                  context,
                  conceptionDate,
                  onConceptionDateChanged,
                  'Select LMP date',
                  firstDate: DateTime.now().subtract(const Duration(days: 300)),
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _trackingPage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text("Final Step", style: textTheme.headlineLarge).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            "When did your last period start?",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          _dateSelectionField(
            context,
            lastPeriodStart,
            onDateChanged,
            'Select period start date',
            firstDate: DateTime.now().subtract(const Duration(days: 90)),
          ),
          const SizedBox(height: 24),
          Text("TIME OF DAY (OPTIONAL)", style: textTheme.labelSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              _ampmToggle(context, true, 'Morning', '9:00 AM'),
              const SizedBox(width: 12),
              _ampmToggle(context, false, 'Evening', '9:00 PM'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Helpful for tracking exact hormone shifts.",
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),
          _setupInput(
            context,
            "HOW MANY DAYS DID IT LAST?",
            durationController,
            "e.g. 5",
            icon: Icons.timer_outlined,
            isNumeric: true,
            onChanged: (v) => onDurationChanged(),
          ),
        ],
      ),
    );
  }

  Widget _dateSelectionField(
    BuildContext context,
    DateTime? selectedDate,
    Function(DateTime) onDatePicked,
    String hint, {
    DateTime? firstDate,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate:
              firstDate ?? DateTime.now().subtract(const Duration(days: 90)),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: AppTheme.accentPink),
              ),
              child: child!,
            );
          },
        );
        if (d != null) onDatePicked(d);
      },
      child: ThemedContainer(
        type: ContainerType.glass,
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.accentPink,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              selectedDate == null
                  ? hint
                  : DateFormat('MMMM dd, yyyy').format(selectedDate),
              style: textTheme.titleLarge?.copyWith(
                color:
                    selectedDate == null
                        ? colorScheme.onSurface.withValues(alpha: 0.2)
                        : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(
    BuildContext context,
    String mode,
    String label,
    bool active,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onInputModeChanged(mode),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppTheme.accentPink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ampmToggle(
    BuildContext context,
    bool value,
    String label,
    String time,
  ) {
    final bool active = isAM == value;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => onAMPMChanged(value),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                active
                    ? AppTheme.accentPink.withValues(alpha: 0.1)
                    : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? AppTheme.accentPink : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: active ? AppTheme.accentPink : colorScheme.onSurface,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: (active ? AppTheme.accentPink : colorScheme.onSurface)
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _setupInput(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hint, {
    IconData? icon,
    bool isNumeric = false,
    bool isRequired = false,
    required Function(String) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: textTheme.labelSmall),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppTheme.accentPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ThemedContainer(
          type: ContainerType.glass,
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            onChanged: onChanged,
            style: textTheme.titleLarge,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon:
                  icon != null
                      ? Icon(icon, color: AppTheme.accentPink, size: 22)
                      : null,
              hintText: hint,
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double factor = (current + 1) / total;
        return Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: 600.ms,
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * factor,
                decoration: BoxDecoration(
                  color: AppTheme.accentPink,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _getStepName(int page) {
  switch (page) {
    case 0:
      return 'Goal';
    case 1:
      return 'About You';
    case 2:
      return 'Cycle Setup';
    default:
      return '';
  }
}
