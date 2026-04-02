import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/user.dart';
import 'base_storage_service.dart';

class OnboardingService extends ChangeNotifier {
  static const String userBoxName = 'user_box';
  static const String userKey = 'current_user';

  final BaseStorageService _base = BaseStorageService.instance;

  Box<User> get _userBox => Hive.box<User>(userBoxName);

  Future<void> init() async {
    await Hive.openBox<User>(userBoxName);
  }

  User? get user => _userBox.get(userKey);

  bool get hasCompletedLogin =>
      _base.prefs.getBool('hasCompletedLogin') ?? false;
  bool get hasCompletedOnboarding =>
      _base.prefs.getBool('hasCompletedOnboarding') ?? false;
  bool get isLoggedIn => _base.prefs.getBool('isLoggedIn') ?? false;

  String get userName =>
      user?.name ?? _base.prefs.getString('userName') ?? 'Guest';
  String get userGoal =>
      user?.goal ?? _base.prefs.getString('userGoal') ?? 'track_cycle';
  int? get userAge =>
      user?.age ??
      (_base.prefs.containsKey('userAge')
          ? _base.prefs.getInt('userAge')
          : null);
  String? get userImagePath =>
      user?.imagePath ?? _base.prefs.getString('userImagePath');
  bool get isDarkMode => _base.prefs.getBool('isDarkMode') ?? false;

  Future<void> saveUser(User newUser) async {
    await _userBox.put(userKey, newUser);
    notifyListeners();
  }

  Future<void> completeLogin(bool loggedIn, [String name = '']) async {
    await _base.prefs.setBool('hasCompletedLogin', true);
    await _base.prefs.setBool('isLoggedIn', loggedIn);

    if (loggedIn && name.isNotEmpty) {
      final currentUser =
          user ?? User(name: name, age: 25, goal: 'track_cycle');
      await saveUser(currentUser.copyWith(name: name));
    }
    notifyListeners();
  }

  Future<void> completeOnboarding(String goal, String name, {int? age}) async {
    await _base.prefs.setBool('hasCompletedOnboarding', true);

    final currentUser = User(
      name: name.isNotEmpty ? name : 'Guest',
      age: age ?? 25,
      goal: goal,
    );
    await saveUser(currentUser);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    if (user != null) {
      await saveUser(user!.copyWith(name: name));
    } else {
      await _base.prefs.setString('userName', name);
    }
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
    await _userBox.delete(userKey);
    notifyListeners();
  }
}
