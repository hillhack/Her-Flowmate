import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'base_storage_service.dart';
import 'onboarding_service.dart';
import 'period_log_service.dart';
import 'pregnancy_service.dart';
import 'health_tracker_service.dart';
import 'appointment_service.dart';
import '../models/period_log.dart';
import '../models/daily_log.dart';
import '../models/appointment.dart';
import 'user_service.dart';
import 'api_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StorageService extends ChangeNotifier {
  StorageService.internal();
  static final StorageService _instance = StorageService.internal();
  static StorageService get instance => _instance;

  final onboarding = OnboardingService();
  final periodLog = PeriodLogService();
  final pregnancy = PregnancyService();
  final healthTracker = HealthTrackerService();
  final appointment = AppointmentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> init() async {
    try {
      // 1. Initialize base shared preferences and Hive registration first (required by others)
      await BaseStorageService.instance.init();

      // 2. Open all specific Hive boxes in parallel to reduce main-thread blocking
      await Future.wait([
        onboarding.init(),
        periodLog.init(),
        healthTracker.init(),
        appointment.init(),
      ]);

      // 3. Set up listeners and reminders after data is ready
      onboarding.addListener(notifyListeners);
      periodLog.addListener(notifyListeners);
      pregnancy.addListener(notifyListeners);
      healthTracker.addListener(notifyListeners);
      appointment.addListener(notifyListeners);

      // Re-link services if they need each other (handled by main.dart now)
    } catch (e) {
      debugPrint('ERROR IN StorageService.init: $e');
      rethrow;
    }
  }

  // ── Facade Getters & Methods (Forwarding to specialized services) ───────────

  bool get hasCompletedLogin => onboarding.hasCompletedLogin;
  bool get hasCompletedOnboarding => onboarding.hasCompletedOnboarding;
  bool get isLoggedIn => onboarding.isLoggedIn;
  String get userName => onboarding.userName;
  String get userGoal => onboarding.userGoal;
  int? get userAge => onboarding.userAge;
  String? get userImagePath => onboarding.userImagePath;
  bool get isDarkMode => onboarding.isDarkMode;
  bool get isMinimalMode =>
      BaseStorageService.instance.prefs.getBool('isMinimalMode') ?? false;
  bool get isHighPerformanceMode =>
      BaseStorageService.instance.prefs.getBool('isHighPerformanceMode') ??
      true;
  double? get weight => onboarding.weight;
  double? get height => onboarding.height;
  bool get periodNotifications => onboarding.periodNotifications;
  bool get healthNotifications => onboarding.healthNotifications;

  DateTime? get dueDate => pregnancy.dueDate;
  DateTime? get conceptionDate => pregnancy.conceptionDate;
  int? get pregnancyWeeks =>
      BaseStorageService.instance.prefs.getInt('pregnancyWeeks');

  Future<void> savePregnancyData({DateTime? conceptionDate, int? weeks}) =>
      pregnancy.savePregnancyData(conceptionDate: conceptionDate, weeks: weeks);
  Future<void> saveDueDate(DateTime date) => pregnancy.saveDueDate(date);

  Future<void> updateUserName(String name) async {
    await onboarding.updateUserName(name);
    if (onboarding.user != null) {
      await UserService.updateUserProfile(onboarding.user!);
    }
  }

  Future<void> updateUserAge(int age) async {
    await BaseStorageService.instance.prefs.setInt('userAge', age);
    if (onboarding.user != null) {
      await onboarding.saveUser(onboarding.user!.copyWith(age: age));
      await UserService.updateUserProfile(onboarding.user!);
    }
    notifyListeners();
  }

  Future<void> updateWeight(double val) async {
    await onboarding.updateWeight(val);
    if (onboarding.user != null) {
      await UserService.updateUserProfile(onboarding.user!);
    }
  }

  Future<void> updateHeight(double val) async {
    await onboarding.updateHeight(val);
    if (onboarding.user != null) {
      await UserService.updateUserProfile(onboarding.user!);
    }
  }

  Future<void> updateNotificationSettings({bool? period, bool? health}) async {
    await onboarding.updateNotificationSettings(period: period, health: health);
    if (onboarding.user != null) {
      await UserService.updateUserProfile(onboarding.user!);
    }
  }

  Future<void> updateUserImagePath(String? path) async {
    if (path == null) {
      await BaseStorageService.instance.prefs.remove('userImagePath');
    } else {
      await BaseStorageService.instance.prefs.setString('userImagePath', path);
    }
    if (onboarding.user != null) {
      await onboarding.saveUser(onboarding.user!.copyWith(imagePath: path));
      await UserService.updateUserProfile(onboarding.user!);
    }
    notifyListeners();
  }

  Future<void> updateUserGoal(String goal) async {
    await BaseStorageService.instance.prefs.setString('userGoal', goal);
    if (onboarding.user != null) {
      await onboarding.saveUser(onboarding.user!.copyWith(goal: goal));
      await UserService.updateUserProfile(onboarding.user!);
    }
    notifyListeners();
  }

  Future<void> completeLogin(bool loggedIn, [String name = '']) async {
    await onboarding.completeLogin(loggedIn, name);
    if (loggedIn) {
      await syncUserWithBackend();
    }
  }

  Future<void> completeOnboarding(String goal, String name, {int? age}) async {
    await onboarding.completeOnboarding(goal, name, age: age);
    await syncUserWithBackend();
  }

  bool _isSyncing = false;

  Future<void> syncUserWithBackend() async {
    if (_isSyncing) return;
    
    final token = ApiService.token;
    if (token == null) return;

    _isSyncing = true;
    _setLoading(true);
    try {
      // 1. Sync User Profile
      final remoteUser = await UserService.getUserProfile();
      if (remoteUser != null) {
        await onboarding.saveUser(remoteUser);
      } else if (onboarding.user != null) {
        await UserService.updateUserProfile(onboarding.user!);
      }

      // 2. Sync Period Logs
      await periodLog.fetchLogs();
      await periodLog.uploadLogs();

      // 3. Sync Daily logs (Health Tracker)
      await healthTracker.fetchLogs();
      await healthTracker.uploadLogs();

      // 4. Sync Appointments
      await appointment.fetchAppointments();
      await appointment.uploadAppointments();
    } catch (e) {
      debugPrint('Full Sync Error: $e');
    } finally {
      _isSyncing = false;
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await onboarding.logout();
    await ApiService.saveToken(null);
  }

  Future<void> toggleDarkMode() => onboarding.toggleDarkMode();

  Future<void> togglePerformanceMode() async {
    final current = isHighPerformanceMode;
    await BaseStorageService.instance.prefs.setBool(
      'isHighPerformanceMode',
      !current,
    );
    notifyListeners();
  }

  Future<bool> saveLog(PeriodLog log) => periodLog.saveLog(log);
  Future<void> deleteLog(int index) => periodLog.deleteLog(index);
  Future<void> deleteLogByRef(PeriodLog log) => periodLog.deleteLogByRef(log);
  List<PeriodLog> getLogs() => periodLog.getLogs();

  Future<String> exportLogsToJson() async {
    _setLoading(true);
    try {
      final data = {
        'periodLogs': getLogs().map((l) => l.toJson()).toList(),
        'dailyLogs': healthTracker.getDailyLogs().map((l) => l.toJson()).toList(),
        'appointments': appointment.getAllAppointments().map((l) => l.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '2.0',
      };
      return jsonEncode(data);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> importLogsFromJson(String jsonString) async {
    _setLoading(true);
    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is List) {
        // Legacy format: List of period logs
        final importedLogs = decoded.map((json) {
          return PeriodLog.fromJson(json as Map<String, dynamic>);
        }).toList();

        for (var log in importedLogs) {
          await periodLog.saveLog(log);
        }
      } else if (decoded is Map<String, dynamic>) {
        // New bundled format
        // 1. Period Logs
        if (decoded['periodLogs'] is List) {
          final pLogs = (decoded['periodLogs'] as List)
              .map((j) => PeriodLog.fromJson(j as Map<String, dynamic>))
              .toList();
          for (var log in pLogs) {
            await periodLog.saveLog(log);
          }
        }

        // 2. Daily Logs
        if (decoded['dailyLogs'] is List) {
          final dLogs = (decoded['dailyLogs'] as List)
              .map((j) => DailyLog.fromJson(j as Map<String, dynamic>))
              .toList();
          for (var log in dLogs) {
            await healthTracker.saveDailyLog(log);
          }
        }

        // 3. Appointments
        if (decoded['appointments'] is List) {
          final aLogs = (decoded['appointments'] as List)
              .map((j) => Appointment.fromJson(j as Map<String, dynamic>))
              .toList();
          for (var log in aLogs) {
            await appointment.saveAppointment(log);
          }
        }
      }
    } catch (e) {
      debugPrint('Error importing JSON: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveDailyLog(DailyLog log) => healthTracker.saveDailyLog(log);
  DailyLog? getDailyLog(DateTime date) => healthTracker.getDailyLog(date);
  List<DailyLog> getDailyLogs() =>
      healthTracker
          .getDailyLogs(); // To be added to HealthTrackerService if needed

  int get hydrationGoal => healthTracker.hydrationGoal;
  Future<void> setHydrationGoal(int glasses) =>
      healthTracker.setHydrationGoal(glasses);
  int getHydrationToday() =>
      healthTracker.getDailyLog(DateTime.now())?.waterIntake ?? 0;
  int getStepsToday() =>
      healthTracker.getDailyLog(DateTime.now())?.stepsCount ?? 0;
  double? getSleepHours() =>
      healthTracker.getDailyLog(DateTime.now())?.sleepHours;
  String getMoodToday() =>
      healthTracker.getDailyLog(DateTime.now())?.moods?.firstOrNull ?? 'Good';
  int getCheckinStreak() => healthTracker.getCheckinStreak();

  bool get isPinLocked =>
      BaseStorageService.instance.prefs.getBool('isPinLocked') ?? false;
  Future<void> setPinLocked(bool value) async {
    await BaseStorageService.instance.prefs.setBool('isPinLocked', value);
    notifyListeners();
  }

  Future<void> saveAppointment(Appointment appt) =>
      appointment.saveAppointment(appt);
  Future<void> deleteAppointment(Appointment appt) =>
      appointment.deleteAppointment(appt);
  List<Appointment> getAllAppointments() => appointment.getAllAppointments();
  List<Appointment> getUpcomingAppointments() =>
      appointment
          .getUpcomingAppointments(); // To be added to AppointmentService if needed

  bool get hasSeenInfoPopup =>
      BaseStorageService.instance.prefs.getBool('hasSeenInfoPopup') ?? false;
  Future<void> markInfoPopupAsSeen() async {
    await BaseStorageService.instance.prefs.setBool('hasSeenInfoPopup', true);
    notifyListeners();
  }

  Future<void> exportLogsToPdf() async {
    _setLoading(true);
    try {
      final pdf = pw.Document();
      final logs = getLogs();
      // final wellness = getAllAppointments(); // Temporarily disabled if unused

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build:
              (context) => [
                pw.Header(
                  level: 0,
                  child: pw.Text('Her-Flowmate Health Report'),
                ),
                pw.Paragraph(
                  text:
                      'Generated on: ${DateTime.now().toString().split('.')[0]}',
                ),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, child: pw.Text('Cycle History')),
                pw.TableHelper.fromTextArray(
                  headers: ['Start Date', 'End Date', 'Duration'],
                  data:
                      logs.map((l) {
                        final duration =
                            l.endDate != null
                                ? l.endDate!.difference(l.startDate).inDays + 1
                                : 'Ongoing';
                        return [
                          l.startDate.toString().split(' ')[0],
                          l.endDate?.toString().split(' ')[0] ?? '-',
                          '$duration days',
                        ];
                      }).toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Header(level: 1, child: pw.Text('Daily Health Log')),
                pw.TableHelper.fromTextArray(
                  headers: ['Date', 'Mood', 'Water', 'Sleep (h)', 'Steps'],
                  data:
                      getDailyLogs().map((d) {
                        return [
                          d.date.toString().split(' ')[0],
                          d.moods?.join(', ') ?? '-',
                          '${d.waterIntake ?? 0} glasses',
                          '${d.sleepHours ?? '-'}',
                          '${d.stepsCount ?? 0}',
                        ];
                      }).toList(),
                ),
              ],
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'her-flowmate-report.pdf',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> stopAndReset() => clearAllData();

  Future<void> clearAllData() async {
    await BaseStorageService.instance.prefs.clear();
    await Hive.deleteFromDisk();
    notifyListeners();
  }
}
