import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import '../widgets/glass_container.dart';

/// Allows the user to change their tracking mode at any time.
class ModeSettingsScreen extends StatefulWidget {
  const ModeSettingsScreen({super.key});

  @override
  State<ModeSettingsScreen> createState() => _ModeSettingsScreenState();
}

class _ModeSettingsScreenState extends State<ModeSettingsScreen> {
  late String _selectedGoal;

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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              radius: 12,
              padding: EdgeInsets.zero,
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.textDark),
            ),
          ),
        ),
        title: Text('Mode Settings',
            style: GoogleFonts.poppins(
                color: AppTheme.textDark, fontWeight: FontWeight.w700)),
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
                      color: AppTheme.textDark),
                ).animate().fadeIn(),
                const SizedBox(height: 10),
                Text(
                  'Switch your focus anytime. Your data history remains safe.',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textDark.withOpacity(0.6),
                      height: 1.4),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),

                _ModeCard(
                  title: 'Track my cycle',
                  subtitle: 'Period tracking & phase predictions',
                  icon: Icons.calendar_month_rounded,
                  iconColor: AppTheme.accentPink,
                  isSelected: _selectedGoal == 'track_cycle',
                  onTap: () => setState(() => _selectedGoal = 'track_cycle'),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

                _ModeCard(
                  title: 'Trying to conceive',
                  subtitle: 'Fertile window & ovulation tracking',
                  icon: Icons.favorite_rounded,
                  iconColor: AppTheme.phaseColors['Ovulation']!,
                  isSelected: _selectedGoal == 'conceive',
                  onTap: () => setState(() => _selectedGoal = 'conceive'),
                ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),

                _ModeCard(
                  title: 'Already pregnant',
                  subtitle: 'Pregnancy week & baby development',
                  icon: Icons.pregnant_woman_rounded,
                  iconColor: AppTheme.phaseColors['Ovulation']!,
                  isSelected: _selectedGoal == 'pregnant',
                  onTap: () => setState(() => _selectedGoal = 'pregnant'),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                const Spacer(),

                GlassContainer(
                  radius: 20,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<StorageService>().updateUserGoal(_selectedGoal);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tracking mode updated! ✨'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_rounded, color: AppTheme.accentPink),
                    label: Text('Confirm Change',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.accentPink)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ).animate().fadeIn(delay: 650.ms),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () async {
                    await context.read<StorageService>().logout();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                    }
                  },
                  child: Text('Logout from Account', 
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 14)),
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
    required this.title, required this.subtitle, required this.icon,
    required this.iconColor, required this.isSelected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 250.ms,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: isSelected
            ? AppTheme.glassDecoration(radius: 24, opacity: 0.2, borderColor: iconColor)
            : AppTheme.glassDecoration(radius: 24, opacity: 0.05),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? iconColor.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon,
                  color: isSelected
                      ? iconColor
                      : AppTheme.textDark.withOpacity(0.35),
                  size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? iconColor : AppTheme.textDark,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textDark.withOpacity(0.6))),
                ],
              ),
            ),
            if (isSelected) 
              Icon(Icons.check_circle_rounded, color: iconColor, size: 24)
            else
              const Icon(Icons.circle_outlined, color: AppTheme.textSecondary, size: 24),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}
