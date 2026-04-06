import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/appointment.dart';
import 'notification_service.dart';
import 'base_storage_service.dart';
import '../utils/constants.dart';


class AppointmentService extends ChangeNotifier {
  static const String appointmentBoxName = 'appointments';
  // ignore: unused_field
  final BaseStorageService _base = BaseStorageService.instance;

  Box<Appointment> get _appointmentBox =>
      Hive.box<Appointment>(appointmentBoxName);

  Future<void> init() async {
    await Hive.openBox<Appointment>(appointmentBoxName);
  }

  Future<void> saveAppointment(Appointment appt) async {
    final key = await _appointmentBox.add(appt);
    await NotificationService().scheduleWellnessReminder(
      key,
      appt.title,
      appt.category.label,
      appt.date,
    );
    notifyListeners();
  }

  Future<void> deleteAppointment(Appointment appt) async {
    final key = appt.key as int?;
    if (key != null) {
      await NotificationService().cancelNotification(100 + key);
    }
    await appt.delete();
    notifyListeners();
  }

  List<Appointment> getAllAppointments() {
    final appts =
        _appointmentBox.values.toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return appts;
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    final limit = now.add(
      const Duration(days: AppConstants.upcomingAppointmentDays),
    );
    final appts =
        _appointmentBox.values
            .where((a) => a.date.isAfter(now) && a.date.isBefore(limit))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return appts;
  }

  // ── Backend Sync ──────────────────────────────────────────────────────────

  Future<bool> uploadAppointments() async {
    // /appointments endpoint not available on backend — local-only
    return true;
  }

  Future<void> fetchAppointments() async {
    // /appointments endpoint not available on backend — local-only
  }
}
