import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/period_log.dart';
import 'notification_service.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'dart:convert';

class PeriodLogService extends ChangeNotifier {
  static const String boxName = 'period_logs';
  bool _isInitialized = false;

  Box<PeriodLog> get _box {
    if (!_isInitialized) {
      throw StateError('PeriodLogService accessed before init()');
    }
    return Hive.box<PeriodLog>(boxName);
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await Hive.openBox<PeriodLog>(boxName);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize PeriodLogService: $e');
      rethrow;
    }
  }

  List<PeriodLog>? _cachedLogs;

  List<PeriodLog> getLogs() {
    if (_cachedLogs != null) return _cachedLogs!;
    try {
      final logs = _box.values.toList();
      logs.sort((a, b) => b.startDate.compareTo(a.startDate));
      _cachedLogs = logs;
      return logs;
    } catch (e) {
      debugPrint('Error fetching logs: $e');
      return [];
    }
  }

  Future<void> saveLog(PeriodLog log) async {
    try {
      await _box.add(log);
      if (_cachedLogs != null) {
        _cachedLogs!.add(log);
        _cachedLogs!.sort((a, b) => b.startDate.compareTo(a.startDate));
      }
      await _updateReminders();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save log: $e');
    }
  }

  Future<void> deleteLog(int index) async {
    try {
      await _box.deleteAt(index);
      if (_cachedLogs != null && index < _cachedLogs!.length) {
        _cachedLogs!.removeAt(index);
      } else {
        _cachedLogs = null;
      }
      await _updateReminders();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete log: $e');
      _cachedLogs = null; // Conservative cleanup on error
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _cachedLogs = null;
    notifyListeners();
  }

  Future<void> _updateReminders() async {
    try {
      final logs = getLogs();
      if (logs.isEmpty) {
        await NotificationService().cancelAll();
        return;
      }

      int averageCycleLength = 28;
      if (logs.length >= 2) {
        final List<int> cycleLengths = [];
        // Look at up to the last 7 logs (6 cycles)
        final maxLogsToCheck = logs.length > 7 ? 7 : logs.length;

        for (int i = 0; i < maxLogsToCheck - 1; i++) {
          final diff =
              logs[i].startDate.difference(logs[i + 1].startDate).inDays;
          if (diff >= AppConstants.minCycleLength &&
              diff <= AppConstants.maxCycleLength) {
            cycleLengths.add(diff);
          }
        }

        if (cycleLengths.isNotEmpty) {
          cycleLengths.sort();
          // Use median for robustness
          averageCycleLength = cycleLengths[cycleLengths.length ~/ 2];
        }
      }

      final nextDate = logs.first.startDate.add(
        Duration(days: averageCycleLength),
      );
      await NotificationService().schedulePeriodReminder(nextDate);
    } catch (e) {
      debugPrint('Error updating reminders: $e');
    }
  }

  // ── Backend Sync ──────────────────────────────────────────────────────────

  Future<bool> uploadLogs() async {
    try {
      final logs = getLogs();
      final response = await ApiService.post('/logs/periods', {
        'logs': logs.map((l) => l.toJson()).toList(),
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error uploading logs: $e');
      return false;
    }
  }

  Future<void> fetchLogs() async {
    try {
      final response = await ApiService.get('/logs/periods');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded is List ? decoded : [];
        final remoteLogs =
            data.map((json) => PeriodLog.fromJson(json)).toList();

        // Simple merge: Clear local and replace with remote for now
        // A more complex merge would check dates to avoid duplicates
        await _box.clear();
        await _box.addAll(remoteLogs);
        _cachedLogs = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    }
  }
}
