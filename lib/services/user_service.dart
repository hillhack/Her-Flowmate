import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  static Future<User?> getUserProfile() async {
    try {
      final response = await ApiService.get('/user/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUserProfile(User user) async {
    try {
      final response = await ApiService.put('/user/profile', user.toJson());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
