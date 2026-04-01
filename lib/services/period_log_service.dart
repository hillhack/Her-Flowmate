import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/period_log.dart';
import 'notification_service.dart';
import '../utils/constants.dart';
import 'base_storage_service.dart';

class PeriodLogService extends ChangeNotifier {
  static const String boxName = 'period_logs';
  // ignore: unused_field
  final BaseStorageService _base = BaseStorageService.instance;

  Box<PeriodLog> get _box => Hive.box<PeriodLog>(boxName);

  Future<void> init() async {
    await Hive.openBox<PeriodLog>(boxName);
  }

  List<PeriodLog>? _cachedLogs;

  List<PeriodLog> getLogs() {
    if (_cachedLogs != null) return _cachedLogs!;
    final logs = _box.values.toList();
    logs.sort((a, b) => b.startDate.compareTo(a.startDate));
    _cachedLogs = logs;
    return logs;
  }

  Future<void> saveLog(PeriodLog log) async {
    await _box.add(log);
    _cachedLogs = null;
    _updateReminders();
    notifyListeners();
  }

  Future<void> deleteLog(int index) async {
    await _box.deleteAt(index);
    _cachedLogs = null;
    _updateReminders();
    notifyListeners();
  }

  Future<void> _updateReminders() async {
    final logs = getLogs();
    if (logs.isEmpty) {
      await NotificationService().cancelAll();
      return;
    }

    int averageCycleLength = 28;
    if (logs.length >= 2) {
      int totalDays = 0;
      int count = 0;
      for (int i = 0; i < logs.length - 1; i++) {
        final diff = logs[i].startDate.difference(logs[i + 1].startDate).inDays;
        if (diff > AppConstants.minCycleLength &&
            diff < AppConstants.maxCycleLength) {
          totalDays += diff;
          count++;
        }
      }
      if (count > 0) averageCycleLength = (totalDays / count).round();
    }

    final nextDate = logs.first.startDate.add(
      Duration(days: averageCycleLength),
    );
    await NotificationService().schedulePeriodReminder(nextDate);
  }
}
