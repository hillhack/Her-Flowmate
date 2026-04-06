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

  Box<DailyLog> get _dailyBox => Hive.box<DailyLog>(dailyBoxName);

  Future<void> init() async {
    await Hive.openBox<DailyLog>(dailyBoxName);
  }

  DailyLog? getDailyLog(DateTime date) {
    try {
      return _dailyBox.values.firstWhere(
        (log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDailyLog(DailyLog log) async {
    final existingKey = _dailyBox.keys.firstWhere((k) {
      final existing = _dailyBox.get(k);
      return existing != null &&
          existing.date.year == log.date.year &&
          existing.date.month == log.date.month &&
          existing.date.day == log.date.day;
    }, orElse: () => null);

    if (existingKey != null) {
      await _dailyBox.delete(existingKey);
    }
    await _dailyBox.add(log);
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
    DateTime day = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
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
        final List<dynamic> data = decoded is List ? decoded : [];
        final remoteLogs = data.map((json) => DailyLog.fromJson(json)).toList();

        await _dailyBox.clear();
        await _dailyBox.addAll(remoteLogs);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching daily logs: $e');
    }
  }
}
