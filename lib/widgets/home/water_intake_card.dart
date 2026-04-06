import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/daily_log.dart';
import '../../services/storage_service.dart';
import '../themed_container.dart';
import '../info_widgets.dart';

class WaterIntakeCard extends StatelessWidget {
  final StorageService storage;
  final VoidCallback onGoalReached;

  const WaterIntakeCard({
    super.key,
    required this.storage,
    required this.onGoalReached,
  });

  @override
  Widget build(BuildContext context) {
    final log = storage.getDailyLog(DateTime.now());
    final water = log?.waterIntake ?? 0;
    final goal = storage.hydrationGoal;

    return ThemedContainer(
      type: ContainerType.glass,
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showGlassInfoPopup(
                    context,
                    title: 'Hydration Tracking 💧',
                    explanation:
                        'Staying hydrated during your cycle helps reduce cramps, bloating, and fatigue.',
                    tip:
                        'Try reaching your 15-glass goal every day to maintain a healthy streak!',
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HYDRATION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  ThemedContainer(
                    type: ContainerType.glass,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _removeWater(context);
                    },
                    width: 44,
                    height: 44,
                    radius: 14,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.remove_rounded,
                      color: Colors.blueAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ThemedContainer(
                    type: ContainerType.glass,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _addWater(context);
                    },
                    width: 44,
                    height: 44,
                    radius: 14,
                    padding: EdgeInsets.zero,
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.blueAccent,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(goal, (i) {
              final filled = i < water;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 2),
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        filled
                            ? Colors.blueAccent
                            : Colors.blueAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '$water / ${storage.hydrationGoal} glasses',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addWater(BuildContext context) async {
    final now = DateTime.now();
    final log = storage.getDailyLog(now) ?? DailyLog(date: now, waterIntake: 0);
    final goal = storage.hydrationGoal;
    final newWater = ((log.waterIntake ?? 0) + 1).clamp(0, goal);

    if (newWater == goal && (log.waterIntake ?? 0) < goal) {
      onGoalReached();
      showGlassInfoPopup(
        context,
        title: 'Hydration Goal Met! 💧',
        explanation:
            'Amazing! You successfully reached $goal glasses of water today.',
        tip:
            'You are maintaining a great hydration streak. Your body thanks you!',
      );
    }

    final updatedLog = DailyLog(
      date: log.date,
      moods: log.moods,
      symptoms: log.symptoms,
      waterIntake: newWater,
      notes: log.notes,
      flowIntensity: log.flowIntensity,
      physicalActivity: log.physicalActivity,
    );

    await storage.saveDailyLog(updatedLog);
  }

  Future<void> _removeWater(BuildContext context) async {
    final now = DateTime.now();
    final log = storage.getDailyLog(now);
    if (log == null) return;

    final goal = storage.hydrationGoal;
    final updatedLog = DailyLog(
      date: log.date,
      moods: log.moods,
      symptoms: log.symptoms,
      waterIntake: ((log.waterIntake ?? 0) - 1).clamp(0, goal),
      notes: log.notes,
      flowIntensity: log.flowIntensity,
      physicalActivity: log.physicalActivity,
    );

    await storage.saveDailyLog(updatedLog);
  }
}
