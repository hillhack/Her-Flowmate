import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_app_bar.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PredictionService, Map<String, dynamic>>(
      selector:
          (ctx, p) => {
            'cycleLen': p.averageCycleLength > 0 ? p.averageCycleLength : 28,
            'currentDay': p.currentCycleDay,
          },
      builder: (context, data, _) {
        final cycleLen = data['cycleLen'] as int;
        final currentDay = data['currentDay'] as int;
        final pred = context.read<PredictionService>();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: const SharedAppBar(title: 'Cycle Timeline'),
          body: Container(
            decoration: AppTheme.getBackgroundDecoration(context),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: AppDesignTokens.space24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDesignTokens.space24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          context,
                          'Menstrual',
                          AppTheme.phaseColors['Menstrual']!,
                        ),
                        const SizedBox(width: AppDesignTokens.space16),
                        _buildLegendItem(
                          context,
                          'Follicular',
                          AppTheme.phaseColors['Follicular']!,
                        ),
                        const SizedBox(width: AppDesignTokens.space16),
                        _buildLegendItem(
                          context,
                          'Ovulation',
                          AppTheme.phaseColors['Ovulation']!,
                        ),
                        const SizedBox(width: AppDesignTokens.space16),
                        _buildLegendItem(
                          context,
                          'Luteal',
                          AppTheme.phaseColors['Luteal']!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDesignTokens.space32),
                  Expanded(
                    child:
                        cycleLen <= 0
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'Log at least one period to see your timeline.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            : RefreshIndicator(
                              color: Theme.of(context).colorScheme.primary,
                              onRefresh: () async {
                                if (context.mounted) {
                                  await context
                                      .read<StorageService>()
                                      .syncUserWithBackend();
                                }
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  40,
                                ),
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                itemCount: cycleLen,
                                itemBuilder: (context, index) {
                                  final day = index + 1;
                                  final isToday = day == currentDay;
                                  final targetDate = DateTime.now().add(
                                    Duration(days: day - currentDay),
                                  );
                                  final phaseEnum = pred.getPhaseForDay(
                                    targetDate,
                                  );
                                  final phaseName = phaseEnum.displayName;
                                  final phaseColor = AppTheme.phaseColor(
                                    phaseName,
                                  );

                                  Widget rowWidget = _TimelineRow(
                                    day: day,
                                    isToday: isToday,
                                    isLast: index == cycleLen - 1,
                                    phaseName: phaseName,
                                    phaseColor: phaseColor,
                                  );

                                  if (index < 5) {
                                    rowWidget = rowWidget
                                        .animate()
                                        .fadeIn(
                                          delay: Duration(
                                            milliseconds: 30 * index,
                                          ),
                                        )
                                        .slideX(begin: 0.05);
                                  }

                                  return rowWidget;
                                },
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Semantics(
      label: '$label phase indicator',
      button: false,
      child: Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: AppDesignTokens.space8),
          Text(
            label,
            style: AppTheme.outfit(
              context: context,
              fontSize: AppDesignTokens.labelSize,
              fontWeight: FontWeight.w700,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isLast;
  final String phaseName;
  final Color phaseColor;

  const _TimelineRow({
    required this.day,
    required this.isToday,
    required this.isLast,
    required this.phaseName,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Cycle day $day, $phaseName phase, ${isToday ? "today, marked with a star" : ""}',
      button: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppDesignTokens.space40,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                '$day',
                style: AppTheme.outfit(
                  context: context,
                  fontSize: AppDesignTokens.bodySize,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                  color: isToday ? AppTheme.accentPink : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          Semantics(
            excludeSemantics: true,
            child: Column(
              children: [
                const SizedBox(height: AppDesignTokens.space16),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isToday ? phaseColor : AppTheme.frameColor,
                    border: Border.all(color: phaseColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child:
                      isToday
                          ? const Icon(
                            Icons.star_rounded,
                            size: 10,
                            color: Colors.white,
                          )
                          : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: AppDesignTokens.space48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.15),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDesignTokens.space16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.space16,
                  vertical: AppDesignTokens.space12,
                ),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      isToday
                          ? Border.all(
                            color: phaseColor.withValues(alpha: 0.6),
                            width: 1.5,
                          )
                          : null,
                ),
                child: _rowContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contrastColor =
        HSLColor.fromColor(
          phaseColor,
        ).withLightness(isDark ? 0.8 : 0.35).toColor();

    return Row(
      children: [
        Text(
          isToday ? 'Today' : 'Cycle Day $day',
          style: AppTheme.outfit(
            context: context,
            fontSize: AppDesignTokens.bodySize,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          phaseName,
          style: AppTheme.outfit(
            context: context,
            fontSize: AppDesignTokens.captionSize,
            fontWeight: FontWeight.w800,
            color: isDark ? phaseColor : contrastColor,
          ),
        ),
      ],
    );
  }
}
