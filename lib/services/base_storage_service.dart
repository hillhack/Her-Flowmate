import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/period_log.dart';
import '../models/daily_log.dart';
import '../models/appointment.dart';

class BaseStorageService extends ChangeNotifier {
  static final BaseStorageService _instance = BaseStorageService._internal();
  static BaseStorageService get instance => _instance;
  BaseStorageService._internal();

  late SharedPreferences prefs;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PeriodLogAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DailyLogAdapter());
    if (!Hive.isAdapterRegistered(3))
      Hive.registerAdapter(AppointmentAdapter());
    if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(UserAdapter());

    _isInitialized = true;
    notifyListeners();
  }
}
