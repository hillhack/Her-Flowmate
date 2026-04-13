import 'dart:convert';
import '../services/api_service.dart';

class PartnerService {
  /// Generates a sync code from the backend.
  /// Returns a map with 'code' and 'expiry' (ISO string).
  static Future<Map<String, dynamic>?> generateSyncCode() async {
    final response = await ApiService.post('/partner/generate-code', {});
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// Connects the current user to a partner using a sync code.
  static Future<bool> connectToPartner(String code) async {
    final response = await ApiService.post('/partner/connect', {
      'code': code.replaceAll('-', ''), // Send clean code
    });
    
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Fetches the partner's current phase info.
  static Future<Map<String, dynamic>?> getPartnerStatus() async {
    final response = await ApiService.get('/partner/status');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
}
