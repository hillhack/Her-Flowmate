import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'info_widgets.dart';
import 'themed_container.dart';

class PhaseCard extends StatelessWidget {
  final String phaseName;
  final bool isMinimal;
  const PhaseCard({super.key, required this.phaseName, this.isMinimal = false});

  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      type: ContainerType.glass,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Current Phase',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: context.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                GlassInfoButton(
                  onTap:
                      () => showGlassInfoPopup(
                        context,
                        title: 'Current Phase',
                        explanation: 'Your cycle consists of four main phases.',
                        tip: 'Each phase brings unique hormonal shifts.',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              phaseName,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: context.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              AppTheme.phaseTip(phaseName),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.phaseColor(phaseName),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class StatusRow extends StatelessWidget {
  final dynamic val1;
  final dynamic val2;
  final String label1;
  final String label2;
  final bool isMinimal;

  const StatusRow({
    super.key,
    required this.val1,
    required this.val2,
    this.label1 = 'Cycle Day',
    this.label2 = 'Next Period',
    this.isMinimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      type: ContainerType.glass,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label1,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: context.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$val1',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1.5,
              height: 40,
              color: AppTheme.shadowDark.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label2,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: context.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    val2 is int && val2 < 0
                        ? '${val2.abs()}d late'
                        : (label2 == 'Days Left' ? '$val2' : 'In $val2 days'),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}

class FertilityCard extends StatelessWidget {
  final int currentConceptionChance;
  final String title;
  final bool isMinimal;

  const FertilityCard({
    super.key,
    required this.currentConceptionChance,
    this.title = 'Fertility Window',
    this.isMinimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedContainer(
      type: ContainerType.glass,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: context.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'High probability today',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.onSurface,
                      ),
                    ),
                  ],
                ),
                ThemedContainer(
                  type: ContainerType.glass,
                  radius: 16,
                  padding: const EdgeInsets.all(12),
                  borderColor: Colors.white.withValues(alpha: 0.5),
                  child: const Icon(
                        Icons.favorite_rounded,
                        color: AppTheme.accentPink,
                        size: 24,
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                        duration: 800.ms,
                        curve: Curves.easeInOut,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chance of Conception',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: context.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$currentConceptionChance%',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentPink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (currentConceptionChance / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPink.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}

class MedicalDisclaimer extends StatelessWidget {
  const MedicalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'This is an estimate based on cycle patterns and should not be considered medical advice.',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: context.secondaryText.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
