import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'base_storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://her-flowmate-backend.onrender.com';
  static const String tokenKey = 'auth_token';

  static String? get token =>
      BaseStorageService.instance.prefs.getString(tokenKey);

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<void> saveToken(String? value) async {
    if (value == null) {
      await BaseStorageService.instance.prefs.remove(tokenKey);
    } else {
      await BaseStorageService.instance.prefs.setString(tokenKey, value);
    }
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('API POST: $url');
    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(minutes: 3));
      _logResponse(response);
      return response;
    } catch (e) {
      debugPrint('API POST Exception: $e');
      rethrow;
    }
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('API GET: $url');
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(minutes: 3));
      _logResponse(response);
      return response;
    } catch (e) {
      debugPrint('API GET Exception: $e');
      rethrow;
    }
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('API PUT: $url');
    try {
      final response = await http
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(minutes: 3));
      _logResponse(response);
      return response;
    } catch (e) {
      debugPrint('API PUT Exception: $e');
      rethrow;
    }
  }

  static void _logResponse(http.Response response) {
    debugPrint('API Response [${response.statusCode}]: ${response.body}');
  }
}
