import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    // Initialization handled in main.dart

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );

    // Request permissions for Android 13+
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> schedulePeriodReminder(DateTime nextPeriodDate) async {
    if (kIsWeb) return;
    // Cancel any existing reminders to avoid duplicates
    await _notifications.cancel(id: 0);

    // Schedule 1 day before at 9 AM
    final reminderDate = nextPeriodDate.subtract(const Duration(days: 1));
    final scheduledTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
      0, // 9:00 AM
    );

    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id: 0,
      title: 'Period Reminder ✨',
      body:
          'Your period is predicted to start tomorrow. Don\'t forget to stay hydrated!',
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'period_cycle_reminders',
          'Period Reminders',
          channelDescription: 'Notifications for upcoming period predictions',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleDailyCheckinReminder() async {
    if (kIsWeb) return;
    // Daily recurring at 8 AM
    await _notifications.zonedSchedule(
      id: 1,
      title: 'Good Morning! 🌸',
      body: 'Time for your daily check-in. How are you feeling today?',
      scheduledDate: _nextInstanceOfTime(8, 0),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_checkin',
          'Daily Check-ins',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleOvulationReminder(DateTime ovulationDate) async {
    if (kIsWeb) return;
    final scheduledTime = DateTime(
      ovulationDate.year,
      ovulationDate.month,
      ovulationDate.day,
      10,
      0,
    );
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id: 2,
      title: 'Fertile Window 🌸',
      body: 'You are entering your peak fertile window. Take care of yourself!',
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'fertility_reminders',
          'Fertility Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleWellnessReminder(
    int id,
    String title,
    String category,
    DateTime date,
  ) async {
    if (kIsWeb) return;
    if (date.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id: 100 + id, // Offset for wellness goals
      title: '$category Goal! 🧘',
      body: 'Time for your wellness activity: $title',
      scheduledDate: tz.TZDateTime.from(date, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'wellness_goals',
          'Wellness Goals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notifications.cancel(id: id);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }
}
