import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    // Initialize timezone data
    tz.initializeTimeZones();

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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }
}
