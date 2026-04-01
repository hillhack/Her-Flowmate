// ── Her-Flowmate Centralized Constants ──────────────────────────────────────
// All magic numbers are extracted here for maintainability and type safety.
// Import this file wherever these values are needed.

// ── App Constants ───────────────────────────────────────────────────────────
abstract final class AppConstants {
  // ── Clinical Constants ────────────────────────────────────────────────────
  /// Standard pregnancy duration from LMP to estimated due date
  static const int pregnancyDaysFromLMP = 280;

  /// Full term pregnancy in weeks
  static const int fullTermWeeks = 40;

  /// Ovulation typically occurs ~14 days before next period
  static const int ovulationOffsetFromPeriod = 14;

  /// Minimum cycle length to consider valid (days)
  static const int minCycleLength = 15;

  /// Maximum cycle length to consider valid (days)
  static const int maxCycleLength = 90;

  // ── Hydration Constants ──────────────────────────────────────────────────
  /// Default daily hydration goal (glasses of water)
  static const int defaultHydrationGoal = 8;

  /// Maximum hydration goal (glasses of water)
  static const int maxHydrationGoal = 20;

  // ── Streak Constants ─────────────────────────────────────────────────────
  /// Streak milestones that trigger celebration
  static const List<int> streakMilestones = [7, 14, 30];

  // ── Appointment Constants ────────────────────────────────────────────────
  /// Days to look ahead for upcoming appointments
  static const int upcomingAppointmentDays = 30;

  // ── Sleep Constants ──────────────────────────────────────────────────────
  /// Min sleep hours considered "great"
  static const double greatSleepHours = 8;

  /// Min sleep hours considered "ok"
  static const double okSleepHours = 6;
}
