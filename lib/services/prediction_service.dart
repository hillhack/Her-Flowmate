import 'storage_service.dart';

enum CyclePhase { menstrual, follicular, ovulation, luteal, unknown }

/// Extension so any widget can call `.displayName` directly on the enum.
extension CyclePhaseX on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:  return 'Menstruation';
      case CyclePhase.follicular: return 'Follicular';
      case CyclePhase.ovulation:  return 'Ovulation';
      case CyclePhase.luteal:     return 'Luteal';
      case CyclePhase.unknown:    return 'Unknown';
    }
  }
}

class PredictionService {
  final StorageService storageService;

  PredictionService(this.storageService);

  /// Convenience shorthand: the human-readable name of the current phase.
  String get phaseDisplayName => currentPhase.displayName;

  int get averageCycleLength {
    final logs = storageService.getLogs();
    if (logs.length < 2) return 28; // Default cycle length

    int totalDays = 0;
    int cycleCount = 0;

    // The logs are orderer newest first.
    for (int i = 0; i < logs.length - 1; i++) {
      final currentStart = logs[i].startDate;
      final previousStart = logs[i+1].startDate;
      
      final cycleDays = currentStart.difference(previousStart).inDays;
      if (cycleDays > 15 && cycleDays < 90) { // Valid duration check
        totalDays = totalDays + cycleDays;
        cycleCount++;
      }
    }

    if (cycleCount == 0) return 28;
    return (totalDays / cycleCount).round();
  }

  /// Variance check: if cycle length varies by more than 7 days, it's flagged as irregular.
  bool get isIrregularCycle {
    final logs = storageService.getLogs();
    if (logs.length < 3) return false;

    int minLen = 100, maxLen = 0;
    for (int i = 0; i < logs.length - 1; i++) {
        final len = logs[i].startDate.difference(logs[i+1].startDate).inDays;
        if (len > 15 && len < 90) {
            if (len < minLen) minLen = len;
            if (len > maxLen) maxLen = len;
        }
    }
    return (maxLen - minLen) > 7;
  }

  /// Calculates a simple health score (0-100) based on regularity and track usage.
  int getHealthScore() {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return 0;
    
    int score = 50; // Base score
    if (!isIrregularCycle) score += 30;
    if (logs.length >= 3) score += 20;
    
    return score.clamp(0, 100);
  }

  DateTime? get currentPeriodStart {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return null;
    return logs.first.startDate;
  }

  DateTime? get nextPeriodDate {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return null;

    final latestPeriod = logs.first;
    return latestPeriod.startDate.add(Duration(days: averageCycleLength));
  }

