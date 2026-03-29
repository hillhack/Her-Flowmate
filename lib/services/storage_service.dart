import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_log.dart';
import '../models/daily_log.dart';
import 'notification_service.dart';

class StorageService extends ChangeNotifier {
  StorageService();
  static final StorageService _instance = StorageService();
  static StorageService get instance => _instance;

  static const String boxName = 'period_logs';
  static const String dailyBoxName = 'daily_logs';
  late SharedPreferences _prefs;

  Future<void> init() async {
    try {
      debugPrint('StorageService: Fetching SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      debugPrint('StorageService: Initializing Hive...');
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(0)) {
        debugPrint('StorageService: Registering PeriodLogAdapter...');
        Hive.registerAdapter(PeriodLogAdapter());
      }

      if (!Hive.isAdapterRegistered(1)) {
        debugPrint('StorageService: Registering DailyLogAdapter...');
        Hive.registerAdapter(DailyLogAdapter());
      }

      debugPrint('StorageService: Opening boxes...');
      await Hive.openBox<PeriodLog>(boxName);
      await Hive.openBox<DailyLog>(dailyBoxName);
      debugPrint('StorageService: Initialization successful.');
    } catch (e) {
      debugPrint('ERROR IN StorageService.init: $e');
      rethrow;
    }
  }

  bool get hasCompletedLogin => _prefs.getBool('hasCompletedLogin') ?? false;
  bool get hasCompletedOnboarding =>
      _prefs.getBool('hasCompletedOnboarding') ?? false;
  bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;
  bool get isEmailUser => _prefs.getBool('isEmailUser') ?? false;
  String get userName => _prefs.getString('userName') ?? 'Guest';
  String get userGoal => _prefs.getString('userGoal') ?? 'track_cycle';
  int? get userAge =>
      _prefs.containsKey('userAge') ? _prefs.getInt('userAge') : null;
  String? get userImagePath => _prefs.getString('userImagePath');
  bool get isMinimalMode => _prefs.getBool('isMinimalMode') ?? false;
  // Pregnancy data
  DateTime? get dueDate {
    // Priority 1: Explicit due date set directly by user
    final ms = _prefs.getInt('dueDate');
    if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    // Priority 2: Conception date + 266 days (38 weeks)
    final cDate = conceptionDate;
    if (cDate != null) return cDate.add(const Duration(days: 280));
    // Priority 3: Derive from weeks remaining
    final pWeeks = pregnancyWeeks;
    if (pWeeks != null) {
      // pWeeks = weeks already elapsed; remaining = 40 - pWeeks
      final remaining = (40 - pWeeks).clamp(0, 40);
      return DateTime.now().add(Duration(days: remaining * 7));
    }
    return null;
  }

