import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  // 1. Initialize GoogleSignIn with your WEB CLIENT ID
  // Make sure this is the Web Client ID you generated in the previous step,
  // NOT the Android Client ID.
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // We specify scopes here as suggested by the teammate, although
  // with GSI the scopes are often handled via the configuration.
  static const List<String> _scopes = ['email', 'profile'];

  static bool _isInitialized = false;

  /// Initializes the Google Sign-In instance.
  /// This should be called early (e.g., in main.dart) to ensure GSI is ready on Web.
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        // On Web, we MUST call initialize to complete the plugin's internal _initialized future.
        // It uses the clientId from the meta tag in index.html by default.
        await _googleSignIn.initialize();
      } else {
        // On Mobile, we need to initialize with the serverClientId
        await _googleSignIn.initialize(
          serverClientId:
              '174435969771-igiff38hijf44gf6lfl6s1irl9vls11n.apps.googleusercontent.com',
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
      final response = await http.post(
        Uri.parse('https://her-flowmate-backend.onrender.com/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Backend Auth Success: $data');
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
