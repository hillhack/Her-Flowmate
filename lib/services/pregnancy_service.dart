import 'package:flutter/foundation.dart';
import 'base_storage_service.dart';
import '../models/pregnancy_week_data.dart';

class PregnancyService extends ChangeNotifier {
  final BaseStorageService _base = BaseStorageService.instance;

  DateTime? get dueDate {
    final ms = _base.prefs.getInt('dueDate');
    if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);

    final cDate = conceptionDate;
    if (cDate != null) return cDate.add(const Duration(days: 280));
    return null;
  }

  DateTime? get conceptionDate {
    final ms = _base.prefs.getInt('conceptionDate');
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Current week of pregnancy (1-42)
  int get currentWeek {
    final dd = dueDate;
    if (dd == null) return 0;
    return pregnancyWeekFromDueDate(dd);
  }

  /// Current day within the week (0-6)
  int get currentDay {
    final dd = dueDate;
    if (dd == null) return 0;
    final conception = dd.subtract(const Duration(days: 280));
    final elapsed = DateTime.now().difference(conception).inDays;
    return elapsed % 7;
  }

  /// Days remaining until due date
  int get daysRemaining {
    final dd = dueDate;
    if (dd == null) return 0;
    return daysUntilDueDate(dd);
  }

  /// Total days elapsed since conception
  int get totalDaysElapsed {
    final dd = dueDate;
    if (dd == null) return 0;
    final conception = dd.subtract(const Duration(days: 280));
    return DateTime.now().difference(conception).inDays;
  }

  /// Progress percentage (0.0 to 1.0) based on 280 days total
  double get progress {
    if (dueDate == null) return 0.0;
    return (totalDaysElapsed / 280).clamp(0.0, 1.0);
  }

  /// Content for the current week
  PregnancyWeekData? get currentWeekData {
    final w = currentWeek;
    if (w < 4) return null; // We only have data from week 4
    return getPregnancyWeekData(w);
  }

  /// Trimester name
  String get trimester {
    return currentWeekData?.trimester ?? (currentWeek < 13 ? '1st Trimester' : 'Unknown');
  }

  Future<void> savePregnancyData({DateTime? conceptionDate, int? weeks}) async {
    if (conceptionDate != null) {
      await _base.prefs.setInt(
        'conceptionDate',
        conceptionDate.millisecondsSinceEpoch,
      );
      await _base.prefs.remove('pregnancyWeeks');
    } else if (weeks != null && weeks > 0) {
      final derivedConception = DateTime.now().subtract(
        Duration(days: weeks * 7),
      );
      await _base.prefs.setInt(
        'conceptionDate',
        derivedConception.millisecondsSinceEpoch,
      );
      await _base.prefs.setInt('pregnancyWeeks', weeks);
    }
    notifyListeners();
  }

  Future<void> saveDueDate(DateTime date) async {
    await _base.prefs.setInt('dueDate', date.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> resetPregnancy() async {
    await _base.prefs.remove('conceptionDate');
    await _base.prefs.remove('pregnancyWeeks');
    await _base.prefs.remove('dueDate');
    notifyListeners();
  }
}
