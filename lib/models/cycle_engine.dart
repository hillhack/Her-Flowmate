import 'period_log.dart';

enum CyclePhase { menstrual, follicular, ovulation, luteal, unknown }

extension CyclePhaseX on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstruation';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
      case CyclePhase.unknown:
        return 'Unknown';
    }
  }
}

class CycleEngine {
  /// Base logic for calculating average cycle length from logs.
  static int calculateAverageCycleLength(List<PeriodLog> logs) {
    if (logs.length < 2) return 28;

    int totalDays = 0;
    int cycleCount = 0;

    for (int i = 0; i < logs.length - 1; i++) {
      final currentStart = logs[i].startDate;
      final previousStart = logs[i + 1].startDate;
      final cycleDays = currentStart.difference(previousStart).inDays;

      if (cycleDays > 15 && cycleDays < 90) {
        totalDays += cycleDays;
        cycleCount++;
      }
    }

    return cycleCount == 0 ? 28 : (totalDays / cycleCount).round();
  }

  /// Detects if the cycle is irregular based on historical variance.
  static bool detectIrregularity(List<PeriodLog> logs) {
    if (logs.length < 3) return false;

    int minLen = 100, maxLen = 0;
    for (int i = 0; i < logs.length - 1; i++) {
      final len = logs[i].startDate.difference(logs[i + 1].startDate).inDays;
      if (len > 15 && len < 90) {
        if (len < minLen) minLen = len;
        if (len > maxLen) maxLen = len;
      }
    }
    return (maxLen - minLen) > 7;
  }

  /// Estimates the current cycle phase for any specific date.
  static CyclePhase getPhaseForDate(
    DateTime date,
    List<PeriodLog> logs,
    int avgCycleLen,
  ) {
    if (logs.isEmpty) return CyclePhase.unknown;

    // Find the relevant period start for this date
    DateTime? periodStart;
    PeriodLog? relevantLog;
    for (final log in logs) {
      if (!date.isBefore(log.startDate)) {
        periodStart = log.startDate;
        relevantLog = log;
        break;
      }
    }

    if (periodStart == null) return CyclePhase.unknown;

    final normDate = DateTime(date.year, date.month, date.day);
    final normStart = DateTime(
      periodStart.year,
      periodStart.month,
      periodStart.day,
    );
    final daysSinceStart = normDate.difference(normStart).inDays;

    if (daysSinceStart < 0) return CyclePhase.unknown;

    // Menstrual phase check
    bool isBleeding;
    if (relevantLog!.endDate != null) {
      final normEnd = DateTime(
        relevantLog.endDate!.year,
        relevantLog.endDate!.month,
        relevantLog.endDate!.day,
      );
      isBleeding = !normDate.isAfter(normEnd);
    } else {
      isBleeding = daysSinceStart < relevantLog.duration;
    }

    if (isBleeding) return CyclePhase.menstrual;

    final ovulationDay = avgCycleLen - 14;

    if (daysSinceStart >= avgCycleLen) return CyclePhase.luteal;
    if (daysSinceStart < ovulationDay - 5) return CyclePhase.follicular;
    if (daysSinceStart <= ovulationDay) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  /// Calculates simplified hormone levels (0.0 to 1.0) based on cycle day.
  static Map<String, double> calculateHormones(int cycleDay, int cycleLen) {
    final ovulationDay = cycleLen - 14;
    int day = cycleDay.clamp(1, cycleLen);

    // Estrogen
    double estrogen = 0.1;
    if (day <= ovulationDay) {
      estrogen = 0.1 + (0.8 * (day / ovulationDay));
    } else {
      double lutealDay = (day - ovulationDay).toDouble();
      double lutealLen = (cycleLen - ovulationDay).toDouble();
      estrogen =
          0.3 +
          0.4 * (1.0 - (lutealDay - (lutealLen / 2)).abs() / (lutealLen / 2));
    }

    // Progesterone
    double progesterone = 0.05;
    if (day > ovulationDay) {
      double lutealDay = (day - ovulationDay).toDouble();
      double lutealLen = (cycleLen - ovulationDay).toDouble();
      progesterone =
          0.1 +
          0.8 * (1.0 - (lutealDay - (lutealLen / 2)).abs() / (lutealLen / 2));
    }

    // LH
    double lh = 0.1;
    if ((day - ovulationDay).abs() <= 1) {
      lh = 0.9;
    } else if ((day - ovulationDay).abs() <= 3) {
      lh = 0.4;
    }

    // FSH
    double fsh = 0.2;
    if (day <= 3) fsh = 0.5;
    if (day == ovulationDay) fsh = 0.6;

    return {
      'Estrogen': estrogen.clamp(0.0, 1.0),
      'Progesterone': progesterone.clamp(0.0, 1.0),
      'LH': lh.clamp(0.0, 1.0),
      'FSH': fsh.clamp(0.0, 1.0),
    };
  }

  /// Calculates conception chance for a specific date.
  static int calculateConceptionChance(
    DateTime date,
    List<PeriodLog> logs,
    int avgCycleLen,
  ) {
    if (logs.isEmpty) return 1;

    final latestPeriod = logs.first;
    final ovulationDay = avgCycleLen - 14;

    final normSearch = DateTime(date.year, date.month, date.day);
    final normStart = DateTime(
      latestPeriod.startDate.year,
      latestPeriod.startDate.month,
      latestPeriod.startDate.day,
    );

    final daysSinceStart = normSearch.difference(normStart).inDays;
    final diff = daysSinceStart - ovulationDay + 1;

    switch (diff) {
      case 0:
        return 33;
      case -1:
        return 31;
      case -2:
        return 27;
      case -3:
        return 14;
      case -4:
        return 16;
      case -5:
        return 10;
      case 1:
        return 5;
      default:
        return 1;
    }
  }

  /// Maps a conception chance percentage to a human-readable string.
  static String getConceptionStatus(int chance) {
    if (chance >= 25) return 'Very high chance of conception';
    if (chance >= 15) return 'High chance of conception';
    if (chance >= 5) return 'Moderate chance of conception';
    return 'Low chance of conception';
  }
}
