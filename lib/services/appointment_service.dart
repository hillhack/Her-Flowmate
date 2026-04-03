import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/appointment.dart';
import 'notification_service.dart';
import 'base_storage_service.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'dart:convert';

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
    try {
      final appts = getAllAppointments();
      final response = await ApiService.post('/appointments/sync', {
        'appointments': appts.map((a) => a.toJson()).toList(),
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error uploading appointments: $e');
      return false;
    }
  }

  Future<void> fetchAppointments() async {
    try {
      final response = await ApiService.get('/appointments');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final remoteAppts =
            data.map((json) => Appointment.fromJson(json)).toList();

        await _appointmentBox.clear();
        await _appointmentBox.addAll(remoteAppts);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    }
  }
}
