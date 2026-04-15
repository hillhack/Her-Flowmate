import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
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
  Size get preferredSize => const Size.fromHeight(106);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Richer frosted glass base
        color:
            isDark
                ? AppTheme.darkBackground.withValues(alpha: 0.75)
                : AppTheme.neuBg.withValues(alpha: 0.72),
        border: Border(
          bottom: BorderSide(
            color:
                isDark
                    ? AppTheme.neuAccent.withValues(alpha: 0.12)
                    : AppTheme.neuAccent.withValues(alpha: 0.14),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : AppTheme.neuShadowDark.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Left: Menu / Back button ──────────────────────────
                      Builder(
                        builder: (context) {
                          final canPop = Navigator.canPop(context);
                          return _BarButton(
                            icon:
                                canPop
                                    ? Icons.arrow_back_rounded
                                    : Icons.menu_rounded,
                            onTap: () {
                              if (canPop) {
                                Navigator.pop(context);
                              } else if (onMenuPressed != null) {
                                onMenuPressed!();
                              } else {
                                Scaffold.of(context).openDrawer();
                              }
                            },
                            label: canPop ? 'Back' : 'Menu',
                          );
                        },
                      ),

                      // ── Center: Brand + screen label ─────────────────────
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Gradient brand name
                            ShaderMask(
                              shaderCallback:
                                  (bounds) => AppTheme.brandGradient
                                      .createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                'Her-Flowmate',
                                textAlign: TextAlign.center,
                                style: AppTheme.brandStyle(fontSize: 24),
                              ),
                            ).animate().fadeIn(duration: 400.ms),

                            const SizedBox(height: 4),

                            // Date pill + screen label row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _DatePill(),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    title.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: context.secondaryText.withValues(
                                        alpha: 0.85,
                                      ),
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Right: Notification bell or custom actions ────────
                      if (actions != null)
                        Row(mainAxisSize: MainAxisSize.min, children: actions!)
                      else
                        const NotificationBell(),
                    ],
                  ),
                ),
              ),

              // ── Animated accent gradient line at the bottom ───────────────
              _AccentLine(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DatePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final dateStr = '${now.day} ${months[now.month - 1]}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neuAccent.withValues(alpha: 0.12),
            AppTheme.neuAccentLight.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.neuAccent.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        dateStr,
        style: AppTheme.poppins(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: context.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Animated gradient accent line ─────────────────────────────────────────────
class _AccentLine extends StatefulWidget {
  @override
  State<_AccentLine> createState() => _AccentLineState();
}

class _AccentLineState extends State<_AccentLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Container(
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: [
                Colors.transparent,
                isDark
                    ? AppTheme.neuAccentLight.withValues(alpha: 0.45)
                    : AppTheme.neuAccent.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Left / Right button ────────────────────────────────────────────────────────
class _BarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;

  const _BarButton({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppTheme.neuAccent.withValues(alpha: 0.15),
          highlightColor: AppTheme.neuAccent.withValues(alpha: 0.08),
          child: Ink(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : AppTheme.neuAccent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : AppTheme.neuAccent.withValues(alpha: 0.12),
                width: 0.8,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color:
                    isDark
                        ? AppTheme.darkOnSurface.withValues(alpha: 0.85)
                        : AppTheme.neuTextPrimary.withValues(alpha: 0.8),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
