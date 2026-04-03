import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'api_service.dart';

class GoogleAuthService {
  // 1. Initialize GoogleSignIn with your WEB CLIENT ID
  // Make sure this is the Web Client ID you generated in the previous step,
  // NOT the Android Client ID.
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const List<String> _scopes = ['email', 'profile'];

  static bool _isInitialized = false;

  /// Initializes the Google Sign-In instance.
  /// This should be called early (e.g., in main.dart) to ensure GSI is ready on Web.
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // On Web, we MUST call initialize to complete the plugin's internal _initialized future.
        await _googleSignIn.initialize();
      } else {
        // On Mobile, we need to initialize with the serverClientId
        await _googleSignIn.initialize(
          serverClientId:
              '536054439823-f54c3aanjfp2ilrfr8nkef4e243lcnrj.apps.googleusercontent.com',
        );
      }
      _isInitialized = true;
      debugPrint('GoogleAuthService: Initialization successful.');
    } catch (e) {
      debugPrint('GoogleAuthService: Initialization failed: $e');
    }
  }

  // 2. The function to trigger the backdrop and get the token
  static Future<String?> signInAndGetToken() async {
    try {
      if (!_isInitialized) {
        await init();
      }

      if (kIsWeb) {
        debugPrint(
          'GoogleAuthService: signInAndGetToken() is not supported on Web. '
          'The GSI button (GoogleAuthButton) handles sign-in automatically on this platform.',
        );
        return null;
      }

      // This line is what actually opens the Google Account backdrop
      final googleUser = await _googleSignIn.authenticate(scopeHint: _scopes);

      // 3. Request the authentication details from Google
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. Extract the id_token! This is what your FastAPI backend needs.
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        debugPrint('Successfully retrieved id_token!');
        return idToken;
      } else {
        debugPrint('Error: id_token is null.');
        return null;
      }
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      return null;
    }
  }

  // A function to send the token to your backend
  static Future<Map<String, dynamic>?> authenticateWithBackend(
    String token,
  ) async {
    try {
      final response = await ApiService.post('/auth/google', {'token': token});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Backend Auth Success: $data');

        // Save the token if provided by backend (usually 'token' or 'access_token')
        final String? backendToken = data['token'] ?? data['access_token'];
        if (backendToken != null) {
          await ApiService.saveToken(backendToken);
        }

        return data as Map<String, dynamic>;
      } else {
        debugPrint(
          'Backend Auth Failed: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (error) {
      debugPrint('Backend Auth Exception: $error');
      return null;
    }
  }

  // A helper function to sign out (clears the selected account)
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
