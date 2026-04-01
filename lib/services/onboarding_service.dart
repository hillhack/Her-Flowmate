import 'package:flutter/foundation.dart';
import 'base_storage_service.dart';

class OnboardingService extends ChangeNotifier {
  final BaseStorageService _base = BaseStorageService.instance;

  bool get hasCompletedLogin =>
      _base.prefs.getBool('hasCompletedLogin') ?? false;
  bool get hasCompletedOnboarding =>
      _base.prefs.getBool('hasCompletedOnboarding') ?? false;
  bool get isLoggedIn => _base.prefs.getBool('isLoggedIn') ?? false;
  String get userName => _base.prefs.getString('userName') ?? 'Guest';
  String get userGoal => _base.prefs.getString('userGoal') ?? 'track_cycle';
  int? get userAge =>
      _base.prefs.containsKey('userAge') ? _base.prefs.getInt('userAge') : null;
  String? get userImagePath => _base.prefs.getString('userImagePath');
  bool get isDarkMode => _base.prefs.getBool('isDarkMode') ?? false;

  Future<void> completeLogin(bool loggedIn, [String name = '']) async {
    await _base.prefs.setBool('hasCompletedLogin', true);
    await _base.prefs.setBool('isLoggedIn', loggedIn);
    if (loggedIn && name.isNotEmpty) {
      await _base.prefs.setString('userName', name);
    }
    notifyListeners();
  }

  Future<void> completeOnboarding(String goal, String name, {int? age}) async {
    await _base.prefs.setString('userGoal', goal);
    await _base.prefs.setBool('hasCompletedOnboarding', true);
    if (name.isNotEmpty) await _base.prefs.setString('userName', name);
    if (age != null) await _base.prefs.setInt('userAge', age);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    await _base.prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    final current = isDarkMode;
    await _base.prefs.setBool('isDarkMode', !current);
    notifyListeners();
  }

  Future<void> logout() async {
    await _base.prefs.setBool('hasCompletedLogin', false);
    await _base.prefs.setBool('hasCompletedOnboarding', false);
    await _base.prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }
}
