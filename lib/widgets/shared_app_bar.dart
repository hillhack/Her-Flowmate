import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'themed_container.dart';
import 'notification_widgets.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;

  const SharedAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(115);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.darkBackground.withValues(alpha: 0.6) 
            : AppTheme.roseCoralPale.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : AppTheme.accentPink.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sidebar Toggle / Back Button
                Builder(
                  builder: (context) {
                    final canPop = Navigator.canPop(context);
                    return _BarButton(
                      icon: canPop ? Icons.arrow_back_rounded : Icons.menu_rounded,
                      onTap: () {
                        if (canPop) {
                          Navigator.pop(context);
                        } else if (onMenuPressed != null) {
                          onMenuPressed!();
                        } else {
                          // Fallback to finding Scaffold in parent context
                          Scaffold.of(context).openDrawer();
                        }
                      },
                      label: canPop ? 'Back' : 'Menu',
                    );
                  },
                ),
    
                // Center Area
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDatePill(context),
                      const SizedBox(height: 8),
                      Text(
                        'Her-Flowmate',
                        textAlign: TextAlign.center,
                        style: AppTheme.playfair(
                          context: context,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentPink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          title.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: context.secondaryText.withValues(alpha: 0.8),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    
                // Right Actions
                if (actions != null)
                  Row(mainAxisSize: MainAxisSize.min, children: actions!)
                else
                  const NotificationBell(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildDatePill(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day} ${_getMonth(now.month)} ${now.year}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.primary.withValues(alpha: 0.15)),
      ),
      child: Text(
        dateStr,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: context.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}

class _BarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;

  const _BarButton({required this.icon, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: ThemedContainer(
        type: ContainerType.glass,
        padding: const EdgeInsets.all(10),
        radius: 16,
        onTap: onTap,
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }
}
