import 'dart:ui';
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
    if (_currentPage == 1 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name to continue.')),
      );
      return;
    }
    if (_currentPage == 2 &&
        _lastPeriodStart == null &&
        _selectedGoal != 'pregnant') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your last period start date.'),
        ),
      );
      return;
    }

    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: 350.ms, curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOut);
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
      final weeks = int.tryParse(_weeksController.text.trim());
      await storage.savePregnancyData(
        conceptionDate: _conceptionDate,
        weeks: weeks,
      );
    } else if (_lastPeriodStart != null) {
      // Create the first log
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _currentPage > widget.initialPage
                          ? _back
                          : () => Navigator.pop(context),
                      child: NeuContainer(
                        padding: const EdgeInsets.all(10),
                        radius: 14,
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.textDark,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Step ${_currentPage + 1} of $_totalPages',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ProgressBar(
                            current: _currentPage,
                            total: _totalPages,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ── Pages ────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [_goalPage(), _infoPage(), _periodPage()],
                ),
              ),

              // ── Continue / Finish button ──────────────────────────
              Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: NeuContainer(
                      radius: 18,
                      child: TextButton.icon(
                        icon: Icon(
                          _currentPage == _totalPages - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          color: AppTheme.accentPink,
                        ),
                        label: Text(
                          _currentPage == _totalPages - 1
                              ? 'Done'
                              : 'Continue →',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentPink,
                          ),
                        ),
                        onPressed: _next,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate(
                    target: (_currentPage == 0 && _selectedGoal.isEmpty)
                        ? 0
                        : 1,
                  )
                  .fadeIn()
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page 1: Goal Selection ──────────────────────────────────────────────
  Widget _goalPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "How would you like to use ",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                ),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: BrandName(fontSize: 28),
                ),
                TextSpan(
                  text: "?",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 32),
          _modePanel(
            'Track my cycle',
            'Period tracking & phase predictions',
            Icons.refresh_rounded,
            'track_cycle',
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
          const SizedBox(height: 16),
          _modePanel(
            'Trying to conceive',
            'Fertile window & ovulation tracking',
            Icons.favorite_rounded,
            'conceive',
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          _modePanel(
            'Already pregnant',
            'Pregnancy week & baby development',
            Icons.child_care_rounded,
            'pregnant',
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
        ],
      ),
    );
  }

  Widget _modePanel(String title, String subtitle, IconData icon, String goal) {
    final isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(24),
        decoration: isSelected
            ? AppTheme.glassDecoration(
                radius: 28,
                opacity: 0.6,
                borderColor: AppTheme.accentPink,
              )
            : AppTheme.glassDecoration(radius: 28, opacity: 0.2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentPink.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.accentPink
                    : AppTheme.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Page 2: Basic Info ──────────────────────────────────────────────────
  Widget _infoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          NeuContainer(
            padding: const EdgeInsets.all(20),
            radius: 28,
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.accentPink,
              size: 48,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            "Let's get to know you",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: "This helps "),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: BrandName(fontSize: 18),
                ),
                const TextSpan(text: " tailor your experience perfectly."),
              ],
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 48),
          _setupInput(
            "WHAT'S YOUR NAME?",
            _nameController,
            'Enter name...',
            isRequired: true,
          ),
          const SizedBox(height: 32),
          _setupInput(
            "AND YOUR AGE?",
            _ageController,
            'Age (optional)',
            isNumeric: true,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppTheme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppTheme.accentPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        NeuContainer(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                color: AppTheme.textSecondary.withOpacity(0.3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Page 3: First Period ────────────────────────────────────────────────
  Widget _periodPage() {
    if (_selectedGoal == 'pregnant') {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Congratulations! 🎉",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            Text(
              "How far along are you?",
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),
            _setupInput(
              "WEEKS PREGNANT",
              _weeksController,
              "e.g. 8",
              isNumeric: true,
            ),
            const SizedBox(height: 32),
            Text(
              "OR SELECT CONCEPTION DATE",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            NeuContainer(
              padding: const EdgeInsets.all(12),
              radius: 24,
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 300)),
                lastDate: DateTime.now(),
                onDateChanged: (date) => setState(() => _conceptionDate = date),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "When did your last period start?",
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 24),
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
          const SizedBox(height: 32),
          _setupInput(
            "HOW MANY DAYS DID IT LAST?",
            _durationController,
            "e.g. 5",
            isNumeric: true,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AM / PM Toggle",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              Row(
                children: [
                  _timeToggle('AM', _isAM, () => setState(() => _isAM = true)),
                  const SizedBox(width: 12),
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

  // ── Page 4: Privacy ─────────────────────────────────────────────────────
}

// ── Progress Bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current, total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      height: 8,
      radius: 4,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (current + 1) / total,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.accentPink,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
