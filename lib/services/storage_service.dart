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

  Future<void> syncUserWithBackend() async {
    final token = ApiService.token;
    if (token == null) return;

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

  Future<void> saveLog(PeriodLog log) => periodLog.saveLog(log);
  Future<void> deleteLog(int index) => periodLog.deleteLog(index);
  List<PeriodLog> getLogs() => periodLog.getLogs();

  Future<String> exportLogsToJson() async {
    _setLoading(true);
    try {
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
      return list.toString(); // Simplified for now
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
