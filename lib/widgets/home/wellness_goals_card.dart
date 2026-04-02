import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../services/storage_service.dart';
import '../../screens/wellness_reminders_screen.dart';
import '../themed_container.dart';

class WellnessGoalsCard extends StatelessWidget {
  final StorageService storage;
  const WellnessGoalsCard({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final reminders = storage.getAllAppointments();
    final nextGoal = reminders.isNotEmpty ? reminders.first : null;

    return Hero(
      tag: 'wellness_goals',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WellnessRemindersScreen(),
                ),
              ),
          borderRadius: BorderRadius.circular(28),
          child: ThemedContainer(
            type: ContainerType.glass,
            padding: const EdgeInsets.all(24),
            radius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.spa_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'WELLNESS GOALS',
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
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(
                        0xFF9E9E9E,
                      ), // Standard text-secondary fallback
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (nextGoal != null)
                  Row(
                    children: [
                      Text(
                        nextGoal.category.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextGoal.title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scheduled for ${DateFormat('MMM d').format(nextGoal.date)}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'No upcoming goals. Tap to set a reminder!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