  CyclePhase get currentPhase {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return CyclePhase.unknown;

    final latestPeriod = logs.first;
    final today = DateTime.now();
    
    final normToday = DateTime(today.year, today.month, today.day);
    final normStart = DateTime(latestPeriod.startDate.year, latestPeriod.startDate.month, latestPeriod.startDate.day);
    
    final daysSinceStart = normToday.difference(normStart).inDays;
    
    if (daysSinceStart < 0) return CyclePhase.unknown;

    // Use endDate if available, otherwise fallback to stored duration
    bool isStillBleeding;
    if (latestPeriod.endDate != null) {
      isStillBleeding = !normToday.isAfter(DateTime(latestPeriod.endDate!.year, latestPeriod.endDate!.month, latestPeriod.endDate!.day));
    } else {
      isStillBleeding = daysSinceStart < latestPeriod.duration;
    }

    if (isStillBleeding) return CyclePhase.menstrual;
    
    final cycleLen = averageCycleLength;
    final lutealPhaseLength = 14; 
    final ovulationDay = cycleLen - lutealPhaseLength;
    
    // Safety check for cycle boundary
    if (daysSinceStart >= cycleLen) return CyclePhase.luteal;
    
    if (daysSinceStart < ovulationDay - 5) {
      return CyclePhase.follicular;
    } else if (daysSinceStart >= ovulationDay - 5 && daysSinceStart <= ovulationDay) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  int get currentCycleDay => getCycleDay(DateTime.now());

  int getCycleDay(DateTime date) {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return 0;
    
    // Find the period start associated with this date
    DateTime? periodStart;
    for (final log in logs) {
      if (date.isAfter(log.startDate) || isSameDay(date, log.startDate)) {
        periodStart = log.startDate;
        break;
      }
    }
    
    if (periodStart == null) return 0;
    
    final normDate = DateTime(date.year, date.month, date.day);
    final normStart = DateTime(periodStart.year, periodStart.month, periodStart.day);
    return normDate.difference(normStart).inDays + 1;
  }

  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool isFertileDay(DateTime date) {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return false;

    final latestPeriod = logs.first;
    final cycleLen = averageCycleLength;
    final ovulationDay = cycleLen - 14;
    
    final fertileStart = latestPeriod.startDate.add(Duration(days: ovulationDay - 5));
    final fertileEnd = latestPeriod.startDate.add(Duration(days: ovulationDay + 1));
    
    final normDate = DateTime(date.year, date.month, date.day);
    final normStart = DateTime(fertileStart.year, fertileStart.month, fertileStart.day);
    final normEnd = DateTime(fertileEnd.year, fertileEnd.month, fertileEnd.day, 23, 59, 59);
    
    return !normDate.isBefore(normStart) && !normDate.isAfter(normEnd);
  }

  bool isPeriodDay(DateTime date) {
    final logs = storageService.getLogs();
    final normDate = DateTime(date.year, date.month, date.day);

    for (final log in logs) {
      final start = DateTime(log.startDate.year, log.startDate.month, log.startDate.day);
      DateTime end;
      if (log.endDate != null) {
        end = DateTime(log.endDate!.year, log.endDate!.month, log.endDate!.day);
      } else {
        end = start.add(Duration(days: log.duration - 1));
      }

      if (!normDate.isBefore(start) && !normDate.isAfter(end)) {
        return true;
      }
    }
    
    // Also check future predicted period
    final next = nextPeriodDate;
    if (next != null) {
      final nextStart = DateTime(next.year, next.month, next.day);
      final nextEnd = nextStart.add(const Duration(days: 4)); // Assume 5 days for prediction
      if (!normDate.isBefore(nextStart) && !normDate.isAfter(nextEnd)) {
        return true;
      }
    }

    return false;
  }

  bool isOvulationDay(DateTime date) {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return false;

    final latestPeriod = logs.first;
    final cycleLen = averageCycleLength;
    final ovulationDay = cycleLen - 14;
    
    final ovDate = latestPeriod.startDate.add(Duration(days: ovulationDay));
    final normDate = DateTime(date.year, date.month, date.day);
    final normOv = DateTime(ovDate.year, ovDate.month, ovDate.day);
    
    return normDate.isAtSameMomentAs(normOv);
  }

  CyclePhase getPhaseForDay(DateTime date) {
    final cycleDay = getCycleDay(date);
    if (cycleDay == 0) return CyclePhase.unknown;
    
    final cycleLen = averageCycleLength;
    final ovulationDay = cycleLen - 14;

    if (isPeriodDay(date)) return CyclePhase.menstrual;
    if (cycleDay == ovulationDay) return CyclePhase.ovulation;
    if (cycleDay < ovulationDay) return CyclePhase.follicular;
    return CyclePhase.luteal;
  }

  int get daysUntilNextPeriod {
    final nextPeriod = nextPeriodDate;
    if (nextPeriod == null) return -1;
    final today = DateTime.now();
    final normToday = DateTime(today.year, today.month, today.day);
    final normNext = DateTime(nextPeriod.year, nextPeriod.month, nextPeriod.day);
    return normNext.difference(normToday).inDays;
  }

  int get daysUntilOvulation {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return -1;
    
    final latestPeriod = logs.first;
    final cycleLen = averageCycleLength;
    final ovulationDay = cycleLen - 14;
    
    final ovDate = latestPeriod.startDate.add(Duration(days: ovulationDay));
    final today = DateTime.now();
    final normToday = DateTime(today.year, today.month, today.day);
    final normOv = DateTime(ovDate.year, ovDate.month, ovDate.day);
    
    int diff = normOv.difference(normToday).inDays;
    
    // If ovulation already passed this cycle, look at next cycle
    if (diff < 0) {
      final nextOvDate = ovDate.add(Duration(days: cycleLen));
      diff = nextOvDate.difference(normToday).inDays;
    }
    
    return diff;
  }

  // ── Hormone Logic ─────────────────────────────────────────────────────────

  /// Calculates simplified hormone levels (0.0 to 1.0) based on cycle day.
  Map<String, double> getHormoneLevels(int cycleDay) {
    final cycleLen = averageCycleLength;
    final ovulationDay = cycleLen - 14;
    
    // Normalize cycle day to 1..cycleLen
    int day = cycleDay.clamp(1, cycleLen);

    // Estrogen Curve: Peaks just before ovulation, secondary lower peak in luteal
    double estrogen = 0.1;
    if (day <= ovulationDay) {
      estrogen = 0.1 + (0.8 * (day / ovulationDay)); // Linear rise to peak
    } else {
      // Drop after ovulation then second peak
      double lutealDay = (day - ovulationDay).toDouble();
      double lutealLen = (cycleLen - ovulationDay).toDouble();
      estrogen = 0.3 + 0.4 * (1.0 - (lutealDay - (lutealLen/2)).abs() / (lutealLen/2));
    }

    // Progesterone Curve: Low until ovulation, then rises in luteal
    double progesterone = 0.05;
    if (day > ovulationDay) {
      double lutealDay = (day - ovulationDay).toDouble();
      double lutealLen = (cycleLen - ovulationDay).toDouble();
      progesterone = 0.1 + 0.8 * (1.0 - (lutealDay - (lutealLen/2)).abs() / (lutealLen/2));
    }

    // LH Curve: Low, then a sharp spike on ovulation day
    double lh = 0.1;
    if ((day - ovulationDay).abs() <= 1) {
      lh = 0.9;
    } else if ((day - ovulationDay).abs() <= 3) {
      lh = 0.4;
    }

    // FSH Curve: Small peak early, then small spike with LH
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

  Map<String, String> getHormoneDescriptions(int cycleDay) {
    final levels = getHormoneLevels(cycleDay);
    final estrogen = levels['Estrogen']!;
    final progesterone = levels['Progesterone']!;
    
    String eStatus = estrogen > 0.7 ? 'High' : (estrogen > 0.4 ? 'Rising' : 'Low');
    String pStatus = progesterone > 0.7 ? 'Peak' : (progesterone > 0.3 ? 'Rising' : 'Low');
    
    return {
      'Estrogen': eStatus,
      'Progesterone': pStatus,
    };
  }

  Map<String, dynamic> getHormoneFocus(int day) {
    final levels = getHormoneLevels(day);
    
    // Find Highest
    String highestName = 'Estrogen';
    double highestVal = -1.0;
    // Find Lowest
    String lowestName = 'Progesterone';
    double lowestVal = 2.0;

    levels.forEach((name, val) {
      if (val > highestVal) {
        highestVal = val;
        highestName = name;
      }
      if (val < lowestVal) {
        lowestVal = val;
        lowestName = name;
      }
    });

    final descriptions = {
      'Estrogen': 'Supports bone health and regulates your cycle.',
      'Progesterone': 'Prepares your body for a potential pregnancy.',
      'LH': 'Surges to trigger the release of an egg (ovulation).',
      'FSH': 'Stimulates follicles to grow and prepare for release.',
    };

    final dailyContext = {
      'Estrogen': highestVal > 0.8 ? 'Peaking now to boost your energy and mood.' : 'Lower today, may lead to quieter energy.',
      'Progesterone': highestVal > 0.8 ? 'Peaking to support the uterine lining.' : 'Remaining low as your cycle prepares to reset.',
      'LH': highestVal > 0.8 ? 'Surging now to trigger ovulation within 24-48h.' : 'Stable levels while follicles develop.',
      'FSH': highestVal > 0.5 ? 'Active now to mature your eggs for the month.' : 'Resting after its early cycle work is done.',
    };

    return {
      'highest': {
        'name': highestName,
        'value': highestVal,
        'desc': dailyContext[highestName],
      },
      'lowest': {
        'name': lowestName,
        'value': lowestVal,
        'desc': descriptions[lowestName],
      }
    };
  }

  Map<String, String> getPhaseBiology(int cycleDay) {
    final phase = getPhaseForDay(DateTime.now().add(Duration(days: cycleDay - currentCycleDay)));
    
    switch (phase) {
      case CyclePhase.menstrual:
        return {
          'insight': 'Your period is occurring. The uterus is shedding its lining because pregnancy did not occur in the previous cycle.',
          'hormoneActivity': 'Low estrogen and progesterone.',
        };
      case CyclePhase.follicular:
        return {
          'insight': 'Your body is preparing for ovulation. The ovaries are developing follicles, and estrogen levels are gradually increasing.',
          'hormoneActivity': 'Rising estrogen, low progesterone.',
        };
      case CyclePhase.ovulation:
        return {
          'insight': 'An egg is released from the ovary. This is the most fertile point in the cycle.',
          'hormoneActivity': 'LH surge and peak estrogen levels.',
        };
      case CyclePhase.luteal:
        return {
          'insight': 'Progesterone increases to support a potential pregnancy. If fertilization does not occur, hormone levels will drop.',
          'hormoneActivity': 'High progesterone, declining estrogen.',
        };
      case CyclePhase.unknown:
        return {
          'insight': 'Data unavailable for this day.',
          'hormoneActivity': 'Unknown',
        };
    }
  }

  String getConceptionStatus(int chance) {
    if (chance >= 25) return 'Very high chance of conception';
    if (chance >= 15) return 'High chance of conception';
    if (chance >= 5) return 'Moderate chance of conception';
    return 'Low chance of conception';
  }

  int getConceptionChance(DateTime date) {
    final logs = storageService.getLogs();
    if (logs.isEmpty) return 1;

    final latestPeriod = logs.first;
    final cycleLen = averageCycleLength;
    final ovulationDay = cycleLen - 14;
    
    final normSearch = DateTime(date.year, date.month, date.day);
    final normStart = DateTime(latestPeriod.startDate.year, latestPeriod.startDate.month, latestPeriod.startDate.day);
    
    final daysSinceStart = normSearch.difference(normStart).inDays;
    final diff = daysSinceStart - ovulationDay + 1; // Adjust to match cycle day logic
    
    switch (diff) {
      case 0: return 33;
      case -1: return 31;
      case -2: return 27;
      case -3: return 14;
      case -4: return 16;
      case -5: return 10;
      case 1: return 5;
      default: return 1;
    }
  }

  int get currentConceptionChance => getConceptionChance(DateTime.now());

  String get fertilityLevel {
    final chance = currentConceptionChance;
    if (chance >= 25) return 'High';
    if (chance >= 10) return 'Moderate';
    return 'Low';
  }
}
