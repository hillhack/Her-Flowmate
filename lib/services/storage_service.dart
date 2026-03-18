import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_log.dart';

class StorageService extends ChangeNotifier {
  static const String boxName = 'period_logs';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    Hive.registerAdapter(PeriodLogAdapter());
    await Hive.openBox<PeriodLog>(boxName);
  }

  bool get hasCompletedLogin => _prefs.getBool('hasCompletedLogin') ?? false;
  bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;
  String get userName => _prefs.getString('userName') ?? 'Guest';

  Future<void> completeLogin(bool loggedIn, [String name = '']) async {
    await _prefs.setBool('hasCompletedLogin', true);
    await _prefs.setBool('isLoggedIn', loggedIn);
    if (loggedIn && name.isNotEmpty) {
      await _prefs.setString('userName', name);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs.setBool('hasCompletedLogin', false);
    await _prefs.setBool('isLoggedIn', false);
    await _prefs.remove('userName');
    await clearLogs(); // optionally clear data on logout
    notifyListeners();
  }

  Box<PeriodLog> get _box => Hive.box<PeriodLog>(boxName);

  Future<void> saveLog(PeriodLog log) async {
    await _box.add(log);
    notifyListeners();
  }

  Future<void> deleteLog(int index) async {
    await _box.deleteAt(index);
    notifyListeners();
  }

  Future<void> clearLogs() async {
    await _box.clear();
    notifyListeners();
  }

  List<PeriodLog> getLogs() {
    final logs = _box.values.toList();
    logs.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
    return logs;
  }
}
