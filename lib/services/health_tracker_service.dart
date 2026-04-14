import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/daily_log.dart';
import 'base_storage_service.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'dart:convert';

class HealthTrackerService extends ChangeNotifier {
  static const String dailyBoxName = 'daily_logs';
  final BaseStorageService _base = BaseStorageService.instance;
  final Box<DailyLog>? unitTestBox;

  HealthTrackerService({this.unitTestBox});

  Box<DailyLog> get _dailyBox => unitTestBox ?? Hive.box<DailyLog>(dailyBoxName);

  Future<void> init() async {
    await Hive.openBox<DailyLog>(dailyBoxName);
  }

  String _dateKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  DailyLog? getDailyLog(DateTime date) {
    try {
      return _dailyBox.get(_dateKey(date));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDailyLog(DailyLog log) async {
    await _dailyBox.put(_dateKey(log.date), log);
    notifyListeners();
  }

  List<DailyLog> getDailyLogs() {
    final all = _dailyBox.values.toList();
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  int get hydrationGoal =>
      _base.prefs.getInt('hydrationGoal') ?? AppConstants.defaultHydrationGoal;

  Future<void> setHydrationGoal(int glasses) async {
    await _base.prefs.setInt('hydrationGoal', glasses);
    notifyListeners();
  }

  int getCheckinStreak() {
    int streak = 0;
    DateTime today = DateTime.now();
    DateTime day = DateTime(today.year, today.month, today.day);

    // If today is not logged, check if yesterday was logged to continue the streak
    if (getDailyLog(day) == null) {
      day = day.subtract(const Duration(days: 1));
    }

    while (true) {
      final log = getDailyLog(day);
      if (log == null) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // ── Backend Sync ──────────────────────────────────────────────────────────

  Future<bool> uploadLogs() async {
    try {
      final logs = getDailyLogs();
      final response = await ApiService.post('/logs/daily', {
        'logs': logs.map((l) => l.toJson()).toList(),
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error uploading daily logs: $e');
      return false;
    }
  }

  Future<void> fetchLogs() async {
    try {
      final response = await ApiService.get('/logs/daily');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['logs'] is List) {
          data = decoded['logs'];
        }
        final remoteLogs = data.map((json) => DailyLog.fromJson(json)).toList();

        // Safe replacement: Clear only after remote logs are ready
        // Guard: only clear local data if remote returned actual logs to prevent accidental wipe
        if (remoteLogs.isNotEmpty) {
          final map = {for (var l in remoteLogs) _dateKey(l.date): l};
          await _dailyBox.clear();
          await _dailyBox.putAll(map);
          notifyListeners();
        } else {
          debugPrint('Remote daily logs were empty - keeping local data.');
        }
      }
    } catch (e) {
      debugPrint('Error fetching daily logs: $e');
    }
  }
}