  DateTime? get conceptionDate {
    final ms = _prefs.getInt('conceptionDate');
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  int? get pregnancyWeeks {
    return _prefs.getInt('pregnancyWeeks');
  }

  Future<void> savePregnancyData({DateTime? conceptionDate, int? weeks}) async {
    if (conceptionDate != null) {
      // The user selected an explicit date (now representing LMP).
      await _prefs.setInt(
        'conceptionDate',
        conceptionDate.millisecondsSinceEpoch,
      );
      await _prefs.remove('pregnancyWeeks'); // Clear stale weeks
    } else if (weeks != null && weeks > 0) {
      // Convert weeks-elapsed to conception date (LMP) so counter advances daily
      final derivedConception = DateTime.now().subtract(
        Duration(days: weeks * 7),
      );
      await _prefs.setInt(
        'conceptionDate',
        derivedConception.millisecondsSinceEpoch,
      );
      await _prefs.setInt('pregnancyWeeks', weeks);
    }
    notifyListeners();
  }

  Future<void> toggleMinimalMode() async {
    await _prefs.setBool('isMinimalMode', !isMinimalMode);
    notifyListeners();
  }

  Future<void> completeLogin(bool loggedIn, [String name = '']) async {
    await _prefs.setBool('hasCompletedLogin', true);
    await _prefs.setBool('isLoggedIn', loggedIn);
    await _prefs.setBool('isEmailUser', loggedIn);
    if (loggedIn && name.isNotEmpty) {
      await _prefs.setString('userName', name);
    }
    notifyListeners();
  }

  Future<void> completeOnboarding(String goal, String name, {int? age}) async {
    await _prefs.setString('userGoal', goal);
    await _prefs.setBool('hasCompletedOnboarding', true);
    await _prefs.setBool('hasCompletedLogin', true); // Legacy fallback
    if (name.isNotEmpty) await _prefs.setString('userName', name);
    if (age != null) await _prefs.setInt('userAge', age);
    notifyListeners();
  }

  Future<void> updateUserGoal(String goal) async {
    await _prefs.setString('userGoal', goal);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    await _prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> updateUserAge(int age) async {
    await _prefs.setInt('userAge', age);
    notifyListeners();
  }

  Future<void> updateUserImagePath(String? path) async {
    if (path == null) {
      await _prefs.remove('userImagePath');
    } else {
      await _prefs.setString('userImagePath', path);
    }
    notifyListeners();
  }

  Future<void> saveDueDate(DateTime date) async {
    await _prefs.setInt('dueDate', date.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs.setBool('hasCompletedLogin', false);
    await _prefs.setBool('hasCompletedOnboarding', false);
    await _prefs.setBool('isLoggedIn', false);
    await _prefs.remove('userName');
    notifyListeners();
  }

  Future<void> stopAndReset() async {
    await _prefs.clear();
    await _box.clear();
    await _dailyBox.clear();
    notifyListeners();
  }

  Future<void> clearAllData() => stopAndReset();

  Box<PeriodLog> get _box => Hive.box<PeriodLog>(boxName);

  Future<void> saveLog(PeriodLog log) async {
    await _box.add(log);
    notifyListeners();
    _updateReminders();
  }

  Future<void> _updateReminders() async {
    final logs = getLogs();
    if (logs.isEmpty) {
      await NotificationService().cancelAll();
      return;
    }

    // Use simple logic to calculate next prediction for notification
    int averageCycleLength = 28;
    if (logs.length >= 2) {
      int totalDays = 0;
      int count = 0;
      for (int i = 0; i < logs.length - 1; i++) {
        final diff = logs[i].startDate.difference(logs[i + 1].startDate).inDays;
        if (diff > 15 && diff < 90) {
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

  Future<void> deleteLog(int index) async {
    await _box.deleteAt(index);
    notifyListeners();
    _updateReminders();
  }

  Future<void> deleteAllLogs() async {
    await _box.clear();
    notifyListeners();
    await NotificationService().cancelAll();
  }

  Future<String> exportLogsToJson() async {
    final logs = getLogs();
    final list =
        logs
            .map(
              (l) => {
                'startDate': l.startDate.toIso8601String(),
                'endDate': l.endDate?.toIso8601String(),
                'duration': l.duration,
              },
            )
            .toList();
    // Simple JSON serialisation without external package
    final buffer = StringBuffer('[');
    for (int i = 0; i < list.length; i++) {
      final m = list[i];
      buffer.write('{');
      buffer.write('"startDate":"${m['startDate']}",');
      buffer.write(
        '"endDate":${m['endDate'] != null ? '"${m['endDate']}"' : 'null'},',
      );
      buffer.write('"duration":${m['duration']}');
      buffer.write('}');
      if (i < list.length - 1) buffer.write(',');
    }
    buffer.write(']');
    return buffer.toString();
  }

  Future<void> exportLogsToPdf() async {
    // Placeholder for PDF generation logic (e.g. using 'pdf' package)
    debugPrint('Exporting logs to PDF...');
  }

  bool get hasSeenInfoPopup => _prefs.getBool('hasSeenInfoPopup') ?? false;

  Future<void> markInfoPopupAsSeen() async {
    await _prefs.setBool('hasSeenInfoPopup', true);
    notifyListeners();
  }

  List<PeriodLog> getLogs() {
    final logs = _box.values.toList();
    logs.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
    return logs;
  }

  Box<DailyLog> get _dailyBox => Hive.box<DailyLog>(dailyBoxName);

  Future<void> saveDailyLog(DailyLog log) async {
    // Delete existing log for this day to replace it
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

  // --- Health Tracker & Dashboard Helpers ---

  int getHydrationToday() {
    final log = getDailyLog(DateTime.now());
    return log?.waterIntake ?? 0;
  }

  int getStepsToday() {
    // This would normally come from a pedometer service, but we use daily log for now
    final log = getDailyLog(DateTime.now());
    final activity = log?.physicalActivity?.firstWhere(
      (a) => a.contains('steps'),
      orElse: () => '',
    );
    if (activity != null && activity.isNotEmpty) {
      final match = RegExp(r'\d+').firstMatch(activity);
      if (match != null) return int.parse(match.group(0)!);
    }
    return 0;
  }

  double getSleepHours() {
    // Simple mock until we have a proper sleep tracker
    return 7.5;
  }

  String getMoodToday() {
    final log = getDailyLog(DateTime.now());
    return log?.moods?.isNotEmpty == true ? log!.moods!.first : 'Good';
  }

  List<dynamic> getUpcomingAppointments() {
    // Temporary stub – you can expand this to use a dedicated Box
    return [];
  }
}
