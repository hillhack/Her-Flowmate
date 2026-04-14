import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/base_storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/common/app_back_button.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

/// Allows the user to change their tracking mode at any time.
class ModeSettingsScreen extends StatefulWidget {
  const ModeSettingsScreen({super.key});

  @override
  State<ModeSettingsScreen> createState() => _ModeSettingsScreenState();
}

class _ModeSettingsScreenState extends State<ModeSettingsScreen> {
  late String _selectedGoal;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedGoal = context.read<StorageService>().userGoal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(4.0),
          child: AppBackButton(),
        ),
        title: Text(
          'Mode Settings',
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'What are you currently tracking?',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 10),
                Text(
                  'Switch your focus anytime. Your data history remains safe.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),
                _ModeCard(
                  title: 'Track my cycle',
                  subtitle:
                      'Period tracking & phase predictions\n(Past cycles improve algorithm)',
                  icon: Icons.calendar_month_rounded,
                  iconColor: AppTheme.accentPink,
                  isSelected: _selectedGoal == 'track_cycle',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedGoal = 'track_cycle');
                  },
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'Conceive',
                  subtitle:
                      'Fertile window & ovulation tracking\n(Unlocks pregnancy prep tools)',
                  icon: Icons.favorite_rounded,
                  iconColor: AppTheme.phaseColors['Ovulation']!,
                  isSelected: _selectedGoal == 'conceive',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedGoal = 'conceive');
                  },
                ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'I am pregnant',
                  subtitle:
                      'Pregnancy week & baby development\n(Syncs upcoming due date)',
                  icon: Icons.pregnant_woman_rounded,
                  iconColor: AppTheme.phaseColors['Ovulation']!,
                  isSelected: _selectedGoal == 'pregnant',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedGoal = 'pregnant');
                  },
                ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),
                const Spacer(),
                PrimaryButton(
                  label: _isProcessing ? 'Updating...' : 'Confirm Change',
                  icon: _isProcessing ? null : Icons.check_circle_rounded,
                  isLoading: _isProcessing,
                  onTap:
                      _isProcessing
                          ? null
                          : () async {
                            final storage = context.read<StorageService>();
                            if (_selectedGoal != storage.userGoal) {
                              bool clearPregnancy = false;

                              if (storage.userGoal == 'pregnant' &&
                                  _selectedGoal != 'pregnant') {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text(
                                          'Clear Pregnancy Data?',
                                        ),
                                        content: const Text(
                                          'You are switching away from pregnancy mode. Would you like to clear your active due date?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, false),
                                            child: const Text('Keep Data'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Clear'),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirmed == null) return;
                                clearPregnancy = confirmed;
                              }

                              setState(() => _isProcessing = true);

                              bool onboardingSuccess = false;
                              if (_selectedGoal == 'pregnant' &&
                                  storage.dueDate == null &&
                                  storage.pregnancyWeeks == null) {
                                if (context.mounted) {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const OnboardingScreen(
                                            forceGoal: 'pregnant',
                                            initialPage: 2,
                                          ),
                                    ),
                                  );
                                  onboardingSuccess = result == true;
                                }
                              } else if ((_selectedGoal == 'track_cycle' ||
                                      _selectedGoal == 'conceive') &&
                                  storage.getLogs().isEmpty) {
                                if (context.mounted) {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => OnboardingScreen(
                                            forceGoal: _selectedGoal,
                                            initialPage: 2,
                                          ),
                                    ),
                                  );
                                  onboardingSuccess = result == true;
                                }
                              } else {
                                onboardingSuccess = true;
                              }

                              if (onboardingSuccess) {
                                try {
                                  if (clearPregnancy) {
                                    final prefs =
                                        BaseStorageService.instance.prefs;
                                    await prefs.remove('dueDate');
                                    await prefs.remove('pregnancyWeeks');
                                    await prefs.remove('conceptionDate');
                                  }
                                  await storage.updateUserGoal(_selectedGoal);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Tracking mode updated! ✨',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Network error. Check your connection.',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                }
                              }
                              if (mounted) {
                                setState(() => _isProcessing = false);
                              }
                            } else {
                              Navigator.pop(context);
                            }
                          },
                ).animate().fadeIn(delay: 650.ms),
                const Divider(color: Colors.black12, height: 48),
                TextButton.icon(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to log out? Your data remains on this device.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      if (context.mounted) {
                        await context.read<StorageService>().logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  label: Text(
                    'Logout from Account',
                    style: GoogleFonts.inter(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmall = MediaQuery.of(context).size.width < 360;

    return Semantics(
      label: '$title mode, $subtitle, ${isSelected ? "selected" : ""}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: 150.ms,
          scale: isSelected ? 1.02 : 1.0,
          child: AnimatedContainer(
            duration: 250.ms,
            padding: EdgeInsets.all(isSmall ? 16 : 20),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? iconColor.withValues(alpha: 0.08)
                      : (isDark
                          ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    isSelected
                        ? iconColor.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? iconColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isSelected
                            ? iconColor
                            : theme.colorScheme.onSurface.withValues(
                              alpha: 0.35,
                            ),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize:
                              isSmall ? 15 : AppDesignTokens.bodyLargeSize,
                          fontWeight: FontWeight.w700,
                          color:
                              isSelected
                                  ? iconColor
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: isSmall ? 11 : AppDesignTokens.captionSize,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: iconColor, size: 24)
                else
                  const Icon(
                    Icons.circle_outlined,
                    color: AppTheme.textSecondary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
