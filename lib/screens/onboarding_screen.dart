import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_navigation_screen.dart';
import '../models/period_log.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_container.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/delight_widgets.dart';

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
    if (_currentPage == 0 && _selectedGoal.isEmpty) return;
    if (_currentPage == 1) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name to continue.')),
        );
        return;
      }

      final ageStr = _ageController.text.trim();
      if (ageStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your age to continue.')),
        );
        return;
      }

      final age = int.tryParse(ageStr);
      if (age == null || age < 10 || age > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid age between 10 and 100.'),
          ),
        );
        return;
      }
    }
    if (_currentPage == 2) {
      if (_selectedGoal == 'pregnant') {
        if (_pregnancyInputMode == 'weeks' &&
            _weeksController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter how many weeks pregnant you are.'),
            ),
          );
          return;
        }
        if (_pregnancyInputMode == 'date' && _conceptionDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select your conception date.'),
            ),
          );
          return;
        }
      } else if (_lastPeriodStart == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your last period start date.'),
          ),
        );
        return;
      }
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: 350.ms,
        curve: Curves.easeOutCubic,
      );
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
      await storage.saveLog(PeriodLog(startDate: logDate, duration: duration));
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentPink.withValues(alpha: 0.05),
            AppTheme.accentPurple.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isSmall = constraints.maxWidth < 360;
              final double horizontalPadding =
                  isSmall ? AppTheme.spacingMedium : AppTheme.spacingXlarge;

              return Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        NeuContainer(
                          padding: const EdgeInsets.all(12),
                          radius: 16,
                          onTap: () {
                            if (_currentPage > widget.initialPage) {
                              _back();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textDark,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'STEP ${_currentPage + 1} OF $_totalPages',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark.withValues(
                                    alpha: 0.5,
                                  ),
                                  letterSpacing: 1.2,
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
                        const SizedBox(width: 80), // Balance the leading button
                      ],
                    ),
                  ),
                  // Pages
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      children: [
                        _goalPage(
                          isSmall,
                          horizontalPadding,
                        ).animate().fadeIn(duration: 400.ms),
                        _infoPage(
                          isSmall,
                          horizontalPadding,
                        ).animate().fadeIn(duration: 400.ms),
                        _periodPage(
                          isSmall,
                          horizontalPadding,
                        ).animate().fadeIn(duration: 400.ms),
                      ],
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
                        child: ShimmerButton(
                          radius: 20,
                          onTap: _next,
                          child: NeuContainer(
                            radius: 20,
                            child: Container(
                              width: double.infinity,
                              height: 58,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == _totalPages - 1
                                        ? 'Finish Setup'
                                        : 'Continue',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmall ? 16 : 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.accentPink,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentPage == _totalPages - 1
                                        ? Icons.check_circle_rounded
                                        : Icons.arrow_forward_rounded,
                                    color: AppTheme.accentPink,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate(
                        target:
                            (_currentPage == 0 && _selectedGoal.isEmpty)
                                ? 0
                                : 1,
                      )
                      .fadeIn()
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Page 1: Goal Selection ──────────────────────────────────────────────
  Widget _goalPage(bool isSmall, double horizontalPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppTheme.spacingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "How would you like to use ",
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.adaptiveFontSize(context, 28),
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: BrandName(
                    fontSize: AppTheme.adaptiveFontSize(context, 28),
                  ),
                ),
                TextSpan(
                  text: "?",
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.adaptiveFontSize(context, 28),
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
          SizedBox(
            height: isSmall ? AppTheme.spacingLarge : AppTheme.spacingXlarge,
          ),
          _modePanel(
            'Track my cycle',
            'Period tracking & phase predictions',
            Icons.refresh_rounded,
            'track_cycle',
            isSmall,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
          const SizedBox(height: AppTheme.spacingMedium),
          _modePanel(
            'Trying to conceive',
            'Fertile window & ovulation tracking',
            Icons.favorite_rounded,
            'conceive',
            isSmall,
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: AppTheme.spacingMedium),
          _modePanel(
            'Already pregnant',
            'Pregnancy week & baby development',
            Icons.child_care_rounded,
            'pregnant',
            isSmall,
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
        ],
      ),
    );
  }

  Widget _modePanel(
    String title,
    String subtitle,
    IconData icon,
    String goal,
    bool isSmall,
  ) {
    final isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: AnimatedScale(
        duration: 400.ms,
        curve: Curves.easeOutBack,
        scale: isSelected ? 1.02 : 1.0,
        child: AnimatedContainer(
          duration: 400.ms,
          padding: EdgeInsets.all(
            isSmall ? AppTheme.spacingMedium : AppTheme.spacingLarge,
          ),
          decoration:
              isSelected
                  ? AppTheme.glassDecoration(
                    radius: 28,
                    opacity: 0.6,
                    borderColor: AppTheme.accentPink,
                  )
                  : AppTheme.glassDecoration(radius: 28, opacity: 0.2),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmall ? 10 : AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppTheme.accentPink.withValues(alpha: 0.1)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? AppTheme.accentPink : AppTheme.textSecondary,
                  size: isSmall ? 24 : 32,
                ),
              ),
              SizedBox(
                width: isSmall ? AppTheme.spacingMedium : AppTheme.spacingLarge,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: isSmall ? 15 : 18,
                        fontWeight: FontWeight.w800,
                        color:
                            isSelected
                                ? AppTheme.accentPink
                                : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: isSmall ? 12 : 14,
                        color: AppTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.accentPink,
                ).animate().scale(curve: Curves.elasticOut),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page 2: Basic Info ──────────────────────────────────────────────────
  Widget _infoPage(bool isSmall, double horizontalPadding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppTheme.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingLarge),
          NeuContainer(
            padding: EdgeInsets.all(isSmall ? AppTheme.spacingMedium : 20),
            radius: 28,
            child: Icon(
              Icons.person_rounded,
              color: AppTheme.accentPink,
              size: isSmall ? 36 : 48,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          SizedBox(
            height: isSmall ? AppTheme.spacingLarge : AppTheme.spacingXlarge,
          ),
          Text(
            "Let's get to know you",
            style: GoogleFonts.poppins(
              fontSize: AppTheme.adaptiveFontSize(context, 32),
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: AppTheme.spacingSmall),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: "This helps "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: BrandName(fontSize: isSmall ? 15 : 18),
                ),
                const TextSpan(text: " tailor your experience perfectly."),
              ],
              style: GoogleFonts.inter(
                fontSize: isSmall ? 14 : 16,
                color: AppTheme.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
          SizedBox(
            height: isSmall ? AppTheme.spacingXlarge : AppTheme.spacingXXlarge,
          ),
          _setupInput(
            "WHAT'S YOUR NAME?",
            _nameController,
            'Enter name...',
            isRequired: true,
            isSmall: isSmall,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _setupInput(
            "AND YOUR AGE?",
            _ageController,
            'Enter age...',
            isNumeric: true,
            isRequired: true,
            isSmall: isSmall,
          ),
        ],
      ),
    );
  }

  Widget _setupInput(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumeric = false,
    bool isRequired = false,
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isSmall ? 11 : 12,
                fontWeight: FontWeight.w900,
                color: AppTheme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
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
        SizedBox(height: isSmall ? 12 : 16),
        NeuContainer(
          radius: 20,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 18 : 24,
            vertical: 8,
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 18 : 20,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Page 3: First Period / Pregnancy ────────────────────────────────────
  Widget _periodPage(bool isSmall, double horizontalPadding) {
    if (_selectedGoal == 'pregnant') {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Congratulations! 🎉",
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 24 : 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            Text(
              "How far along are you?",
              style: GoogleFonts.inter(
                fontSize: isSmall ? 15 : 16,
                color: AppTheme.textSecondary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),

            // Toggle
            Container(
              decoration: AppTheme.glassDecoration(radius: 16),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => setState(() => _pregnancyInputMode = 'weeks'),
                      child: AnimatedContainer(
                        duration: 300.ms,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _pregnancyInputMode == 'weeks'
                                  ? AppTheme.accentPink
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Weeks',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color:
                                  _pregnancyInputMode == 'weeks'
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _pregnancyInputMode = 'date'),
                      child: AnimatedContainer(
                        duration: 300.ms,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _pregnancyInputMode == 'date'
                                  ? AppTheme.accentPink
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Last Period (LMP)',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color:
                                  _pregnancyInputMode == 'date'
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),

            AnimatedSwitcher(
              duration: 400.ms,
              transitionBuilder:
                  (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
              child:
                  _pregnancyInputMode == 'weeks'
                      ? _setupInput(
                        "WEEKS PREGNANT",
                        _weeksController,
                        "e.g. 8",
                        isNumeric: true,
                        isRequired: true,
                        isSmall: isSmall,
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        key: const ValueKey('date'),
                        children: [
                          Text(
                            "SELECT LAST PERIOD (LMP) DATE",
                            style: GoogleFonts.inter(
                              fontSize: isSmall ? 11 : 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          NeuContainer(
                            padding: const EdgeInsets.all(12),
                            radius: 24,
                            child: CalendarDatePicker(
                              initialDate:
                                  _conceptionDate ??
                                  DateTime.now().subtract(
                                    const Duration(days: 30),
                                  ),
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 300),
                              ),
                              lastDate: DateTime.now(),
                              onDateChanged:
                                  (date) =>
                                      setState(() => _conceptionDate = date),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppTheme.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "When did your last period start?",
            style: GoogleFonts.poppins(
              fontSize: AppTheme.adaptiveFontSize(context, 26),
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              height: 1.3,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: AppTheme.spacingLarge),
          NeuContainer(
            padding: const EdgeInsets.all(12),
            radius: 24,
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 90)),
              lastDate: DateTime.now(),
              onDateChanged: (date) => setState(() => _lastPeriodStart = date),
            ),
          ),
          SizedBox(
            height: isSmall ? AppTheme.spacingLarge : AppTheme.spacingXlarge,
          ),
          _setupInput(
            "HOW MANY DAYS DID IT LAST?",
            _durationController,
            "e.g. 5",
            isNumeric: true,
            isSmall: isSmall,
          ),
          SizedBox(
            height: isSmall ? AppTheme.spacingLarge : AppTheme.spacingXlarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AM / PM Toggle",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  fontSize: isSmall ? 13 : 16,
                ),
              ),
              Row(
                children: [
                  _timeToggle('AM', _isAM, () => setState(() => _isAM = true)),
                  const SizedBox(width: AppTheme.spacingMedium),
                  _timeToggle(
                    'PM',
                    !_isAM,
                    () => setState(() => _isAM = false),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeToggle(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: NeuContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        radius: 12,
        borderColor: isSelected ? AppTheme.accentPink : Colors.white,
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: isSelected ? AppTheme.accentPink : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current, total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final double factor = (current + 1) / total;
    return NeuContainer(
      height: 12,
      radius: 6,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: 600.ms,
            curve: Curves.easeOutCubic,
            width: MediaQuery.of(context).size.width * 0.6 * factor,
            decoration: BoxDecoration(
              color: AppTheme.accentPink,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPink.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
